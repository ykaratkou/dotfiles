import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const MCP_STATUS_EVENT = "pi-mcp-adapter/status/v1";

type UsageLike = {
	input?: number;
	output?: number;
	cacheRead?: number;
	cacheWrite?: number;
	cost?: { total?: number };
};

type McpStatusSnapshot = {
	version: 1;
	servers: unknown[];
	connectedCount: number;
	disabledCount: number;
};

function formatTokens(count: number): string {
	if (count < 1_000) return `${count}`;
	if (count < 10_000) return `${(count / 1_000).toFixed(1)}k`;
	if (count < 1_000_000) return `${Math.round(count / 1_000)}k`;
	if (count < 10_000_000) return `${(count / 1_000_000).toFixed(1)}M`;
	return `${Math.round(count / 1_000_000)}M`;
}

function isMcpStatusSnapshot(value: unknown): value is McpStatusSnapshot {
	if (!value || typeof value !== "object") return false;
	const snapshot = value as Partial<McpStatusSnapshot>;
	return (
		snapshot.version === 1 &&
		Array.isArray(snapshot.servers) &&
		typeof snapshot.connectedCount === "number" &&
		typeof snapshot.disabledCount === "number"
	);
}

function getEntryUsage(entry: unknown): UsageLike | undefined {
	if (!entry || typeof entry !== "object") return undefined;
	const value = entry as {
		type?: string;
		message?: { role?: string; usage?: UsageLike };
		usage?: UsageLike;
	};

	if (value.type === "message" && (value.message?.role === "assistant" || value.message?.role === "toolResult")) {
		return value.message.usage;
	}
	if (value.type === "branch_summary" || value.type === "compaction") return value.usage;
	return undefined;
}

function fallbackMcpCount(status: string | undefined): string | undefined {
	if (!status) return undefined;
	const compact = status.match(/MCP\s+(\d+)\/(\d+)/i);
	if (compact) return `MCP ${compact[1]}/${compact[2]}`;

	const enabled = status.match(/(\d+)\s+servers?\s+enabled/i);
	if (!enabled) return "MCP …";
	const connected = status.match(/\((\d+)\s+connected\)/i);
	return `MCP ${connected?.[1] ?? "0"}/${enabled[1]}`;
}

export default function (pi: ExtensionAPI) {
	let mcpStatus: McpStatusSnapshot | undefined;
	let requestRender: (() => void) | undefined;

	const unsubscribe = pi.events.on(MCP_STATUS_EVENT, (data) => {
		if (!isMcpStatusSnapshot(data)) return;
		mcpStatus = data;
		requestRender?.();
	});

	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		ctx.ui.setFooter((tui, theme, footerData) => {
			requestRender = () => tui.requestRender();

			return {
				invalidate() {},
				dispose() {
					requestRender = undefined;
				},
				render(width: number): string[] {
					let input = 0;
					let output = 0;
					let cacheRead = 0;
					let cacheWrite = 0;
					let cost = 0;
					let latestCacheHitRate: number | undefined;

					for (const entry of ctx.sessionManager.getEntries()) {
						const usage = getEntryUsage(entry);
						if (!usage) continue;
						input += usage.input ?? 0;
						output += usage.output ?? 0;
						cacheRead += usage.cacheRead ?? 0;
						cacheWrite += usage.cacheWrite ?? 0;
						cost += usage.cost?.total ?? 0;

						const promptTokens = (usage.input ?? 0) + (usage.cacheRead ?? 0) + (usage.cacheWrite ?? 0);
						if (promptTokens > 0) latestCacheHitRate = ((usage.cacheRead ?? 0) / promptTokens) * 100;
					}

					const stats: string[] = [];
					if (input) stats.push(`↑${formatTokens(input)}`);
					if (output) stats.push(`↓${formatTokens(output)}`);
					if (cacheRead) stats.push(`R${formatTokens(cacheRead)}`);
					if (cacheWrite) stats.push(`W${formatTokens(cacheWrite)}`);
					if ((cacheRead || cacheWrite) && latestCacheHitRate !== undefined) {
						stats.push(`CH${latestCacheHitRate.toFixed(1)}%`);
					}
					if (cost) stats.push(`$${cost.toFixed(3)}`);

					const context = ctx.getContextUsage();
					const contextWindow = context?.contextWindow ?? ctx.model?.contextWindow ?? 0;
					const contextText = context?.percent === null || context?.percent === undefined
						? `?/${formatTokens(contextWindow)}`
						: `${context.percent.toFixed(1)}%/${formatTokens(contextWindow)}`;
					const styledContext = context?.percent !== null && context?.percent !== undefined && context.percent > 90
						? theme.fg("error", contextText)
						: context?.percent !== null && context?.percent !== undefined && context.percent > 70
							? theme.fg("warning", contextText)
							: theme.fg("dim", contextText);

					const dimStats = stats.length > 0 ? theme.fg("dim", stats.join(" ")) : "";
					const leftParts = [dimStats, styledContext].filter(Boolean);

					const enabledMcpCount = mcpStatus
						? Math.max(0, mcpStatus.servers.length - mcpStatus.disabledCount)
						: undefined;
					const mcpCount = enabledMcpCount !== undefined && enabledMcpCount > 0
						? `MCP ${mcpStatus!.connectedCount}/${enabledMcpCount}`
						: fallbackMcpCount(footerData.getExtensionStatuses().get("mcp"));
					if (mcpCount) leftParts.push(theme.fg("accent", mcpCount));

					const modelName = ctx.model?.id ?? "no-model";
					const modelText = ctx.model?.reasoning
						? `${modelName} • ${ctx.thinkingLevel ?? "off"}`
						: modelName;
					const right = theme.fg("dim", modelText);
					const rightWidth = visibleWidth(right);
					const separatorWidth = 2;

					if (rightWidth + separatorWidth >= width) {
						return [truncateToWidth(right, width, "")];
					}

					const maxLeftWidth = width - rightWidth - separatorWidth;
					const left = truncateToWidth(leftParts.join(" "), maxLeftWidth, theme.fg("dim", "…"));
					const padding = " ".repeat(Math.max(separatorWidth, width - visibleWidth(left) - rightWidth));
					return [left + padding + right];
				},
			};
		});
	});

	pi.on("session_shutdown", () => {
		requestRender = undefined;
		unsubscribe();
	});
}

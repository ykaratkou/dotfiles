import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";

const MCP_STATUS_EVENT = "pi-mcp-adapter/status/v1";
const QUOTA_REFRESH_INTERVAL_MS = 60_000;
const QUOTA_REQUEST_TIMEOUT_MS = 10_000;
const CODEX_USAGE_URL = "https://chatgpt.com/backend-api/wham/usage";
const OPENCODE_GO_USAGE_URL = "https://opencode.ai/zen/go/v1/usage";

const SUBSCRIPTION_PROVIDERS = new Set(["openai-codex", "opencode-go"] as const);

type SubscriptionProvider = "openai-codex" | "opencode-go";

type SubscriptionQuota = {
	fiveHourUsed?: number;
	weeklyUsed?: number;
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

function formatWindow(tokens: number): string {
	return formatTokens(tokens).replace(/\.0(?=[kM])/, "").replace("k", "K");
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

function fallbackMcpCount(status: string | undefined): string | undefined {
	if (!status) return undefined;
	const compact = status.match(/MCP\s+(\d+)\/(\d+)/i);
	if (compact) return `MCP ${compact[1]}/${compact[2]}`;

	const enabled = status.match(/(\d+)\s+servers?\s+enabled/i);
	if (!enabled) return "MCP …";
	const connected = status.match(/\((\d+)\s+connected\)/i);
	return `MCP ${connected?.[1] ?? "0"}/${enabled[1]}`;
}

function isSubscriptionProvider(provider: string | undefined): provider is SubscriptionProvider {
	return provider !== undefined && SUBSCRIPTION_PROVIDERS.has(provider as SubscriptionProvider);
}

function asRecord(value: unknown): Record<string, unknown> | undefined {
	return value !== null && typeof value === "object" ? value as Record<string, unknown> : undefined;
}

function nestedRecord(value: Record<string, unknown> | undefined, key: string): Record<string, unknown> | undefined {
	return asRecord(value?.[key]);
}

function finiteNumber(value: unknown): number | undefined {
	return typeof value === "number" && Number.isFinite(value) ? value : undefined;
}

function normalizeUsedPercent(value: unknown): number | undefined {
	const percent = finiteNumber(value);
	return percent === undefined ? undefined : Math.max(0, Math.min(100, percent));
}

function parseCodexQuota(value: unknown): SubscriptionQuota | undefined {
	const rateLimit = nestedRecord(asRecord(value), "rate_limit");
	const primary = nestedRecord(rateLimit, "primary_window");
	const secondary = nestedRecord(rateLimit, "secondary_window");
	const quota = {
		fiveHourUsed: normalizeUsedPercent(primary?.used_percent),
		weeklyUsed: normalizeUsedPercent(secondary?.used_percent),
	};
	return quota.fiveHourUsed === undefined && quota.weeklyUsed === undefined ? undefined : quota;
}

function parseOpenCodeGoQuota(value: unknown): SubscriptionQuota | undefined {
	const usage = nestedRecord(asRecord(value), "usage");
	const rolling = nestedRecord(usage, "rolling");
	const weekly = nestedRecord(usage, "weekly");
	const quota = {
		fiveHourUsed: normalizeUsedPercent(rolling?.percent),
		weeklyUsed: normalizeUsedPercent(weekly?.percent),
	};
	return quota.fiveHourUsed === undefined && quota.weeklyUsed === undefined ? undefined : quota;
}

function decodeJwtAccountId(token: string): string | undefined {
	try {
		const payload = token.split(".")[1];
		if (!payload) return undefined;
		const normalized = payload.replace(/-/g, "+").replace(/_/g, "/");
		const padded = normalized.padEnd(Math.ceil(normalized.length / 4) * 4, "=");
		const claims = asRecord(JSON.parse(atob(padded)));
		const auth = nestedRecord(claims, "https://api.openai.com/auth");
		return typeof auth?.chatgpt_account_id === "string" ? auth.chatgpt_account_id : undefined;
	} catch {
		return undefined;
	}
}

async function fetchJson(url: string, headers: Record<string, string>, sessionSignal: AbortSignal): Promise<unknown> {
	const controller = new AbortController();
	const abort = () => controller.abort();
	const timeout = setTimeout(abort, QUOTA_REQUEST_TIMEOUT_MS);
	if (sessionSignal.aborted) abort();
	else sessionSignal.addEventListener("abort", abort, { once: true });
	try {
		const response = await fetch(url, { headers, signal: controller.signal });
		if (!response.ok) throw new Error(`Usage request failed (${response.status})`);
		return await response.json();
	} finally {
		clearTimeout(timeout);
		sessionSignal.removeEventListener("abort", abort);
	}
}

async function loadSubscriptionQuota(
	provider: SubscriptionProvider,
	ctx: ExtensionContext,
	sessionSignal: AbortSignal,
): Promise<SubscriptionQuota> {
	const auth = await ctx.modelRegistry.getProviderAuth(provider);
	const apiKey = auth?.auth.apiKey;
	if (!apiKey) throw new Error(`No authentication configured for ${provider}`);

	if (provider === "openai-codex") {
		const headers: Record<string, string> = {
			Accept: "application/json",
			Authorization: `Bearer ${apiKey}`,
		};
		const accountId = decodeJwtAccountId(apiKey);
		if (accountId) headers["ChatGPT-Account-Id"] = accountId;
		const quota = parseCodexQuota(await fetchJson(CODEX_USAGE_URL, headers, sessionSignal));
		if (!quota) throw new Error("OpenAI Codex returned no quota windows");
		return quota;
	}

	const quota = parseOpenCodeGoQuota(await fetchJson(OPENCODE_GO_USAGE_URL, {
		Accept: "application/json",
		Authorization: `Bearer ${apiKey}`,
	}, sessionSignal));
	if (!quota) throw new Error("OpenCode Go returned no quota windows");
	return quota;
}

function formatPercent(used: number | undefined): string {
	if (used === undefined) return "?";
	return `${Number.isInteger(used) ? `${used}` : used.toFixed(1)}%`;
}

export default function (pi: ExtensionAPI) {
	let mcpStatus: McpStatusSnapshot | undefined;
	let requestRender: (() => void) | undefined;
	let sessionAbort: AbortController | undefined;
	let quotaRefreshTimer: ReturnType<typeof setInterval> | undefined;
	let quotaGeneration = 0;
	const quotaCache = new Map<SubscriptionProvider, SubscriptionQuota>();
	const quotaRequests = new Map<SubscriptionProvider, Promise<SubscriptionQuota>>();
	const quotaErrors = new Set<SubscriptionProvider>();

	const refreshQuota = async (ctx: ExtensionContext) => {
		const provider = ctx.model?.provider;
		const generation = ++quotaGeneration;
		if (!isSubscriptionProvider(provider) || !sessionAbort) {
			requestRender?.();
			return;
		}

		quotaErrors.delete(provider);
		requestRender?.();

		let request = quotaRequests.get(provider);
		if (!request) {
			request = loadSubscriptionQuota(provider, ctx, sessionAbort.signal);
			quotaRequests.set(provider, request);
			void request.finally(() => {
				if (quotaRequests.get(provider) === request) quotaRequests.delete(provider);
			}).catch(() => {});
		}

		try {
			const quota = await request;
			if (generation !== quotaGeneration || ctx.model?.provider !== provider) return;
			quotaCache.set(provider, quota);
			quotaErrors.delete(provider);
		} catch {
			if (generation !== quotaGeneration || ctx.model?.provider !== provider) return;
			quotaErrors.add(provider);
		} finally {
			if (generation === quotaGeneration) requestRender?.();
		}
	};

	const unsubscribe = pi.events.on(MCP_STATUS_EVENT, (data) => {
		if (!isMcpStatusSnapshot(data)) return;
		mcpStatus = data;
		requestRender?.();
	});

	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		sessionAbort = new AbortController();
		quotaRefreshTimer = setInterval(() => void refreshQuota(ctx), QUOTA_REFRESH_INTERVAL_MS);

		ctx.ui.setFooter((tui, theme, footerData) => {
			requestRender = () => tui.requestRender();

			return {
				invalidate() {},
				dispose() {
					requestRender = undefined;
				},
				render(width: number): string[] {
					const context = ctx.getContextUsage();
					const contextWindow = context?.contextWindow ?? ctx.model?.contextWindow ?? 0;
					const percent = context?.percent ?? undefined;

					const filled = percent === undefined ? 0 : Math.min(10, Math.max(0, Math.floor(percent / 10)));
					const bar = `[${"█".repeat(filled)}${"░".repeat(10 - filled)}]`;
					const contextText = `${bar} ${percent === undefined ? "?" : Math.round(percent)}%`;
					const contextColor = percent !== undefined && percent > 90
						? "error"
						: percent !== undefined && percent > 70 ? "warning" : "dim";

					const modelName = ctx.model?.id ?? "no-model";
					const effort = ctx.model?.reasoning ? `, ${ctx.thinkingLevel ?? "off"}` : "";
					const header = `${contextText} (${formatWindow(contextWindow)}, ${modelName}${effort})`;

					const parts = [theme.fg(contextColor, header)];

					const provider = ctx.model?.provider;
					if (isSubscriptionProvider(provider)) {
						const quota = quotaCache.get(provider);
						const hasError = quotaErrors.has(provider);
						const quotaText = `5h:${formatPercent(quota?.fiveHourUsed)} 7d:${formatPercent(quota?.weeklyUsed)}`;
						const maxUsed = Math.max(quota?.fiveHourUsed ?? 0, quota?.weeklyUsed ?? 0);
						const quotaColor = hasError ? "warning" : maxUsed >= 90 ? "error" : maxUsed >= 75 ? "warning" : "dim";
						parts.push(theme.fg(quotaColor, quotaText));
					}

					const enabledMcpCount = mcpStatus
						? Math.max(0, mcpStatus.servers.length - mcpStatus.disabledCount)
						: undefined;
					const mcpCount = enabledMcpCount !== undefined && enabledMcpCount > 0
						? `MCP ${mcpStatus!.connectedCount}/${enabledMcpCount}`
						: fallbackMcpCount(footerData.getExtensionStatuses().get("mcp"));
					if (mcpCount) parts.push(theme.fg("dim", mcpCount));

					return [truncateToWidth(parts.join(theme.fg("dim", " | ")), width, theme.fg("dim", "…"))];
				},
			};
		});

		void refreshQuota(ctx);
	});

	pi.on("model_select", (_event, ctx) => {
		void refreshQuota(ctx);
	});

	pi.on("agent_settled", (_event, ctx) => {
		void refreshQuota(ctx);
	});

	pi.on("session_shutdown", () => {
		quotaGeneration++;
		sessionAbort?.abort();
		sessionAbort = undefined;
		if (quotaRefreshTimer) clearInterval(quotaRefreshTimer);
		quotaRefreshTimer = undefined;
		requestRender = undefined;
		unsubscribe();
	});
}

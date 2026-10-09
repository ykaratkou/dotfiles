import { VERSION, keyHint, rawKeyHint, type ExtensionAPI, type Theme } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth, type Component } from "@earendil-works/pi-tui";

const LOGO = [
	"██████  ",
	"██  ██  ",
	"████  ██",
	"██    ██",
];

class WelcomeHeader implements Component {
	private expanded = false;

	constructor(
		private readonly theme: Theme,
		private readonly details: () => { model: string; thinking?: string; cwd: string },
	) {}

	setExpanded(expanded: boolean): void {
		this.expanded = expanded;
	}

	invalidate(): void {}

	render(width: number): string[] {
		if (width <= 0) return [];

		const logo = LOGO.map((line) => this.theme.bold(this.theme.fg("accent", line)));
		const { model, thinking, cwd } = this.details();
		const modelLine = thinking ? `${model} · ${thinking}` : model;
		const side = this.expanded
			? [
				this.theme.bold(`pi v${VERSION}`),
				this.theme.fg("muted", modelLine),
				this.theme.fg("dim", cwd),
				this.theme.fg("dim", "This one is yours."),
			]
			: [
				this.theme.bold(`pi v${VERSION}`),
				this.theme.fg("muted", "This one is yours."),
				"",
				this.theme.fg("dim", `${keyHint("app.tools.expand", "details")} · ${rawKeyHint("/", "commands")}`),
			];

		const gap = 4;
		const logoWidth = Math.max(...LOGO.map(visibleWidth));
		const sideBySide = width >= logoWidth + gap + 24;
		const lines = sideBySide
			? logo.map((line, index) => `${line}${" ".repeat(gap)}${side[index] ?? ""}`)
			: [...logo, "", ...side.filter((line) => visibleWidth(line) > 0)];

		if (this.expanded) {
			lines.push(
				"",
				[
					keyHint("tui.input.submit", "send"),
					keyHint("app.message.followUp", "follow up"),
					keyHint("app.interrupt", "interrupt"),
					keyHint("app.model.select", "model"),
				].join(this.theme.fg("dim", " · ")),
				rawKeyHint("!", "shell") + this.theme.fg("dim", " · ") + rawKeyHint("@", "attach file"),
				"",
				this.theme.fg("dim", "Loaded resources are listed below. The same details shortcut expands them."),
			);
		}

		return lines.map((line) => truncateToWidth(line, width, this.theme.fg("dim", "…")));
	}
}

export default function welcome(pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		ctx.ui.setHeader((_tui, theme) => new WelcomeHeader(theme, () => ({
			model: ctx.model?.id ?? "no model",
			thinking: ctx.model?.reasoning ? ctx.thinkingLevel : undefined,
			cwd: ctx.cwd,
		})));
	});
}

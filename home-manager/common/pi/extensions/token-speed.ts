// @ts-nocheck -- Pi provides its extension types and Node globals at runtime.
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type Stats = { output: number; elapsedMs: number };

function tokenSpeed(stats: Stats | undefined): number | undefined {
	if (!stats || !Number.isFinite(stats.output) || stats.output <= 0 ||
		!Number.isFinite(stats.elapsedMs) || stats.elapsedMs <= 0) return;
	const speed = stats.output / (stats.elapsedMs / 1000);
	return Number.isFinite(speed) ? speed : undefined;
}

export default function (pi: ExtensionAPI) {
	let started: number | undefined;
	let pending: Stats | undefined;

	pi.registerEntryRenderer<Stats>("token-speed", (entry, _options, theme) => {
		const speed = tokenSpeed(entry.data);
		if (speed === undefined) return;
		const label = `${speed.toFixed(1)} tok/s`;
		return {
			invalidate() {},
			render(width: number) {
				const text = truncateToWidth(label, width, "");
				return [theme.fg("dim", " ".repeat(Math.max(0, width - visibleWidth(text))) + text)];
			},
		};
	});

	pi.on("session_start", () => {
		started = undefined;
		pending = undefined;
	});

	pi.on("turn_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;
		started = performance.now();
		pending = undefined;
	});

	pi.on("message_end", (event, ctx) => {
		if (ctx.mode !== "tui" || event.message.role !== "assistant" || started === undefined) return;
		pending = { output: event.message.usage.output, elapsedMs: performance.now() - started };
		started = undefined;
	});

	pi.on("turn_end", (_event, ctx) => {
		// The assistant and its tool results are persisted before this boundary.
		if (ctx.mode === "tui" && tokenSpeed(pending) !== undefined) pi.appendEntry("token-speed", pending);
		pending = undefined;
	});
}

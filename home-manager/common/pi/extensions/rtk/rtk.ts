// @ts-nocheck -- Pi provides its extension types and Node globals at runtime.

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";

const REWRITE_TIMEOUT_MS = 2_000;

async function rewriteCommand(
	pi: ExtensionAPI,
	command: string,
	signal?: AbortSignal,
): Promise<string | null> {
	const result = await pi.exec("rtk", ["rewrite", command], {
		timeout: REWRITE_TIMEOUT_MS,
		signal,
	});
	// A missing or pre-0.23 rtk fails here, so the command passes through unchanged.
	if (result.killed || (result.code !== 0 && result.code !== 3)) return null;
	return result.stdout.trim() || null;
}

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		try {
			if (!isToolCallEventType("bash", event)) return;

			const command = event.input.command;
			if (
				typeof command !== "string" ||
				command.trim() === "" ||
				/\bfind(?:\s|$)/.test(command) ||
				command.startsWith("rtk ") ||
				process.env.RTK_DISABLED === "1"
			) {
				return;
			}

			const rewritten = await rewriteCommand(pi, command, ctx.signal);
			if (rewritten && rewritten !== command) event.input.command = rewritten;
		} catch (error) {
			console.error(
				"[rtk] unexpected error in tool_call handler; passing through command",
				error,
			);
		}
	});
}

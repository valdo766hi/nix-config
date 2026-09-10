// RTK OpenCode plugin — rewrites shell tool commands to use rtk for token savings.
// Requires: rtk >= 0.23.0 in PATH.
//
// Targets the OpenCode 2 plugin API (V1 cannot load this file).
//
// This is a thin delegating plugin: all rewrite logic lives in `rtk rewrite`,
// which is the single source of truth (src/discover/registry.rs).
// To add or change rewrite rules, edit the Rust registry — not this file.

import { execFile } from "node:child_process"

const run = (args: string[]) =>
  new Promise<string>((resolve) => {
    execFile("rtk", args, { encoding: "utf8", timeout: 10_000 }, (_error, stdout) => {
      resolve((stdout ?? "").trim())
    })
  })

export default {
  id: "rtk",
  async setup(ctx) {
    if (!(await run(["--version"]))) {
      console.warn("[rtk] rtk binary not found in PATH — plugin disabled")
      return
    }

    await ctx.tool.hook("execute.before", async (event) => {
      const tool = String(event.tool ?? "").toLowerCase()
      if (tool !== "bash" && tool !== "shell") return

      const args = event.input
      if (!args || typeof args !== "object") return

      const command = (args as Record<string, unknown>).command
      if (typeof command !== "string" || !command) return

      const rewritten = await run(["rewrite", command])
      if (rewritten && rewritten !== command) {
        event.input = {...(args as Record<string, unknown>), command: rewritten}
      }
    })
  },
}

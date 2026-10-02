// OpenCode 2 API only; rewrite rules belong to `rtk rewrite` (RTK >= 0.23.0).

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

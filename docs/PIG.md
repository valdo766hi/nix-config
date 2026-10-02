# PiG alongside Pi

[Documentation index](./README.md) · [Maintenance](MAINTENANCE.md)

**PiG is currently chat-only, not a replacement for Pi's coding workflow.**

`pi` remains upstream Pi. `pig` is PiG 0.2.0 (Pi 0.87.1 parity target), installed
from SHA-256-pinned archives by
[`pkgs/pig/default.nix`](../pkgs/pig/default.nix) for `x86_64-linux` and
`aarch64-darwin`. Its
[Home Manager module](../home-manager/common/pig/default.nix) supplies a filtered
launcher and separate `~/.pig/agent` settings. Nothing links or copies `~/.pi`
into `~/.pig`.

## Isolation and safety

The shared `agent-instructions.md` and Catppuccin source are reused for PiG's
`APPEND_SYSTEM.md` and theme. Provider/model, thinking, fullscreen, and thinking
visibility settings match Pi. PiG requires its **own** OAuth login
(`pig login openai-codex`); do not copy Pi's `auth.json`.

Sessions, history, packages, caches, and trust decisions remain independent.
The [launcher](../pkgs/configured-apps/default.nix) filters its environment,
sets `PIG_HOME=$HOME/.pig` regardless of `XDG_CONFIG_HOME`, and opts out of
install telemetry.

**Safety stop:** PiG 0.2.0 failed permission-system registration in the earlier tests below; current Pi pins have not been verified with PiG. Until its ask/deny behavior can be tested, `defaultTools = []` and no Pi extensions are selected. `pig` can chat after independent login but cannot safely replace Pi for coding yet. Manually passing `--tools` bypasses this safeguard; PiG is not a sandbox. Project/user skills may still be discovered through PiG's normal rules. Do not enable permission, YOLO, MCP or other extensions merely because they install or register.

## Compatibility evidence (historical)

The table records earlier tests with PiG's official 0.2.0 darwin-arm64 binary
and an isolated `PIG_HOME` under `/tmp`. Listed versions are **tested versions,
not the current Pi pins**. Later Pi/package updates have not been retested here;
do not silently apply these results to them. Current pins live in
[`home-manager/common/pi/default.nix`](../home-manager/common/pi/default.nix).

`pig install --validate-only --json` tests registration, **not** behavior.
No authenticated provider request, real-session interactive TUI, MCP, or
permission-policy integration test was run; untested behavior is not counted
as compatible.

| Tested component | Pi (then) | PiG enabled | Status | Evidence / limitation |
|---|---|---|---|---|
| Core / TUI | yes | installed | PARTIALLY_COMPATIBLE | Binary reports `0.2.0+0.87.1`; RPC started with zero model tools; fullscreen started in a pseudo-terminal with a test model, not visually verified. |
| OpenAI Codex OAuth | yes | supported | NOT_TESTED | `pig login openai-codex` is documented; independent login not performed. Never switched to API-billed OpenAI. |
| gpt-6-luna | yes | configured | NOT_TESTED | PiG's pinned model catalog includes `openai-codex/gpt-6-luna`; no authenticated request. |
| Catppuccin theme | yes | discovered | PARTIALLY_COMPATIBLE | PiG `status --json` recognizes the shared theme; TUI rendering not tested. |
| APPEND_SYSTEM | yes | configured | NOT_TESTED | Same file installed at PiG's documented path; model-visible content not tested. |
| pi-lens 4.3.0 | yes | no | INCOMPATIBLE | Validator rejects its bundled extension: no Pi-compatible default export. LSP behavior untested. |
| pi-mcp-adapter 3.0.0 | yes | no | NOT_TESTED | Registration passes; MCP connection/tool invocation not tested. Existing shared MCP config remains Pi-owned. |
| server compaction (8a3de2f) | yes | no | INCOMPATIBLE | Extension fails to import `calculateCost` from PiG's `@earendil-works/pi-ai` bridge. Native PiG `/compact` exists, not exercised against a real session. |
| Plannotator 0.27.21 | yes | no | INCOMPATIBLE | Validator cannot load the package's directory extension entry. UI not tested. |
| subagents 0.72.1 | yes | no | INCOMPATIBLE | Registration fails: missing `@earendil-works/pi-agent-core` peer. No invocation tested. |
| permission system 32.1.0 | yes | no | INCOMPATIBLE | Registration fails on extensionless TypeScript import (`access-intent/bash/parser`). No ask/deny behavior tested. |
| pi-fast 0.1.2 | yes | no | NOT_TESTED | Registration passes; provider payload modification not tested. |
| pi-footer 0.1.0 | yes | no | NOT_TESTED | Registration passes; TUI footer rendering not tested. |
| pi-yolo 0.1.6 | yes | no | NOT_TESTED | Registration passes, but cannot safely enable without working permission policy; no reload test. |
| lazy-skill 0.3.0 | yes | no | INCOMPATIBLE | Registration fails: PiG bridge lacks `parseFrontmatter` export. Discovery/routing not tested. |
| pi-usage 0.2.0 | yes | no | NOT_TESTED | Registration passes; provider usage command not exercised. |
| pi-fff 0.11.0 | yes | no | NOT_TESTED | Registration passes; file/content search not exercised. |
| RTK 0.50.0 | yes | no | INCOMPATIBLE | PiG rejects the local extension's `isToolCallEventType` import. The existing shared `rtk` binary rewrites `git status` correctly; no PiG tool hook tested. |
| Context7 MCP | yes | no | NOT_TESTED | Adapter registers, but no real server call through PiG; credentials stay in environment. |
| Exa MCP | yes | no | NOT_TESTED | Same limitation as Context7. |

The PiG Node bridge executes extensions in subprocesses rather than Pi's in-process runtime. Missing exports, module resolution, UI, and mutable-event semantics must be resolved and tested before enabling extensions. Native PiG compaction exists, but the Pi extension's provider-specific behavior is not reproduced. Pi's custom subagent overrides, lazy skill routing, MCP `compact` footer / script mode, Plannotator phases, pi-fff mode, and YOLO permission rules are not configured in PiG while their integrations remain unverified.

## Try and remove

Check the packaged binary without activation:

```sh
nix run .#pig -- --version
```

After [manual activation](MAINTENANCE.md#apply-manually-on-the-target-host),
log in separately and start a chat:

```sh
pig login openai-codex
pig
```

Do not enable coding tools until the permission integration has passed behavior
tests with the selected package versions.

To remove PiG, delete the import of `./pig/default.nix` from `home-manager/common/default.nix` and activate your reviewed configuration again. Leave `~/.pig` intact unless you separately decide to remove its mutable state. Pi and its `~/.pi` tree are unaffected.

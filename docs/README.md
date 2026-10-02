# Documentation

[Repository overview](../README.md) · [Maintenance](./MAINTENANCE.md)

## Start here

- **Changing the config?** Read [maintenance](./MAINTENANCE.md) for module
  placement, validation, updates, and manual activation.
- **Learning the editor?** Start with [Neovim's everyday workflow](NVF_KEYBINDINGS.md#start-here).
- **Updating OmniWM?** Review [compatibility and restart instructions](OMNIWM_UPDATES.md).
- **Updating Pi packages?** Use the [audit-first maintenance scripts](../home-manager/common/pi/scripts/README.md).

## Desktop and editor

| Guide | Scope |
| --- | --- |
| [Neovim](NVF_KEYBINDINGS.md) | Shared nvf workflow, navigation, Git, completion, and tests |
| [Niri](NIRI_KEYBINDINGS.md) | Active Linux bindings, DMS, and optional Noctalia |
| [OmniWM keybindings](OMNIWM_KEYBINDINGS.md) | Active macOS manager and managed shortcuts |
| [OmniWM updates](OMNIWM_UPDATES.md) | Pinned cask, schema changes, restart, and recovery |
| [AeroSpace](AEROSPACE_KEYBINDINGS.md) | Inactive alternative; not imported by the current Mac host |

## Agents and tools

| Guide | Scope |
| --- | --- |
| [Pi YOLO](PI_YOLO.md) | Session-local approval overlay and permission limitations |
| [Pi maintenance scripts](../home-manager/common/pi/scripts/README.md) | Package audits, updates, temporary override, and skill scans |
| [PiG](PIG.md) | Separate chat-only setup and historical compatibility evidence |
| [RTK + OpenCode](RTK_OPENCODE.md) | OpenCode 2 plugin, package pinning, and troubleshooting |

## Keep these guides accurate

Configuration files are the source of truth. Each tool guide points to its
owning module; edit persistent settings there rather than in generated files.

When changing a binding, package API, or update procedure, update the matching
guide in the same change. Keep exact package versions in their source modules,
except when recording release-specific migration notes or historical tests.
Distinguish configured behavior from behavior that has actually been tested.

Command blocks are examples, not automatic steps. Privileged activation and
rollback instructions are for the operator on the target host; agents follow
[AGENTS.md](../AGENTS.md) and use non-privileged validation only.

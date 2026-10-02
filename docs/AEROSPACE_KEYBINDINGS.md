# AeroSpace keybindings (inactive alternative)

[Documentation index](./README.md) · [Active OmniWM bindings](OMNIWM_KEYBINDINGS.md)

The current Mac host imports OmniWM, **not** AeroSpace. This reference describes
[`modules/darwin/aerospace/default.nix`](../modules/darwin/aerospace/default.nix)
if you deliberately choose that alternative. Do not enable both window managers
at once. `Alt` means the macOS Option key.

## Focus Movement

| Keybind | Action |
|---------|--------|
| `Alt+H` | Focus window left |
| `Alt+J` | Focus window down |
| `Alt+K` | Focus window up |
| `Alt+L` | Focus window right |

## Window Swapping

| Keybind | Action |
|---------|--------|
| `Alt+Shift+H` | Swap window left |
| `Alt+Shift+J` | Swap window down |
| `Alt+Shift+K` | Swap window up |
| `Alt+Shift+L` | Swap window right |

## Window Moving

| Keybind | Action |
|---------|--------|
| `Alt+Ctrl+H` | Move window left |
| `Alt+Ctrl+J` | Move window down |
| `Alt+Ctrl+K` | Move window up |
| `Alt+Ctrl+L` | Move window right |

## Window Resize

| Keybind | Action |
|---------|--------|
| `Alt+Shift+R` | Resize width +120 |
| `Alt+Shift+E` | Resize height +120 |

## Window Actions

| Keybind | Action |
|---------|--------|
| `Alt+Q` | Close window |
| `Alt+F` | Fullscreen |
| `Alt+Shift+F` | macOS native fullscreen |
| `Alt+Shift+Space` | Toggle layout (floating/tiling) |
| `Alt+E` | Toggle layout (horizontal/vertical) |
| `Alt+Shift+B` | Balance window sizes |

## Application Launch

| Keybind | Action |
|---------|--------|
| `Alt+Enter` | Open new Ghostty window |
| `Alt+B` | Open Zen browser |
| `Alt+D` | Open Spotlight |

## Workspace Navigation

| Keybind | Action |
|---------|--------|
| `Alt+1` through `Alt+9` | Focus workspace 1-9 |
| `Alt+Shift+1` through `Alt+Shift+9` | Move window to workspace 1-9 |
| `Alt+Tab` | Switch to previous workspace |
| `Alt+P` | Previous workspace (wrap around) |
| `Alt+N` | Next workspace (wrap around) |
| `Ctrl+Alt+N` | Next workspace |
| `Ctrl+Alt+X` | Previous workspace |

## Monitor Navigation

| Keybind | Action |
|---------|--------|
| `Ctrl+Alt+1` | Focus monitor 1 |
| `Ctrl+Alt+2` | Focus monitor 2 |
| `Ctrl+Alt+3` | Focus monitor 3 |
| `Ctrl+Shift+Alt+1` | Move window to monitor 1 |
| `Ctrl+Shift+Alt+2` | Move window to monitor 2 |
| `Ctrl+Shift+Alt+3` | Move window to monitor 3 |

## Layout Helpers

| Keybind | Action |
|---------|--------|
| `Alt+Shift+T` | Toggle tiling/floating layout |
| `Alt+R` | Reset layout (tiles horizontal vertical) |

## Service Helpers

| Keybind | Action |
|---------|--------|
| `Ctrl+Shift+Alt+R` | Restart AeroSpace |
| `Ctrl+Shift+Alt+Q` | Stop AeroSpace |

## System

| Keybind | Action |
|---------|--------|
| `Alt+Shift+Esc` | Sleep displays (`pmset displaysleepnow`) |

## Floating Apps

These apps open as floating windows:
- System Settings
- System Preferences
- System Information
- Activity Monitor
- Calculator
- Finder
- Archive Utility
- App Store
- KeePassXC

---

The module sets `start-at-login = false`; nix-darwin's service owns startup
when the module is enabled. Display sleep is not an explicit lock command;
actual locking depends on macOS's password-after-sleep settings.

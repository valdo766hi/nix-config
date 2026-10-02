# Niri keybindings

[Documentation index](./README.md) · [Maintenance](MAINTENANCE.md)

Bindings come from
[`home-manager/nixos/niri/niri-config.kdl`](../home-manager/nixos/niri/niri-config.kdl),
installed at `~/.config/niri/config.kdl`. **Mod** is Super (Windows key) on TTY,
or Alt when Niri runs nested in a window. `Mod+Shift+/` opens the hotkey overlay.

DankMaterialShell (DMS) starts by default. Noctalia is installed but not
started automatically; its optional bindings need its user service running.
See the [DMS](../home-manager/nixos/dank-material-shell.nix) and
[Noctalia](../home-manager/nixos/noctalia-shell.nix) modules.

This doc is split into:

- Global Niri keybindings (compositor actions)
- DMS keybindings (commands that call `dms ipc ...`)
- Noctalia keybindings (commands that call `noctalia ipc ...`)

## Global: System & Help

| Keybind | Action |
| --------- | -------- |
| `Mod+Shift+/` | Show hotkey overlay |
| `Mod+Shift+E` | Quit Niri (with confirmation) |
| `Ctrl+Alt+Delete` | Quit Niri |
| `Mod+Escape` | Toggle keyboard shortcuts inhibit |
| `Mod+Shift+P` | Power off monitors |

## Global: Application Launcher & Tools

| Keybind | Action |
| --------- | -------- |
| `Mod+T` | Open terminal (alacritty) |
| `Mod+D` | Launch Vicinae |

## Global: Window Management

| Keybind | Action |
| --------- | -------- |
| `Mod+Q` | Close window |
| `Mod+W` | Toggle column tabbed display |
| `Mod+Shift+W` | Toggle window floating |
| `Mod+Shift+V` | Switch focus between floating and tiling |
| `Mod+O` | Toggle overview |

## Global: Window Focus (Arrow Keys)

| Keybind | Action |
| --------- | -------- |
| `Mod+Left` | Focus column left |
| `Mod+Right` | Focus column right |
| `Mod+Up` | Focus window up |
| `Mod+Down` | Focus window down |

## Global: Window Focus (Vim Keys)

| Keybind | Action |
| --------- | -------- |
| `Mod+H` | Focus column left |
| `Mod+L` | Focus column right |
| `Mod+K` | Focus window up |
| `Mod+J` | Focus window down |

## Global: Move Windows/Columns (Arrow Keys)

| Keybind | Action |
| --------- | -------- |
| `Mod+Ctrl+Left` | Move column left |
| `Mod+Ctrl+Right` | Move column right |
| `Mod+Ctrl+Up` | Move window up |
| `Mod+Ctrl+Down` | Move window down |

## Global: Move Windows/Columns (Vim Keys)

| Keybind | Action |
| --------- | -------- |
| `Mod+Ctrl+H` | Move column left |
| `Mod+Ctrl+L` | Move column right |
| `Mod+Ctrl+K` | Move window up |
| `Mod+Ctrl+J` | Move window down |

## Global: Column Navigation

| Keybind | Action |
| --------- | -------- |
| `Mod+Home` | Focus first column |
| `Mod+End` | Focus last column |
| `Mod+Ctrl+Home` | Move column to first |
| `Mod+Ctrl+End` | Move column to last |

## Global: Monitor Focus (Arrow Keys)

| Keybind | Action |
| --------- | -------- |
| `Mod+Shift+Left` | Focus monitor left |
| `Mod+Shift+Right` | Focus monitor right |
| `Mod+Shift+Up` | Focus monitor up |
| `Mod+Shift+Down` | Focus monitor down |

## Global: Monitor Focus (Vim Keys)

| Keybind | Action |
| --------- | -------- |
| `Mod+Shift+H` | Focus monitor left |
| `Mod+Shift+L` | Focus monitor right |
| `Mod+Shift+K` | Focus monitor up |
| `Mod+Shift+J` | Focus monitor down |

## Global: Move Column to Monitor (Arrow Keys)

| Keybind | Action |
| --------- | -------- |
| `Mod+Shift+Ctrl+Left` | Move column to monitor left |
| `Mod+Shift+Ctrl+Right` | Move column to monitor right |
| `Mod+Shift+Ctrl+Up` | Move column to monitor up |
| `Mod+Shift+Ctrl+Down` | Move column to monitor down |

## Global: Move Column to Monitor (Vim Keys)

| Keybind | Action |
| --------- | -------- |
| `Mod+Shift+Ctrl+H` | Move column to monitor left |
| `Mod+Shift+Ctrl+L` | Move column to monitor right |
| `Mod+Shift+Ctrl+K` | Move column to monitor up |
| `Mod+Shift+Ctrl+J` | Move column to monitor down |

## Global: Workspace Navigation

| Keybind | Action |
| --------- | -------- |
| `Mod+U` | Focus workspace down |
| `Mod+I` | Focus workspace up |
| `Mod+Page_Down` | Focus workspace down |
| `Mod+Page_Up` | Focus workspace up |
| `Mod+1` through `Mod+9` | Focus workspace 1-9 |

## Global: Move Column to Workspace

| Keybind | Action |
| --------- | -------- |
| `Mod+Ctrl+U` | Move column to workspace down |
| `Mod+Ctrl+I` | Move column to workspace up |
| `Mod+Ctrl+Page_Down` | Move column to workspace down |
| `Mod+Ctrl+Page_Up` | Move column to workspace up |
| `Mod+Ctrl+1` through `Mod+Ctrl+9` | Move column to workspace 1-9 |

## Global: Move Workspace

| Keybind | Action |
| --------- | -------- |
| `Mod+Shift+U` | Move workspace down |
| `Mod+Shift+I` | Move workspace up |
| `Mod+Shift+Page_Down` | Move workspace down |
| `Mod+Shift+Page_Up` | Move workspace up |

## Global: Column & Window Sizing

| Keybind | Action |
| --------- | -------- |
| `Mod+R` | Switch preset column width |
| `Mod+Shift+R` | Switch preset window height |
| `Mod+Ctrl+R` | Reset window height |
| `Mod+F` | Maximize column |
| `Mod+Shift+F` | Fullscreen window |
| `Mod+Ctrl+F` | Expand column to available width |
| `Mod+Minus` | Decrease column width by 10% |
| `Mod+Equal` | Increase column width by 10% |
| `Mod+Shift+Minus` | Decrease window height by 10% |
| `Mod+Shift+Equal` | Increase window height by 10% |

## Global: Column Arrangement

| Keybind | Action |
| --------- | -------- |
| `Mod+C` | Center column |
| `Mod+Ctrl+C` | Center all visible columns |
| `Mod+BracketLeft` | Consume or expel window left |
| `Mod+BracketRight` | Consume or expel window right |
| `Mod+Shift+Comma` | Consume window into column |
| `Mod+Period` | Expel window from column |

## Global: Lock Screen

| Keybind | Action |
| --------- | -------- |
| `Mod+Alt+L` | Lock screen (`dms ipc call lock lock`) |

## Global: Screenshots

| Keybind | Action |
| --------- | -------- |
| `Print` | Screenshot |
| `Ctrl+Print` | Screenshot screen |
| `Alt+Print` | Screenshot window |

## Global: Media & Volume

| Keybind | Action |
| --------- | -------- |
| `XF86AudioRaiseVolume` | Increase volume |
| `XF86AudioLowerVolume` | Decrease volume |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle mic mute |
| `XF86MonBrightnessUp` | Increase brightness |
| `XF86MonBrightnessDown` | Decrease brightness |

## Global: Mouse Wheel Bindings

### Workspace Navigation

- `Mod+WheelScrollDown/Up` - Focus workspace down/up
- `Mod+Ctrl+WheelScrollDown/Up` - Move column to workspace down/up

### Column Navigation

- `Mod+WheelScrollRight/Left` - Focus column right/left
- `Mod+Ctrl+WheelScrollRight/Left` - Move column right/left
- `Mod+Shift+WheelScrollDown/Up` - Focus column right/left
- `Mod+Ctrl+Shift+WheelScrollDown/Up` - Move column right/left

## DMS: Shell Keybindings

These keybindings only work when the DMS systemd user service is running.

| Keybind | Action |
| --------- | -------- |
| `Mod+Space` | Application launcher (`dms ipc call spotlight toggle`) |
| `Mod+M` | Task manager (`dms ipc call processlist toggle`) |
| `Mod+N` | Notification center (`dms ipc call notifications toggle`) |
| `Mod+Shift+N` | Notepad (`dms ipc call notepad toggle`) |
| `Mod+V` | Clipboard manager (`dms ipc call clipboard toggle`) |
| `Mod+Comma` | Settings (`dms ipc call settings toggle`) |
| `Mod+Alt+L` | Lock screen (`dms ipc call lock lock`) |

## Noctalia: Shell Keybindings (Optional)

These keybindings only work when the Noctalia systemd user service is running.
They are intentionally non-conflicting with the DMS defaults.

| Keybind | Action |
| --------- | -------- |
| `Mod+Ctrl+Space` | Launcher (`noctalia ipc launcher toggle`) |
| `Mod+Ctrl+S` | Control Center (`noctalia ipc controlCenter toggle`) |
| `Mod+Ctrl+Comma` | Settings (`noctalia ipc settings toggle`) |
| `Mod+Ctrl+N` | Notifications history (`noctalia ipc notifications toggleHistory`) |
| `Mod+Ctrl+M` | System monitor (`noctalia ipc systemMonitor toggle`) |
| `Mod+Ctrl+V` | Clipboard (`noctalia ipc launcher clipboard`) |
| `Mod+Ctrl+Alt+L` | Lock screen (`noctalia ipc lockScreen lock`) |

# OmniWM Default Keybindings

<!-- markdownlint-disable MD013 -->

This reference records the upstream OmniWM **0.6.9** hotkeys plus the managed
navigation overrides. Home Manager replaces the arrow-based focus and move
bindings with Vim-style keys so macOS can keep `Option + Arrow` for text editing.

## First Run

OmniWM requires:

- macOS 26 Tahoe or newer on Apple Silicon.
- **Displays have separate Spaces** enabled in **System Settings > Desktop &
  Dock > Mission Control**. Log out and back in if you change this setting.
- Accessibility access in **System Settings > Privacy & Security >
  Accessibility**.
- Input Monitoring only if you enable a **System Hyper Trigger** or a binding
  that distinguishes left- and right-side modifier keys.

The nix-darwin module installs OmniWM and opens it at login. On the first
launch, grant Accessibility access when prompted. Keep one macOS Space per
display and use OmniWM workspaces for normal navigation.

All shortcuts can be changed in **OmniWM Settings > Hotkeys**. Changes made
only in the GUI last until the next Home Manager activation; persistent changes
belong in `home-manager/darwin/omniwm/settings.toml`. `Hyper` defaults to the
literal `Control + Option + Shift + Command` chord, and its modifier set is
configurable. A System Hyper Trigger can map a single key or supported mouse
button to that chord; leave it set to `None` if it is not needed.

## Layout Legend

- `Shared` works in any active layout.
- `Niri` works only when the active workspace uses the Niri layout.
- `Dwindle` works only when the active workspace uses the Dwindle layout.
- `Unassigned` means OmniWM provides the action, but no default shortcut. It
  can be assigned in **Settings > Hotkeys**.

## Workspace

| Action | Default shortcut | Layout |
| --- | --- | --- |
| Switch to Workspace 1-9 | `Option + 1-9` | `Shared` |
| Move Window to Workspace 1-9 | `Option + Shift + 1-9` | `Shared` |
| Switch to Previous Workspace (Back and Forth) | `Control + Option + Tab` | `Shared` |
| Switch to Next Workspace | `Unassigned` | `Shared` |
| Switch to Previous Workspace (Sequential) | `Unassigned` | `Shared` |
| Move Window to Workspace Up | `Control + Option + Shift + Up Arrow` | `Shared` |
| Move Window to Workspace Down | `Control + Option + Shift + Down Arrow` | `Shared` |
| Move Column to Workspace 1-9 | `Unassigned` | `Niri` |
| Move Column to Workspace Up | `Control + Option + Shift + Page Up` | `Niri` |
| Move Column to Workspace Down | `Control + Option + Shift + Page Down` | `Niri` |

## Focus

| Action | Default shortcut | Layout |
| --- | --- | --- |
| Focus Left / Down / Up / Right | `Option + H / J / K / L` | `Shared` |
| Focus Down or Top / Up or Bottom | `Unassigned` | `Shared` |
| Focus Previous Window | `Option + Tab` | `Niri` |
| Traverse Backward | `Unassigned` | `Niri` |
| Traverse Forward | `Unassigned` | `Niri` |
| Focus First Column | `Option + Home` | `Niri` |
| Focus Last Column | `Option + End` | `Niri` |
| Focus Column 1-9 | `Control + Option + 1-9` | `Niri` |
| Toggle Command Palette | `Control + Option + Space` | `Shared` |
| Open Menu Anywhere | `Control + Option + M` | `Shared` |
| Toggle Workspace Bar | `Unassigned` | `Shared` |
| Toggle Hidden Icons Bar | `Unassigned` | `Shared` |
| Toggle Quake Terminal | `` Option + ` `` | `Shared` |
| Toggle Overview | `Option + Shift + O` | `Shared` |

## Move Window

| Action | Default shortcut | Layout |
| --- | --- | --- |
| Move Left / Down / Up / Right | `Option + Shift + H / J / K / L` | `Shared` |
| Reorder Window Up / Down | `Unassigned` | `Shared` |

## Monitor

| Action | Default shortcut | Layout |
| --- | --- | --- |
| Focus Next Monitor | `Control + Command + Tab` | `Shared` |
| Focus Previous Monitor | `Unassigned` | `Shared` |
| Focus Last Monitor | `` Control + Command + ` `` | `Shared` |
| Move Workspace to Left / Right / Up / Down Monitor | `Unassigned` | `Shared` |
| Move Window to Left / Right / Up / Down Monitor | `Unassigned` | `Shared` |

The workspace-to-monitor actions move the active workspace without changing
its saved home monitor. The window-to-monitor actions move the focused window
to the adjacent monitor's active workspace; **Follow Window to Monitor**
controls whether focus follows it.

## Layout

| Action | Default shortcut | Layout |
| --- | --- | --- |
| Toggle Fullscreen | `Option + Return` | `Shared` |
| Toggle Native Fullscreen | `Unassigned` | `Shared` |
| Balance Sizes | `Option + Shift + B` | `Shared` |
| Cycle Size Forward | `Option + .` | `Shared` |
| Cycle Size Backward | `Option + ,` | `Shared` |
| Move to Root | `Unassigned` | `Dwindle` |
| Toggle Split | `Unassigned` | `Dwindle` |
| Swap Split | `Unassigned` | `Dwindle` |
| Grow Horizontally / Vertically | `Unassigned` | `Dwindle` |
| Shrink Horizontally / Vertically | `Unassigned` | `Dwindle` |
| Grow / Shrink Focused Window | `Unassigned` | `Dwindle` |
| Preselect Left / Right / Up / Down | `Unassigned` | `Dwindle` |
| Clear Preselection | `Unassigned` | `Dwindle` |
| Raise All Floating Windows | `Option + Shift + R` | `Shared` |
| Toggle Focused Window Floating | `Unassigned` | `Shared` |
| Assign Focused Window to Scratchpad 1 | `Unassigned` | `Shared` |
| Toggle Scratchpad 1 | `Unassigned` | `Shared` |
| Assign Focused Window to Scratchpad 2-10 | `Unassigned` | `Shared` |
| Toggle Scratchpad 2-10 | `Unassigned` | `Shared` |
| Toggle Workspace Layout | `Control + Option + Shift + L` | `Shared` |

## Container and Column

| Action | Default shortcut | Layout |
| --- | --- | --- |
| Move Container Left / Right | `Control + Option + Shift + Left / Right Arrow` | `Shared` |
| Move Container Up / Down | `Unassigned` | `Dwindle` |
| Toggle Column Tabbed | `Option + T` | `Niri` |
| Toggle Container Full Primary Span | `Option + Shift + F` | `Niri` |

In Niri, the everyday focus and move bindings adapt to the column model.
Moving left or right can expel a focused window from a multi-window column or
consume a single-window column into its neighbor; moving up or down reorders
within a column.

## Dwindle Groups

Dwindle groups reuse the normal Focus and Move bindings. Only the active group
member occupies the tile; other members are hidden and appear in the clickable
tab rail.

| Goal | Default shortcut | Behavior |
| --- | --- | --- |
| Focus another tile | `Option + H / J / K / L` | Left/right are spatial; up/down are spatial for a singleton tile. |
| Select the next/previous tab | `Option + J / K` | J advances and K goes back within a group. At an edge, OmniWM tries a spatial tile, then monitor transition, then local wrapping. |
| Join a singleton into a tile or group | `Option + Shift + H / J / K / L` | Joins it with the touching tile in that direction. |
| Extract the active tab | `Option + Shift + H / J / K / L` | Extracts only the active tab onto the requested side. |
| Move the complete tile or group | `Control + Option + Shift + Left / Right Arrow` | Swaps the whole structure; the advanced up/down actions are unassigned. |
| Select an exact tab | Click its tab rail item | Reveals and focuses that member without reordering the group. |

Moving a tab directly between two existing groups is a two-step operation:
extract it, then move the resulting singleton toward the destination group.
Structural Dwindle moves are unavailable while Overview is open.

## Sources and Version Drift

- [OmniWM 0.6.9 release](https://github.com/BarutSRB/OmniWM/releases/tag/v0.6.9)
- [Upstream Keyboard Shortcuts tables](https://github.com/BarutSRB/OmniWM#keyboard-shortcuts)
- [Official Homebrew cask](https://github.com/Homebrew/homebrew-cask/blob/main/Casks/o/omniwm.rb)

This document is pinned to the defaults published for OmniWM 0.6.9. Upstream
may add actions or change defaults in later releases. Before updating OmniWM,
follow [OMNIWM_UPDATES.md](./OMNIWM_UPDATES.md), review the release notes and
relevant issues, and compare the upstream tables with this document.

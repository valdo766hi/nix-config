# Updating OmniWM

[Documentation index](./README.md) · [Keybindings](OMNIWM_KEYBINDINGS.md) · [Maintenance](MAINTENANCE.md)

OmniWM is installed by nix-darwin from Homebrew's official `omniwm`
cask. The cask definition is pinned via the `homebrew-cask` flake input, so
`flake.lock` pins the version used by this configuration.

Do not update OmniWM by running an unreviewed `brew upgrade`. Use the workflow
below so the tap revision, configuration evaluation, and documentation remain
reviewable.

## 0.8.0 Compatibility

The pinned cask moves from 0.7.6 to [0.8.0](https://github.com/OmniNull/OmniWM/releases/tag/v0.8.0);
Apple Silicon and macOS 26 Tahoe requirements are unchanged.

- Managed settings use schema 5. The six resize span actions now use
  `resizeContainerPrimarySpan`, `resizeWindowPrimarySpan`, and
  `resizeWindowSecondarySpan` with `.shrink` / `.grow`; bindings are unchanged.
  `[niri].resizeStepPercent = 10.0` preserves the old 10% steps instead of the
  new 5% default.
- OmniShell replaces the fixed workspace bar. The managed
  [`shell/shell.toml`](../home-manager/darwin/omniwm/shell/shell.toml) selects Default
  with only the workspaces widget, a compact 24 pt bar, background opacity 0.1,
  no reserved layout space, and no System Stats button. Profile settings override
  the same keys in `[workspaceBar]`. The renderer is new, so appearance may differ.
  Keeping `fullWidth = false` avoids the new full-width bar's menu-bar auto-hide.
- Home Manager copies both TOML files to writable locations on each activation.
  Persist bar changes in the managed shell file, not only in
  **Settings > Styles & Widgets**; GUI edits are replaced on activation.
- The new window switcher defaults to disabled, preserving `Option + Tab` for
  focus history. Quake terminal dragging now uses `Command + Option + drag`.
- IPC uses protocol 22 instead of 19. Use the bundled `omniwmctl`; IPC remains
  disabled in this configuration.
- Optional widgets may request additional permissions. Hidden Bar concealment
  still needs Full Disk Access; no apps are selected for concealment here.
- Keep updates Nix-managed; do not use the new in-app **Install and Relaunch**.
- The [Ghostty native-tab issue](https://github.com/OmniNull/OmniWM/issues/643)
  remains open. Test `Command + T` and tab switching after updating.

## Restart Without Updating

Updating `flake.lock` alone does not install or restart the app. After installing
the pinned version through your normal nix-darwin activation, choose **Quit
OmniWM** from its menu, then run (also works in Nushell):

```sh
/usr/bin/open -a OmniWM
```

The login agent only runs `open -a OmniWM`; kicking it while OmniWM is running
does not restart the existing process. No logout or reboot is needed for an
ordinary app restart. Runtime window marks are lost when OmniWM quits.

Check the installed app bundle version:

```sh
/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' /Applications/OmniWM.app/Contents/Info.plist
```

## 1. Review Upstream Before Every Update

Before changing `flake.lock`, always review:

1. [OmniWM releases and release notes](https://github.com/OmniNull/OmniWM/releases).
2. [Open OmniWM issues](https://github.com/OmniNull/OmniWM/issues?q=is%3Aissue%20is%3Aopen),
   plus issues relevant to the target release or affected features.
3. The updated
   [official cask](https://github.com/Homebrew/homebrew-cask/blob/main/Casks/o/omniwm.rb)
   for its version, checksum, macOS requirement, architecture requirement, and
   artifact layout.
4. Upstream setup notes and default hotkey tables for permission, settings,
   compatibility, or shortcut changes.

Pay particular attention to startup regressions, Accessibility or Input
Monitoring changes, layout/state migrations, renamed commands, and changed
default shortcuts. Delay the update if a relevant unresolved issue makes it
unsafe for this host.

## 2. Update Only the Pinned Cask Input

From the repository root:

```bash
nix flake update homebrew-cask
git diff -- flake.lock
```

Confirm the diff only repins `homebrew-cask` (this input backs every cask,
so avoid unrelated churn). Check the cask version at the newly pinned
revision against the release reviewed above.

If upstream default shortcuts changed, update
[`OMNIWM_KEYBINDINGS.md`](./OMNIWM_KEYBINDINGS.md) in the same change. Confirm
that the managed
[`settings.toml`](../home-manager/darwin/omniwm/settings.toml) still decodes with
the new release. Home Manager copies it to a writable settings file on every
activation rather than linking OmniWM directly to the Nix store. It also copies
`home-manager/darwin/omniwm/shell/shell.toml` to `~/.config/omniwm/shell/shell.toml`.

## 3. Validate Before Activation

Evaluate without a host build or system change:

```sh
nix flake check --all-systems --no-build
git diff --check
git diff -- flake.lock modules/darwin/omniwm home-manager/darwin/omniwm docs
```

Also inspect `git diff --cached` if changes are staged. Evaluation does not
exercise OmniWM's runtime settings decoder or Accessibility behavior; compare
the target release's schema and test the app after manual activation.
Do not activate when evaluation fails, the cask is unavailable, or the release
and issue review is incomplete.

## 4. Activate

On the target Mac, preserve the live settings and quit OmniWM first: Homebrew
replaces the app bundle underneath a running instance, and 0.7.6 cannot read the
managed schema-5 file. Then use the
[manual Darwin activation](MAINTENANCE.md#apply-manually-on-the-target-host)
and reopen OmniWM. Activation is an operator step, never coding-agent validation.

Log out and back in when testing login startup. A logout/login is also required
if **Displays have separate Spaces** was changed.

## 5. Post-Update Checks

Verify installation and command availability:

```bash
brew list --cask omniwm
command -v omniwmctl
pgrep -fl OmniWM
launchctl print "gui/$(id -u)/org.nixos.omniwm"
```

Then check manually:

- OmniWM opens at login and shows its menu bar item.
- Accessibility permission still applies to the updated signed application.
- Input Monitoring is still granted.
- **Displays have separate Spaces** remains enabled.
- The Home Manager-managed borders and gaps still apply without migration warnings.
- The compact workspace bar stays 24 pt, does not reserve layout space, and has no
  System Stats button; macOS menu-bar auto-hiding has not changed.
- Representative bindings work: `Option + H/J/K/L`, `Option + 1-9`,
  `Option + Shift + H/J/K/L`, `Option + Return`, and
  `Control + Option + Shift + L`.
- Niri/Dwindle layout behavior and multi-monitor focus still work as expected.

Recheck the upstream issue tracker after testing if any behavior changed or a
new regression appears.

## Rollback

Preserve local work and live settings before recovery. Review the known-good
`homebrew-cask` pin **and its matching managed OmniWM module and TOML files** in Git.
OmniWM 0.7.4 through 0.7.6 use schema 4 and cannot load schema 5. Restore the
schema-4 source and live settings before reopening 0.7.6. OmniWM creates a
`settings.toml.pre-v5` backup only when it migrates an older live file itself;
Home Manager installing an already-schema-5 file does not create that backup.

Evaluate the reviewed source before applying it manually. For system generation
recovery, see [manual rollback](MAINTENANCE.md#roll-back-manually).

Homebrew casks are stateful, so restoring a system generation or old tap pin
may not automatically downgrade an already installed OmniWM application. If
the application itself must be downgraded, first preserve any settings needed
for recovery, uninstall the current cask, and re-run the known-good
nix-darwin configuration so it installs from the restored tap. Confirm the old
cask artifact is still available before uninstalling.

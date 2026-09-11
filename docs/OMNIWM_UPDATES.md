# Updating OmniWM

OmniWM is installed by nix-darwin from Homebrew's official `omniwm`
cask. The cask definition is pinned via the `homebrew-cask` flake input, so
`flake.lock` pins the version used by this configuration.

Do not update OmniWM by running an unreviewed `brew upgrade`. Use the workflow
below so the tap revision, configuration evaluation, and documentation remain
reviewable.

## 1. Review Upstream Before Every Update

Before changing `flake.lock`, always review:

1. [OmniWM releases and release notes](https://github.com/BarutSRB/OmniWM/releases).
2. [Open OmniWM issues](https://github.com/BarutSRB/OmniWM/issues?q=is%3Aissue%20is%3Aopen),
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
nix flake lock --update-input homebrew-cask
git diff -- flake.lock
```

Confirm the diff only repins `homebrew-cask` (this input backs every cask,
so avoid unrelated churn). Check the cask version at the newly pinned
revision against the release reviewed above.

If upstream default shortcuts changed, update
[`OMNIWM_KEYBINDINGS.md`](./OMNIWM_KEYBINDINGS.md) in the same change. Confirm
that the minimal `home-manager/darwin/omniwm/settings.toml` still decodes with
the new release. Home Manager copies it to a writable settings file on every
activation rather than linking OmniWM directly to the Nix store.

## 3. Evaluate and Build Before Activation

Run the repository checks before changing the live system:

```bash
nix flake check --all-systems --no-build
darwin-rebuild build --flake .#Rivaldos-MacBook-Pro
```

Review the complete diff:

```bash
git diff --check
git diff -- flake.nix flake.lock modules/darwin/omniwm docs
```

Do not activate when evaluation/build fails, when the cask is unavailable, or
when the release and issue review is incomplete.

## 4. Activate

On the target Mac, quit OmniWM first (Homebrew replaces the app bundle
underneath a running instance), then:

```bash
sudo darwin-rebuild switch --flake .#Rivaldos-MacBook-Pro
```

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
- Input Monitoring is present only if a System Hyper Trigger or sided-modifier
  binding is enabled.
- **Displays have separate Spaces** remains enabled.
- The Home Manager-managed border width, gap, and corner radius still apply
  without migration warnings.
- Representative bindings work: `Option + H/J/K/L`, `Option + 1-9`,
  `Option + Shift + H/J/K/L`, `Option + Return`, and
  `Control + Option + Shift + L`.
- Niri/Dwindle layout behavior and multi-monitor focus still work as expected.

Recheck the upstream issue tracker after testing if any behavior changed or a
new regression appears.

## Rollback

First, return the repository to the previously reviewed `homebrew-cask` lock
revision, then rebuild:

```bash
git restore --source=<known-good-commit> -- flake.lock
nix flake check --all-systems --no-build
darwin-rebuild build --flake .#Rivaldos-MacBook-Pro
sudo darwin-rebuild switch --flake .#Rivaldos-MacBook-Pro
```

A nix-darwin generation rollback is also available for system configuration:

```bash
sudo darwin-rebuild switch --rollback --flake .#Rivaldos-MacBook-Pro
```

Homebrew casks are stateful, so restoring a system generation or old tap pin
may not automatically downgrade an already installed OmniWM application. If
the application itself must be downgraded, first preserve any settings needed
for recovery, uninstall the current cask, and re-run the known-good
nix-darwin configuration so it installs from the restored tap. Confirm the old
cask artifact is still available before uninstalling.

# Maintenance

[Documentation index](./README.md) · [Repository overview](../README.md)

Run commands from the repository root. Shell blocks use Bash/Zsh syntax unless
noted. This guide assumes Nix with flakes enabled; activation assumes the host
already has its normal NixOS or nix-darwin setup.

## Make a change

1. Inspect `git status --short` and the module that owns the setting.
2. Put the change in the right layer:
   - shared user settings or CLI packages: `home-manager/common/`;
   - platform-only user settings: `home-manager/{nixos,darwin}/`;
   - OS services and system integration: `modules/{nixos,darwin}/`.
3. Import a new module through the nearest existing `default.nix`. Keep
   `hosts/*/configuration.nix` thin and use one package owner per tool.
4. Update the relevant [guide](./README.md). Persistent settings belong in source,
   not generated files.
5. Stage newly added or renamed paths explicitly if Nix needs to see them:
   `git add path/to/new-file.nix`. Git-backed flakes exclude untracked files.
6. Validate and review the diff before activating.

Do not change `home.stateVersion` or `system.stateVersion` merely to match a
new Nixpkgs release; these track compatibility defaults, not package versions.

## Validation

The default check evaluates both hosts and the declared checks without building
them or changing the live system:

```sh
git diff --check
git diff --cached --check
nix flake check --all-systems --no-build
```

To build and execute isolated editor/shell smoke tests on your own platform:

```sh
nix build --no-link .#checks.aarch64-darwin.neovim-config .#checks.aarch64-darwin.nushell-config
```

On Linux, use `checks.x86_64-linux.neovim-config` and
`checks.x86_64-linux.nushell-config`. These checks use temporary HOME/XDG paths,
not your live shell or editor state. They are application checks, not host
rebuilds.

[CI](../.github/workflows/check.yml) evaluates all systems, then builds selected
Linux application and configuration checks. The full Linux Home Manager
profile build runs only through the manually triggered workflow. Passing
evaluation alone does not mean every package builds or every runtime works.

## Update dependencies

Review upstream release notes and relevant issues before changing pins.
Prefer a targeted update:

```sh
nix flake update nixpkgs
git diff -- flake.lock
nix flake check --all-systems --no-build
```

Use `nix flake update` only when you intend to update all inputs. Recheck the
affected application's config and documented bindings after an update.

| Dependency | Source of truth / procedure |
| --- | --- |
| Nixpkgs, nvf, Home Manager, desktop shells | Inputs in `flake.nix` and revisions in `flake.lock` |
| Pi/OpenCode binaries | `llm-agents` input; update with `nix flake update llm-agents` |
| macOS apps and formulas | `homebrew-cask` / `homebrew-core` inputs |
| OmniWM | [Release review and migration procedure](OMNIWM_UPDATES.md) |
| Pi npm extensions | [Audit-first updater](../home-manager/common/pi/scripts/README.md) |
| RTK | [Version and archive hashes](RTK_OPENCODE.md#update-rtk) |
| PiG | Version and archive hashes in [`pkgs/pig/default.nix`](../pkgs/pig/default.nix); reassess compatibility before enabling tools |

Pi's top-level npm pins are declarative, but its installed transitive dependency
tree under `~/.pi/agent/npm` is mutable and is not locked by `flake.lock`.
Run the package audit after activation. The temporary `fast-uri` override is
documented in the [maintenance scripts](../home-manager/common/pi/scripts/README.md);
remove it only after isolated audits and compatibility checks pass.

Homebrew activation uses pinned taps with `autoUpdate = false`,
`upgrade = true`, and `cleanup = "uninstall"`. Review all Brew changes before
activation: updating `homebrew-cask` affects more than OmniWM. App self-updaters
can still introduce drift, and old tap pins do not guarantee a downgrade.

## Apply manually on the target host

**These commands change the live system. They are operator instructions, not
coding-agent validation.** Agents must not run host rebuilds, dry-builds,
activation, or rollback commands in this workspace.

Host activation includes Home Manager:

```sh
sudo nixos-rebuild switch --flake .#thinker
```

On the configured Mac:

```sh
sudo darwin-rebuild switch --flake .#Rivaldos-MacBook-Pro
```

For a user-only change, standalone profiles are also exported:

```sh
nix run .#home-manager -- switch --flake .#rivaldo@thinker
```

Use `rivaldo@Rivaldos-MacBook-Pro` on macOS. This command still activates the
user profile; it is not a preview and does not apply system services, Homebrew
changes, or host-managed secrets.

Quit OmniWM before replacing its app bundle, then [reopen it](OMNIWM_UPDATES.md#restart-without-updating).
Restart long-running editors and agents after changing their packages.

## Roll back manually

Inspect your generations and identify the intended recovery point first.
On the corresponding target host:

```sh
sudo nixos-rebuild switch --rollback
```

Or, on macOS:

```sh
sudo darwin-rebuild switch --rollback
```

Generation rollback does not revert your Git checkout, mutable Pi npm state,
or necessarily Homebrew apps. See [OmniWM recovery](OMNIWM_UPDATES.md#rollback)
before attempting a cask downgrade.

## Troubleshooting

- **Missing path in the flake source:** inspect `git status --short`; stage the
  specific new path rather than the whole repository.
- **Home Manager file collision:** integrated profiles use the `hm-bak`
  backup extension. Inspect the reported file and any existing backup; preserve
  local changes before resolving the collision.
- **Permission error:** inspect the exact failing path and its ownership first.
  Do not apply a blanket recursive `chown` or `chmod` to `~/.config`.
- **Nushell lacks Starship on macOS:** open a new `nu` after activation. The
  [module](../home-manager/common/nushell.nix) manages XDG config and the
  `~/Library/Application Support/nushell` fallback, plus vendor-autoload
  initialization for Starship, Atuin, and Zoxide. Do not add duplicate init
  commands.
- **Cache settings disagree:** keep [`caches.nix`](../caches.nix) and the literal
  `flake.nix` `nixConfig` values synchronized. Darwin trusts only `root`; do not
  grant extra daemon trust just to use a configured cache.

## Linux Flatpak apps

Flatpak installs are deliberately outside Home Manager activation, so a Flathub
outage cannot break a profile switch. Run manually when needed:

```sh
flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak --user install -y flathub org.telegram.desktop io.kinvolk.Headlamp
```

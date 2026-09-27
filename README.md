# Unified NixOS + nix-darwin Config

This repository manages my Linux and macOS machines from one flake.

The design is simple:

- keep host files thin
- keep reusable logic in modules
- keep Home Manager shared-first
- keep secrets encrypted with `sops-nix`

## Hosts

- NixOS: `thinker`
- Darwin: `Rivaldos-MacBook-Pro`

## Directory guide

- `flake.nix` - inputs, host outputs, shared Home Manager module lists, and evaluation checks
- `caches.nix` - shared host cache URLs and trusted keys
- `.github/workflows/check.yml` - deterministic flake validation in CI
- `hosts/` - minimal host wrappers
- `modules/` - reusable system modules
  - `modules/nixos/` for NixOS-only system config
  - `modules/darwin/` for macOS-only system config
- `home-manager/` - user config
  - `home-manager/home.nix` shared base
  - `home-manager/common/` cross-platform HM modules
  - `home-manager/nixos/` Linux-only HM modules
  - `home-manager/darwin/` macOS-only HM modules
- `secrets/` - encrypted secrets data
- `pkgs/configured-apps/` - wrappers for configured application flake outputs
- `docs/` - keybind, editor, and Pi behavior docs
  - `docs/PI_YOLO.md` - Pi YOLO behavior and troubleshooting
- `home-manager/common/pi/` - Pi package settings, permission policy, checks, and maintenance scripts

## Daily commands

Run these from the repo root.

```bash
# Evaluate every supported system without building
nix flake check --all-systems --no-build

# Apply NixOS
sudo nixos-rebuild switch --flake .#thinker

# Apply Darwin (run on the target Mac)
sudo darwin-rebuild switch --flake .#Rivaldos-MacBook-Pro
```

## Package ownership policy

Use one owner per tool to avoid path conflicts:

- CLI tools -> Nix (system modules or Home Manager)
- Tools with native OS integration -> prefer system modules
- macOS GUI apps -> Homebrew casks
- Homebrew formulas -> avoid for CLI tools unless strictly necessary

`uv` is an intentional exception: NixOS owns it system-wide alongside `nix-ld`, while Darwin owns it through the Homebrew formula.

If a tool is already managed in Nix, do not also manage it in Brew.

The repository-owned `rtk` package is exported for both hosts and can be run without installation:

```bash
nix run github:valdo766hi/nix-config#rtk
```

Configured applications are also exported for both supported systems:

```bash
nix run github:valdo766hi/nix-config#neovim
nix run github:valdo766hi/nix-config#yazi
nix run github:valdo766hi/nix-config#lazygit
nix run github:valdo766hi/nix-config#pi
nix run github:valdo766hi/nix-config#pig
```

If `home-manager` is not yet on `PATH`, bootstrap the current profile with:

```bash
nix run .#home-manager -- switch --flake .#rivaldo@Rivaldos-MacBook-Pro
```

These outputs reuse the Home Manager configuration. Pi loads the `fast`,
`footer`, and `yolo` extensions from the published `@valdo766hi` npm packages;
RTK and the Catppuccin theme remain Nix-managed. Yazi uses an immutable
configuration directory, so its `y` shell wrapper cannot change the parent
shell's directory when launched through `nix run`. LazyGit uses the managed
Catppuccin configuration and Nix-provided Delta. Pi uses the Nix package while
its extensions, settings, authentication, and mutable state remain under
`~/.pi`. PiG is separately installed from a pinned upstream release; its
independent configuration and compatibility limits are in [docs/PIG.md](docs/PIG.md).

Other installed tools come from nixpkgs and can be run directly with `nix run nixpkgs#<package>` when they provide an executable.

Niri is intentionally split by responsibility: its NixOS module owns installation, system integration, and the display-manager session; Home Manager owns the user configuration file.

Flatpak apps are intentionally installed outside Home Manager activation so a network or Flathub outage cannot break a profile switch:

```bash
flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak --user install -y flathub org.telegram.desktop io.kinvolk.Headlamp
```

## Secrets

Secrets are managed with `sops-nix`.

- Encrypted file: `secrets/secrets.yaml`
- Private SSH host configuration is rendered from the encrypted `ssh_config` value.
- Linux key: `/home/rivaldo/.config/sops/age/keys.txt`
- macOS key: `/Users/rivaldo/.config/sops/age/keys.txt`

Edit secrets:

```bash
nix shell nixpkgs#sops -c sops secrets/secrets.yaml
```

## How to modify this repo safely

1. Run `nix flake check --all-systems --no-build` before changing anything.
2. Make the change in the right layer:
   - system-level -> `modules/*`
   - user-level -> `home-manager/*`
   - shared user-scoped CLI tools -> `home-manager/common/packages.nix`
3. Import new module from the nearest `default.nix` aggregator.
4. Stage only added or renamed paths explicitly (flakes only see tracked files), for example `git add home-manager/common/new-module.nix`.
5. Run `nix flake check --all-systems --no-build` again.
6. Apply on target host.

## Automated checks

GitHub Actions runs `nix flake check --all-systems` for every push and pull request. The workflow uses commit-pinned actions, evaluates both host configurations, and builds the Linux Home Manager profile, `rtk`, Neovim, Yazi, LazyGit, Pi, and Pi extension checks.

## Validation shortcuts

```bash
# NixOS dry run
sudo nixos-rebuild dry-build --flake .#thinker

# Home Manager eval on Linux
home-manager build --flake .#rivaldo@thinker

# Darwin build (on the target Mac)
darwin-rebuild build --flake .#Rivaldos-MacBook-Pro
```

## Troubleshooting notes

- If Home Manager reports file collisions, backups are saved as `*.hm-bak`.
- If HM fails with permission errors in `~/.config/*`, fix ownership:

```bash
sudo chown -R rivaldo:staff ~/.config/nushell ~/.config/fish
```

- If flake says a path does not exist in `/nix/store/...-source`, stage the missing path explicitly with `git add path/to/file`.
- Host cache settings come from `caches.nix`. Keep the literal `flake.nix` `nixConfig` values synchronized because flake-level settings cannot import them.

## Rollback

```bash
# NixOS
sudo nixos-rebuild switch --rollback --flake .#thinker

# Darwin (on the target Mac)
darwin-rebuild switch --rollback --flake .#Rivaldos-MacBook-Pro
```

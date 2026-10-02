# Nix Config Agent Guide

This repo manages one NixOS host (`thinker`) and one macOS host (`Rivaldos-MacBook-Pro`) with a shared Home Manager base. Optimize for small, reusable module changes and keep host files thin.

## Hard Rules

- Never run `sudo`, `nixos-rebuild`, `darwin-rebuild`, activation switch commands, rollback commands, or other password-requiring commands from this workspace.
- Never run host rebuilds or dry-build equivalents here. They usually require a password, machine-local context, or both.
- Never run `git commit`, `git commit --amend`, `git rebase`, or other git history-writing commands unless the user explicitly asks for them.
- Default to non-privileged validation only.
- Do not duplicate ownership of the same tool across NixOS modules, Darwin modules, Home Manager, and Homebrew.
- Secrets live in `secrets/secrets.yaml` via `sops-nix`, never in plain text.

## Repo Map

- `flake.nix`: inputs, supported systems, and public outputs
- `outputs/`: construction of hosts, standalone Home Manager profiles, packages, and checks
- `caches.nix`: shared host cache URLs and trusted public keys
- `.github/workflows/check.yml`: deterministic CI validation with commit-pinned actions
- `hosts/nixos/thinker/configuration.nix`: thin NixOS host wrapper importing shared NixOS modules plus hardware config
- `hosts/darwin/configuration.nix`: thin Darwin host wrapper importing shared Darwin modules
- `modules/nixos/`: NixOS system modules
- `modules/darwin/`: nix-darwin system modules
- `home-manager/home.nix`: shared Home Manager base
- `home-manager/common/`: cross-platform Home Manager modules
- `home-manager/nixos/`: Linux-only Home Manager modules
- `home-manager/darwin/`: macOS-only Home Manager modules
- `secrets/secrets.yaml`: encrypted secrets source, including private SSH host configuration
- `pkgs/rtk/`: repository-owned package exported through `packages.<system>.rtk`
- `pkgs/configured-apps/`: wrappers for configured Neovim, Yazi, LazyGit, and Pi outputs
- `docs/`: reference docs and keybindings

## Placement Rules

- Put NixOS system integration in `modules/nixos/*`.
- Put Darwin system integration in `modules/darwin/*`.
- Put shared user-scoped packages and shell/editor/tool config in `home-manager/common/*`.
- Put Linux-only Home Manager config in `home-manager/nixos/*` and import it from `home-manager/nixos/default.nix`.
- Put macOS-only Home Manager config in `home-manager/darwin/*` and import it from `home-manager/darwin/default.nix`.
- Keep `hosts/*/configuration.nix` thin. If logic grows, move it into a reusable module.
- If a new module is introduced, wire it through the existing import path instead of growing host wrappers.
- Keep Niri installation and display-manager integration in the NixOS module; keep its user configuration in Home Manager.

## Package and App Ownership

- CLI tools belong in Nix, usually Home Manager or system modules.
- Prefer Home Manager for user-scoped CLI tools that do not need system integration.
- Prefer `modules/nixos/common/default.nix` or `modules/darwin/common/default.nix` when a tool needs platform-native system options or service wiring.
- macOS GUI apps belong in Homebrew casks in `modules/darwin/homebrew/default.nix`.
- Avoid Homebrew formulas for CLI tools unless there is a strong reason Nix cannot own them.
- `uv` is intentionally host-owned: NixOS installs it system-wide with `nix-ld`; Darwin uses the Homebrew formula.

## Repo-Specific Facts

- Home Manager has one shared base: `home-manager/home.nix`, with XDG paths enabled on both platforms.
- Nushell and LazyGit are owned by their native Home Manager modules. Nushell retains vendor-autoload initialization; keep native Nushell integrations disabled to avoid double initialization.
- Shared aliases use `home.shellAliases`; shell-specific aliases remain in their shell modules.
- Linux-only packages belong in `home-manager/nixos/default.nix`; modules under `home-manager/nixos/` do not need repeated platform guards.
- Integrated and standalone Home Manager both use `home-manager/nixos/default.nix` or `home-manager/darwin/default.nix`; each imports `home-manager/home.nix`.
- External Home Manager modules are imported beside their configuration, not listed in `flake.nix`.
- `backupFileExtension = "hm-bak"` is enabled.
- Flake mode only sees tracked files. If a new file is added and Nix reports a missing path, stage that path explicitly with `git add path/to/file`.
- Darwin Home Manager uses `/Users/rivaldo`; NixOS uses `/home/rivaldo`.
- Current secrets include `shell_secrets`, `ssh_config`, and on NixOS also `winapps_rdp_user` and `winapps_rdp_pass`.
- External host cache settings are centralized in `caches.nix`. The literal `flake.nix` `nixConfig` values must remain synchronized because flake-level settings cannot import them.
- Darwin trusts only `root`; devenv and Cachix caches are configured globally so `rivaldo` does not need Nix daemon trust.
- Homebrew activation intentionally updates and upgrades packages on Darwin.

## Safe Workflow

1. Inspect the relevant existing module before editing.
2. Keep changes minimal and reuse the current module split.
3. Check package ownership before adding any package or app.
4. Run `git status --short` before and after changes.
5. Run `nix flake check --all-systems --no-build` when validation is needed.

## Safe Validation

- Preferred local check: `nix flake check --all-systems --no-build`
- Configured applications: `nix run .#neovim`, `nix run .#yazi`, `nix run .#lazygit`, and `nix run .#pi`
- CI runs: `nix flake check --all-systems`
- Allowed: non-mutating reads, searches, and static inspection
- Do not run: `nixos-rebuild`, `darwin-rebuild`, `home-manager switch`, rollback commands, or other privileged/local-machine activation commands

## Secrets

- Encrypted source: `secrets/secrets.yaml`
- Edit with: `nix shell nixpkgs#sops -c sops secrets/secrets.yaml`
- NixOS age key: `/home/rivaldo/.config/sops/age/keys.txt`
- Darwin age key: `/Users/rivaldo/.config/sops/age/keys.txt`

## Commit Style

- Use lowercase imperative present tense: `add`, `fix`, `refactor`, `update`
- Keep scope obvious and repo-specific.
- This is for commit message style only. Do not create commits unless the user explicitly asks.
- Example: `refactor darwin module placement rules`

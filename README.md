# Nix config

One flake for my NixOS and macOS machines: thin hosts, explicit modules, and a
shared Home Manager base. Inspired by
[gvolpe/nix-config](https://github.com/gvolpe/nix-config).

This is a personal configuration, not an installation template. Before
adapting it, review usernames, home directories, hardware, and secret paths.

## Hosts

| Host | System | Desktop |
| --- | --- | --- |
| `thinker` | `x86_64-linux` · NixOS | Niri + DankMaterialShell |
| `Rivaldos-MacBook-Pro` | `aarch64-darwin` · nix-darwin | OmniWM |

Both hosts share nvf Neovim, Nushell/Fish, Starship, Yazi, LazyGit, Pi, and RTK.
Noctalia is an optional Linux shell; AeroSpace is an inactive macOS alternative.

## Try it

From this checkout, evaluate without building or activating a host:

```sh
nix flake check --all-systems --no-build
```

Run the configured editor or an exported tool without a system switch:

```sh
nix run .#neovim
nix run .#yazi
nix run .#lazygit
nix run .#rtk -- --version
```

These packages also work with a remote flake reference, for example
`nix run github:valdo766hi/nix-config#neovim`.

`nix run .#pi` and `nix run .#pig` launch the Nix-managed binaries with filtered
environments; they still use mutable settings and authentication in `~/.pi` and
`~/.pig`. Running them does **not** install the Home Manager settings.
[PiG is currently chat-only](docs/PIG.md), with coding tools disabled.

Yazi's package embeds its configuration, but cannot change the calling shell's
directory. Use the Home Manager `y` wrapper for that. LazyGit embeds its managed
configuration; Neovim includes its Nix-managed plugins and language tools.

## Configuration layout

```text
flake.nix
├── outputs/hosts.nix    → hosts/ → modules/
├── outputs/home.nix     → home-manager/{nixos,darwin}/
│                          └── home.nix → common/
├── outputs/packages.nix → application packages from those profiles
└── outputs/checks.nix   → evaluation and application checks
```

Integrated and standalone Home Manager use the same platform entrypoints.
External Home Manager modules are imported beside their configuration. There
is no automatic directory scanning or custom module framework.

| Path | Responsibility |
| --- | --- |
| [`flake.nix`](flake.nix), [`flake.lock`](flake.lock) | Inputs and their revisions |
| [`outputs/`](outputs/) | Host, profile, package, and check construction |
| [`hosts/`](hosts/) | Thin host wrappers and hardware configuration |
| [`modules/nixos/`](modules/nixos/) | Linux system integration |
| [`modules/darwin/`](modules/darwin/) | macOS system integration and Homebrew |
| [`home-manager/home.nix`](home-manager/home.nix) | Shared user base |
| [`home-manager/common/`](home-manager/common/) | Shared packages and tool settings |
| [`home-manager/nixos/`](home-manager/nixos/) | Linux user settings |
| [`home-manager/darwin/`](home-manager/darwin/) | macOS user settings |
| [`pkgs/`](pkgs/) | RTK, PiG, and configured application wrappers |
| [`caches.nix`](caches.nix) | Host cache URLs and trusted public keys |

### One owner per tool

- User-scoped CLI tools and settings belong in Home Manager.
- OS services and native system integration belong in system modules.
- macOS GUI apps belong in Homebrew casks; avoid duplicate Nix/Brew ownership.
- `uv` is intentionally system-owned on NixOS and Homebrew-owned on macOS.
- Niri's system module owns installation and its login session; Home Manager
  owns `config.kdl`.

Homebrew taps are pinned in `flake.lock`; activation upgrades from those taps
without auto-updating them and uninstalls undeclared Brew packages. Updating a
pin alone does not update an installed app.

## Guides

Start with the [documentation index](docs/README.md), or jump to:

| Task | Guide |
| --- | --- |
| Change, validate, update, apply, or roll back | [Maintenance](docs/MAINTENANCE.md) |
| Navigate and edit code | [Neovim workflow](docs/NVF_KEYBINDINGS.md) |
| Use the Linux desktop | [Niri keybindings](docs/NIRI_KEYBINDINGS.md) |
| Use or restart the macOS window manager | [OmniWM keys](docs/OMNIWM_KEYBINDINGS.md) · [Updates](docs/OMNIWM_UPDATES.md) |
| Understand agent permissions | [Pi YOLO](docs/PI_YOLO.md) |
| Audit or update Pi packages | [Pi maintenance scripts](home-manager/common/pi/scripts/README.md) |
| Use RTK with OpenCode | [RTK integration](docs/RTK_OPENCODE.md) |
| Try the independent PiG setup | [PiG compatibility](docs/PIG.md) |

## Secrets

[sops-nix](https://github.com/Mic92/sops-nix) renders secrets from the encrypted
[`secrets/secrets.yaml`](secrets/secrets.yaml), including private SSH host
configuration. Never put credentials in Nix source or documentation.

Edit locally with SOPS:

```sh
nix shell nixpkgs#sops -c sops secrets/secrets.yaml
```

Age keys stay on each host at `~/.config/sops/age/keys.txt`; they are not in Git.

## Validation

[CI](.github/workflows/check.yml) evaluates both systems and builds selected
Linux application, Pi, Nushell, and headless Neovim checks. The complete Linux
Home Manager build is manual-only. Evaluation does not build or execute tests;
see [maintenance](docs/MAINTENANCE.md#validation) for local smoke-test commands.

Host activation is a separate, manual step on the target machine.
[AGENTS.md](AGENTS.md) prohibits coding agents from running host rebuilds,
dry-builds, activation, or rollback commands.

# NixOS Configuration Management Guidelines

## Quick Reference
```bash
# Most Common Commands
nix flake check                                      # Always run first!
sudo nixos-rebuild switch --flake .#thinker          # Apply NixOS system changes
darwin-rebuild switch --flake .#darwin               # Apply macOS system changes
home-manager switch --flake .#rivaldo@thinker        # Apply user changes (NixOS)
git status                                           # Check for untracked files
nix flake update                                     # Update all flake inputs
```

## Project Structure & Module Organization
- `flake.nix`: Main entry point defining inputs, outputs, system & home configurations
- `flake.lock`: Pinned dependencies (auto-updated with `nix flake update`)
- `hosts/`: Host-specific system configurations
  - `nixos/thinker/`: NixOS host (thinker)
    - `default.nix`: Main config, imports modules
    - `hardware-configuration.nix`: Hardware-specific (auto-generated)
  - `darwin/`: macOS host
    - `default.nix`: Main config, imports modules
- `home-manager/`: User-level configuration
  - `home.nix`: Main home-manager entry point
  - `common/`: Shared across both platforms (fish, git, starship, bat, zoxide, atuin, tmux, packages)
  - `nixos/`: Linux-specific (niri, vicinae, dank-material-shell, nvf, winapps)
  - `darwin/`: macOS-specific (aerospace, homebrew)
- `modules/`: Reusable system modules
  - `shared/`: Cross-platform modules (core services)
  - `nixos/`: Linux-only modules (desktop, virtualisation)
  - `darwin/`: macOS-only modules (desktop, homebrew)

## Pre-Change Checklist
Before making ANY changes:
1. Run `nix flake check` to ensure current state is valid
2. Check `git status` for untracked files (they break builds!)
3. Review ESP space if touching bootloader: `df -h /boot`
4. Backup important configs if making risky changes

## Common Operations

### Adding a New Package
```nix
# For shared packages: home-manager/common/packages.nix
home.packages = with pkgs; [
  existing-package
  new-package
];

# For Linux-only: use lib.mkIf in nixos-specific module
home.packages = with pkgs; lib.optionals pkgs.stdenv.isLinux [
  linux-only-package
];

# For macOS-only: use lib.mkIf in darwin-specific module
home.packages = with pkgs; lib.optionals pkgs.stdenv.isDarwin [
  macos-only-package
];
```

### Creating a New Module
1. Decide where it belongs:
   - `home-manager/common/` for cross-platform user config
   - `home-manager/nixos/` for Linux-only user config
   - `home-manager/darwin/` for macOS-only user config
   - `modules/nixos/` for Linux-only system config
   - `modules/darwin/` for macOS-only system config
2. Import in `home.nix` or host `default.nix` respectively
3. Use this template:
```nix
{ config, pkgs, lib, ... }:
{
  # Module configuration here
}
```

### Platform-Conditional Configuration
```nix
{ config, pkgs, lib, ... }:

{
  # Conditionally enable on Linux
  programs.example = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
  };

  # Conditionally add packages
  home.packages = with pkgs; lib.optionals pkgs.stdenv.isDarwin [
    darwin-package
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    linux-package
  ];
}
```

## Coding Style & Best Practices
- **Indentation**: 2 spaces, consistent throughout
- **Attributes**: Group logically, sort alphabetically within groups
- **Imports**: Be explicit, avoid `with` unless it significantly reduces duplication
- **Package references**: Use explicit `pkgs.packageName`
- **Platform detection**: Use `pkgs.stdenv.isLinux` and `pkgs.stdenv.isDarwin`
- **Avoid duplicates**: One source per package (prevents path conflicts)
- **Asset management**: Track all new files with `git add` immediately

## Testing & Validation

### Build Validation (NixOS)
```bash
nix flake check                                      # Catch syntax/eval errors
sudo nixos-rebuild dry-build --flake .#thinker       # Test system build
home-manager build --flake .#rivaldo@thinker         # Test home build
```

### Build Validation (macOS)
```bash
nix flake check                                      # Catch syntax/eval errors
darwin-rebuild build --flake .#darwin                # Test system build
home-manager build --flake .#rivaldo@darwin          # Test home build
```

### Manual Smoke Tests After Changes
- Yazi: `y` command works and returns to last directory
- Bat: `bat --list-themes | grep Catppuccin` shows theme
- Fish: Shell loads with correct prompt/aliases
- NVF: Neovim loads with correct settings
- Bootloader: Entries appear correctly (check ESP space!)

## Critical Safety Notes

### ESP/Bootloader Constraints (NixOS only)
- **ESP Size**: ~247MB - CRITICAL LIMIT!
- Keep `boot.loader.systemd-boot.configurationLimit = 5` or lower
- Clean old generations if space errors: `sudo nix-collect-garbage --delete-older-than 7d`
- Check space before bootloader changes: `df -h /boot`

### Network & Downloads
- Pin all downloaded sources with hashes
- Avoid network fetches at build time
- Use `fetchFromGitHub` with `rev` and `sha256`

### Package Management
- Use Home Manager modules over `home.packages` when module exists
- Never duplicate package installations (causes conflicts)
- Check for existing packages: `nix-env -q | grep package-name`

## Troubleshooting

### Common Issues & Solutions
| Issue | Solution |
|-------|----------|
| "No space left on /boot" | Run `sudo nix-collect-garbage -d` then rebuild |
| "Untracked files" error | `git add` the files or add to `.gitignore` |
| "Attribute not found" | Check spelling, ensure module is imported |
| "Infinite recursion" | Look for circular dependencies in configs |
| Build succeeds but app missing | Check PATH, may need shell reload |
| Darwin build fails | Check `nixpkgs.hostPlatform` is "aarch64-darwin" |

### Debugging Commands
```bash
nix repl '<nixpkgs>'          # Interactive Nix exploration
nix-store --verify --check-contents  # Verify store integrity
nix why-depends <path1> <path2>      # Dependency analysis
journalctl -xe                       # System service logs (NixOS)
log show --predicate 'process == "darwin-rebuild"' --last 10  # macOS logs
```

## Commit & PR Guidelines

### Commit Messages
- Present tense, imperative mood ("Add", "Fix", "Update", not "Added", "Fixed")
- Format: `<verb> <what> [where]`
- Examples:
  - Good: `Add Catppuccin theme to bat`
  - Good: `Fix bootloader space constraints`
  - Good: `Add AeroSpace config for macOS`
  - Good: `Unify fish shell config across platforms`

### Pull Request Template
```markdown
## Changes
- Main change description
- Secondary changes

## Testing
- [ ] `nix flake check` passes
- [ ] NixOS rebuild tested (if applicable)
- [ ] macOS rebuild tested (if applicable)
- [ ] Home-manager rebuild tested
- [ ] Manual smoke tests performed

## Risks
- Bootloader: [yes/no]
- System services: [affected services]
- User environment: [affected tools]
```

## Agent Learning Log
*Append lessons learned here immediately to preserve knowledge:*

- **2025-11-26**: Both CLAUDE.md and AGENTS.md must stay synchronized for multi-agent collaboration
- **Bootloader**: ESP is only ~247M, always check space before changes
- **Packages**: Avoid duplicates - one source per tool, use overrides in modules
- **Assets**: Untracked files break flake builds, always `git add` new themes/configs
- **Wrapper naming**: Keep it minimal (e.g., `y` for yazi, not `yazi-wrapper`)
- **2026-01-02**: Unified NixOS + nix-darwin in single repo
  - Use `lib.mkIf pkgs.stdenv.isLinux/Darwin` for conditional config
  - `self` is not available in module context (darwin configRevision)
  - Use `lib.optionalAttrs` for conditional attributes in sets
  - Home Manager as module on both platforms for unified rebuilds

## Rollback Procedures

### NixOS Rollback
```bash
# List previous generations
sudo nix-env --list-generations -p /nix/var/nix/profiles/system

# Rollback system
sudo nixos-rebuild switch --rollback --flake .#thinker

# Rollback home-manager
home-manager generations  # list
home-manager switch --flake .#rivaldo@thinker --rollback

# Nuclear option: boot previous generation from bootloader menu
```

### macOS Rollback
```bash
# List previous generations
darwin-rebuild list-generations

# Rollback system
darwin-rebuild switch --rollback --flake .#darwin

# Rollback home-manager
home-manager generations
home-manager switch --flake .#rivaldo@darwin --rollback
```

## Essential Resources
- [NixOS Options Search](https://search.nixos.org/options)
- [Nixpkgs Search](https://search.nixos.org/packages)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/)
- [Nix Pills](https://nixos.org/guides/nix-pills/) - Deep understanding
- Local flake: Check `flake.nix` for current input versions

---
*Remember: When in doubt, `nix flake check` first, ask questions second!*

# RTK + OpenCode Reference

This repository integrates [RTK](https://github.com/rtk-ai/rtk) with OpenCode through Home Manager so the setup is reproducible on both supported hosts:

- `x86_64-linux`
- `aarch64-darwin`

## What This Setup Does

- Installs the RTK binary from upstream release archives with Nix
- Places RTK on `PATH` through shared Home Manager packages
- Installs a global OpenCode local plugin at `~/.config/opencode/plugins/rtk.ts`
- Rewrites OpenCode Bash or shell tool commands through `rtk rewrite` before execution

This means common commands like `git status`, `rg`, `cat`, `cargo test`, and similar shell commands can be automatically rewritten to `rtk ...` equivalents when they pass through OpenCode's Bash tool.

## Files Involved

- `pkgs/rtk/default.nix`: pinned RTK version and per-platform release hashes
- `home-manager/common/packages.nix`: adds `rtk` to shared CLI packages
- `home-manager/common/opencode/default.nix`: installs the plugin into OpenCode's global plugin directory
- `home-manager/common/opencode/rtk.ts`: vendored local OpenCode plugin

## Why This Repo Uses This Approach

- Reproducible: RTK version is pinned in Nix
- Cross-platform: one shared setup for Linux and macOS
- Safer than `cargo install rtk`: upstream warns the crates.io `rtk` name can resolve to the wrong project
- No manual plugin drift: Home Manager writes the OpenCode plugin file for you
- No npm dependency required for the plugin itself

## Important Notes

- The plugin implements the OpenCode 2 plugin API and only loads in `opencode2`; the V1 `opencode` CLI cannot load it
- OpenCode plugin hooks only affect Bash or shell tool calls
- OpenCode built-in tools like `Read`, `Grep`, and `Glob` are not rewritten by RTK automatically
- OpenCode currently does not apply plugin hooks to subagent tool calls, so subagents will not benefit from this hook until upstream changes that behavior
- The repo currently packages RTK only for `x86_64-linux` and `aarch64-darwin`

## Apply The Configuration

Use your normal rebuild flow.

### Linux

```bash
home-manager switch --flake .#rivaldo@thinker
```

Or apply via full system rebuild:

```bash
sudo nixos-rebuild switch --flake .#thinker
```

### macOS

```bash
# Replace the host name with the target Darwin machine if needed
sudo darwin-rebuild switch --flake .#Rivaldos-MacBook-Pro
```

## Verify RTK Is Working

After rebuilding:

1. Check the binary:

   ```bash
   rtk --version
   rtk gain
   ```

2. Check the plugin file exists:

   ```bash
   ls -l ~/.config/opencode/plugins/rtk.ts
   ```

3. Restart OpenCode

4. Test a normal Bash command in OpenCode, for example:

   ```bash
   git status
   ```

## How To Update RTK Later

RTK upgrades are intentionally kept simple.

### 1. Bump the version

Edit `pkgs/rtk/default.nix` and update:

```nix
version = "0.30.0";
```

### 2. Fetch the new upstream checksums

Find the latest release and its `checksums.txt` file from:

- `https://github.com/rtk-ai/rtk/releases`

You can also fetch it with `gh`:

```bash
gh api repos/rtk-ai/rtk/releases/latest --jq '.assets[] | select(.name=="checksums.txt") | .browser_download_url'
```

Then open the checksum file and copy the values for:

- `rtk-x86_64-unknown-linux-musl.tar.gz`
- `rtk-aarch64-apple-darwin.tar.gz`

### 3. Replace the hashes in `pkgs/rtk/default.nix`

Update:

- `sources.x86_64-linux.sha256`
- `sources.aarch64-darwin.sha256`

### 4. Validate the config

```bash
nix flake check "path:$PWD" --no-build
```

Optional deeper checks:

```bash
nix build "path:$PWD#homeConfigurations.\"rivaldo@thinker\".activationPackage"
# Replace the Darwin host name with the target machine if needed
nix eval --impure --json --expr 'let flake = builtins.getFlake (toString ./.); in builtins.map (pkg: pkg.pname or pkg.name or "") flake.darwinConfigurations."Rivaldos-MacBook-Pro".config.home-manager.users.rivaldo.home.packages'
```

### 5. Rebuild the affected host(s)

```bash
home-manager switch --flake .#rivaldo@thinker
# Replace the host name with the target Darwin machine if needed
sudo darwin-rebuild switch --flake .#Rivaldos-MacBook-Pro
```

### 6. Verify again

```bash
rtk --version
rtk gain
```

## Troubleshooting Notes

- If `rtk gain` does not exist, confirm you are using the RTK binary from this repo-managed setup, not a different `rtk` package installed elsewhere
- If OpenCode does not appear to rewrite commands, restart OpenCode after the rebuild
- After a Home Manager rebuild, also restart the background service (`opencode2 service restart`): the running beta caches the plugin module for the plugin path and a file watcher reload can keep serving the previous version
- If a command is executed through a non-Bash tool path, RTK rewrite will not apply
- If a subagent runs the command, the OpenCode plugin limitation still applies
- If the OpenCode log shows `Plugin must export a default definition with an id and an effect or setup function`, the plugin file is still the V1 version or the Home Manager rebuild has not linked the new one yet; rebuild and restart OpenCode

## Comparison To npm-Only Plugin Setups

Some external projects package only the OpenCode plugin and expect RTK to be installed separately. This repo intentionally does more than that:

- it manages the RTK binary itself
- it pins the RTK version
- it vendors the plugin locally
- it installs both pieces declaratively through Home Manager

For this repository, that makes upgrades, rollbacks, and cross-host consistency much easier.

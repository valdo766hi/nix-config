# RTK + OpenCode

[Documentation index](./README.md) · [Maintenance](MAINTENANCE.md)

[RTK](https://github.com/rtk-ai/rtk) reduces shell output before it reaches the
model. This repository installs its pinned upstream binary on
`x86_64-linux` and `aarch64-darwin`, and provides a local **OpenCode 2** plugin.

## Configuration

| File | Role |
| --- | --- |
| [`pkgs/rtk/default.nix`](../pkgs/rtk/default.nix) | Version, archive URLs, and platform hashes |
| [`home-manager/common/packages.nix`](../home-manager/common/packages.nix) | Shared RTK installation |
| [`home-manager/common/opencode/default.nix`](../home-manager/common/opencode/default.nix) | OpenCode 2 package and plugin installation |
| [`home-manager/common/opencode/rtk.ts`](../home-manager/common/opencode/rtk.ts) | Vendored command-rewrite hook |

Home Manager installs the plugin at `~/.config/opencode/plugins/rtk.ts`.
It hooks `bash` and `shell` execution, asks `rtk rewrite` to transform the
command, and uses a nonempty rewrite when it differs from the original.

The V1 `opencode` CLI cannot load this plugin API. Built-in file-read/search
tools are not rewritten. Only calls that reach this hook benefit; do not assume
subagent or other execution paths use it.

## Verify

After [manual activation](MAINTENANCE.md#apply-manually-on-the-target-host),
restart OpenCode and check:

```sh
rtk --version
rtk gain
ls -l ~/.config/opencode/plugins/rtk.ts
rtk rewrite 'git status'
```

Ask OpenCode to run `git status` through its Bash tool and inspect the result.
Testing `rtk rewrite` alone verifies rewrite rules, not that OpenCode loaded
the plugin.

For complete, uncompressed output, bypass RTK's formatting:

```sh
rtk proxy git diff
```

## Update RTK

The current version lives in `pkgs/rtk/default.nix`, not `flake.lock`.
Do not use `cargo install rtk`: the crates.io name may identify a different
project.

1. Review the target [upstream release](https://github.com/rtk-ai/rtk/releases).
2. Update `version` in `pkgs/rtk/default.nix`.
3. Obtain the release's `checksums.txt` and verify the two archive checksums:
   - `rtk-x86_64-unknown-linux-musl.tar.gz`;
   - `rtk-aarch64-apple-darwin.tar.gz`.
4. Convert each archive's SHA-256 to Nix SRI format and update
   `sources.x86_64-linux.hash` and `sources.aarch64-darwin.hash`:

   ```sh
   nix hash convert --hash-algo sha256 --to sri 'archive-sha256-hex'
   ```

   Replace the placeholder with the corresponding verified digest.
5. Evaluate, then build or run the package on the matching platform:

   ```sh
   nix flake check --all-systems --no-build
   nix build .#rtk --no-link
   nix run .#rtk -- --version
   ```

6. Review the diff and [activate manually](MAINTENANCE.md#apply-manually-on-the-target-host).
   Restart OpenCode and repeat the verification.

Use verified upstream digests; never accept a hash mismatch merely by replacing
the expected value with the reported download hash.

## Troubleshooting

- **No rewriting:** check `rtk` is on PATH and the plugin is installed. The
  plugin disables itself when its RTK version probe fails.
- **Old plugin still running:** restart the OpenCode 2 background service with
  `opencode2 service restart`, then reopen the client. A watcher reload may keep
  the cached plugin module.
- **“Plugin must export a default definition…”:** verify you are running
  OpenCode 2 and have activated the current plugin, then restart the service.
- **Output appears incomplete:** use `rtk proxy <command>` for raw output.
- **Non-Bash tool or subagent behaves differently:** confirm its execution path
  reaches the plugin hook before treating it as a rewrite failure.

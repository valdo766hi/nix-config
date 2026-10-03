# Pi package maintenance

[Documentation index](../../../../docs/README.md) · [Repository maintenance](../../../../docs/MAINTENANCE.md)

These scripts make Pi package updates audit-first and keep the Home Manager
module as the source of truth.

> Here, **secure** means that npm reports no known advisories. An audit cannot
> prove that package code is safe or non-malicious.

## Installed security check

```sh
pi-package-security-check
```

Audits the complete installed dependency tree, including development
dependencies, in `~/.pi/agent/npm`.

To repair vulnerable transitive dependencies without allowing breaking
upgrades, run:

```sh
pi-package-security-check --repair
```

This applies the repository's `fast-uri@3.1.8` override, runs `npm audit fix`
with install scripts and `--force` disabled, then audits the repaired tree.
Peer installation stays disabled, matching Pi: Pi supplies its own host APIs.

The `fast-uri@3.1.8` override is a temporary workaround for the `fast-uri`/`ajv`
advisories. New upstream releases may resolve them. Recheck future updates in an
isolated tree without the override; remove it only when that tree audits clean
and compatibility checks pass. A fully locked Nix extension build is deferred
unless the workaround remains necessary.

Exit codes distinguish the outcomes:

- `0`: no known vulnerabilities
- `1`: known vulnerabilities found
- `2`: audit could not run or its result was invalid

## Candidate security check

```sh
pi-package-security-check --candidate pi-lens@4.3.0
pi-package-security-check --candidate \
  pi-lens@4.3.0 \
  @plannotator/pi-extension@0.27.25
```

The versions above are examples, not a promise that they remain advisory-free.
Use the exact target versions you are reviewing. The script copies the
current manifest and lockfile to a temporary directory, applies the
`fast-uri@3.1.8` override, simulates all supplied updates with install scripts
disabled, repairs semver-compatible transitive dependencies, and audits the
resulting combined tree. It does not change the live installation.

Audit success does not establish runtime compatibility. Peer installation and
enforcement are disabled with `--legacy-peer-deps`; review host and extension
peer constraints and upstream migration notes before accepting pins. Update
coupled extensions together; see [YOLO compatibility](../../../../docs/PI_YOLO.md#state-and-configuration).

## Find secure updates

```sh
pi-package-update check
pi-package-update check pi-lens pi-subagents
```

The updater considers only registry versions semantically newer than exact
pins in `home-manager/common/pi/default.nix`. It audits each candidate and then
audits all accepted candidates together.

## Update secure pins

```sh
pi-package-update update
pi-package-update update pi-lens
```

The updater writes only candidates that pass both audits. All accepted pins
are written atomically; registry, checker, combined-audit, or editing errors
leave the configuration unchanged. A vulnerable candidate is skipped, while
other secure candidates may still be updated together.

The command finds this repository automatically at `$XDG_CONFIG_HOME/nix`
(default `~/.config/nix`) or from the current Git checkout. Direct package
versions are pinned in the Nix module, but the installed dependency tree under
`~/.pi/agent/npm` remains mutable application state and is not represented in
`flake.lock`; run the security check after activation. For a different
checkout, set:

```sh
PI_PACKAGES_CONFIG=/path/to/home-manager/common/pi/default.nix \
  pi-package-update check
```

The scripts deliberately do not activate Home Manager. `update` only changes
the Nix source and candidate checks use isolated temporary trees. After normal
activation, repair and verify the installed result:

```sh
pi-package-security-check --repair
pi-package-security-check
```

The repair is limited to safe npm fixes and the pinned `fast-uri` override;
it never uses `npm audit fix --force`.

Pi is launched with an allowlisted environment: only the Context7, Exa,
OpenCode, and TypeSafe credentials used by its configured servers/providers are
forwarded. Codemode is enabled by default. To use Jev, add
`export TYPESAFE_API_KEY="..."` to the `shell_secrets` entry in the
SOPS-encrypted `secrets/secrets.yaml`; after sops-nix renders the update, start
a new shell and Pi process. Never put the key in Nix source.
`SSH_AUTH_SOCK` is preserved for normal SSH authentication.
`TMPDIR=/tmp` keeps new temporary work in the approved cleanup location.
Outside-project file access requires approval, or is auto-approved with
`/yolo` on; credential and Pi-state denials still apply in either mode. The permission
rules are not a process sandbox: arbitrary programs and extensions retain
your account's privileges.

Both scripts print stable `[INFO]`, `[PASS]`, `[SKIP]`, `[FAIL]`, `[AUDIT]`,
and `[VULNERABLE]` messages plus meaningful exit codes so people and AI agents
can use the same workflow.

## Portable Pi

```sh
nix run github:valdo766hi/nix-config#pi
```

The exported app links the same Home Manager settings, MCP definitions,
Catppuccin theme, RTK extension, instructions, permission policy, and extension
configuration into `~/.pi/nix-config/agent`. It includes Node/npm, Git, RTK,
Plannotator, `pi-tmp-rm`, and the skill security checker on Pi's PATH. A Nix Bash
and `shellCommandPrefix` keep those tools available even when shell startup
resets PATH. Normal `~/.pi/agent` settings and state are untouched; no activation
is required.

The first launch needs network access to install the pinned npm/git packages.
Their mutable dependency trees and sessions are cached in the portable profile,
not built into the Nix closure. Subsequent launches reuse those installations.
The configuration links are read-only and refreshed on every launch; change
managed settings in this repository rather than with `/settings` or `pi config`.
Trusted project configuration and CLI overrides still apply.

Use `/login` in this profile: authentication is not copied from your normal Pi
installation and is never included in the Nix store. Set `CONTEXT7_API_KEY` and
`EXA_API_KEY` in the calling environment to authenticate the bundled MCP servers.
The existing credential-filtering launcher is retained. The permission policy
is relocated to protect the portable profile, and the compaction ratio is
forwarded explicitly because that extension's global config lookup is fixed to
`~/.pi/agent`.

The offline `checks.<system>.pi-config` smoke test uses a temporary HOME, checks
configuration and tool availability, and verifies that normal Pi settings are
preserved. It does not download extensions, connect MCP servers, or make model
requests.

## Pi runtime and subagents

Pi comes from the official release-tagged `pi` flake input and runs on Node.js;
`llm-agents` still supplies OpenCode and Antigravity CLI. Update Pi's release tag
in `flake.nix`, then run `nix flake update pi` and validate before activation.
The launcher retains its credential allowlist and disables telemetry and
self-update checks.

The standalone-only `asyncByDefault = false` override is removed. Subagents use
the package's default background behavior and resolve the SDK from the Node Pi
installation; explicit `async: false` still selects foreground execution.
Agent models, contexts, tools, and the custom `planner`/`context-builder` definitions
are managed in [`../subagent/default.nix`](../subagent/default.nix) and included in
the portable app. Scout and delegate use Luna 6; the other native roles use Sol 6.1.
Restart Pi after normal activation to load changes.

Tool arrays are still supported, but use current names:

```nix
tools = [ "read" "codemode" "mcp:context7" "mcp:exa" "contact_supervisor" ];
```

- `mcp:context7` or `mcp:exa` grants that server's tools; `mcp:server/tool`
  grants one tool. Pi resolves these selectors to `mcp__<server>__<tool>` names
  and exposes them directly in the child, even when the parent uses codemode.
- `codemode` is optional for batching, discovery, and filtering. It does not
  replace the MCP selectors or grant access to unselected MCP tools.
- `contact_supervisor` is the native child-to-parent channel. `intercom` needs
  a separate provider, which this configuration does not install. The old
  adapter's generic `mcp` tool is not part of built-in MCP.
- Reviewer uses the package's read-only `watchdog_diff`, not Bash. Researcher
  and evidence-auditor prompts use the configured MCP providers instead of
  requiring uninstalled `web_search`/`source_check` tools.

Selected MCP servers must be connected and non-hidden in the parent. Check
`/mcp` before launching; missing tools fail preflight. File-configured servers
work in foreground and background children. Extension-only registered servers
require background execution. For other extension tools, naming a tool is not
sufficient: load its provider with `extensions` or `subagentOnlyExtensions`.

## OpenAI compaction

Auto-compaction is enabled explicitly. For both `openai/*` and
`openai-codex/*`, Pi triggers compaction with its default 16,384-token reserve;
`pi-openai-server-compaction` then requests remote compaction and a portable
text summary. If remote compaction fails, the extension falls back to text.

Home Manager sets `thresholdRatio = 1.0` in
`~/.pi/agent/openai-server-compaction.json`, moving direct OpenAI's independent
inline threshold from 70% to 100%. Pi's threshold should therefore run first;
inline compaction remains a fallback, not disabled. Project-local extension
configuration can override this setting.

## MCP ownership

Pi's built-in MCP is on trial in place of `pi-mcp-adapter`. Home Manager writes
Context7 and Exa to `~/.pi/agent/mcp.json`; their keys come from the launcher's
`CONTEXT7_API_KEY` and `EXA_API_KEY`. Tools are named
`mcp__context7__*` and `mcp__exa__*` and are called from codemode scripts.

```sh
pi mcp list
```

The file is read-only, so make enable/exposure changes in
[`default.nix`](../default.nix), not through `/mcp`. Since permission-system
38, the permission policy's `mcp` rules gate both Pi's built-in MCP tools and
the adapter's umbrella tool. The configured Context7 and Exa targets are
allowed; unmatched MCP targets use `ask`. The top-level `"*": "allow"` does
not override that surface policy.

To return to the adapter, restore its quoted package pin, add
`extensions = ["-builtin:mcp"]`, and move the servers back to
`~/.config/mcp/mcp.json`. Never use both: each registers `/mcp`, and the
adapter cannot disable the built-in through the read-only settings file.

The `fast-uri`/`ajv` chain comes only from the adapter. After activation, recheck
whether the `fast-uri` override is still needed.

## SSH identities

Normal `ssh -i ~/.ssh/<key> <destination>` remains available with Bash approval.
Built-in file tools deny SSH directory access; Bash commands mentioning `.ssh`
are denied except for SSH itself. No SSH wrapper or extra prompt is installed.
These simple rules do not prevent arbitrary shell code or extension tools from
reading keys; see [the policy limitations](../../../../docs/PI_YOLO.md).

## Temporary cleanup

`pi-tmp-rm /tmp/<file-or-directory>` deletes one temporary entry without flags.
It refuses the temp root, parent traversal, outside paths, extra arguments,
and symlinked parents; recursive cleanup does not follow symlinks. Raw deletion
commands remain denied. See [Pi YOLO mode](../../../../docs/PI_YOLO.md) for
policy details and limitations.

## Skill security checks

Pi permits reads of global skills under `~/.agents/skills`, selected Pi
package/skill directories, and Pi-created `pi-clipboard-*` temporary files.
Broad Pi-state scans and credential paths are denied before infrastructure
auto-allow applies. Skills under `~/.agents/skills` and `~/.pi/agent/skills`
may be written and edited; other Pi state remains protected. Outside-project
access otherwise requires approval with YOLO off and is auto-approved with
YOLO on.

Scan one skill or a directory containing multiple skills:

```sh
skill-sec-check.sh ~/.agents/skills
skill-sec-check.sh ~/.agents/skills/ponytail
skill-sec-check.sh ~/.agents/skills/ponytail/SKILL.md
```

The command finds skills by `SKILL.md` and recursively runs Trivy's
vulnerability, secret, and misconfiguration scanners. Exit codes distinguish
the outcomes:

- `0`: no findings
- `1`: findings require review
- `2`: invalid input or the scan could not complete

A clean scan only means that these automated scanners found nothing. Skills
contain instructions and executable code, so review their source before use.

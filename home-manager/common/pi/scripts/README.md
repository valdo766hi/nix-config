# Pi package maintenance

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

This applies the repository's safe npm overrides, runs `npm audit fix` with
install scripts and `--force` disabled, then audits the repaired tree.

Exit codes distinguish the outcomes:

- `0`: no known vulnerabilities
- `1`: known vulnerabilities found
- `2`: audit could not run or its result was invalid

## Candidate security check

```sh
pi-package-security-check --candidate pi-lens@3.8.71
pi-package-security-check --candidate \
  pi-lens@3.8.71 \
  @plannotator/pi-extension@0.24.2
```

Candidate versions must be exact semantic versions. The script copies the
current manifest and lockfile to a temporary directory, applies the safe
`fast-uri` override, simulates all supplied updates with install scripts
disabled, repairs semver-compatible transitive dependencies, and audits the
resulting combined tree. It does not change the live installation.

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

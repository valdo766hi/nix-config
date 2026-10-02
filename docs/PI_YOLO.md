# Pi YOLO mode

This repository's `/yolo` command provides fast approval for permission checks
without disabling the permission policy's explicit denials.

## Usage

```text
/yolo       # toggle the current session
/yolo on    # enable
/yolo off   # disable
```

After changing the mode, the extension reloads Pi so the permission system
sees the updated setting immediately. Restart Pi after a Home Manager
activation.

## What YOLO changes

YOLO uses the native `@gotgenes/pi-permission-system` `yoloMode` behavior:

| Policy result | YOLO off | YOLO on |
| --- | --- | --- |
| `allow` | allowed | allowed |
| `ask` | prompts or follows the configured authorizer | allowed |
| `deny` | blocked | blocked |

Outside-project reads, writes, and commands require approval with YOLO off
and are auto-approved with YOLO on. Temporary entries, the Nix store, selected
Pi package/skill directories, and SSH authentication paths remain allowlisted.
Explicit path, tool, and Bash denials still apply in either mode; SSH has the
narrower protection described below.

YOLO is not a general unrestricted mode. In particular, it does not turn a
`deny` rule into an `allow` rule. It does auto-approve rules configured as
`ask`, including the Bash fallback. `sudo`, `doas`, and `git clean` are denied.

## Protected rules in this configuration

The permission policy continues to deny, among other things:

- secret files such as `.env`, GnuPG, AWS, Kubernetes, Docker, npm,
  GitHub, SOPS age keys, and agent login files, including `auth.json` backups;
- broad access to Pi state (including sessions and settings), other agents'
  state, and home/configuration directory roots;
- destructive commands such as `rm *`, `shred *`, filesystem formatting and
  partitioning commands, recursive ownership/permission changes, shutdown and
  reboot commands;
- forced Git pushes and hard resets.

The source policy is
`home-manager/common/pi/extensions/pi-permission-system/config.json`.

## SSH authentication

Use normal SSH, without a wrapper or extra system prompt:

```sh
ssh -i ~/.ssh/id_ed25519 user@host
```

SSH paths are allowed at the external-directory boundary, while built-in
`read`, `grep`, `find`, `ls`, `write`, and `edit` tools deny `~/.ssh` access.
Bash commands mentioning `.ssh` are denied except for normal `ssh` and
`/usr/bin/ssh`, which use `ask` (auto-approved in YOLO). The launcher preserves
`SSH_AUTH_SOCK` for existing agent-backed authentication.

This is a convenience policy, not a hard key-disclosure boundary: arbitrary
code, extension tools, aliases, and SSH options can bypass these simple
command rules. Do not use YOLO for untrusted work. Pi's `auth.json` protection
remains cross-cutting; Pi itself can still use it for provider authentication.

## Temporary cleanup

Use one absolute path, without flags:

```sh
pi-tmp-rm /tmp/my-temporary-file
pi-tmp-rm /tmp/my-temporary-directory
```

The helper refuses paths outside `/tmp`, the temp root itself, parent
traversal, extra arguments, and symlinked parent directories. Directory
cleanup never follows symlinks; deleting a leaf symlink removes only the
link. On macOS, `/private/tmp` is accepted as the resolved `/tmp` location.
Pi's launcher sets `TMPDIR=/tmp` so new temporary work uses this location.
Raw `rm`, `rmdir`, `unlink`, common `find` deletion/exec forms, and `git clean`
remain denied. Do not add a permissive `rm /tmp/*` rule: the glob also matches
extra arguments and does not validate paths.

## Security boundary

These rules reduce accidental exposure; they are **not an OS sandbox**.
A recursive scan of an allowed directory is checked at its starting path,
not every descendant. Arbitrary programs, inline code, and extensions can
access files with your account's privileges, including credentials. YOLO
also approves the Bash fallback. Use trusted extensions, keep YOLO off for
untrusted work, run Pi from a project directory (not home), and use process
isolation for a hard credential or deletion boundary.

## How it is wired

- The published `@valdo766hi/pi-yolo` package registers the command and stores
  `yolo-state` in the current Pi session.
- `home-manager/common/pi/extensions/pi-permission-system/config.json` keeps
  native `yoloMode` disabled by default.
- `/yolo` updates the live permission-system config atomically at
  `~/.pi/agent/extensions/pi-permission-system/config.json` and reloads Pi.
- Home Manager installs the package through the Pi settings in
  `home-manager/common/pi/default.nix`.

Because Home Manager manages the live config path, a later activation can
restore the declared default (`yoloMode: false`). That is intentional: the
repository remains safe by default, and the session command can enable YOLO
again when needed.

## Troubleshooting

1. Run `/yolo on` and retry the operation.
2. Check the footer for `YOLO: ON`.
3. If an external path still prompts, restart Pi after Home Manager activation
   and try again.
4. Use `/permission-system show` to inspect the active native setting after the
   next agent turn.

If a protected path or command is still blocked in YOLO mode, that is expected
when a `deny` rule matched it. Do not weaken the deny rule merely to make YOLO
work; check whether the path or command is intentionally protected.

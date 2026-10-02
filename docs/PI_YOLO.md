# Pi YOLO mode

[Documentation index](./README.md) · [Package maintenance](../home-manager/common/pi/scripts/README.md)

This repository's `/yolo` command provides fast approval for permission checks
without disabling the permission policy's explicit denials.

## Usage

```text
/yolo       # toggle the current session
/yolo on    # enable
/yolo off   # disable
```

After changing the mode, the extension saves session-local state and reloads
Pi to reattach the approval overlay. It does not change the permission-system
configuration. Restart Pi after a Home Manager activation to load updated
packages and settings.

## What YOLO changes

The published `@valdo766hi/pi-yolo` package listens for the permission system's
`permissions:ui_prompt` event and approves the matching permission dialog. The
native policy evaluates first; final denials do not open an approval prompt.
Keep native `yoloMode` disabled—this overlay is separate from that global mode.

| Policy result | YOLO off | YOLO on |
| --- | --- | --- |
| `allow` | allowed | allowed |
| `ask` | prompts or follows the configured authorizer | matching UI prompts auto-approved |
| `deny` | blocked | blocked |

The overlay is a best-effort UI integration, not a replacement for permission
evaluation. Do not assume it approves noninteractive requests or custom
authorizers that do not show a supported dialog.

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
[`config.json`](../home-manager/common/pi/extensions/pi-permission-system/config.json).

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

## State and configuration

Home Manager selects the published package in
[`home-manager/common/pi/default.nix`](../home-manager/common/pi/default.nix).
The repository's local `extensions/yolo/yolo.ts` is not the loaded implementation.

The package stores the toggle at `~/.pi/agent/yolo-state/<session-id>.json`.
The same session restores it after reload, restart, resume, or compaction;
a new session, fork, or subagent starts off. Turning it on in one session does
not enable it globally.

The managed permission config stays at `yoloMode: false`. Neither `/yolo` nor
its overlay writes that config or the permission map. Home Manager activation
does not reset the separate session toggle.

## Troubleshooting

1. Run `/yolo on` and retry the operation.
2. Check the footer for `YOLO: ON`.
3. If an external path still prompts, restart Pi after Home Manager activation
   and try again.
4. Use `/permission-system show` to inspect the native policy. Its
   `yoloMode: false` is expected even when the footer says `YOLO: ON`.
5. If the footer says `YOLO: ERROR`, inspect the reported session state file
   manually. Invalid state triggers best-effort blocking and aborts; do not
   bypass the permission system to continue.

If a protected path or command is still blocked in YOLO mode, that is expected
when a `deny` rule matched it. Do not weaken the deny rule merely to make YOLO
work; check whether the path or command is intentionally protected.

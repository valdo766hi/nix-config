#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

cat > "$tmp/managed.json" <<'JSON'
{"model":"test","attribution":{},"statusLine":{"type":"command","command":"/nix/store/current/bin/claude-statusline"},"enabledPlugins":{},"extraKnownMarketplaces":{},"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"/nix/store/current-rtk/bin/rtk hook claude"}]}]}}
JSON
cat > "$tmp/input.json" <<'JSON'
{"custom":true,"hooks":{"PostToolUse":[{"matcher":"Edit","hooks":[]}],"PreToolUse":[{"matcher":"Bash","hooks":[{"command":"/nix/store/old-rtk/bin/rtk hook claude"},{"command":"other-hook"}]},{"matcher":"Bash","hooks":[{"command":"/nix/store/current-rtk/bin/rtk hook claude"}]}]}}
JSON
merge() {
  jq --slurpfile managed "$tmp/managed.json" --from-file merge-settings.jq
}
merge < "$tmp/input.json" > "$tmp/once.json"
merge < "$tmp/once.json" > "$tmp/twice.json"
cmp "$tmp/once.json" "$tmp/twice.json"
jq -e '.custom and .statusLine.type == "command" and (.hooks.PostToolUse | length == 1) and
  ([.hooks.PreToolUse[].hooks[].command] ==
    ["other-hook", "/nix/store/current-rtk/bin/rtk hook claude"])' "$tmp/once.json" > /dev/null
printf '{}\n' | merge | jq -e '.hooks.PreToolUse | length == 1' > /dev/null
if [[ $# -gt 0 ]]; then
  fixture_script="$1"
  for settings in valid invalid missing; do
    fixture="$tmp/$settings"
    mkdir -p "$fixture/.claude"
    case "$settings" in
      valid) printf '{"custom":true}\n' > "$fixture/.claude/settings.json" ;;
      invalid) printf '{invalid\n' > "$fixture/.claude/settings.json" ;;
    esac
    printf '{"custom":true,"mcpServers":{"context7":{},"exa":{},"github":{},"keep":{"url":"https://example.invalid"}}}\n' > "$fixture/.claude.json"
    chmod 600 "$fixture/.claude.json"
    (umask 022; HOME="$fixture" bash "$fixture_script")
    jq -e '.custom and (.mcpServers | keys == ["keep"])' "$fixture/.claude.json" > /dev/null
    if [[ "$settings" == invalid ]]; then
      [[ $(< "$fixture/.claude/settings.json") == '{invalid' ]]
    else
      jq -e '.model and .statusLine.type == "command"' "$fixture/.claude/settings.json" > /dev/null
    fi
    python3 - "$fixture" "$settings" <<'PY'
import pathlib
import stat
import sys
home = pathlib.Path(sys.argv[1])
paths = [home / ".claude.json"]
if sys.argv[2] != "invalid":
    paths.append(home / ".claude/settings.json")
for path in paths:
    assert stat.S_IMODE(path.stat().st_mode) == 0o600, path
assert sorted(p.name for p in home.iterdir()) == [".claude", ".claude.json"]
assert [p.name for p in (home / ".claude").iterdir()] == ["settings.json"]
PY
  done
fi
printf 'Claude settings merge tests passed\n'

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
printf 'Claude settings merge tests passed\n'

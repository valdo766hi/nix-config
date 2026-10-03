#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

render() {
  jq -r --arg branch "${2-main}" --arg home /home/me --argjson width "$1" \
    --from-file statusline.jq | sed 's/\x1b\[[0-9;]*m//g'
}
session='{"workspace":{"current_dir":"/home/me/pi-packages"},"session_name":"Footer extension status indicator","model":{"display_name":"Opus"},"effort":{"level":"high"},
  "context_window":{"total_input_tokens":84000,"context_window_size":200000,"used_percentage":42,"current_usage":{}},
  "prompt_cache":{"hit_ratio":0.91},"cost":{"total_cost_usd":0.5}}'

wide=$(render 80 <<<"$session")
[[ $(sed -n 1p <<<"$wide") =~ ^pi-packages\ ·\ ⎇\ main\ +Opus\ ●\ high$ ]]
[[ $(sed -n 2p <<<"$wide") =~ ^━{10}■─{13}\ \ 42%\ \ 84k/200k\ +◎\ 91%\ \ \$0\.50$ ]]
jq -Rne '[inputs | length] == [80, 80]' <<<"$wide" > /dev/null

# Narrow terminals drop cost, then cache, then the bar.
[[ $(render 35 <<<"$session" | sed -n 2p) =~ ^━+■─*\ \ 42%\ \ 84k/200k\ \ ◎\ 91%$ ]]
[[ $(render 20 <<<"$session" | sed -n 2p) == "42%" ]]

# Before the first response: unknown usage, no head, no stats; home shows as ~.
fresh=$(render 60 "" <<<'{"workspace":{"current_dir":"/home/me"},"model":{"display_name":"Sonnet"},"thinking":{"enabled":false},
  "context_window":{"total_input_tokens":0,"context_window_size":200000,"used_percentage":null,"current_usage":null}}')
[[ $(sed -n 1p <<<"$fresh") =~ ^~\ +Sonnet\ ●\ off$ ]]
[[ $(sed -n 2p <<<"$fresh") == "$(printf '─%.0s' {1..24})  ?%  ?/200k" ]]

printf 'Claude status line tests passed\n'

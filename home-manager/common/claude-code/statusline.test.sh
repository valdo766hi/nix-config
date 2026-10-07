#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

render_json() {
  jq -c --arg branch "${2-main}" --arg home /home/me --argjson width "$1" \
    --argjson previous "${3:-null}" --from-file statusline.jq
}
render() {
  render_json "$@" | jq -r '.lines[]' | sed 's/\x1b\[[0-9;]*m//g'
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

response=$(jq '.context_window.current_usage.output_tokens = 650 | .cost.total_api_duration_ms = 21000' <<<"$session")
sample=$(render_json 80 main '{"api_ms":1000,"speed":null}' <<<"$response")
previous=$(jq -c '.stats' <<<"$sample")
[[ "$previous" == '{"api_ms":21000,"speed":32.5}' ]]
fast=$(render 80 main '{"api_ms":1000,"speed":null}' <<<"$response")
[[ $(sed -n 2p <<<"$fast") == *'◎ 91%  $0.50  ~32.5 tok/s' ]]
jq -Rne '[inputs | length] == [80, 80]' <<<"$fast" > /dev/null
[[ $(render 40 main "$previous" <<<"$response" | sed -n 2p) == *'~32.5 tok/s' ]]
[[ $(render_json 80 main "$previous" <<<"$response" | jq -c '.stats') == "$previous" ]]

next=$(jq '.context_window.current_usage.output_tokens = 100 | .cost.total_api_duration_ms = 24000' <<<"$response")
[[ $(render 80 main "$previous" <<<"$next" | sed -n 2p) == *'~33.3 tok/s' ]]
[[ $(render_json 80 <<<"$response" | jq '.stats.speed') == null ]]
for input in \
  "$session" \
  "$(jq '.cost.total_api_duration_ms = 0' <<<"$response")" \
  "$(jq '.cost.total_api_duration_ms = 1000' <<<"$response")" \
  "$(jq '.context_window.current_usage = null' <<<"$response")"; do
  [[ $(render_json 80 main "$previous" <<<"$input" | jq '.stats.speed') == null ]]
done
[[ -z $(render 7 main "$previous" <<<"$response") ]]

printf 'Claude status line tests passed\n'

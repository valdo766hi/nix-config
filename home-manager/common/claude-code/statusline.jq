# Two-line Claude Code status line modeled on the pi-footer extension: project,
# branch, and model, then the context bar, cache hit rate, cost, and token speed.
# Narrow terminals drop cost, cache, speed, then the bar instead of wrapping.

def seg($t; $c): {t: $t, c: $c};
def plain: map(.t) | add // "";
def cols: plain | length;
def ansi: map(if .c == "" or .t == "" then .t else "\u001b[\(.c)m\(.t)\u001b[0m" end) | add // "";
def gap: [seg("  "; "")];
def joined: map(select(length > 0)) | if length == 0 then [] else reduce .[1:][] as $s (.[0]; . + gap + $s) end;

def tokens:
  def fixed($unit): (. / ($unit / 10) | round) as $n | "\($n / 10 | floor).\($n % 10)";
  if . < 1000 then tostring
  elif . < 10000 then fixed(1000) + "k"
  elif . < 1000000 then "\(. / 1000 | round)k"
  elif . < 10000000 then fixed(1000000) + "M"
  else "\(. / 1000000 | round)M" end;
def money: (. * 100 | round) as $c | "$\($c / 100 | floor).\($c % 100 | tostring | if length < 2 then "0" + . else . end)";
def zone: if . > 90 then "31" elif . > 70 then "33" else "32" end;

# Thin bar with a `■` head at the current usage.
def bar($pct; $cells):
  (if $pct == null then -1 else [$cells - 1, ([[$pct, 0] | max, 100] | min) * $cells / 100 | floor] | min end) as $head
  | (if $head < 0 then [] else [seg(([range($head)] | map("━") | join("")) + "■"; $pct | zone)] end)
  + [seg([range($head + 1; $cells)] | map("─") | join(""); "2")];

# Pad `left` and `right` to the width; drop `right` when it does not fit.
def fit($left; $right; $width):
  ($left | cols) as $lw | ($right | cols) as $rw
  | if $lw >= $width then [seg(($left | plain)[:$width - 1] + "…"; "")]
    elif $rw == 0 or $width - $lw - 2 < $rw then $left
    else $left + [seg([range($width - $lw - $rw)] | map(" ") | join(""); "")] + $right end;

# API time is cumulative, but output tokens belong only to the latest response.
def token_stats($previous):
  (.cost.total_api_duration_ms // 0) as $ms
  | (.context_window.current_usage.output_tokens // 0) as $output
  | {api_ms: $ms, speed:
      (if $output <= 0 or $ms <= 0 or $previous.api_ms == null then null
       elif $ms == $previous.api_ms then $previous.speed
       elif $ms > $previous.api_ms then $output * 1000 / ($ms - $previous.api_ms)
       else null end)};

token_stats($previous) as $stats
| {stats: $stats, lines: [if $width < 8 then empty else
  (.workspace.current_dir // .cwd // "") as $dir
  | ([seg(if $dir == $home then "~" else $dir | split("/") | map(select(. != "")) | last // $dir end; "1")]
    + (if $branch != "" then [seg(" · "; "2"), seg("⎇ \($branch)"; "32")] else [] end)) as $location
  | (.effort.level // (if .thinking.enabled == false then "off" else null end)) as $level
  | ([seg(.model.display_name // "no model"; "36")]
    + (if $level then [seg(" ● \($level)"; {off: "90", low: "34", medium: "36", high: "35", xhigh: "95", max: "91"}[$level] // "2")] else [] end)) as $model

  | .context_window as $cw
  | $cw.used_percentage as $pct
  | (if $pct == null then seg("?%"; "90") else seg("\($pct | round)%"; "1;\($pct | zone)") end) as $percent
  | (if $cw.current_usage == null then "?" else $cw.total_input_tokens | tokens end) as $used
  | (gap + [$percent] + gap + [seg("\($used)/\($cw.context_window_size // 0 | tokens)"; "2")]) as $tail
  | (if .prompt_cache.hit_ratio != null then [seg("◎ \(.prompt_cache.hit_ratio * 100 | round)%"; "2")] else [] end) as $cache
  | (if (.cost.total_cost_usd // 0) > 0 then [seg(.cost.total_cost_usd | money; "90")] else [] end) as $cost
  | (if $stats.speed != null then [seg("~\($stats.speed * 10 | round / 10) tok/s"; "2")] else [] end) as $speed

  | fit($location; $model; $width),
    (first(
      ([$cache, $cost, $speed] | joined), ([$cache, $speed] | joined), $speed, []
      | . as $right
      | ([24, $width - ($tail | cols) - ($right | cols) - 2] | min) as $cells
      | select($cells >= 8)
      | fit(bar($pct; $cells) + $tail; $right; $width)
    ) // [$percent])
  | ansi
end]}

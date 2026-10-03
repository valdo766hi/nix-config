.model = $managed[0].model |
.attribution = ((.attribution // {}) + $managed[0].attribution) |
.enabledPlugins = ((.enabledPlugins // {}) + $managed[0].enabledPlugins) |
.extraKnownMarketplaces = ((.extraKnownMarketplaces // {}) + $managed[0].extraKnownMarketplaces) |
.hooks.PreToolUse = (
  ((.hooks.PreToolUse // []) | map(
    .hooks |= map(select(
      ((.command // "") | test("^/nix/store/[^/]+/bin/rtk hook claude$")) | not
    )) | select(.hooks | length > 0)
  )) + $managed[0].hooks.PreToolUse
)

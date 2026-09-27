{pkgs, ...}: let
  configuredApps = import ../../../pkgs/configured-apps {inherit pkgs; inherit (pkgs) lib;};
  pig = pkgs.callPackage ../../../pkgs/pig {};
in {
  home.packages = [ (configuredApps.mkPiG {package = pig;}) ];

  home.file = {
    ".pig/agent/settings.json".text = builtins.toJSON {
      theme = "catppuccin-mocha";
      tuiMode = "fullscreen";
      defaultProvider = "openai-codex";
      defaultModel = "gpt-6-luna";
      defaultThinkingLevel = "max";
      hideThinkingBlock = true;
      enableInstallTelemetry = false;
      # The Pi permission policy fails registration in PiG 0.2.0. Do not
      # expose unguarded read, shell, or file mutation tools as a fallback.
      defaultTools = [];
    };
    ".pig/agent/APPEND_SYSTEM.md".source = ../agent-instructions.md;
    ".pig/agent/themes/catppuccin-mocha.json".source = ../pi/themes/catppuccin-mocha.json;
  };
}

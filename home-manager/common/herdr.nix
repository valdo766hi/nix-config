{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.herdr = {
    enable = true;
    settings.onboarding = false;
    settings.terminal.default_shell = "fish";
    settings.theme.name = "catppuccin";
  };

  xdg.configFile."herdr-core/config.toml".text = ''
    shell = ["fish"]
  '';

  xdg.configFile."herdr-app/themes/catppuccin-mocha.json".text = builtins.toJSON {
    background = "#1e1e2e";
    foreground = "#cdd6f4";
    selection = "#f5e0dc";
    cursor = "#f5e0dc";
    ansi = [
      "#45475a"
      "#f38ba8"
      "#a6e3a1"
      "#f9e2af"
      "#89b4fa"
      "#f5c2e7"
      "#94e2d5"
      "#bac2de"
      "#585b70"
      "#f38ba8"
      "#a6e3a1"
      "#f9e2af"
      "#89b4fa"
      "#f5c2e7"
      "#94e2d5"
      "#a6adc8"
    ];
    colors.foreground = "#cdd6f4";
  };

  # Keep settings writable so Herdr can still save preferences from its UI.
  home.activation.herdrAppSettings = lib.hm.dag.entryAfter ["linkGeneration"] (
    lib.hm.generators.mkImpureConfigMerger {
      inherit pkgs;
      format = "json";
      empty = "{}";
      jqOperation = "$dynamic * $static";
      path = "${config.xdg.configHome}/herdr-app/settings.json";
      staticSettings = pkgs.writeText "herdr-app-settings.json" (builtins.toJSON {
        font_size = 12;
        theme = "catppuccin-mocha";
        appearance = "dark";
      });
    }
  );
}

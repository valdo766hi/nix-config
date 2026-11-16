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
  };

  xdg.configFile."herdr-core/config.toml".text = ''
    shell = ["fish"]
  '';

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
      });
    }
  );
}

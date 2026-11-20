{
  config,
  lib,
  pkgs,
  ...
}: let
  p = config.palette;
in {
  programs.herdr = {
    enable = true;
    settings.onboarding = false;
    settings.terminal.default_shell = "fish";
    settings.theme.name = "catppuccin";
  };

  # Per-file links: Herdr writes jsconfig.json and .d.ts files into every mod folder.
  # When mutable, Herdr only notices an edit once the link is touched: `touch -h <link>`.
  xdg.configFile =
    lib.listToAttrs (map (file:
      lib.nameValuePair "herdr-app/${lib.removePrefix "./" (lib.path.removePrefix ./herdr-app file)}" {
        source = config.dotfiles.make file;
      })
    (lib.filesystem.listFilesRecursive ./herdr-app))
    // {
      "herdr-core/config.toml".text = ''
        shell = ["fish"]
      '';

      "herdr-app/themes/catppuccin-mocha.json".text = builtins.toJSON {
        background = p.base;
        foreground = p.text;
        selection = p.rosewater;
        cursor = p.rosewater;
        ansi = [
          p.surface1
          p.red
          p.green
          p.yellow
          p.blue
          p.pink
          p.teal
          p.subtext1
          p.surface2
          p.red
          p.green
          p.yellow
          p.blue
          p.pink
          p.teal
          p.subtext0
        ];
        colors.foreground = p.text;
      };
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

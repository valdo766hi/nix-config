{config, pkgs, lib, inputs, ...}: {
  services.vicinae = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    systemd = {
      enable = true;
      autoStart = true;
    };
    settings = {
      favicon_service = "twenty";
      font = {
        normal = {
          size = 11;
        };
      };
      pop_to_root_on_close = false;
      search_files_in_root = false;
      theme = {
        dark = {
          name = "catppuccin-mocha";
        };
      };
      launcher_window = {
        opacity = 0.95;
      };
      extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
        bluetooth
        nix
        power-profile
        ssh
      ];
    };
  };
}

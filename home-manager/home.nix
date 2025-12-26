# My Home-manager config
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # Import other home-manager modules
  imports = [
    # Niri compositor (home-manager module)
    inputs.niri.homeModules.niri

    # DankMaterialShell
    inputs.dankMaterialShell.homeModules.dank-material-shell

    # Zen Browser (using beta module)
    inputs.zen-browser.homeModules.beta

    # NVF Home-Manager module
    inputs.nvf.homeManagerModules.default

    # Vicinae launcher/service
    inputs.vicinae.homeManagerModules.default

    # Custom configurations
    ./niri
    ./fish.nix
    ./git.nix
    ./packages.nix
    ./starship.nix
    ./bat
    ./eza.nix
    ./fzf.nix
    ./zoxide.nix
    ./yazi
    ./atuin.nix
    ./zed.nix
    ./flatpak.nix
    ./winapps
    ./nvf/default.nix
  ];

  # User info
  home = {
    username = "rivaldo";
    homeDirectory = "/home/rivaldo";
  };

  # Programs
  # Zen Browser
  programs.zen-browser.enable = true;

  # WinApps
  programs.winapps = {
    enable = true;
    manageConfigFile = false;
    manageComposeFile = false;
  };

  # DankMaterialShell configuration
  programs.dank-material-shell = {
    enable = true;
    quickshell.package = pkgs.quickshell;

    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
  };

  # Vicinae launcher configuration
  services.vicinae = {
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
    };
    extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
      bluetooth
      nix
      power-profile
      ssh
      # Extension names can be found in https://github.com/vicinaehq/extensions/tree/main/extensions
    ];
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}

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
    # DankMaterialShell
    inputs.dankMaterialShell.homeModules.dankMaterialShell.default

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
    ./winapps
    ./nvf/default.nix
  ];

  # User info
  home = {
    username = "rivaldo";
    homeDirectory = "/home/rivaldo";
  };

  programs.niri.package = inputs.niri.packages."${pkgs.stdenv.hostPlatform.system}".niri-stable;

  # Programs
  programs.home-manager.enable = true;

  # Zen Browser
  programs.zen-browser.enable = true;

  # WinApps
  programs.winapps = {
    enable = true;
    manageConfigFile = false;
    manageComposeFile = false;
  };

  # DankMaterialShell configuration
  programs.dankMaterialShell = {
    enable = true;

    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    enableSystemMonitoring = true;
    enableClipboard = true;
    enableVPN = true;
    enableBrightnessControl = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
    enableSystemSound = false;
  };

  # Vicinae launcher configuration
  services.vicinae = {
    enable = true;
    autoStart = true;
    settings = {
      faviconService = "twenty";
      font.size = 11;
      popToRootOnClose = false;
      rootSearch.searchFiles = false;
      theme.name = "catppuccin-mocha";
      window = {
        csd = true;
        opacity = 0.95;
        rounding = 10;
      };
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}

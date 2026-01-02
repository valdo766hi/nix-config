{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.niri.homeModules.niri
    inputs.dankMaterialShell.homeModules.dank-material-shell
    inputs.zen-browser.homeModules.beta
    inputs.nvf.homeManagerModules.default
    inputs.vicinae.homeManagerModules.default
    ./common/shell.nix
    ./common/git.nix
    ./common/packages.nix
    ./common/starship.nix
    ./common/bat.nix
    ./common/zoxide.nix
    ./common/atuin.nix
    ./common/tmux.nix
    ./nixos/niri.nix
    ./nixos/vicinae.nix
    ./nixos/dank-material-shell.nix
    ./nixos/nvf/default.nix
    ./nixos/winapps.nix
    ./darwin/aerospace.nix
    ./darwin/homebrew.nix
  ];

  home = {
    username = "rivaldo";
    homeDirectory = if pkgs.stdenv.isLinux then "/home/rivaldo" else "/Users/rivaldo";
  };

  programs.zen-browser.enable = true;

  programs.winapps = {
    enable = true;
    manageConfigFile = false;
    manageComposeFile = false;
  };

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
    ];
  };

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "25.05";
}

{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../home.nix
    inputs.zen-browser.homeModules.beta
    ./dank-material-shell.nix
    ./niri/default.nix
    ./noctalia-shell.nix
    ./vicinae.nix
    ./winapps.nix
  ];

  home.homeDirectory = lib.mkDefault "/home/rivaldo";
  home.packages = with pkgs; [
    ghostty
    herdr-desktop
    keepassxc
    obs-studio
    podman-compose
    inputs.sonora.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  programs.zen-browser.enable = true;
  systemd.user.startServices = "sd-switch";
}

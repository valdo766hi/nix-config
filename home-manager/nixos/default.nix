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
    keepassxc
    obs-studio
    podman-compose
  ];
  programs.zen-browser.enable = true;
  systemd.user.startServices = "sd-switch";
}

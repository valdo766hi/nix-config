{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Flake inputs
    inputs.dankMaterialShell.homeModules.dank-material-shell
    inputs.zen-browser.homeModules.beta
    inputs.nvf.homeManagerModules.default
    inputs.vicinae.homeManagerModules.default
    # Common modules (cross-platform)
    ./common/shell.nix
    ./common/git.nix
    ./common/packages.nix
    ./common/starship.nix
    ./common/bat.nix
    ./common/zoxide.nix
    ./common/atuin.nix
    ./common/tmux.nix
    ./common/lazygit.nix
    ./common/eza.nix
    ./common/yazi/default.nix
    ./common/zed.nix
    # NixOS-specific modules (have platform guards)
    ./nixos/niri/default.nix
    ./nixos/vicinae.nix
    ./nixos/dank-material-shell.nix
    ./nixos/nvf/default.nix
    ./nixos/flatpak.nix
  ];

  home = {
    username = "rivaldo";
    homeDirectory = if pkgs.stdenv.isLinux then "/home/rivaldo" else "/Users/rivaldo";
  };

  programs.zen-browser = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  systemd.user.startServices = lib.mkIf pkgs.stdenv.isLinux "sd-switch";

  home.stateVersion = "25.05";
}

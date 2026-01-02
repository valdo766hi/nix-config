{ config, pkgs, lib, ... }:

{
  homebrew = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;

    casks = [
      "ghostty"
      "google-chrome"
      "iterm2"
      "keepassxc"
      "obs"
      "pritunl"
      "telegram"
      "vlc"
      "raycast"
    ];

    brews = [
      "nushell"
      "asdf"
      "wireguard-tools"
      "wireguard-go"
      "sops"
      "helm"
      "acli"
      "codex"
    ];

    taps = [];
  };
}

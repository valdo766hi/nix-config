# My packages
{
  config,
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  winappsPkgs = inputs.winapps.packages.${system};
  antigravityPackage = inputs.antigravity-nix.packages.${system}.default;
in {
  home.packages =
    (with pkgs; [
      # CLI
      home-manager
      neovim
      git
      nil
      nixpkgs-fmt
      nodejs
      ripgrep
      bat
      btop
      fastfetch
      eza
      fd
      fzf
      zoxide
      atuin
      kubectl
      kustomize
      fluxcd
      helm
      sops
      gh
      podman-compose

      # GUI
      alacritty
      fuzzel
      obs-studio
      mpv
      pritunl-client
      keepassxc
      antigravityPackage
      zed-editor
      steam

      # Wayland
      swaylock
      xwayland-satellite
    ])
    ++ [
      winappsPkgs.winapps
      winappsPkgs.winapps-launcher
    ];
}

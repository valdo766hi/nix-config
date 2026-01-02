{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    neovim
    bat
    btop
    pwgen
    zoxide
    yazi
    starship
    atuin
    gh
    kubectl
    fluxcd
    cilium-cli
    kustomize
    podman
    podman-compose
    eza
    fzf
  ];
}

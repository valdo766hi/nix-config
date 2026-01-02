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
    starship
    atuin
    gh
    kubectl
    fluxcd
    cilium-cli
    kustomize
    podman
    podman-compose
    fzf
  ];
}

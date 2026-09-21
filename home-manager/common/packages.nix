{
  pkgs,
  lib,
  ...
}: let
  rtk = pkgs.callPackage ../../pkgs/rtk {};
in {
  home.packages = with pkgs; [
    # CLI
    nushell
    btop
    pwgen
    nodejs
    gh
    kubectl
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
    fluxcd
    cilium-cli
    kustomize
    teleport
    fzf
    kubernetes-helm
    jq
    bun
    python3
    jujutsu
    yq
    sops
    pandoc
    ripgrep
    antigravity-ide
    rtk
    nixd
    fd
    hunk
    tree
    fastfetch
  ] ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    ghostty
    keepassxc
    obs-studio
  ];
}

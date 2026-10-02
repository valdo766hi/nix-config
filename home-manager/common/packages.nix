{
  inputs,
  pkgs,
  ...
}: let
  rtk = pkgs.callPackage ../../pkgs/rtk {};
  antigravityCli = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli;
in {
  home.packages = with pkgs; [
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
    antigravityCli
  ];
}

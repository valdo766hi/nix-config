{pkgs, ...}: {
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
    (teleport_18.override {withRdpClient = false;})
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
    local.rtk
    nixd
    fd
    hunk
    tree
    fastfetch
    llm-agents.antigravity-cli
    ladybird
  ];
}

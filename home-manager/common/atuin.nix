{
  config,
  pkgs,
  ...
}: {
  programs.atuin = {
    enable = true;
    enableFishIntegration = false;
  };
}

{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.winapps.packages.${pkgs.stdenv.hostPlatform.system}.winapps
    inputs.winapps.packages.${pkgs.stdenv.hostPlatform.system}.winapps-launcher
  ];

  xdg.configFile."winapps/compose.yaml" = {
    source = inputs.winapps + "/compose.yaml";
  };
}

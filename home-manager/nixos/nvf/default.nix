{
  pkgs,
  lib,
  ...
}: let
  nvfSettings = import ./settings.nix { inherit pkgs lib; };
in {
  programs.nvf = {
    enable = true;
    enableManpages = true;
    defaultEditor = true;
    settings = nvfSettings;
  };
}

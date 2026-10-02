{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [inputs.nvf.homeManagerModules.default];

  programs.nvf = {
    enable = true;
    enableManpages = true;
    defaultEditor = true;
    settings = import ./settings.nix {inherit inputs pkgs lib;};
  };
}

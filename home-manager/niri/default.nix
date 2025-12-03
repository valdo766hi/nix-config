{
  inputs,
  pkgs,
  ...
}: {
  programs.niri = {
    enable = true;
    package = inputs.niri.packages."${pkgs.stdenv.hostPlatform.system}".niri-unstable;
    config = builtins.readFile ./niri-config.kdl;
  };

  xdg.configFile."niri/dms/binds.kdl" = {
    source = ./dms/binds.kdl;
    force = true;
  };
}

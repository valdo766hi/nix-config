{lib, pkgs, ...}: {
  xdg.configFile."niri/config.kdl" = lib.mkIf pkgs.stdenv.isLinux {
    source = ./niri-config.kdl;
  };
}

{lib, pkgs, ...}: {
  programs.niri = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
  };
}

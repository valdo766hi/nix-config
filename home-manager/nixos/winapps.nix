{lib, pkgs, ...}: {
  programs.winapps = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    manageConfigFile = false;
    manageComposeFile = false;
  };
}

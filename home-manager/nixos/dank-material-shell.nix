{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.dank-material-shell = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    quickshell.package = pkgs.quickshell;

    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
  };
}

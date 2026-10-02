{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.dankMaterialShell.homeModules.dank-material-shell];

  programs.dank-material-shell = {
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

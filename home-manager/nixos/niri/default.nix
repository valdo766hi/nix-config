{pkgs, ...}: {
  # Niri config file - compositor is enabled at NixOS system level
  # The niri.homeModules.config is auto-imported when using HM as NixOS module
  home.packages = with pkgs; [
    brightnessctl
    cliphist
    wireplumber
    wl-clipboard
    xwayland-satellite
  ];

  xdg.configFile."niri/config.kdl" = {
    source = ./niri-config.kdl;
  };
}

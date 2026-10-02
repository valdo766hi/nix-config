{pkgs, ...}: {
  # Niri installation is owned by the NixOS module.
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

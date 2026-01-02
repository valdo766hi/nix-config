{
  pkgs,
  lib,
  ...
}: {
  services.xserver.enable = true;

  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = false;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
    config.common.default = ["wlr" "gtk"];
  };

  programs.firefox.enable = true;
}

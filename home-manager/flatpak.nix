# Flatpak configuration and declarative app installs
{
  lib,
  pkgs,
  ...
}: {
  # Ensure Flathub remote exists
  home.activation.flatpakFlathub = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.flatpak}/bin/flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  '';

  home.activation.flatpakTelegram = lib.hm.dag.entryAfter ["flatpakFlathub"] ''
    ${pkgs.flatpak}/bin/flatpak --user install -y --noninteractive flathub org.telegram.desktop
  '';
}

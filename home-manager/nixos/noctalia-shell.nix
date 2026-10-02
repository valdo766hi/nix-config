{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.noctalia.homeModules.default];

  programs.noctalia = {
    enable = true;
    # DMS remains the default shell; Noctalia can still be started with systemd.
    systemd.enable = true;

    settings.theme = {
      mode = "dark";
      source = "builtin";
      builtin = "Catppuccin";
    };
  };

  # Keep the unit startable manually instead of enabling it by default.
  systemd.user.services.noctalia = {
    Install.WantedBy = lib.mkForce [];
  };
}

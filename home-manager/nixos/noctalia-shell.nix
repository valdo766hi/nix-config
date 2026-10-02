{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.noctalia.homeModules.default];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;

    settings.theme = {
      mode = "dark";
      source = "builtin";
      builtin = "Catppuccin";
    };
  };

  # DMS is the default; keep Noctalia startable manually.
  systemd.user.services.noctalia = {
    Install.WantedBy = lib.mkForce [];
  };
}

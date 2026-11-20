{
  inputs,
  lib,
  pkgs,
  ...
}: let
  caches = import ../../../caches.nix;
in {
  nixpkgs.config.allowUnfree = true;

  nixpkgs.hostPlatform = "aarch64-darwin";

  nix.enable = false;

  # Determinate Nix owns nix.conf because nix.enable is false.
  environment.etc."nix/nix.custom.conf".text = ''
    trusted-users = root
    accept-flake-config = true
    extra-substituters = ${builtins.concatStringsSep " " caches.substituters}
    extra-trusted-public-keys = ${builtins.concatStringsSep " " caches.trustedPublicKeys}
  '';

  # Determinate Nix collects garbage on its own but keeps every generation alive.
  # Prune generations weekly, as nix.gc does on NixOS, and leave collection to it.
  launchd.daemons.nh-clean = {
    command = "${lib.getExe pkgs.nh} clean all --keep 3 --keep-since 7d --no-gc --no-gcroots";
    serviceConfig = {
      StartCalendarInterval = [
        {
          Weekday = 0;
          Hour = 12;
          Minute = 0;
        }
      ];
      StandardOutPath = "/var/log/nh-clean.log";
      StandardErrorPath = "/var/log/nh-clean.log";
    };
  };

  environment.systemPackages = [pkgs.devenv];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.fish.enable = true;
  services.netbird.enable = true;

  system = {
    primaryUser = "rivaldo";
    stateVersion = 6;
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    defaults = {
      dock = {
        autohide = true;
        mru-spaces = false;
      };

      finder = {
        AppleShowAllExtensions = true;
        FXPreferredViewStyle = "clmv";
      };

      screencapture = {
        location = "~/Pictures/screenshots";
      };

      screensaver = {
        askForPasswordDelay = 10;
      };
    };
  };
}

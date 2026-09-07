{
  inputs,
  pkgs,
  ...
}: let
  caches = import ../../../caches.nix;
in {
  imports = [
    inputs.niri.nixosModules.niri
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
      substituters = ["https://cache.nixos.org"] ++ caches.substituters;
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ] ++ caches.trustedPublicKeys;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.networkmanager = {
    enable = true;
    logLevel = "INFO";
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };

  networking.hosts = {
    # Example for adding on /etc/hosts
    # "127.0.0.1" = ["app.test" "api.app.test"];
    # "192.168.1.10" = ["server.test"];
  };

  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.rivaldo = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMJetj70q+Atvrws3WlGgJJrqq4Dvnok5OLHccgwy0Xx rivaldo.silalahi@lintasarta.co.id"
    ];
  };

  programs.firefox.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  # Use nixpkgs' maintained package; the niri-flake package currently expects
  # a removed libdisplay-info compatibility input.
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.steam-hardware.enable = true;
  programs.nm-applet.enable = true;
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
      libffi
      glibc
    ];
  };
  environment.localBinInPath = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };
  services.flatpak.enable = true;
  services.netbird.enable = true;
  services.tailscale.enable = true;

  systemd.packages = [pkgs.pritunl-client];
  systemd.targets.multi-user.wants = ["pritunl-client.service"];

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    alacritty
    openvpn
    pritunl-client
    devenv
    uv
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  system.stateVersion = "25.05";
}

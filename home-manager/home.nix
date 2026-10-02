{...}: {
  imports = [
    ./common/default.nix
  ];

  home.username = "rivaldo";
  xdg.enable = true;

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Avoid generating the Home Manager options manual during every rebuild.
  manual.manpages.enable = false;

  home.stateVersion = "25.05";
}

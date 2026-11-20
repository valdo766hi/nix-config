{lib, ...}: {
  imports = [
    ../home.nix
    ./omniwm
  ];

  home.homeDirectory = lib.mkForce "/Users/rivaldo";
  # The checkout lives at ~/.config/nix here; edits to linked files skip the rebuild.
  dotfiles.mutable = true;
}

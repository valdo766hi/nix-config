{lib, ...}: {
  imports = [
    ../home.nix
    ./omniwm
  ];

  home.homeDirectory = lib.mkForce "/Users/rivaldo";
}

{inputs, lib, ...}: {
  imports = [
    ../home.nix
    ./omniwm
  ];

  home.homeDirectory = lib.mkForce "/Users/rivaldo";
  programs.atuin.package = inputs.nixpkgs-atuin.legacyPackages.aarch64-darwin.atuin;
}

{
  inputs,
  pkgsFor,
}: let
  mkHome = system: module:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor.${system};
      modules = [module];
      extraSpecialArgs = {inherit inputs;};
    };
in {
  "rivaldo@thinker" = mkHome "x86_64-linux" ../home-manager/nixos;
  "rivaldo@Rivaldos-MacBook-Pro" = mkHome "aarch64-darwin" ../home-manager/darwin;
}

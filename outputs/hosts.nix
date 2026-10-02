{inputs}: let
  inherit (inputs) nixpkgs nix-darwin home-manager;
  specialArgs = {inherit inputs;};
  homeManagerModule = module: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-bak";
      users.rivaldo.imports = [module];
      extraSpecialArgs = specialArgs;
    };
  };
in {
  nixosConfigurations.thinker = nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    modules = [
      ../hosts/nixos/thinker/configuration.nix
      home-manager.nixosModules.home-manager
      (homeManagerModule ../home-manager/nixos)
    ];
  };

  darwinConfigurations."Rivaldos-MacBook-Pro" = nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    inherit specialArgs;
    modules = [
      ../hosts/darwin/configuration.nix
      home-manager.darwinModules.home-manager
      (homeManagerModule ../home-manager/darwin)
    ];
  };
}

{
  description = "Rivaldo's Unified NixOS + nix-darwin Configuration";

  nixConfig = {
    "extra-substituters" = [
      "https://vicinae.cachix.org"
      "https://niri.cachix.org"
    ];
    "extra-trusted-public-keys" = [
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    dankMaterialShell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae.url = "github:vicinaehq/vicinae";

    vicinae-extensions.url = "github:vicinaehq/extensions";

    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
    niri,
    zen-browser,
    nvf,
    vicinae,
    vicinae-extensions,
    winapps,
    ...
  } @ inputs: let
    systems = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    nixosConfigurations = {
      thinker = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/nixos/thinker/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.rivaldo = import ./home-manager/home.nix;
              extraSpecialArgs = {inherit inputs;};
            };
          }
        ];
      };
    };

    darwinConfigurations = {
      "Rivaldos-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/darwin/default.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.rivaldo = import ./home-manager/home.nix;
              extraSpecialArgs = {inherit inputs;};
            };
          }
        ];
      };
    };

    nixosModules = {
      desktop = import ./modules/nixos/desktop.nix;
      virtualisation = import ./modules/nixos/virtualisation.nix;
    };

    homeConfigurations = {
      "rivaldo@thinker" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./home-manager/home.nix
        ];
      };
    };
  };
}

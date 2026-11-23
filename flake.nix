{
  description = "Rivaldo's Unified NixOS + nix-darwin Configuration";

  # Keep synchronized with caches.nix; flake nixConfig requires literal values.
  nixConfig = {
    "extra-substituters" = [
      "https://vicinae.cachix.org"
      "https://niri.cachix.org"
      "https://devenv.cachix.org"
    ];
    "extra-trusted-public-keys" = [
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
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

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      # Pinned brew 7.0.11 can't parse homebrew-core's manifest_sha256 bottles (added in 7.0.14).
      # Drop once nix-homebrew pins brew-src >= 7.0.14.
      inputs.brew-src.url = "github:Homebrew/brew/7.0.15";
    };

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    dux-shell = {
      url = "github:duxlabs-dev/dux-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pi = {
      url = "github:earendil-works/pi/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {nixpkgs, ...}: let
    inherit (nixpkgs) lib;
    forAllSystems = lib.genAttrs [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    overlay = import ./overlays {inherit inputs;};
    pkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [overlay];
      });
    homeConfigurations = import ./outputs/home.nix {inherit inputs pkgsFor;};
    homes = {
      "x86_64-linux" = homeConfigurations."rivaldo@thinker";
      "aarch64-darwin" = homeConfigurations."rivaldo@Rivaldos-MacBook-Pro";
    };
  in
    (import ./outputs/hosts.nix {inherit inputs overlay;})
    // {
      inherit homeConfigurations;

      overlays.default = overlay;

      nixosModules = {
        common = ./modules/nixos/common/default.nix;
        desktop = ./modules/nixos/desktop.nix;
        secrets = ./modules/nixos/secrets.nix;
        virtualisation = ./modules/nixos/virtualisation.nix;
      };

      darwinModules = {
        aerospace = ./modules/darwin/aerospace/default.nix;
        common = ./modules/darwin/common/default.nix;
        homebrew = ./modules/darwin/homebrew/default.nix;
        omniwm = ./modules/darwin/omniwm/default.nix;
        secrets = ./modules/darwin/secrets.nix;
      };

      packages = forAllSystems (system:
        import ./outputs/packages.nix {
          inherit inputs;
          pkgs = pkgsFor.${system};
          home = homes.${system};
        });

      formatter = forAllSystems (system: pkgsFor.${system}.alejandra);

      checks = import ./outputs/checks.nix {inherit inputs pkgsFor;};
    };
}

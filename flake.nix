{
  description = "Rivaldo's Unified NixOS + nix-darwin Configuration";

  # Keep synchronized with caches.nix; flake nixConfig requires literal values.
  nixConfig = {
    "extra-substituters" = [
      "https://cachix.cachix.org"
      "https://vicinae.cachix.org"
      "https://niri.cachix.org"
      "https://devenv.cachix.org"
    ];
    "extra-trusted-public-keys" = [
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
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

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    systems = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    forAllSystems = lib.genAttrs systems;
    specialArgs = {inherit inputs;};
    mkPkgs = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    commonHomeModules = [./home-manager/home.nix];
    linuxHomeModules =
      commonHomeModules
      ++ [
        # Note: niri home module is provided via NixOS module integration
        inputs.dankMaterialShell.homeModules.dank-material-shell
        inputs.noctalia.homeModules.default
        inputs.zen-browser.homeModules.beta
        inputs.nvf.homeManagerModules.default
        inputs.vicinae.homeManagerModules.default
        ./home-manager/nixos/default.nix
      ];
    darwinHomeModules =
      commonHomeModules
      ++ [
        inputs.nvf.homeManagerModules.default
        ./home-manager/darwin/default.nix
      ];
    mkHomeManagerModule = modules: {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "hm-bak";
        users.rivaldo.imports = modules;
        extraSpecialArgs = specialArgs;
      };
    };
    mkHomeConfiguration = {
      system,
      modules,
    }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs system;
        inherit modules;
        extraSpecialArgs = specialArgs;
      };
    homeConfigurations = {
      "rivaldo@thinker" = mkHomeConfiguration {
        system = "x86_64-linux";
        modules = linuxHomeModules;
      };
      "rivaldo@Rivaldos-MacBook-Pro" = mkHomeConfiguration {
        system = "aarch64-darwin";
        modules = darwinHomeModules;
      };
    };
  in {
    nixosConfigurations = {
      thinker = lib.nixosSystem {
        inherit specialArgs;
        modules = [
          ./hosts/nixos/thinker/configuration.nix
          home-manager.nixosModules.home-manager
          (mkHomeManagerModule linuxHomeModules)
        ];
      };
    };

    darwinConfigurations = {
      "Rivaldos-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        inherit specialArgs;
        modules = [
          ./hosts/darwin/configuration.nix
          home-manager.darwinModules.home-manager
          (mkHomeManagerModule darwinHomeModules)
        ];
      };
    };

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
      let
        pkgs = mkPkgs system;
        home = {
          "x86_64-linux" = homeConfigurations."rivaldo@thinker";
          "aarch64-darwin" = homeConfigurations."rivaldo@Rivaldos-MacBook-Pro";
        }.${system};
        configuredApps = import ./pkgs/configured-apps {inherit lib pkgs;};
        rtk = pkgs.callPackage ./pkgs/rtk {};
      in {
        inherit rtk;
        home-manager = home-manager.packages.${system}.home-manager;
        default = rtk;
        neovim = configuredApps.mkNeovim {
          package = home.config.programs.nvf.finalPackage;
        };
        yazi = configuredApps.mkYazi {
          package = home.config.programs.yazi.package;
          yaziToml = home.config.xdg.configFile."yazi/yazi.toml".source;
          themeToml = home.config.xdg.configFile."yazi/theme.toml".source;
        };
        lazygit = configuredApps.mkLazygit {
          package = pkgs.lazygit;
          configFile = home.config.xdg.configFile."lazygit/config.yml".source;
        };
        pi = configuredApps.mkPi {
          package = home.config.programs."pi-coding-agent".package;
        };
      });

    checks.x86_64-linux = {
      configurations = let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in
        assert self.nixosConfigurations.thinker.config.system.build.toplevel.drvPath != "";
        assert self.darwinConfigurations."Rivaldos-MacBook-Pro".system.drvPath != "";
        pkgs.runCommand "check-configurations" {} "touch $out";
      inherit (self.packages.x86_64-linux) rtk neovim yazi lazygit pi;

      home-profile = self.homeConfigurations."rivaldo@thinker".activationPackage;

      pi-fast-extension =
        nixpkgs.legacyPackages.x86_64-linux.callPackage
        ./home-manager/common/pi/extensions/fast/check.nix {};

      pi-tools =
        nixpkgs.legacyPackages.x86_64-linux.callPackage
        ./home-manager/common/pi/check.nix {};
    };

    inherit homeConfigurations;

  };
}

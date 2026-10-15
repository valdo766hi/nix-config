{
  description = "Portable Pi coding agent configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pi = {
      url = "github:earendil-works/pi/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {nixpkgs, ...}: {
    packages = nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-darwin"] (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pi = import ./. {inherit inputs pkgs;};
    in {
      inherit pi;
      inherit (pkgs) herdr;
      default = pi;
    });
  };
}

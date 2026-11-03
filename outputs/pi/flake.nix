{
  description = "Portable Pi coding agent configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pi = {
      # Pi 1.4.0; 1.5.0 has an incomplete Nix install lockfile.
      url = "github:earendil-works/pi/d5b3de22d0e24a3e9c38a9410d3329b099717283";
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

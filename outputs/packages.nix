{
  inputs,
  pkgs,
  home,
}: let
  inherit (pkgs) lib;
  inherit (pkgs.stdenv.hostPlatform) system;
  configuredApps = import ../pkgs/configured-apps {inherit lib pkgs;};
  rtk = pkgs.callPackage ../pkgs/rtk {};
in {
  inherit rtk;
  home-manager = inputs.home-manager.packages.${system}.home-manager;
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
  pig = configuredApps.mkPiG {
    package = pkgs.callPackage ../pkgs/pig {};
  };
}

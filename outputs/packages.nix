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
    package = home.config.programs.lazygit.package;
    configFile = home.config.home.file."${home.config.xdg.configHome}/lazygit/config.yml".source;
  };
  pi = configuredApps.mkPi {
    inherit (home.config.programs.pi-coding-agent) package settings;
    agentFiles = (lib.mapAttrs' (name: file:
      lib.nameValuePair (lib.removePrefix ".pi/agent/" name) file.source
    ) (lib.filterAttrs (name: _: lib.hasPrefix ".pi/agent/" name) home.config.home.file)) // {
      "extensions/pi-permission-system/config.json" = pkgs.writeText "pi-portable-permissions.json"
        (lib.replaceStrings ["~/.pi/agent"] ["~/.pi/nix-config/agent"]
          (builtins.readFile home.config.home.file.".pi/agent/extensions/pi-permission-system/config.json".source));
    };
    compactionRatio = (builtins.fromJSON home.config.home.file.".pi/agent/openai-server-compaction.json".text).thresholdRatio;
    runtimeInputs = [rtk] ++ builtins.filter (package:
      builtins.elem (lib.getName package) ["pi-tmp-rm" "skill-sec-check.sh" "plannotator"]
    ) home.config.home.packages;
  };
  pig = configuredApps.mkPiG {
    package = pkgs.callPackage ../pkgs/pig {};
  };
}

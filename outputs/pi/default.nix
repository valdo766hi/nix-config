{
  inputs,
  pkgs,
}: let
  inherit (pkgs) lib;
  home = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      ../../home-manager/common/pi
      {
        home.username = "rivaldo";
        home.homeDirectory = "/home/rivaldo";
        home.stateVersion = "25.05";
      }
    ];
    extraSpecialArgs = {inherit inputs;};
  };
  configuredApps = import ../../pkgs/configured-apps {inherit lib pkgs;};
in
  configuredApps.mkPi {
    inherit (home.config.programs.pi-coding-agent) package settings;
    agentFiles = (lib.mapAttrs' (name: file:
      lib.nameValuePair (lib.removePrefix ".pi/agent/" name) file.source
    ) (lib.filterAttrs (name: _: lib.hasPrefix ".pi/agent/" name) home.config.home.file)) // {
      "extensions/pi-permission-system/config.json" = pkgs.writeText "pi-portable-permissions.json"
        (lib.replaceStrings ["~/.pi/agent"] ["~/.pi/nix-config/agent"]
          (builtins.readFile home.config.home.file.".pi/agent/extensions/pi-permission-system/config.json".source));
    };
    compactionRatio = (builtins.fromJSON home.config.home.file.".pi/agent/openai-server-compaction.json".text).thresholdRatio;
    runtimeInputs = [(pkgs.callPackage ../../pkgs/rtk {})]
      ++ builtins.filter (package: builtins.elem (lib.getName package) ["skill-sec-check.sh" "pi-tmp-rm"]) home.config.home.packages
      ++ [(pkgs.callPackage ../../pkgs/plannotator {})];
  }

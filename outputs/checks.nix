{inputs}: let
  inherit (inputs) self;
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  home = self.homeConfigurations."rivaldo@thinker";
  files = home.config.home.file;

in {
  x86_64-linux = {
    configurations = assert self.nixosConfigurations.thinker.config.system.build.toplevel.drvPath != "";
    assert self.darwinConfigurations."Rivaldos-MacBook-Pro".system.drvPath != "";
      pkgs.runCommand "check-configurations" {} "touch $out";

    inherit (self.packages.x86_64-linux) rtk neovim yazi lazygit pi pig;

    pig-config = pkgs.runCommand "check-pig-config" {nativeBuildInputs = [pkgs.jq];} ''
      jq -e '.defaultTools == [] and .theme == "catppuccin-mocha" and .defaultProvider == "openai-codex"' ${files.".pig/agent/settings.json".source} > /dev/null
      jq -e '.name == "catppuccin-mocha"' ${files.".pig/agent/themes/catppuccin-mocha.json".source} > /dev/null
      test -s ${files.".pig/agent/APPEND_SYSTEM.md".source}
      touch $out
    '';

    home-profile = home.activationPackage;

    pi-fast-extension = pkgs.callPackage ../home-manager/common/pi/extensions/fast/check.nix {};
    pi-tools = pkgs.callPackage ../home-manager/common/pi/check.nix {};
  };
}

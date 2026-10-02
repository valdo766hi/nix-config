{inputs}: let
  inherit (inputs) self;
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  home = self.homeConfigurations."rivaldo@thinker";
  files = home.config.home.file;
  nushellTests = pkgs.lib.mapAttrsToList (name: profile:
    pkgs.writeText "nushell-${name}.nu" ''
      use std/assert
      source ${pkgs.writeText "nushell-env-${name}.nu" profile.config.programs.nushell.envFile.text}

      let npmBin = ($env.HOME | path join ".npm-global" "bin")
      $env.PATH = ["/usr/bin"]
      _path_prepend $npmBin
      _path_prepend $npmBin
      assert equal $env.PATH [$npmBin "/usr/bin"]

      $env.PATH = "/usr/bin"
      _path_prepend $npmBin
      assert equal $env.PATH [$npmBin "/usr/bin"]

      $env.PATH = ""
      _path_prepend $npmBin
      _path_prepend ($env.HOME | path join "missing")
      assert equal $env.PATH [$npmBin]

      assert (nu-check --debug ${pkgs.writeText "nushell-config-${name}.nu"
        profile.config.home.file."${profile.config.xdg.configHome}/nushell/config.nu".text})
    '')
  self.homeConfigurations;
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

    nushell-config = pkgs.runCommand "check-nushell-config" {nativeBuildInputs = [pkgs.nushell];} ''
      export HOME="$TMPDIR/home"
      mkdir -p "$HOME/.npm-global/bin"
      for script in ${toString nushellTests}; do
        nu --no-config-file "$script"
      done
      touch $out
    '';

    home-profile = home.activationPackage;

    pi-fast-extension = pkgs.callPackage ../home-manager/common/pi/extensions/fast/check.nix {};
    pi-tools = pkgs.callPackage ../home-manager/common/pi/check.nix {};
  };
}

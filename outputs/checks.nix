{inputs}: let
  inherit (inputs) self;
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  home = self.homeConfigurations."rivaldo@thinker";
  files = home.config.home.file;
  nushellTests = testPkgs:
    testPkgs.lib.mapAttrsToList (name: profile:
      testPkgs.writeText "nushell-${name}.nu" ''
        use std/assert
        source ${testPkgs.writeText "nushell-env-${name}.nu" profile.config.programs.nushell.envFile.text}

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

        assert (nu-check --debug ${testPkgs.writeText "nushell-config-${name}.nu"
          profile.config.home.file."${profile.config.programs.nushell.configDir}/config.nu".text})
      '')
    self.homeConfigurations;
  mkNushellCheck = system: let
    testPkgs = inputs.nixpkgs.legacyPackages.${system};
    profile =
      self.homeConfigurations."rivaldo@${
        if testPkgs.stdenv.hostPlatform.isDarwin
        then "Rivaldos-MacBook-Pro"
        else "thinker"
      }";
    cfg = profile.config;
    configFiles = cfg.home.file;
    startupTest = testPkgs.writeText "nushell-startup.nu" ''
      use std/assert
      assert equal $env.STARSHIP_SHELL "nu" "Starship was not initialized"
      assert equal ($env.PROMPT_COMMAND | describe) "closure" "Missing Starship prompt"
      assert equal $env.NPM_CONFIG_PREFIX ($env.HOME | path join ".npm-global") "env.nu was not loaded"
      assert equal (which z | get 0.type) "alias" "Zoxide was not initialized"
      assert ((do $env.PROMPT_COMMAND | ansi strip | str trim) != "")
      print "nushell startup test passed"
    '';
  in
    testPkgs.runCommand "check-nushell-config" {
      nativeBuildInputs = [testPkgs.nushell cfg.programs.atuin.package cfg.programs.zoxide.package];
    } ''
      export HOME="$TMPDIR/home"
      export XDG_CONFIG_HOME="$HOME/.config"
      export XDG_DATA_HOME="$HOME/.local/share"
      export STARSHIP_CONFIG="$HOME/starship.toml"
      export TERM=xterm-256color
      mkdir -p "$HOME/.npm-global/bin" "$XDG_CONFIG_HOME/nushell"
      printf 'format = "$character"\n' > "$STARSHIP_CONFIG"
      cp ${configFiles."${cfg.programs.nushell.configDir}/config.nu".source} "$XDG_CONFIG_HOME/nushell/config.nu"
      cp ${configFiles."${cfg.programs.nushell.configDir}/env.nu".source} "$XDG_CONFIG_HOME/nushell/env.nu"
      ${cfg.home.activation.nushellInit.data}

      ${testPkgs.lib.optionalString testPkgs.stdenv.hostPlatform.isDarwin ''
        fallback="$HOME/Library/Application Support/nushell"
        mkdir -p "$fallback/vendor"
        cp ${configFiles."Library/Application Support/nushell/config.nu".source} "$fallback/config.nu"
        cp ${configFiles."Library/Application Support/nushell/env.nu".source} "$fallback/env.nu"
        test "$(readlink ${configFiles."Library/Application Support/nushell/vendor/autoload".source})" = "${cfg.xdg.dataHome}/nushell/vendor/autoload"
        ln -s "$XDG_DATA_HOME/nushell/vendor/autoload" "$fallback/vendor/autoload"
        # Test startup without trying to read the host's sops-managed secrets.
        substituteInPlace "$XDG_CONFIG_HOME/nushell/config.nu" "$fallback/config.nu" \
          --replace-fail '"/run/secrets/rendered/shell-secrets"' '"~/.config/shell-secrets.env"'
      ''}

      for script in ${toString (nushellTests testPkgs)}; do
        nu --no-config-file "$script"
      done
      nu --no-history --execute 'try { source ${startupTest}; exit 0 } catch {|err| print --stderr $err.msg; exit 1 }'
      env -u XDG_CONFIG_HOME -u XDG_DATA_HOME nu --no-history --execute 'try { source ${startupTest}; exit 0 } catch {|err| print --stderr $err.msg; exit 1 }'
      touch $out
    '';
  mkPiCheck = system: let
    testPkgs = inputs.nixpkgs.legacyPackages.${system};
  in testPkgs.runCommand "check-pi-config" {nativeBuildInputs = [testPkgs.python3];} ''
    python ${../pkgs/configured-apps/pi-smoke-test.py} ${self.packages.${system}.pi}/bin/pi
    touch $out
  '';
  mkNeovimCheck = system:
    inputs.nixpkgs.legacyPackages.${system}.runCommand "check-neovim-config" {} ''
      export HOME="$TMPDIR/home"
      export XDG_CONFIG_HOME="$HOME/.config"
      export XDG_DATA_HOME="$HOME/.local/share"
      export XDG_STATE_HOME="$HOME/.local/state"
      export XDG_CACHE_HOME="$HOME/.cache"
      mkdir -p "$HOME"
      cd "$HOME"
      ${self.packages.${system}.neovim}/bin/nvim --headless \
        -c "luafile ${../home-manager/common/nvf/smoke-test.lua}"
      touch $out
    '';
in {
  aarch64-darwin = {
    pi-config = mkPiCheck "aarch64-darwin";
    neovim-config = mkNeovimCheck "aarch64-darwin";
    nushell-config = mkNushellCheck "aarch64-darwin";
  };

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

    nushell-config = mkNushellCheck "x86_64-linux";

    neovim-config = mkNeovimCheck "x86_64-linux";

    home-profile = home.activationPackage;

    pi-fast-extension = pkgs.callPackage ../home-manager/common/pi/extensions/fast/check.nix {};
    pi-tools = pkgs.callPackage ../home-manager/common/pi/check.nix {};
    pi-config = mkPiCheck "x86_64-linux";
  };
}

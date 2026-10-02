{
  config,
  pkgs,
  lib,
  ...
}: {
  # Keep the existing vendor autoload files as the single integration owner.
  home.shell.enableNushellIntegration = false;
  programs.nushell.enable = true;
  programs.nushell.shellAliases = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    bjg = ''echo "I use NixOS, BTW"'';
  };

  # macOS uses these paths when the launching shell has no XDG variables.
  home.file = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
    "Library/Application Support/nushell/config.nu".source =
      config.home.file."${config.programs.nushell.configDir}/config.nu".source;
    "Library/Application Support/nushell/env.nu".source =
      config.home.file."${config.programs.nushell.configDir}/env.nu".source;
    "Library/Application Support/nushell/vendor/autoload".source =
      config.lib.file.mkOutOfStoreSymlink "${config.xdg.dataHome}/nushell/vendor/autoload";
  };

  home.activation.nushellInit = lib.hm.dag.entryAfter ["writeBoundary"] ''
    set -euo pipefail

    mkdir -p "$HOME/.config/nushell" "$HOME/.local/share/nushell/vendor/autoload"

    ${pkgs.starship}/bin/starship init nu > "$HOME/.local/share/nushell/vendor/autoload/starship.nu"
    ${pkgs.atuin}/bin/atuin init nu > "$HOME/.local/share/nushell/vendor/autoload/atuin.nu"
    ${pkgs.zoxide}/bin/zoxide init nushell > "$HOME/.local/share/nushell/vendor/autoload/zoxide.nu"
  '';

  programs.nushell.envFile.text = ''
    $env.TERM = "xterm-256color"

    def --env _path_prepend [p: string] {
      if not ($p | path exists) {
        return
      }

      let current = ($env.PATH? | default [])
      let parts = if ($current | describe) == "string" {
        if $current == "" { [] } else { $current | split row (char esep) }
      } else {
        $current
      }
      $env.PATH = ($parts | prepend $p | uniq)
    }

    _path_prepend ($env.HOME | path join ".npm-global" "bin")
    $env.NPM_CONFIG_PREFIX = ($env.HOME | path join ".npm-global")

    ${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
      _path_prepend "/opt/homebrew/sbin"
      _path_prepend "/opt/homebrew/bin"

      if ("/opt/homebrew" | path exists) {
        $env.HOMEBREW_PREFIX = "/opt/homebrew"
        $env.HOMEBREW_CELLAR = "/opt/homebrew/Cellar"
        $env.HOMEBREW_REPOSITORY = "/opt/homebrew"
      }
    ''}
  '';

  programs.nushell.configFile.text = ''
    const secrets = "${
      if pkgs.stdenv.hostPlatform.isLinux
      then "~/.config/shell-secrets.env"
      else "/run/secrets/rendered/shell-secrets"
    }"

    def --env envsource [file: path] {
      if not ($file | path exists) {
        error make { msg: $"envsource: file not found: ($file)" }
      }

      for l in (open $file | lines) {
        let line = ($l | str trim)
        if ($line == "" or ($line | str starts-with "#")) {
          continue
        }

        let cleaned = (
          if ($line | str starts-with "export ") {
            $line | str replace -r '^export[ \t]+' ""
          } else {
            $line
          }
        )

        let m = ($cleaned | parse -r '^(?P<key>[A-Za-z_][A-Za-z0-9_]*)=(?P<value>.*)$')
        if ($m | is-empty) {
          continue
        }

        let key = ($m.0.key | str trim)
        let raw = ($m.0.value | str trim | str replace -r ';$' "")
        let val = (
          $raw
          | str replace -r '^"(.*)"$' '$1'
          | str replace -r "^'(.*)'$" '$1'
        )

        load-env { ($key): $val }
      }

      print $"Sourced ($file)"
    }

    if ($secrets | path exists) {
      envsource $secrets | ignore
    }

    def --env rebuild [] {
      cd ($env.HOME | path join ".config" "nix")
      ${
      if pkgs.stdenv.hostPlatform.isLinux
      then "sudo nixos-rebuild switch --flake .#thinker"
      else "sudo darwin-rebuild switch --flake .#Rivaldos-MacBook-Pro"
    }
    }

    def --env update-flake [] {
      cd ($env.HOME | path join ".config" "nix")
      nix flake update
    }
  '';
}

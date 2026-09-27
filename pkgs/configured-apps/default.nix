{
  lib,
  pkgs,
}:
let
  withMainProgram = package: mainProgram:
    package.overrideAttrs (old: {
      meta = (old.meta or {}) // {inherit mainProgram;};
    });

  mkConfigDir = {name, files}:
    pkgs.runCommand name {} ''
      mkdir -p "$out"
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (fileName: source: ''
        install -Dm444 "${source}" "$out/${fileName}"
      '') files)}
    '';
in {
  mkNeovim = {package}: withMainProgram package "nvim";

  mkYazi = {
    package,
    yaziToml,
    themeToml,
  }:
    let
      configDir = mkConfigDir {
        name = "yazi-configured";
        files = {
          "theme.toml" = themeToml;
          "yazi.toml" = yaziToml;
        };
      };
    in
      pkgs.symlinkJoin {
        name = "yazi-configured";
        paths = [package];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram "$out/bin/yazi" \
            --set YAZI_CONFIG_HOME "${configDir}"
        '';
        meta = (package.meta or {}) // {mainProgram = "yazi";};
      };

  mkLazygit = {
    package,
    configFile,
  }:
    pkgs.symlinkJoin {
      name = "lazygit-configured";
      paths = [package];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram "$out/bin/lazygit" \
          --add-flags "--use-config-file=${configFile}"
      '';
      meta = (package.meta or {}) // {mainProgram = "lazygit";};
    };

  mkPi = {package}: withMainProgram package "pi";

  mkPiG = {package}: pkgs.writeShellApplication {
    name = "pig";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      exec env -i \
        HOME="$HOME" \
        PIG_HOME="$HOME/.pig" \
        PATH="$PATH" \
        TERM="''${TERM:-xterm-256color}" \
        LANG="''${LANG:-}" \
        LC_ALL="''${LC_ALL:-}" \
        XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}" \
        XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}" \
        XDG_STATE_HOME="''${XDG_STATE_HOME:-$HOME/.local/state}" \
        XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}" \
        XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-}" \
        DBUS_SESSION_BUS_ADDRESS="''${DBUS_SESSION_BUS_ADDRESS:-}" \
        CONTEXT7_API_KEY="''${CONTEXT7_API_KEY:-}" \
        EXA_API_KEY="''${EXA_API_KEY:-}" \
        OPENCODE_API_KEY="''${OPENCODE_GO_API_KEY:-}" \
        PI_TELEMETRY=0 \
        ${package}/bin/pig "$@"
    '';
  };
}

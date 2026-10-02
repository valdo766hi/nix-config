{inputs, pkgs, ...}: let
  piPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi;

  # Pi is launched from shells that contain provider and Git credentials. Keep
  # only the credentials required by the configured MCP servers and providers.
  piLauncher = pkgs.writeShellApplication {
    name = "pi";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      exec env -i \
        HOME="$HOME" \
        TMPDIR=/tmp \
        SSH_AUTH_SOCK="''${SSH_AUTH_SOCK:-}" \
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
        TYPESAFE_API_KEY="''${TYPESAFE_API_KEY:-}" \
        OPENCODE_API_KEY="''${OPENCODE_GO_API_KEY:-}" \
        ${piPackage}/bin/pi "$@"
    '';
  };

  skillSecCheck = pkgs.writeShellApplication {
    name = "skill-sec-check.sh";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
      jq
      trivy
    ];
    text = builtins.readFile ./scripts/skill-sec-check.sh;
  };
  piTmpRm = pkgs.writeShellApplication {
    name = "pi-tmp-rm";
    text = ''
      exec ${pkgs.python3}/bin/python3 -I ${./scripts/pi-tmp-rm.py} "$@"
    '';
  };
in {
  imports = [ ./subagent ];

  home.packages = [skillSecCheck piTmpRm];

  home.file = {
    # The flake-provided Pi is a standalone binary, so keep subagents in-process.
    ".pi/agent/extensions/subagent/config.json".text = builtins.toJSON {
      asyncByDefault = false;
    };
    ".pi/agent/extensions/rtk.ts".source = ./extensions/rtk/rtk.ts;
    ".pi/agent/extensions/pi-permission-system/config.json" = {
      source = ./extensions/pi-permission-system/config.json;
      force = true;
    };
    ".pi/agent/plannotator.json".source = ./extensions/plannotator/config.json;
    ".pi/agent/pi-fff.json".text = builtins.toJSON {mode = "override";};
    ".pi/agent/lazy-skill.json".text = builtins.toJSON {
      routing = "adaptive";
    };
    ".local/bin/pi-package-security-check" = {
      source = ./scripts/pi-package-security-check;
      executable = true;
    };
    ".local/bin/pi-package-update" = {
      source = ./scripts/pi-package-update;
      executable = true;
    };
    ".pi/agent/themes/catppuccin-mocha.json".source = ./themes/catppuccin-mocha.json;
    ".pi/agent/APPEND_SYSTEM.md".source = ../agent-instructions.md;
  };

  # Trial of Pi's built-in MCP; restore pi-mcp-adapter by re-enabling its
  # package pin, -builtin:mcp, and ~/.config/mcp/mcp.json with these servers.
  home.file.".pi/agent/mcp.json".text = builtins.toJSON {
    mcpServers = {
      context7 = {
        url = "https://mcp.context7.com/mcp";
        headers.Authorization = "Bearer \${CONTEXT7_API_KEY}";
        description = "Current library and framework documentation";
      };

      exa = {
        url = "https://mcp.exa.ai/mcp";
        headers."x-api-key" = "\${EXA_API_KEY}";
        description = "Web search and page content";
      };
    };
  };

  programs.pi-coding-agent = {
    enable = true;
    package = piLauncher;

    settings = {
      theme = "catppuccin-mocha";
      tuiMode = "fullscreen";
      fullscreenExitOutput = "resume-hint";
      defaultProvider = "openai-codex";
      defaultModel = "gpt-6-luna";
      hideThinkingBlock = true;
      defaultThinkingLevel = "max";
      defaultTools = ["+codemode"];
      packages = [
        "npm:pi-lens@4.3.0"
        # npm:pi-mcp-adapter@5.0.0 (unquoted so pi-package-update skips it)
        "git:github.com/algal/pi-openai-server-compaction@8a3de2f3b0c178fdd6f73f2f94172dfc3943e466"
        "npm:@plannotator/pi-extension@0.27.25"
        "npm:pi-subagents@0.74.0"
        "npm:@gotgenes/pi-permission-system@37.0.0"
        "npm:@valdo766hi/pi-fast@0.1.2"
        "npm:@valdo766hi/pi-footer@0.2.0"
        "npm:@valdo766hi/pi-yolo@0.1.6"
        "npm:@valdo766hi/pi-lazy-skill-tool@0.3.0"
        "npm:@mtrojnar/pi-usage@0.2.0"
        "npm:@ff-labs/pi-fff@0.11.0"
      ];
    };
  };
}

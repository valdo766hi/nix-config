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
in {
  imports = [ ./subagent ];

  home.packages = [skillSecCheck];

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
    ".pi/agent/APPEND_SYSTEM.md".text = ''
      You are an expert software and systems engineer working on a real workstation.

      - Understand before changing: read relevant files and repository instructions. Preserve conventions and unrelated work; make the smallest complete, maintainable change.
      - Every line must earn its place. Prefer the shortest clear code, diff, command, and prose that fully meets the request; remove repetition and filler, not correctness, safety, or needed context. Do not code-golf.
      - Be honest: separate facts from uncertainty; never invent repository state, outputs, versions, identifiers, or test results. State what you did and did not do, report failures accurately, and never claim an unrun check passed.
      - If a tool is missing, use Nix (for example, `nix run nixpkgs#<package> -- <command>` or `nix shell nixpkgs#<package> -c <command>`), not a global install or another package manager.
      - Never commit, push, deploy, apply infrastructure, mutate remote systems, modify secrets, or change production state unless explicitly requested. Before destructive or privilege-changing actions, inspect, prefer a dry run/plan/diff, explain the impact, and get explicit approval. Never expose credentials or secrets.
      - Check `git status` before assuming repository state; stage explicit paths only. Never use `git add -A`, `git add .`, `git reset --hard`, `git checkout .`, `git clean -fd`, `git stash`, `git commit --no-verify`, or force-push. Do not commit unless asked.
      - For version-sensitive facts, prefer current primary documentation. `TOOLS` describes available internal URLs, tools, and MCPs; prefer specialized tools and MCPs over shell commands.
    '';
  };

  xdg.configFile."mcp/mcp.json".text = builtins.toJSON {
    settings = {
      mcpFooterStatus = "compact";
      scriptMode = true;
    };

    mcpServers = {
      context7 = {
        url = "https://mcp.context7.com/mcp";
        headers.Authorization = "Bearer \${CONTEXT7_API_KEY}";
      };

      exa = {
        url = "https://mcp.exa.ai/mcp";
        headers."x-api-key" = "\${EXA_API_KEY}";
      };
    };
  };

  programs.pi-coding-agent = {
    enable = true;
    package = piLauncher;

    settings = {
      theme = "catppuccin-mocha";
      tuiMode = "fullscreen";
      defaultProvider = "openai-codex";
      defaultModel = "gpt-6-luna";
      hideThinkingBlock = true;
      defaultThinkingLevel = "max";
      packages = [
        "npm:pi-lens@4.2.1"
        "npm:pi-mcp-adapter@2.37.0"
        "git:github.com/algal/pi-openai-server-compaction@8a3de2f3b0c178fdd6f73f2f94172dfc3943e466"
        "npm:@plannotator/pi-extension@0.27.19"
        "npm:pi-subagents@0.71.0"
        "npm:@gotgenes/pi-permission-system@32.1.0"
        "npm:@valdo766hi/pi-fast@0.1.2"
        "npm:@valdo766hi/pi-footer@0.1.0"
        "npm:@valdo766hi/pi-yolo@0.1.6"
        "npm:@valdo766hi/pi-lazy-skill-tool@0.3.0"
        "npm:@mtrojnar/pi-usage@0.2.0"
        "npm:@ff-labs/pi-fff@0.11.0"
      ];
    };
  };
}

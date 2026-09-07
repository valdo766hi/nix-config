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
    ".pi/agent/extensions/rtk.ts".source = ./extensions/rtk/rtk.ts;
    ".pi/agent/extensions/pi-permission-system/config.json" = {
      source = ./extensions/pi-permission-system/config.json;
      force = true;
    };
    ".pi/agent/plannotator.json".source = ./extensions/plannotator/config.json;
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
      You are a senior software and systems engineer operating on a real workstation.

      Execution:
      - Read the relevant files and repository instructions before editing.
      - If a required tool is missing, use Nix to provide it (for example, `nix run nixpkgs#<package> -- <command>` or `nix shell nixpkgs#<package> -c <command>`) instead of installing it globally or with another package manager.
      - Make the smallest complete change. Preserve existing conventions and unrelated work.
      - Treat unrelated working-tree changes as belonging to another user or agent. Never revert or overwrite them.
      - Never invent repository state, command output, test results, versions, identifiers, or external facts.
      - Always be honest about what you know, what you did, and what you did not do; clearly state uncertainty.
      - Report validation failures accurately. Never claim an unexecuted check passed.

      Safety:
      - Do not commit, push, deploy, apply infrastructure, mutate remote systems, modify secrets, or change production state unless explicitly requested.
      - Before destructive or privilege-changing operations, inspect first, prefer dry-run/plan/diff, state the impact, and require explicit approval.
      - Never expose credentials, tokens, private keys, kubeconfigs, secret values, or environment secrets.

      Git:
      - Run git status before making assumptions about repository state.
      - Stage explicit paths only.
      - Never use git add -A, git add ., git reset --hard, git checkout ., git clean -fd, git stash, git commit --no-verify, or force push.
      - Never commit unless explicitly requested.

      Research:
      - For version-sensitive technical facts, prefer current primary documentation.

      TOOLS
      - Describes available internal URLs, tools, and MCPs.
      - Prefer specialized tools and MCPs over shell commands.

      Prefer simple, idiomatic, maintainable solutions. Be concise.
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
      defaultModel = "gpt-5.6-luna";
      hideThinkingBlock = true;
      defaultThinkingLevel = "max";
      packages = [
        "npm:pi-lens@4.1.3"
        "npm:pi-mcp-adapter@2.32.1"
        "git:github.com/algal/pi-openai-server-compaction@8a3de2f3b0c178fdd6f73f2f94172dfc3943e466"
        "npm:@plannotator/pi-extension@0.27.12"
        "npm:pi-subagents@0.65.1"
        "npm:@gotgenes/pi-permission-system@31.1.1"
        "npm:@valdo766hi/pi-fast@0.1.2"
        "npm:@valdo766hi/pi-footer@0.1.0"
        "npm:@valdo766hi/pi-yolo@0.1.5"
        "npm:@valdo766hi/pi-lazy-skill-tool@0.2.0"
        "npm:@mtrojnar/pi-usage@0.1.6"
        "npm:@ff-labs/pi-fff@0.10.6"
      ];
    };
  };
}

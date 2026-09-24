{lib, pkgs, ...}: let
  version = "0.27.19";
  sources = {
    x86_64-linux = {
      asset = "plannotator-linux-x64";
      hash = "sha256-eEeDBiIdD/LEdGy4qqA+gSTuMNLHkCGROpIM8t04dO4=";
    };
    aarch64-darwin = {
      asset = "plannotator-darwin-arm64";
      hash = "sha256-AjuEKevn1agh+Giv0y0TMaQAvIJ6/YwVptmYxvJfwkA=";
    };
  };
  source = sources.${pkgs.stdenv.hostPlatform.system};
  plannotator = pkgs.stdenvNoCC.mkDerivation {
    pname = "plannotator";
    inherit version;
    src = pkgs.fetchurl {
      url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/${source.asset}";
      inherit (source) hash;
    };
    dontUnpack = true;
    installPhase = ''
      mkdir -p "$out/bin"
      cp "$src" "$out/bin/plannotator"
      chmod +x "$out/bin/plannotator"
    '';
  };
  readTools = ["Read" "Grep" "Glob"];
  agents = {
    scout = {
      model = "haiku";
      tools = readTools;
      description = "Locate relevant code and summarize the paths when asked to scout.";
      prompt = "Find the relevant files and entry points. Report evidence and uncertainty; do not edit.";
    };
    delegate = {
      model = "haiku";
      tools = readTools;
      description = "Handle a bounded read-only lookup delegated by the user.";
      prompt = "Answer the assigned lookup with sources and no edits.";
    };
    researcher = {
      model = "sonnet";
      tools = readTools ++ ["WebSearch" "WebFetch"];
      description = "Research external documentation when explicitly requested.";
      prompt = "Prefer current primary sources. Cite what you checked; do not edit.";
    };
    context-builder = {
      model = "sonnet";
      tools = readTools;
      description = "Map a codebase and its relevant dependencies when asked.";
      prompt = "Summarize the actual flow, key files, and open questions without editing.";
    };
    planner = {
      model = "sonnet";
      tools = readTools;
      description = "Prepare an implementation plan when explicitly requested.";
      prompt = "Plan the smallest complete solution from the code you read. Do not edit.";
    };
    worker = {
      model = "sonnet";
      tools = readTools ++ ["Bash" "Edit" "Write"];
      description = "Implement a bounded change when the user asks for delegated implementation.";
      prompt = "Own only the assigned files. Check git status, preserve other work, make minimal changes, and validate without committing.";
    };
    reviewer = {
      model = "opus";
      tools = readTools ++ ["Bash"];
      description = "Independently review a change when asked for review.";
      prompt = "Read the diff and relevant code. Use Bash only for read-only inspection. Report actionable findings, not edits.";
    };
    oracle = {
      model = "opus";
      tools = readTools;
      description = "Provide a second opinion on a difficult decision when requested.";
      prompt = "Assess alternatives and tradeoffs independently; state uncertainty. Do not edit.";
    };
  };
  settings = pkgs.writeText "claude-code-settings.json" (builtins.toJSON {
    attribution = {commit = ""; pr = ""; sessionUrl = false;};
    enabledPlugins."plannotator@plannotator" = true;
    extraKnownMarketplaces.plannotator.source = {
      source = "github";
      repo = "backnotprop/plannotator";
    };
    hooks.PreToolUse = [{
      matcher = "Bash";
      hooks = [{type = "command"; command = "${lib.getExe (pkgs.callPackage ../../../pkgs/rtk {})} hook claude";}];
    }];
  });
in {
  home.packages = [plannotator]; # RTK is already owned by common/packages.nix.

  home.file = (lib.mapAttrs' (name: agent: lib.nameValuePair ".claude/agents/${name}.md" {
    text = ''
      ---
      name: ${name}
      description: ${agent.description}
      model: ${agent.model}
      tools: ${lib.concatStringsSep ", " agent.tools}
      ---

      ${agent.prompt}
    '';
  }) agents) // {
    ".claude/CLAUDE.md".text = builtins.readFile ../agent-instructions.md + ''

      Delegate only when the user asks for it. Never add Claude/AI attribution to commit messages, trailers, or pull request descriptions, even when asked to use Git.
    '';
  };

  home.activation.claudeCodeSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
    set -euo pipefail
    config="$HOME/.claude/settings.json"
    temp_file="$(${pkgs.coreutils}/bin/mktemp)"
    trap '${pkgs.coreutils}/bin/rm -f "$temp_file"' EXIT

    if [ -f "$config" ] && ! ${pkgs.jq}/bin/jq empty "$config" >/dev/null 2>&1; then
      echo "warning: skipping invalid Claude Code settings: $config" >&2
    else
      merge() {
        ${pkgs.jq}/bin/jq --slurpfile managed ${settings} '
        .attribution = ((.attribution // {}) + $managed[0].attribution) |
        .enabledPlugins = ((.enabledPlugins // {}) + $managed[0].enabledPlugins) |
        .extraKnownMarketplaces = ((.extraKnownMarketplaces // {}) + $managed[0].extraKnownMarketplaces) |
        .hooks.PreToolUse = ((.hooks.PreToolUse // []) |
          if any(.[]; any(.hooks[]?; .command == $managed[0].hooks.PreToolUse[0].hooks[0].command))
          then . else . + $managed[0].hooks.PreToolUse end)
        ' > "$temp_file"
      }
      if [ -f "$config" ]; then
        merge < "$config"
      else
        ${pkgs.coreutils}/bin/printf '{}\n' | merge
      fi
      mv "$temp_file" "$config"
    fi

    # These three servers were previously managed here; leave other MCPs alone.
    config="$HOME/.claude.json"
    if [ -f "$config" ]; then
      if ${pkgs.jq}/bin/jq empty "$config" >/dev/null 2>&1; then
        ${pkgs.jq}/bin/jq 'del(.mcpServers.context7, .mcpServers.exa, .mcpServers.github)' "$config" > "$temp_file"
        mv "$temp_file" "$config"
      else
        echo "warning: skipping invalid Claude Code state: $config" >&2
      fi
    fi
  '';

  # Optional MCPs (disabled; register explicitly if needed):
  # mcpServers = {
  #   context7 = {
  #     type = "http";
  #     url = "https://mcp.context7.com/mcp";
  #     headers.Authorization = "Bearer \${CONTEXT7_API_KEY:-}";
  #   };
  #   exa = { type = "http"; url = "https://mcp.exa.ai/mcp"; };
  #   github = {
  #     type = "stdio";
  #     command = "${pkgs.github-mcp-server}/bin/github-mcp-server";
  #     args = ["stdio"];
  #     env.GITHUB_PERSONAL_ACCESS_TOKEN = "\${GH_TOKEN:-}";
  #   };
  # };
}

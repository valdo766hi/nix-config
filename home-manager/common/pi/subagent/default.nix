{...}: {
  programs.pi-coding-agent.settings.subagents.agentOverrides = {
    scout = {
      model = "openai-codex/gpt-6-luna";
      thinking = "low";
      defaultContext = "fresh";
      acceptanceRole = "read-only";
      tools = [ "read" "grep" "find" "ls" "bash" "mcp" "intercom" ];
    };

    delegate = {
      model = "openai-codex/gpt-6-luna";
      thinking = "low";
      defaultContext = "fresh";
      acceptanceRole = "read-only";
      tools = [ "read" "grep" "find" "ls" "bash" "contact_supervisor" ];
    };

    researcher = {
      model = "openai-codex/gpt-6.1-sol";
      thinking = "medium";
      defaultContext = "fresh";
      acceptanceRole = "read-only";
      tools = [ "read" "mcp" "intercom" ];
    };

    "context-builder" = {
      model = "openai-codex/gpt-6.1-sol";
      thinking = "medium";
      defaultContext = "fresh";
      acceptanceRole = "read-only";
      tools = [ "read" "grep" "find" "ls" "bash" "mcp" "intercom" ];
    };

    planner = {
      model = "openai-codex/gpt-6.1-sol";
      thinking = "high";
      defaultContext = "fork";
      acceptanceRole = "read-only";
      tools = [ "read" "grep" "find" "ls" "intercom" ];
    };

    worker = {
      model = "openai-codex/gpt-6.1-sol";
      thinking = "high";
      defaultContext = "fork";
      acceptanceRole = "writer";
      tools = [ "read" "grep" "find" "ls" "bash" "edit" "write" "contact_supervisor" ];
    };

    reviewer = {
      model = "openai-codex/gpt-6.1-sol";
      thinking = "high";
      defaultContext = "fresh";
      acceptanceRole = "read-only";
      tools = [ "read" "grep" "find" "ls" "bash" "intercom" ];
    };

    oracle = {
      model = "openai-codex/gpt-6.1-sol";
      thinking = "max";
      defaultContext = "fork";
      acceptanceRole = "read-only";
      tools = [ "read" "grep" "find" "ls" "bash" "intercom" ];
    };
  };
}

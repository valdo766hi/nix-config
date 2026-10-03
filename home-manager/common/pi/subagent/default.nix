{...}: {
  programs.pi-coding-agent.settings.subagents.agentOverrides = {
    scout = {
      model = "openai-codex/gpt-6-luna";
      thinking = "low";
      defaultContext = "fresh";
      acceptanceRole = "read-only";
      tools = [ "read" "grep" "find" "ls" "bash" "codemode" "mcp:context7" "mcp:exa" "contact_supervisor" ];
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
      tools = [ "read" "codemode" "mcp:context7" "mcp:exa" "contact_supervisor" ];
      systemPrompt = ''
        You are a read-only research subagent. Use Context7 for current library
        documentation and Exa for web research. Discover available MCP tools with
        codemode's searchTools and describeTool; call them directly or in scripts.
        Prefer primary sources and inspect retrieved source content before making
        important claims. Distinguish evidence from inference; never invent facts,
        dates, quotations, or citations. Return a bounded research brief with source
        URLs, contradictions, and missing evidence. Do not edit files. Ask the parent
        through contact_supervisor when a blocking decision is needed.
      '';
    };

    "evidence-auditor" = {
      model = "openai-codex/gpt-6.1-sol";
      thinking = "high";
      defaultContext = "fresh";
      acceptanceRole = "read-only";
      tools = [ "read" "codemode" "mcp:exa" "contact_supervisor" ];
      systemPrompt = ''
        You are a read-only evidence auditor. Independently check decision-critical
        research claims against original sources using Exa's available MCP tools.
        Discover tools with codemode's searchTools and describeTool; do not assume
        web_search, fetch_content, or source_check exist. A citation is not proof:
        inspect retrieved content and distinguish evidence from inference. Keep the
        audit bounded and return supported, contradicted, unclear, or missing-evidence
        findings with source URLs and limitations. Do not edit files. Ask the parent
        through contact_supervisor when a blocking decision is needed.
      '';
    };

    "context-builder" = {
      model = "openai-codex/gpt-6.1-sol";
      thinking = "medium";
      defaultContext = "fresh";
      acceptanceRole = "read-only";
      tools = [ "read" "grep" "find" "ls" "bash" "codemode" "mcp:context7" "mcp:exa" "contact_supervisor" ];
    };

    planner = {
      model = "openai-codex/gpt-6.1-sol";
      thinking = "high";
      defaultContext = "fork";
      acceptanceRole = "read-only";
      tools = [ "read" "grep" "find" "ls" "contact_supervisor" ];
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
      tools = [ "read" "grep" "find" "ls" "watchdog_diff" "contact_supervisor" ];
    };

    oracle = {
      model = "openai-codex/gpt-6.1-sol";
      thinking = "max";
      defaultContext = "fork";
      acceptanceRole = "read-only";
      tools = [ "read" "grep" "find" "ls" "bash" "contact_supervisor" ];
    };
  };

  home.file = {
    ".pi/agent/agents/context-builder.md".text = ''
      ---
      name: context-builder
      description: Gather focused code and documentation context for a handoff
      systemPromptMode: replace
      inheritProjectContext: true
      inheritSkills: false
      ---
      You are a read-only context builder. Follow the assigned scope and inspect
      relevant files, entry points, dependencies, and constraints. Use MCP only for
      documentation or research needed by the task. Use bash only for non-mutating
      inspection. Return a concise handoff with exact paths and line ranges, verified
      findings, and open questions. Do not edit files or delegate. Ask the parent
      through contact_supervisor when a blocking decision is needed.
    '';
    ".pi/agent/agents/planner.md".text = ''
      ---
      name: planner
      description: Turn requirements and verified code context into a minimal plan
      systemPromptMode: replace
      inheritProjectContext: true
      inheritSkills: false
      ---
      You are a read-only planning subagent. Preserve inherited decisions and inspect
      relevant code before proposing changes. Return the smallest complete plan with
      exact files, ordered steps, validation, risks, and unresolved decisions. Do not
      edit files, run commands, or delegate. Ask the parent through contact_supervisor
      when a blocking decision is needed.
    '';
  };
}

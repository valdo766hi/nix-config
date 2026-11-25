{
  lib,
  pkgs,
  ...
}: let
  mkModel = {
    name,
    context,
    output,
    inputs,
    variants ? null,
  }:
    {
      inherit name;
      limit = {
        inherit context output;
      };
      modalities = {
        input = inputs;
        output = ["text"];
      };
    }
    // lib.optionalAttrs (variants != null) {
      inherit variants;
    };
in {
  xdg.configFile."opencode/plugins/rtk.ts".source = ./rtk.ts;

  programs.opencode = {
    enable = lib.mkDefault true;
    package = pkgs.llm-agents.opencode2;
    settings = lib.mkDefault {
      plugin = [];

      skills.paths = [
        "{env:HOME}/.config/opencode/skills"
      ];

      mcp.context7 = {
        type = "remote";
        url = "https://mcp.context7.com/mcp";
        headers.CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
        enabled = true;
      };

      mcp.exa = {
        type = "remote";
        url = "https://mcp.exa.ai/mcp";
        headers."x-api-key" = "{env:EXA_API_KEY}";
        enabled = true;
      };

      mcp.github = {
        type = "local";
        command = ["${pkgs.github-mcp-server}/bin/github-mcp-server" "stdio"];
        environment.GITHUB_PERSONAL_ACCESS_TOKEN = "{env:GH_TOKEN}";
        enabled = false;
      };

      provider = {
        google = {
          options.apiKey = "{env:GEMINI_API_KEY}";
        };

        minimax = {
          options.apiKey = "{env:MINIMAX_API_KEY}";
        };

        opencode-go = {
          options.apiKey = "{env:OPENCODE_GO_API_KEY}";
        };

        dekallm = {
          name = "Deka LLM";
          npm = "@ai-sdk/openai-compatible";
          options = {
            baseURL = "https://dekallm.cloudeka.ai/v1";
            apiKey = "{env:DEKA_API_KEY}";
            compatibility = "strict";
          };
          models = {
            "qwen/qwen3-coder" = mkModel {
              name = "Qwen3 Coder (Deka LLM)";
              context = 131072;
              output = 8192;
              inputs = ["text"];
            };

            "qwen/qwen25-vl-7b-instruct" = mkModel {
              name = "Qwen2.5 VL 7B Instruct (Deka LLM)";
              context = 32768;
              output = 8192;
              inputs = ["text" "image"];
            };

            "qwen/qwen25-72b-instruct" = mkModel {
              name = "Qwen2.5 72B Instruct (Deka LLM)";
              context = 131072;
              output = 8192;
              inputs = ["text"];
            };

            "qwen/qwen3-30b-a3b-instruct-2507" = mkModel {
              name = "Qwen3 30B A3B Instruct (Deka LLM)";
              context = 131072;
              output = 8192;
              inputs = ["text"];
            };

            "zai/glm-4.7-fp8" = mkModel {
              name = "GLM 4.7 FP8 (Deka LLM)";
              context = 128000;
              output = 8192;
              inputs = ["text"];
            };
          };
        };
      };
    };
  };
}

# Declarative NVF settings
{ pkgs, lib }:

let
  lazygitBin = "${pkgs.lazygit}/bin/lazygit";
  fishShell = "${pkgs.fish}/bin/fish";
in {
  vim = {
    package = pkgs.neovim-unwrapped;
    viAlias = false;
    vimAlias = true;

    globals = {
      mapleader = " ";
      maplocalleader = "\\";
    };

    options = {
      number = true;
      relativenumber = true;
      signcolumn = "yes";
      cursorline = true;
      scrolloff = 8;
      clipboard = "unnamedplus";
      undofile = true;
      timeoutlen = 300;
      updatetime = 250;
      splitright = true;
      splitbelow = true;
      ignorecase = true;
      smartcase = true;
      termguicolors = true;
      autoread = true;

      # Tabs and indentation
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      smartindent = true;
    };

    lineNumberMode = "relNumber";
    searchCase = "smart";
    preventJunkFiles = true;
    hideSearchHighlight = false;

    autocmds = [
      # Auto-close terminal when lazygit exits
      {
        event = ["TermClose"];
        pattern = ["term://*lazygit"];
        command = "bdelete!";
      }
      # Force file tree to reload after LazyGit runs (keeps new files in sync)
      {
        event = ["TermClose"];
        pattern = ["term://*lazygit"];
        command = "lua local ok, api = pcall(require, 'nvim-tree.api'); if ok then api.tree.reload() end";
      }
      # Refresh buffers after external edits (e.g., LazyGit pulls)
      {
        event = ["FocusGained" "BufEnter" "TermClose" "TermLeave"];
        command = "checktime";
      }
    ];

    extraPackages = with pkgs; [
      # Search and navigation
      ripgrep
      fd

      # Git
      lazygit
      delta

      # Nix
      nil
      nixd
      alejandra
      nixfmt-rfc-style
      statix
      deadnix

      # Lua
      stylua
      lua-language-server

      # Shell
      shfmt
      shellcheck

      # Rust
      rust-analyzer

      # Python
      pyright

      # Node/TypeScript
      nodejs_22

      # YAML/Kubernetes
      yaml-language-server
      actionlint
    ];

    withPython3 = true;
    python3Packages = ["pynvim"];
    withNodeJs = true;

    diagnostics = {
      enable = true;
      config = {
        underline = true;
        virtual_text = true;
        signs = true;
        update_in_insert = false;
      };
    };

    lsp = {
      enable = true;
      formatOnSave = true;
      inlayHints.enable = true;
      lspkind.enable = true;
      trouble.enable = true;
    };

    autocomplete = {
      enableSharedCmpSources = true;
      nvim-cmp = {
        enable = true;
        sourcePlugins = with pkgs.vimPlugins; [
          cmp-nvim-lsp
          cmp-buffer
          cmp-path
          cmp_luasnip
          cmp-nvim-lua
          copilot-cmp
        ];
        sources = {
          copilot = "[Copilot]";
          nvim_lsp = "[LSP]";
          buffer = "[Buffer]";
          path = "[Path]";
          nvim_lua = "[Lua]";
        };
      };
    };

    # GitHub Copilot
    extraPlugins = {
      copilot-lua = {
        package = pkgs.vimPlugins.copilot-lua;
        setup = ''
          require('copilot').setup({
            suggestion = { enabled = false },
            panel = { enabled = false },
          })
          require('copilot_cmp').setup()
        '';
      };

      copilot-chat = {
        package = pkgs.vimPlugins.CopilotChat-nvim;
        setup = ''
          require('CopilotChat').setup({
            model = 'claude-sonnet-4.5',
            allow_think = true,
            prompts = {
              Explain = {
                prompt = '/COPILOT_EXPLAIN Write an explanation for the selected code as paragraphs of text.',
              },
              Review = {
                prompt = '/COPILOT_REVIEW Review the selected code.',
              },
              Fix = {
                prompt = '/COPILOT_FIX There is a problem in this code. Rewrite the code to show it with the bug fixed.',
              },
              Optimize = {
                prompt = '/COPILOT_REFACTOR Optimize the selected code to improve performance and readability.',
              },
              Docs = {
                prompt = '/COPILOT_GENERATE Please add documentation comment for the selection.',
              },
              Tests = {
                prompt = '/COPILOT_GENERATE Please generate tests for my code.',
              },
            },
          })
        '';
      };

      avante-nvim = {
        package = pkgs.vimPlugins.avante-nvim;
        setup = ''
          require('avante').setup({
            provider = "copilot",
            providers = {
              copilot = {
                endpoint = "https://api.githubcopilot.com",
                model = "claude-sonnet-4.5",
                timeout = 30000,
                temperature = 0,
                extra_request_body = {
                  max_tokens = 4096,
                },
              },
            },
            behaviour = {
              auto_suggestions = false,
              auto_set_highlight_group = true,
              auto_set_keymaps = true,
              auto_apply_diff_after_generation = false,
              support_paste_from_clipboard = false,
            },
            dual_boost = {
              enabled = true,
              first_provider = "copilot",
              second_provider = "copilot",
              prompt = "Based on the two reference outputs below, generate a response that incorporates the best aspects of both.",
              timeout = 60000,
            },
            mappings = {
              ask = "<leader>aa",
              edit = "<leader>ae",
              refresh = "<leader>ar",
              diff = {
                ours = "co",
                theirs = "ct",
                both = "cb",
                next = "]x",
                prev = "[x",
              },
              jump = {
                next = "]]",
                prev = "[[",
              },
              submit = {
                normal = "<CR>",
                insert = "<C-s>",
              },
              toggle_debug = "<leader>ad",
            },
            hints = { enabled = true },
            windows = {
              wrap = true,
              width = 30,
              sidebar_header = {
                align = "center",
                rounded = true,
              },
            },
            highlights = {
              diff = {
                current = "DiffText",
                incoming = "DiffAdd",
              },
            },
          })
        '';
      };
    };

    snippets.luasnip = {
      enable = true;
      providers = with pkgs.vimPlugins; [
        friendly-snippets
      ];
    };

    autopairs.nvim-autopairs.enable = true;

    comments.comment-nvim.enable = true;

    git.gitsigns.enable = true;

    treesitter = {
      enable = true;
      fold = true;
      autotagHtml = true;
    };

    telescope = {
      enable = true;
      setupOpts = {
        defaults = {
          path_display = ["smart"];
          layout_config = {
            width = 0.9;
            height = 0.85;
            horizontal.preview_width = 0.6;
          };
        };
      };
      extensions = [
        {
          name = "fzf";
          packages = [pkgs.vimPlugins.telescope-fzf-native-nvim];
          setup = {
            fzf = {
              fuzzy = true;
              override_generic_sorter = true;
              override_file_sorter = true;
              case_mode = "smart_case";
            };
          };
        }
      ];
    };

    theme = {
      enable = true;
      name = "catppuccin";
      style = "mocha";
      transparent = false;
    };

    statusline.lualine.enable = true;
    tabline.nvimBufferline.enable = true;

    filetree.nvimTree = {
      enable = true;
      openOnSetup = false;
      setupOpts = {
        hijack_cursor = true;
        reload_on_bufenter = true;
        filesystem_watchers = {
          enable = true;
          debounce_delay = 50;
        };
        view = {
          width = 36;
          relativenumber = true;
        };
        renderer = {
          highlight_git = true;
          add_trailing = false;
        };
        actions = {
          open_file = {
            quit_on_open = false;
            resize_window = false;
          };
        };
      };
    };

    binds.whichKey.enable = true;

    maps = {
      normal = {
        # Telescope
        "<leader>ff" = {
          action = "<cmd>Telescope find_files<CR>";
          desc = "Find files";
        };
        "<leader>fg" = {
          action = "<cmd>Telescope live_grep<CR>";
          desc = "Live grep";
        };
        "<leader>fb" = {
          action = "<cmd>Telescope buffers<CR>";
          desc = "Find buffers";
        };
        "<leader>fh" = {
          action = "<cmd>Telescope help_tags<CR>";
          desc = "Help tags";
        };
        "<leader>fo" = {
          action = "<cmd>Telescope oldfiles<CR>";
          desc = "Recent files";
        };

        # File tree
        "<leader>e" = {
          action = "<cmd>NvimTreeToggle<CR>";
          desc = "Toggle file tree (open/close)";
        };

        # Better window navigation
        "<C-h>" = {
          action = "<C-w>h";
          desc = "Move to left window";
        };
        "<C-j>" = {
          action = "<C-w>j";
          desc = "Move to bottom window";
        };
        "<C-k>" = {
          action = "<C-w>k";
          desc = "Move to top window";
        };
        "<C-l>" = {
          action = "<C-w>l";
          desc = "Move to right window";
        };

        # Buffer navigation
        "<S-l>" = {
          action = "<cmd>bnext<CR>";
          desc = "Next buffer";
        };
        "<S-h>" = {
          action = "<cmd>bprevious<CR>";
          desc = "Previous buffer";
        };

        # Bufferline "tabs" navigation
        "<leader>tn" = {
          action = "<cmd>BufferLineCycleNext<CR>";
          desc = "Next buffer tab";
        };
        "<leader>tp" = {
          action = "<cmd>BufferLineCyclePrev<CR>";
          desc = "Previous buffer tab";
        };
        "<leader>tc" = {
          action = "<cmd>BufferLinePickClose<CR>";
          desc = "Close buffer tab";
        };

        # Clear search highlight
        "<leader>h" = {
          action = "<cmd>nohlsearch<CR>";
          desc = "Clear search highlight";
        };

        # Git
        "<leader>gg" = {
          action = "<cmd>tabnew | terminal ${lazygitBin}<CR><cmd>startinsert<CR>";
          desc = "Open LazyGit in new tab";
        };

        # Terminal helpers (fish shell)
        "<leader>tt" = {
          action = "<cmd>lua ToggleFishTerminal()<CR>";
          desc = "Toggle fish terminal";
        };
        "<leader>t+" = {
          action = "<cmd>lua ResizeFishTerminal(5)<CR>";
          desc = "Increase terminal height";
        };
        "<leader>t-" = {
          action = "<cmd>lua ResizeFishTerminal(-5)<CR>";
          desc = "Decrease terminal height";
        };
        "<leader>tx" = {
          action = "<cmd>lua HideFishTerminal()<CR>";
          desc = "Hide fish terminal";
        };
        "<leader>tk" = {
          action = "<cmd>lua KillFishTerminal()<CR>";
          desc = "Kill fish terminal session";
        };

        # LSP
        "gd" = {
          action = "<cmd>lua vim.lsp.buf.definition()<CR>";
          desc = "Go to definition";
        };
        "gr" = {
          action = "<cmd>lua vim.lsp.buf.references()<CR>";
          desc = "Show references";
        };
        "K" = {
          action = "<cmd>lua vim.lsp.buf.hover()<CR>";
          desc = "Show hover";
        };
        "<leader>rn" = {
          action = "<cmd>lua vim.lsp.buf.rename()<CR>";
          desc = "Rename symbol";
        };
        "<leader>ca" = {
          action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
          desc = "Code action";
        };

        # CopilotChat
        "<leader>cc" = {
          action = "<cmd>CopilotChatToggle<CR>";
          desc = "Toggle Copilot Chat";
        };
        "<leader>ce" = {
          action = "<cmd>CopilotChatExplain<CR>";
          desc = "Copilot Explain";
        };
        "<leader>cr" = {
          action = "<cmd>CopilotChatReview<CR>";
          desc = "Copilot Review";
        };
        "<leader>cf" = {
          action = "<cmd>CopilotChatFix<CR>";
          desc = "Copilot Fix";
        };
        "<leader>co" = {
          action = "<cmd>CopilotChatOptimize<CR>";
          desc = "Copilot Optimize";
        };
        "<leader>cd" = {
          action = "<cmd>CopilotChatDocs<CR>";
          desc = "Copilot Docs";
        };
        "<leader>ct" = {
          action = "<cmd>CopilotChatTests<CR>";
          desc = "Copilot Tests";
        };
      };

      visual = {
        # Better indenting
        "<" = {
          action = "<gv";
          desc = "Indent left";
        };
        ">" = {
          action = ">gv";
          desc = "Indent right";
        };
      };
    };

    luaConfigRC.telescope-open-in-tab = ''
      local ok, telescope = pcall(require, 'telescope')
      if not ok then
        return
      end

      local actions = require('telescope.actions')
      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ['<CR>'] = actions.select_tab,
              ['<C-o>'] = actions.select_default,
            },
            n = {
              ['<CR>'] = actions.select_tab,
              ['<C-o>'] = actions.select_default,
            },
          },
        },
      })
    '';

    # Custom Lua configuration for arrow keys in nvim-cmp
    luaConfigRC.cmp-arrow-keys = ''
      local cmp = require('cmp')

      -- Setup arrow keys for nvim-cmp
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ['<Down>'] = cmp.mapping.select_next_item(),
          ['<Up>'] = cmp.mapping.select_prev_item(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
      })
    '';

    # Floating fish terminal helper (persistent session)
    luaConfigRC.fish-terminal = ''
      local state = { buf = nil, win = nil }

      local function is_term_running(bufnr)
        if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
          return false
        end
        local ok, job_id = pcall(function()
          return vim.b[bufnr].terminal_job_id
        end)
        if not ok or not job_id then
          return false
        end
        return vim.fn.jobwait({ job_id }, 0)[1] == -1
      end

      function ToggleFishTerminal()
        if state.win and vim.api.nvim_win_is_valid(state.win) then
          vim.api.nvim_win_close(state.win, true)
          state.win = nil
          return
        end

        if not is_term_running(state.buf) then
          state.buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_option(state.buf, 'bufhidden', 'hide')
          vim.api.nvim_buf_call(state.buf, function()
            vim.fn.termopen('${fishShell}')
          end)
        end

        vim.cmd('botright 15split')
        state.win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(state.win, state.buf)
        vim.cmd('startinsert')
      end

      function ResizeFishTerminal(delta)
        if state.win and vim.api.nvim_win_is_valid(state.win) then
          local height = vim.api.nvim_win_get_height(state.win) + delta
          if height < 5 then
            height = 5
          end
          vim.api.nvim_win_set_height(state.win, height)
        end
      end

      function HideFishTerminal()
        if state.win and vim.api.nvim_win_is_valid(state.win) then
          vim.api.nvim_win_close(state.win, true)
          state.win = nil
        end
      end

      function KillFishTerminal()
        HideFishTerminal()
        if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
          vim.api.nvim_buf_delete(state.buf, { force = true })
        end
        state.buf = nil
      end
    '';

    visuals.indent-blankline = {
      enable = true;
      setupOpts = {
        indent = {
          char = "│";
        };
        scope = {
          enabled = true;
          show_start = true;
          show_end = true;
        };
      };
    };

    ui.borders = {
      enable = true;
      globalStyle = "rounded";
    };

    languages = {
      enableTreesitter = true;
      enableFormat = true;
      enableExtraDiagnostics = true;

      nix = {
        enable = true;
        lsp.server = "nixd";
        format.enable = true;
        extraDiagnostics.enable = true;
      };

      rust = {
        enable = true;
        lsp.enable = true;
        crates.enable = true;
        format.enable = true;
      };

      lua = {
        enable = true;
        lsp = {
          enable = true;
          lazydev.enable = true;
        };
        format.enable = true;
        extraDiagnostics.enable = true;
      };

      bash = {
        enable = true;
        lsp.enable = true;
        format.enable = true;
        extraDiagnostics.enable = true;
      };

      ts = {
        enable = true;
        lsp.enable = true;
        format.enable = true;
        extraDiagnostics.enable = true;
        extensions."ts-error-translator".enable = true;
      };

      markdown = {
        enable = true;
        lsp.enable = true;
        format.enable = true;
        extraDiagnostics.enable = true;
      };

      python = {
        enable = true;
        lsp.enable = true;
        format.enable = true;
      };

      yaml = {
        enable = true;
        lsp.enable = true;
      };
    };
  };
}

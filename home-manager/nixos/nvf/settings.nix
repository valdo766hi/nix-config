{
  pkgs,
  lib,
}: let
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
      mouse = "a";

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
      {
        event = ["TermClose"];
        pattern = ["term://*lazygit"];
        command = "bdelete!";
      }
      {
        event = ["TermClose"];
        pattern = ["term://*lazygit"];
        command = "lua local ok, api = pcall(require, 'nvim-tree.api'); if ok then api.tree.reload() end";
      }
      {
        event = ["FocusGained" "BufEnter" "TermClose" "TermLeave"];
        command = "checktime";
      }
    ];

    extraPackages = with pkgs; [
      wl-clipboard
      chafa
      imagemagick
      poppler-utils
      ffmpegthumbnailer
      ripgrep
      fd
      lazygit
      delta
      nil
      nixd
      alejandra
      nixfmt-rfc-style
      statix
      deadnix
      stylua
      lua-language-server
      shfmt
      shellcheck
      rust-analyzer
      pyright
      nodejs_22
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
      formatOnSave = false;
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

        "<leader>e" = {
          action = "<cmd>NvimTreeToggle<CR>";
          desc = "Toggle file tree (open/close)";
        };

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

        "<S-l>" = {
          action = "<cmd>bnext<CR>";
          desc = "Next buffer";
        };
        "<S-h>" = {
          action = "<cmd>bprevious<CR>";
          desc = "Previous buffer";
        };

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

        "<leader>h" = {
          action = "<cmd>nohlsearch<CR>";
          desc = "Clear search highlight";
        };

        "<leader>gg" = {
          action = "<cmd>lua OpenLazygitFloating()<CR>";
          desc = "Open LazyGit in floating terminal";
        };

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

    luaConfigRC.telescope-config = ''
      local ok, telescope = pcall(require, 'telescope')
      if not ok then
        return
      end

      local actions = require('telescope.actions')
      local previewers = require('telescope.previewers')

      local image_previewer = function(filepath, bufnr, opts)
        local image_extensions = {'png', 'jpg', 'jpeg', 'gif', 'webp', 'svg', 'bmp'}
        local ext = filepath:match("^.+%.(.+)$")
        if ext and vim.tbl_contains(image_extensions, ext:lower()) then
          local term = vim.api.nvim_open_term(bufnr, {})
          local width = vim.api.nvim_win_get_width(opts.winid)
          local height = vim.api.nvim_win_get_height(opts.winid)
          vim.fn.jobstart({
            'chafa',
            '--format=symbols',
            '--colors=256',
            '--size=' .. width .. 'x' .. height,
            filepath
          }, {
            on_stdout = function(_, data)
              for _, line in ipairs(data) do
                vim.api.nvim_chan_send(term, line .. '\r\n')
              end
            end,
            stdout_buffered = true
          })
          return true
        end
        return false
      end

      telescope.setup({
        defaults = {
          file_previewer = function(...)
            local args = {...}
            local filepath = args[1]
            local bufnr = args[2]
            local opts = args[3] or {}

            if not image_previewer(filepath, bufnr, opts) then
              return previewers.cat.new(...)
            end
          end,
          mappings = {
            i = {
              ['<CR>'] = actions.select_default,
              ['<C-o>'] = actions.select_tab,
            },
            n = {
              ['<CR>'] = actions.select_default,
              ['<C-o>'] = actions.select_tab,
            },
          },
        },
      })
    '';

    luaConfigRC.cmp-arrow-keys = ''
      local cmp = require('cmp')

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

    luaConfigRC.lazygit-floating = ''
      function OpenLazygitFloating()
        local buf = vim.api.nvim_create_buf(false, true)
        local width = math.floor(vim.o.columns * 0.9)
        local height = math.floor(vim.o.lines * 0.9)
        local col = math.floor((vim.o.columns - width) / 2)
        local row = math.floor((vim.o.lines - height) / 2)

        local opts = {
          relative = 'editor',
          width = width,
          height = height,
          col = col,
          row = row,
          style = 'minimal',
          border = 'rounded',
        }

        local win = vim.api.nvim_open_win(buf, true, opts)
        vim.fn.termopen('${lazygitBin}', {
          on_exit = function()
            if vim.api.nvim_buf_is_valid(buf) then
              vim.api.nvim_buf_delete(buf, { force = true })
            end
          end
        })
        vim.cmd('startinsert')
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
        lsp.servers = ["nixd"];
        format.enable = true;
        extraDiagnostics.enable = true;
      };

      rust = {
        enable = true;
        lsp.enable = true;
        extensions.crates-nvim.enable = true;
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

{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.generators) mkLuaInline;

  mkKeymaps = mode: mappings:
    lib.mapAttrsToList (key: mapping: mapping // {inherit key mode;}) mappings;
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
      wrap = false;
      breakindent = true;
      splitkeep = "screen";
      inccommand = "split";
      laststatus = 3;
      showmode = false;
      winborder = "rounded";
      completeopt = "menu,menuone,noselect";
      list = true;
      listchars = "tab:» ,trail:·,nbsp:␣";
      foldlevel = 99;
      foldenable = false;

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
        event = ["TextYankPost"];
        callback = mkLuaInline "function() vim.hl.on_yank({timeout = 150}) end";
      }
      {
        event = ["FocusGained" "BufEnter" "TermClose" "TermLeave"];
        command = "checktime";
      }
    ];

    # Language tools are installed by nvf presets; these serve UI/runtime features.
    extraPackages =
      (with pkgs; [
        chafa
        imagemagick
        poppler-utils
        ffmpegthumbnailer
        ripgrep
        fd
        git
        lazygit
        diffutils
      ])
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        pkgs.wl-clipboard
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
        pkgs.pngpaste
      ];

    withPython3 = true;
    python3Packages = ["pynvim"];
    withNodeJs = true;

    diagnostics = {
      enable = true;
      config = {
        underline = true;
        virtual_text = {
          spacing = 2;
          source = "if_many";
        };
        signs = true;
        update_in_insert = false;
        severity_sort = true;
        float = {
          border = "rounded";
          source = "always";
        };
      };
    };

    lsp = {
      enable = true;
      formatOnSave = false;
      inlayHints.enable = true;
      lspkind.enable = true;
      trouble.enable = true;
      servers."typescript-language-server".filetypes = ["typescriptreact" "javascriptreact"];
    };

    autocomplete = {
      enableSharedCmpSources = true;
      nvim-cmp = {
        enable = true;
        sourcePlugins = with pkgs.vimPlugins; [
          cmp-nvim-lsp
          cmp-buffer
          cmp-path
          cmp-nvim-lua
        ];
        sources = {
          nvim_lsp = "[LSP]";
          buffer = "[Buffer]";
          path = "[Path]";
          nvim_lua = "[Lua]";
        };
      };
    };

    extraPlugins = {
      fff-nvim = {
        package = pkgs.vimPlugins.fff-nvim;
        setup = ''
          require('fff').setup({
            title = 'FFFiles',
            prompt = '>',
            max_results = 100,
            lazy_sync = true,
            grep = {
              modes = { 'plain', 'regex', 'fuzzy' },
              smart_case = true,
            },
          })
        '';
      };

      oil-nvim = {
        package = pkgs.vimPlugins.oil-nvim;
        setup = ''
          require('oil').setup({
            default_file_explorer = true,
            cleanup_delay_ms = 2000,
            watch_for_changes = true,
            columns = { 'icon' },
            keymaps = {
              ['<C-h>'] = false,
            },
            float = {
              padding = 2,
              max_width = 0.7,
              max_height = 0.8,
              border = 'rounded',
            },
            view_options = {
              show_hidden = false,
            },
            win_options = {
              relativenumber = true,
            },
          })
        '';
      };
    };

    utility = {
      snacks-nvim = {
        enable = true;
        setupOpts = {
          image.enabled = true;
          input.enabled = true;
          bigfile.enabled = true;
          terminal = {
            shell = lib.getExe pkgs.fish;
            # Let Snacks choose a split for the shell and a float for commands.
            win.height = 0.3;
          };
          lazygit.win = {
            width = 0.9;
            height = 0.9;
          };
        };
      };
      surround = {
        enable = true;
        useVendoredKeybindings = false;
      };
      undotree.enable = true;
    };

    mini.ai.enable = true;

    navigation.harpoon = {
      enable = true;
      mappings = {
        markFile = "<leader>a";
        listMarks = "<C-e>";
        file1 = "<leader>1";
        file2 = "<leader>2";
        file3 = "<leader>3";
        file4 = "<leader>4";
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

    git.gitsigns = {
      enable = true;
      mappings = {
        stageHunk = "<leader>gs";
        resetHunk = "<leader>gr";
        undoStageHunk = "<leader>gu";
        stageBuffer = "<leader>gS";
        resetBuffer = "<leader>gR";
        previewHunk = "<leader>gp";
        blameLine = "<leader>gb";
        diffThis = "<leader>gd";
        diffProject = "<leader>gD";
      };
    };

    treesitter = {
      enable = true;
      fold = true;
      indent.enable = false; # Keep filetype indentation; no automatic reindent.
      grammars = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [fish tsx];
      context = {
        enable = true;
        setupOpts = {
          max_lines = 3;
          min_window_height = 20;
          separator = null;
        };
      };
    };

    telescope = {
      enable = true;
      mappings = {
        findFiles = "<leader>fF";
        liveGrep = "<leader>fG";
        buffers = "<leader>fb";
        helpTags = "<leader>fh";
        resume = "<leader>fr";
        lspDocumentSymbols = "<leader>fs";
        lspWorkspaceSymbols = "<leader>fw";
        diagnostics = "<leader>fd";
      };
      setupOpts = {
        defaults = {
          path_display = ["smart"];
          sorting_strategy = "ascending";
          buffer_previewer_maker = mkLuaInline ''
            function(filepath, bufnr, opts)
              local ext = filepath:match("%.([^%.]+)$")
              local images = {'png', 'jpg', 'jpeg', 'gif', 'webp', 'svg', 'bmp', 'heic', 'avif'}
              if not (ext and vim.tbl_contains(images, ext:lower()) and opts.winid and vim.api.nvim_win_is_valid(opts.winid)) then
                return require('telescope.previewers').buffer_previewer_maker(filepath, bufnr, opts)
              end

              local term = vim.api.nvim_open_term(bufnr, {})
              vim.fn.jobstart({
                '${lib.getExe pkgs.chafa}', '--format=symbols', '--colors=256',
                '--size=' .. vim.api.nvim_win_get_width(opts.winid) .. 'x' .. vim.api.nvim_win_get_height(opts.winid),
                filepath,
              }, {
                stdout_buffered = true,
                on_stdout = function(_, data)
                  if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].channel == term then
                    vim.api.nvim_chan_send(term, table.concat(data, '\r\n'))
                  end
                end,
              })
            end
          '';
          layout_config = {
            width = 0.9;
            height = 0.85;
            horizontal.preview_width = 0.6;
            horizontal.prompt_position = "top";
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

    binds.whichKey = {
      enable = true;
      register = {
        "<leader>f" = "Find";
        "<leader>g" = "Git";
        "<leader>c" = "Code";
        "<leader>b" = "Buffer";
        "<leader>t" = "Terminal / toggles";
        "<leader>h" = null; # Clear search, not a prefix for Git actions.
      };
    };

    keymaps =
      (mkKeymaps "n" {
        "<leader>ff" = {
          action = "<cmd>lua require('fff').find_files()<CR>";
          desc = "Find files (fff)";
        };
        "<leader>fg" = {
          action = "<cmd>lua require('fff').live_grep()<CR>";
          desc = "Live grep (fff)";
        };
        "<leader>fo" = {
          action = "<cmd>Telescope oldfiles<CR>";
          desc = "Recent files";
        };

        "<leader>fc" = {
          action = "<cmd>lua require('fff').live_grep_under_cursor()<CR>";
          desc = "Search word under cursor";
        };
        "<leader>f/" = {
          action = "<cmd>Telescope current_buffer_fuzzy_find<CR>";
          desc = "Search current buffer";
        };

        "<leader>e" = {
          action = "<cmd>lua require('oil').toggle_float()<CR>";
          desc = "Toggle file explorer";
        };
        "-" = {
          action = "<cmd>Oil<CR>";
          desc = "Open parent directory";
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

        "<leader>bd" = {
          action = "<cmd>lua require('snacks').bufdelete()<CR>";
          desc = "Delete buffer without closing splits";
        };
        "<leader>u" = {
          action = "<cmd>UndotreeToggle<CR>";
          desc = "Browse undo history";
        };
        "<C-d>" = {
          action = "<C-d>zz";
          desc = "Scroll down and center";
        };
        "<C-u>" = {
          action = "<C-u>zz";
          desc = "Scroll up and center";
        };
        "n" = {
          action = "nzzzv";
          desc = "Next match and center";
        };
        "N" = {
          action = "Nzzzv";
          desc = "Previous match and center";
        };
        "]d" = {
          action = "<cmd>lua vim.diagnostic.jump({count = 1, float = true})<CR>";
          desc = "Next diagnostic";
        };
        "[d" = {
          action = "<cmd>lua vim.diagnostic.jump({count = -1, float = true})<CR>";
          desc = "Previous diagnostic";
        };
        "]q" = {
          action = "<cmd>cnext<CR>zz";
          desc = "Next quickfix item";
        };
        "[q" = {
          action = "<cmd>cprevious<CR>zz";
          desc = "Previous quickfix item";
        };
        "<leader>cd" = {
          action = "<cmd>lua vim.diagnostic.open_float()<CR>";
          desc = "Line diagnostics";
        };
        "<leader>cq" = {
          action = "<cmd>lua vim.diagnostic.setqflist()<CR>";
          desc = "Diagnostics in quickfix";
        };
        "<leader>cf" = {
          action = "<cmd>lua require('conform').format({async = true, lsp_format = 'fallback'})<CR>";
          desc = "Format buffer (manual)";
        };
        "<leader>cs" = {
          action = "<cmd>lua vim.lsp.buf.signature_help()<CR>";
          desc = "Signature help";
        };
        "gD" = {
          action = "<cmd>lua vim.lsp.buf.declaration()<CR>";
          desc = "Go to declaration";
        };
        "gI" = {
          action = "<cmd>lua vim.lsp.buf.implementation()<CR>";
          desc = "Go to implementation";
        };
        "gy" = {
          action = "<cmd>lua vim.lsp.buf.type_definition()<CR>";
          desc = "Go to type definition";
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
          action = "<cmd>lua require('snacks').lazygit()<CR>";
          desc = "Open LazyGit in floating terminal";
        };

        "<leader>tt" = {
          action = "<cmd>lua require('snacks').terminal()<CR>";
          desc = "Toggle fish terminal";
        };
        "<leader>t+" = {
          action = "function() ResizeFishTerminal(5) end";
          lua = true;
          desc = "Increase terminal height";
        };
        "<leader>t-" = {
          action = "function() ResizeFishTerminal(-5) end";
          lua = true;
          desc = "Decrease terminal height";
        };
        "<leader>tx" = {
          action = "function() local t = require('snacks').terminal.get(nil, {create = false}); if t then t:hide() end end";
          lua = true;
          desc = "Hide fish terminal";
        };
        "<leader>tk" = {
          action = "function() local t = require('snacks').terminal.get(nil, {create = false}); if t then t:close() end end";
          lua = true;
          desc = "Close fish terminal";
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
      })
      ++ (mkKeymaps "x" {
        "J" = {
          action = ":m '>+1<CR>gv=gv";
          desc = "Move selection down";
        };
        "K" = {
          action = ":m '<-2<CR>gv=gv";
          desc = "Move selection up";
        };
        "<leader>p" = {
          action = ''"_dP'';
          desc = "Paste without replacing yank register";
        };
        "<leader>fc" = {
          action = "<cmd>lua require('fff').live_grep_under_cursor()<CR>";
          desc = "Search selection";
        };
        "<" = {
          action = "<gv";
          desc = "Indent left";
        };
        ">" = {
          action = ">gv";
          desc = "Indent right";
        };
      });

    luaConfigRC.cmp-arrow-keys = ''
      local cmp = require('cmp')

      cmp.setup({
        preselect = cmp.PreselectMode.None,
        mapping = cmp.mapping.preset.insert({
          ['<Down>'] = cmp.mapping.select_next_item(),
          ['<Up>'] = cmp.mapping.select_prev_item(),
          ['<CR>'] = cmp.mapping.confirm({ select = false }),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif require('luasnip').expand_or_locally_jumpable() then
              require('luasnip').expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif require('luasnip').locally_jumpable(-1) then
              require('luasnip').jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
      })
    '';

    luaConfigRC.fish-terminal = ''
      function ResizeFishTerminal(delta)
        local term = require('snacks').terminal.get(nil, {create = false})
        if term and term:win_valid() then
          vim.api.nvim_win_set_height(term.win, math.max(5, vim.api.nvim_win_get_height(term.win) + delta))
        end
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
        lsp.enable = true;
        extensions.lazydev.enable = true;
        format.enable = true;
        extraDiagnostics.enable = true;
      };

      bash = {
        enable = true;
        lsp.enable = true;
        format.enable = true;
        extraDiagnostics.enable = true;
      };

      typescript = {
        enable = true;
        lsp.enable = true;
        format.enable = true;
        extraDiagnostics.enable = true;
      };

      markdown = {
        enable = true;
        lsp.enable = false;
        format = {
          enable = true;
          type = ["rumdl"];
        };
        extraDiagnostics.enable = true;
      };

      python = {
        enable = true;
        lsp.enable = true;
        format.enable = true;
      };

      go = {
        enable = true;
        extraDiagnostics.enable = false; # Project-specific linters belong in dev shells.
      };

      json = {
        enable = true;
        format.type = ["prettier"];
      };

      yaml = {
        enable = true;
        lsp.enable = true;
      };
    };
  };
}

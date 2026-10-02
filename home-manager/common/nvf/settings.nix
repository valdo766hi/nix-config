{
  pkgs,
  lib,
  ...
}: let
  lazygitBin = "${pkgs.lazygit}/bin/lazygit";
  fishShell = "${pkgs.fish}/bin/fish";

  treesitterWithGrammars = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
    p.nix
    p.bash
    p.fish
    p.lua
    p.markdown
    p.markdown_inline
    p.yaml
    p.rust
    p.go
    p.python
    p.vim
    p.vimdoc
    p.query
  ]);

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
        event = ["FocusGained" "BufEnter" "TermClose" "TermLeave"];
        command = "checktime";
      }
    ];

    extraPackages =
      (with pkgs; [
        chafa
        imagemagick
        poppler-utils
        ffmpegthumbnailer
        ripgrep
        fd
        delta
        nil
        nixd
        alejandra
        nixfmt
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
      snacks-nvim = {
        package = pkgs.vimPlugins.snacks-nvim;
        setup = ''
          require('snacks').setup({
            image = { enabled = true },
          })
        '';
      };

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

      # Manual treesitter setup; see https://github.com/NotAShelf/nvf/issues/1312
      nvim-treesitter = {
        package = treesitterWithGrammars;
        setup = ''
          -- Configure folding with treesitter
          vim.opt.foldmethod = "expr"
          vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.opt.foldenable = false
          vim.opt.foldlevel = 99

          -- Enable treesitter highlighting for supported filetypes
          vim.api.nvim_create_autocmd("FileType", {
            callback = function()
              pcall(vim.treesitter.start)
            end,
          })
        '';
      };
    };

    lazy.plugins."lazydev-nvim" = {
      package = "lazydev-nvim";
      setupModule = "lazydev";
      ft = "lua";
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

    # FIXME: Temporarily disabled due to https://github.com/NotAShelf/nvf/issues/1312
    # nvim-treesitter.configs module was removed in newer treesitter versions
    # Re-enable once nvf releases a fix
    treesitter = {
      enable = false;
      # fold = true;
      # autotagHtml = true;
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

    binds.whichKey.enable = true;

    keymaps =
      (mkKeymaps "n" {
        "<leader>ff" = {
          action = "<cmd>lua require('fff').find_files()<CR>";
          desc = "Find files (fff)";
        };
        "<leader>fF" = {
          action = "<cmd>Telescope find_files<CR>";
          desc = "Find files (telescope)";
        };
        "<leader>fg" = {
          action = "<cmd>lua OpenFffLiveGrep()<CR>";
          desc = "Live grep (fff)";
        };
        "<leader>fG" = {
          action = "<cmd>Telescope live_grep<CR>";
          desc = "Live grep (telescope)";
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
      })
      ++ (mkKeymaps "v" {
        "<" = {
          action = "<gv";
          desc = "Indent left";
        };
        ">" = {
          action = ">gv";
          desc = "Indent right";
        };
      });

    luaConfigRC.telescope-config = ''
      local ok, telescope = pcall(require, 'telescope')
      if not ok then
        return
      end

      local actions = require('telescope.actions')
      local previewers = require('telescope.previewers')

      local function snacks_image(filepath, bufnr, opts)
        local ok_snacks, Snacks = pcall(require, 'snacks')
        if not ok_snacks then
          return false
        end
        if not (Snacks.image and Snacks.image.render) then
          return false
        end
        local ok_render = pcall(function()
          Snacks.image.render(filepath, { buf = bufnr, win = opts.winid })
        end)
        return ok_render
      end

      local image_extensions = { 'png', 'jpg', 'jpeg', 'gif', 'webp', 'svg', 'bmp', 'heic', 'avif' }
      local function is_image(filepath)
        local ext = filepath:match("^.+%.(.+)$")
        if not ext then
          return false
        end
        ext = ext:lower()
        for _, e in ipairs(image_extensions) do
          if e == ext then
            return true
          end
        end
        return false
      end

      local image_previewer = function(filepath, bufnr, opts)
        if is_image(filepath) and snacks_image(filepath, bufnr, opts) then
          return true
        end

        -- Fallback to chafa if snacks image rendering isn't available
        if is_image(filepath) then
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
            local args = { ... }
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

    luaConfigRC.fff-grep-compat = ''
      function OpenFffLiveGrep()
        local ok_fff, fff = pcall(require, 'fff')
        if ok_fff and type(fff.live_grep) == 'function' then
          fff.live_grep()
          return
        end

        vim.notify(
          'fff.nvim in current lock has no live_grep(); using Telescope live_grep fallback',
          vim.log.levels.WARN
        )
        vim.cmd('Telescope live_grep')
      end
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

        vim.api.nvim_open_win(buf, true, opts)
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
      # FIXME: Disabled due to nvf bug #1312 (treesitter main branch incompatibility)
      enableTreesitter = false;
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
        # Workaround for https://github.com/NotAShelf/nvf/pull/1769:
        # nvf registers `lazydev` but the package is `lazydev-nvim`.
        extensions.lazydev.enable = false;
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

      yaml = {
        enable = true;
        lsp.enable = true;
      };
    };
  };
}

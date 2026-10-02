-- Run with the configured Neovim and an isolated HOME/XDG environment.
local vim = assert(rawget(_G, "vim"), "Run this test inside configured Neovim")
local ok, err = xpcall(function()
  assert(vim.v.errmsg == "", vim.v.errmsg)
  assert(vim.g.formatsave == false, "format-on-save must remain disabled")
  assert(vim.o.laststatus == 3 and vim.o.winborder == "rounded")
  assert(vim.fn.maparg(" ff", "n"):find("fff", 1, true), "FFF mapping was overridden")
  assert(vim.fn.maparg("<C-h>", "n") == "<C-W>h", "window navigation was overridden")
  for _, key in ipairs({ " cf", " bd", " tt", " gg", " 1" }) do
    assert(vim.fn.maparg(key, "n") ~= "", "missing mapping: " .. key)
  end

  local cmp = require("cmp")
  assert(cmp.get_config().preselect == cmp.PreselectMode.None)
  local original_confirm, select = cmp.confirm, nil
  cmp.confirm = function(opts)
    select = opts.select
    return true
  end
  cmp.get_config().mapping["<CR>"].i(function() end)
  cmp.confirm = original_confirm
  assert(select == false, "Enter must not accept an unselected completion")

  for _, name in ipairs({ "mini.ai", "nvim-surround", "lazydev", "oil", "conform" }) do
    assert(type(require(name)) == "table", "plugin did not load: " .. name)
  end
  local gitsigns = require("gitsigns")
  for _, action in ipairs({ "stage_hunk", "reset_hunk", "undo_stage_hunk", "preview_hunk", "blame_line", "diffthis" }) do
    assert(type(gitsigns[action]) == "function", "missing Git action: " .. action)
  end
  assert(vim.fn.maparg("ys", "n") ~= "", "surround mappings did not load")
  assert(type(require("luasnip").expand_or_locally_jumpable) == "function")
  vim.cmd("UndotreeToggle")
  vim.cmd("UndotreeHide")

  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_buf_set_name(buf, vim.fn.tempname() .. ".lua")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "local value = 1" })
  for _, language in ipairs({ "lua", "nix", "go", "json", "yaml", "typescript", "tsx", "fish", "markdown" }) do
    local parser = vim.treesitter.get_parser(buf, language)
    assert(parser:parse()[1], "parser did not load: " .. language)
    assert(vim.treesitter.query.get(language, "highlights"), "missing highlights: " .. language)
  end
  local harpoon = require("harpoon")
  harpoon:list():add()
  assert(harpoon:list():length() == 1, "Harpoon did not bookmark the file")

  local conform = require("conform")
  for _, formatter in ipairs({ "alejandra", "stylua", "prettier" }) do
    assert(conform.get_formatter_info(formatter).available, "missing formatter: " .. formatter)
  end
  for _, server in ipairs({ "nixd", "gopls", "vscode-json-language-server" }) do
    local cmd = assert(vim.lsp.config[server], "missing LSP configuration: " .. server).cmd
    assert(type(cmd) == "table" and vim.fn.executable(cmd[1]) == 1, "missing LSP: " .. server)
  end
  assert(vim.tbl_contains(vim.lsp.config["typescript-language-server"].filetypes, "typescriptreact"))
  for _, executable in ipairs({ "git", "rg", "fd", "chafa", "lazygit", "diff" }) do
    assert(vim.fn.executable(executable) == 1, "missing runtime tool: " .. executable)
  end

  local preview_buf = vim.api.nvim_create_buf(false, true)
  local preview_win = vim.api.nvim_open_win(preview_buf, false, {
    relative = "editor", row = 0, col = 0, width = 40, height = 8,
  })
  local text_file = vim.fn.tempname() .. ".txt"
  vim.fn.writefile({ "preview works" }, text_file)
  local previewer = require("telescope.config").values.buffer_previewer_maker
  previewer(text_file, preview_buf, { winid = preview_win })
  assert(vim.wait(3000, function()
    return vim.api.nvim_buf_get_lines(preview_buf, 0, 1, false)[1] == "preview works"
  end), "Telescope text preview failed")
  vim.api.nvim_win_close(preview_win, true)

  -- Use a tiny generated image; test the actual async Chafa preview hook.
  local image_file = vim.fn.tempname() .. ".PNG"
  local result = vim.system({ "magick", "-size", "2x2", "xc:red", image_file }):wait()
  assert(result.code == 0, result.stderr)
  local image_buf = vim.api.nvim_create_buf(false, true)
  local image_win = vim.api.nvim_open_win(image_buf, false, {
    relative = "editor", row = 0, col = 0, width = 40, height = 8,
  })
  previewer(image_file, image_buf, { winid = image_win })
  assert(vim.wait(3000, function()
    return table.concat(vim.api.nvim_buf_get_lines(image_buf, 0, -1, false)):match("%S") ~= nil
  end), "Telescope image preview failed")
  vim.api.nvim_win_close(image_win, true)

  local snacks = require("snacks")
  local terminal = snacks.terminal(nil, { interactive = false })
  assert(vim.api.nvim_win_get_config(terminal.win).relative == "", "Fish terminal must remain a split")
  local terminal_buf = terminal.buf
  assert(rawget(_G, "ResizeFishTerminal"), "missing terminal resize helper")(-100)
  assert(vim.api.nvim_win_get_height(terminal.win) == 5, "terminal resize minimum failed")
  terminal:hide()
  assert(terminal:buf_valid(), "hiding a terminal killed its buffer")
  assert(snacks.terminal(nil, { interactive = false }).buf == terminal_buf, "terminal was not reused")
  terminal:close()
  assert(vim.wait(1000, function() return not vim.api.nvim_buf_is_valid(terminal_buf) end))

  -- Exercise LazyGit's window without opening a repository or writing its config.
  local lazygit = snacks.lazygit({ configure = false, interactive = false, args = { "--version" } })
  assert(vim.api.nvim_win_get_config(lazygit.win).relative == "editor", "LazyGit must open in a float")
  lazygit:close()

  vim.api.nvim_set_current_buf(buf)
  vim.bo[buf].modified = false
  local windows = #vim.api.nvim_tabpage_list_wins(0)
  snacks.bufdelete({ buf = buf })
  assert(#vim.api.nvim_tabpage_list_wins(0) == windows, "buffer deletion closed a split")
  assert(vim.v.errmsg == "", vim.v.errmsg)
  print("nvf smoke test passed")
end, debug.traceback)

if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
else
  vim.cmd("qa!")
end

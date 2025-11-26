# Neovim Keybindings Reference

Leader key: `Space`

## File Navigation (Telescope)

| Keybind | Action | Description |
|---------|--------|-------------|
| `<leader>ff` | Find Files | Search for files in current directory |
| `<leader>fg` | Live Grep | Search text in all files |
| `<leader>fb` | Find Buffers | List and switch between open buffers |
| `<leader>fh` | Help Tags | Search help documentation |
| `<leader>fo` | Old Files | Recently opened files |

## File Explorer

| Keybind | Action | Description |
|---------|--------|-------------|
| `<leader>e` | Toggle File Tree | Open/Close NvimTree file explorer |

**Navigation between file tree and editor:**
- Use `Ctrl+h` to move to file tree (left window)
- Use `Ctrl+l` to move back to editor (right window)
- Or use arrow keys in NvimTree and press Enter to open files

**Note:** File tree will NOT auto-open when you type `nvim`. Use `<leader>e` to open it manually.

## Window Navigation

| Keybind | Action | Description |
|---------|--------|-------------|
| `Ctrl+h` | Move Left | Switch to left window |
| `Ctrl+j` | Move Down | Switch to bottom window |
| `Ctrl+k` | Move Up | Switch to top window |
| `Ctrl+l` | Move Right | Switch to right window |

## Buffer Navigation

| Keybind | Action | Description |
|---------|--------|-------------|
| `Shift+h` | Previous Buffer | Go to previous buffer |
| `Shift+l` | Next Buffer | Go to next buffer |

## Tab Navigation

| Keybind | Action | Description |
|---------|--------|-------------|
| `<leader>tn` | Next Tab | Go to next tab |
| `<leader>tp` | Previous Tab | Go to previous tab |
| `<leader>tc` | Close Tab | Close current tab |

## LSP (Language Server Protocol)

| Keybind | Action | Description |
|---------|--------|-------------|
| `gd` | Go to Definition | Jump to symbol definition |
| `gr` | Show References | List all references |
| `K` | Hover Documentation | Show documentation popup |
| `<leader>rn` | Rename | Rename symbol under cursor |
| `<leader>ca` | Code Action | Show available code actions |

## Git Integration

| Keybind | Action | Description |
|---------|--------|-------------|
| `<leader>gg` | LazyGit | Open LazyGit in new tab |
| `<leader>tn` | Next Buffer Tab | Cycle to the next Bufferline tab |
| `<leader>tp` | Previous Buffer Tab | Cycle to the previous Bufferline tab |
| `<leader>tc` | Close Buffer Tab | Pick and close a Bufferline tab |
| `<leader>tt` | Toggle Fish Terminal | Show/hide persistent fish terminal split |
| `<leader>t+` | Grow Terminal | Increase fish terminal height by 5 |
| `<leader>t-` | Shrink Terminal | Decrease fish terminal height by 5 |
| `<leader>tx` | Hide Terminal | Temporarily hide fish terminal (keeps session alive) |
| `<leader>tk` | Kill Terminal | Close fish terminal and end the session |

GitSigns is also enabled for inline git status in the sign column.

**How it works:**
- Opens in a new tab (won't mess with your current layout)
- Press `q` to quit lazygit - tab closes automatically
- Or use `<leader>tc` to manually close the tab
- **Themed with Catppuccin Mocha** to match your Neovim!

## Code Editing

| Keybind | Action | Description |
|---------|--------|-------------|
| `gcc` | Toggle Comment Line | Comment/uncomment current line (Normal mode) |
| `gc` | Toggle Comment Block | Comment/uncomment selection (Visual mode) |

### Visual Mode Indenting

| Keybind | Action | Description |
|---------|--------|-------------|
| `<` | Indent Left | Decrease indentation (keeps selection) |
| `>` | Indent Right | Increase indentation (keeps selection) |

## Search

| Keybind | Action | Description |
|---------|--------|-------------|
| `<leader>h` | Clear Highlight | Remove search highlighting |

## Auto-completion (nvim-cmp)

When the completion menu appears:

| Keybind | Action | Description |
|---------|--------|-------------|
| `↓` or `Ctrl+n` | Next Item | Navigate to next suggestion |
| `↑` or `Ctrl+p` | Previous Item | Navigate to previous suggestion |
| `Tab` | Next | Next item in menu |
| `Shift+Tab` | Previous | Previous item in menu |
| `Enter` | Confirm | Accept selected suggestion |
| `Ctrl+e` | Close | Close completion menu |

**Arrow keys now work!** Use ↑/↓ to navigate completions.

## Additional Features

### Indent Guides & Scope Highlighting
**indent-blankline** plugin is enabled to show:
- Vertical indent guides (│) for better code structure visibility
- Highlighted scope - shows which block/function you're currently in
- Helps track brackets, braces, and code blocks easily

### Auto-pairs
Automatically closes brackets, quotes, and parentheses.

### Which-Key
Press `Space` (leader) and wait briefly to see all available keybindings starting with Space.

### Treesitter
Advanced syntax highlighting and code folding enabled.

## Language Support

Configured languages with LSP, formatting, and diagnostics:
- **Nix** (nixd LSP)
- **Rust** (rust-analyzer)
- **Lua** (lua-language-server)
- **Bash** (shellcheck, shfmt)
- **TypeScript/JavaScript** (tsserver)
- **Python** (pyright)
- **Markdown**
- **YAML/Kubernetes** (yaml-language-server, actionlint)

## AI-Powered Coding

### GitHub Copilot Chat

| Keybind | Action | Description |
|---------|--------|-------------|
| `<leader>cc` | Toggle Chat | Open/close Copilot Chat window |
| `<leader>ce` | Explain | Explain selected code |
| `<leader>cr` | Review | Review selected code |
| `<leader>cf` | Fix | Fix code issues |
| `<leader>co` | Optimize | Optimize selected code |
| `<leader>cd` | Docs | Generate documentation |
| `<leader>ct` | Tests | Generate tests |

**Usage:**
1. Select code in visual mode (`v`)
2. Press one of the keybindings above
3. View AI response in chat window

### Avante.nvim

| Keybind | Action | Description |
|---------|--------|-------------|
| `<leader>aa` | Ask | Chat with AI about code |
| `<leader>ae` | Edit | AI-powered code editing |
| `<leader>ar` | Refresh | Regenerate AI response |
| `<leader>ad` | Debug | Toggle debug mode |

**Diff Navigation:**

| Keybind | Action | Description |
|---------|--------|-------------|
| `co` | Ours | Accept your original code |
| `ct` | Theirs | Accept AI suggestion |
| `cb` | Both | Keep both versions |
| `]x` | Next Conflict | Jump to next diff |
| `[x` | Previous Conflict | Jump to previous diff |
| `]]` | Next Section | Jump to next section |
| `[[` | Previous Section | Jump to previous section |

**Available Models (GitHub Copilot Pro):**
- Claude Sonnet 4.5 (default)
- Claude Haiku 4.5
- Gemini 3 Pro
- GPT-5.1-Codex
- Grok Code Fast 1

**Features:**
- Thinking mode enabled by default for deeper reasoning
- Switch models in Avante interface
- Diff view for code changes

**First-time setup:**
1. Open Neovim: `nvim`
2. Run: `:Copilot auth`
3. Follow browser prompt to authenticate

## Tips

1. **Format on save** is enabled for all languages
2. **Inlay hints** are enabled for supported languages
3. **Diagnostic virtual text** shows errors/warnings inline
4. **Persistent undo** with `undofile` - your changes persist across sessions
5. **Smart case search** - case-insensitive unless you type uppercase

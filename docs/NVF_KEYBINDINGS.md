# Neovim workflow (nvf)

Leader is **Space**. Configuration: `home-manager/common/nvf/settings.nix`.

A keyboard-first workflow inspired by ThePrimeagen and TJ DeVries—not a copy of
anyone's dotfiles. Catppuccin Mocha, Oil, FFF, Telescope, and your existing window
keys stay. Plugins, parsers, language servers, and formatters are pinned by Nix;
there is no Mason or runtime plugin installation step.

## Start here

1. `Space ff` finds a file; `Space fg` searches project text.
2. Mark your working files with `Space a`, then jump with `Space 1`–`4`.
3. Use `gd` / `gr` for definitions / references; `Ctrl+o` jumps back.
4. `Space gp` previews a Git hunk; `Space gs` stages it.
5. `Space cf` formats on demand. **Format-on-save remains off.**

Try without activating a host configuration:

```bash
nix run .#neovim
```

## Find and navigate

| Key | Action |
|-----|--------|
| `Space ff` / `Space fg` | FFF file search / live grep |
| `Space fF` / `Space fG` | Telescope file search / live grep |
| `Space fc` | Search the word under the cursor, or the visual selection |
| `Space f/` | Fuzzy search the current buffer |
| `Space fb` / `Space fo` | Open buffers / recent files |
| `Space fs` / `Space fw` | Document / workspace symbols via Telescope |
| `Space fd` | Search diagnostics |
| `Space fr` / `Space fh` | Resume Telescope / search help |
| `Space e` / `-` | Oil floating explorer / parent directory |
| `Space a` | Add file to this directory's Harpoon list |
| `Ctrl+e` (normal mode) | Edit the Harpoon bookmark list |
| `Space 1`–`Space 4` | Jump to bookmarked files |

Oil: `Enter` opens, `-` goes up, `g.` toggles hidden files, `Ctrl+c` closes.
Telescope keeps standard text previews and uses Chafa for image previews.
Snacks also provides inline/document images on supported terminals such as
Ghostty and Kitty (`:checkhealth snacks` for troubleshooting).

## Editing and movement

| Key / example | Action |
|---------------|--------|
| `Ctrl+h/j/k/l` | Move between splits |
| `Shift+h/l` | Previous / next buffer |
| `Space bd` | Delete a buffer while preserving splits; unsaved changes prompt |
| `Space tn/tp/tc` | Bufferline next / previous / choose a buffer to close (not tabs) |
| `Ctrl+d/u` | Half-page scroll, then center the cursor |
| `n` / `N` | Next / previous match, centered and unfolded |
| `J` / `K` in visual mode | Move selected lines down / up and reindent |
| `<` / `>` in visual mode | Indent and keep the selection |
| `Space p` in visual mode | Paste without replacing the yank register |
| `gcc` / visual `gc` | Toggle comments |
| `ysiw"` | Surround a word with double quotes |
| `cs"'` / `ds"` | Change double quotes to single / delete surrounding quotes |
| `S` in visual mode | Surround a selection |
| `cia` / `cif` | Change an argument / function-call contents (mini.ai) |
| `Space u` | Browse persistent, branching undo history |
| `Space h` | Clear search highlighting |

Treesitter highlights the configured languages. `zc` / `zo` close / open a fold;
`zM` / `zR` close / open all folds. Files start unfolded. A small context header
keeps enclosing code visible in windows tall enough to benefit from it.

## Code, diagnostics, and Git

| Key | Action |
|-----|--------|
| `gd` / `gD` / `gI` / `gy` | Definition / declaration / implementation / type |
| `gr` / `K` | References / hover documentation |
| `Space rn` / `Space ca` | Rename / code action |
| `Space cs` / `Space cf` | Signature help / manual Conform formatting |
| `[d` / `]d` | Previous / next diagnostic, with a popup |
| `Space cd` / `Space cq` | Line diagnostics / diagnostics in quickfix |
| `[q` / `]q` | Previous / next quickfix result |
| `[c` / `]c` | Previous / next Git hunk |
| `Space gp` / `Space gb` | Preview hunk / blame line |
| `Space gs` / `Space gu` | Stage hunk / undo staging |
| `Space gr` / `Space gR` | **Discard** hunk / buffer changes |
| `Space gS` | Stage the entire buffer |
| `Space gd` / `Space gD` | Diff the file / compare against the previous revision |
| `Space gg` | LazyGit floating terminal, integrated with this Neovim instance |

Git actions now use `Space g…`, not the old `Space h…` prefix, so clearing search
with `Space h` is unambiguous. Reset actions discard edits: preview first.

## Completion and snippets

| Key (insert mode) | Action |
|-------------------|--------|
| `Ctrl+Space` | Request completion |
| `Down` / `Up`, `Ctrl+n/p` | Select a completion |
| `Enter` | Accept an explicitly selected completion; otherwise a normal newline |
| `Tab` | Next completion, or expand/jump forward in a snippet |
| `Shift+Tab` | Previous completion, or jump backward in a snippet |
| `Ctrl+e` | Close the completion menu |

## Terminal

| Key | Action |
|-----|--------|
| `Space tt` | Toggle a reusable Fish terminal in a bottom split |
| `Space t+` / `Space t-` | Resize it |
| `Space tx` / `Space tk` | Hide (keep running) / close (stop) it |
| Double `Esc` in terminal mode | Return to normal mode |

## Language support and validation

Nix, Rust, Lua, Bash, TypeScript/JavaScript (including TSX/JSX), Python, Go,
JSON/JSONC, YAML, and Markdown have syntax support. Native nvf presets provide
language tools: nixd, rust-analyzer, lua-language-server, typescript-language-server,
basedpyright, gopls, vscode-json-language-server, and yaml-language-server.
Markdown uses Rumdl for formatting/linting rather than an LSP. Go uses gopls;
project-specific Go linters are intentionally not installed globally.

Helpful commands: `:ConformInfo`, `:checkhealth`, `:checkhealth snacks`.

```bash
nix flake check --all-systems --no-build
# Build and run the isolated headless test for your platform
nix build .#checks.aarch64-darwin.neovim-config --no-link # macOS
nix build .#checks.x86_64-linux.neovim-config --no-link   # Linux
```

The smoke test checks startup, mappings, plugin and parser availability,
completion safety, text/image previews, terminal reuse, and split-preserving
buffer deletion. It uses a temporary HOME/XDG environment, not your editor state.

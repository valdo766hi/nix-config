# NixOS Configuration Management Guidelines

## Quick Reference
```bash
# Most Common Commands
nix flake check                                # Always run first!
sudo nixos-rebuild switch --flake .#thinker    # Apply system changes
home-manager switch --flake .#rivaldo@thinker  # Apply user changes only
git status                                      # Check for untracked files
nix flake update                                # Update all flake inputs
```

## Project Structure & Module Organization
- `flake.nix`: Main entry point defining inputs, outputs, system & home configurations
- `flake.lock`: Pinned dependencies (auto-updated with `nix flake update`)
- `nixos/`: System-level configuration
  - `configuration.nix`: Core system settings (bootloader, networking, services, users)
  - Additional system modules imported here
- `home-manager/`: User-level configuration
  - Tool modules: `fish.nix`, `packages.nix`, `yazi.nix`, `bat.nix`, etc.
  - Asset folders: `yazi/`, `bat/`, `niri/`, `nvf/` (keep assets next to their module)
  - `home.nix`: Main home-manager entry point
- `modules/`: Custom NixOS modules (import from main config)

## Pre-Change Checklist
Before making ANY changes:
1. Run `nix flake check` to ensure current state is valid
2. Check `git status` for untracked files (they break builds!)
3. Review ESP space if touching bootloader: `df -h /boot`
4. Backup important configs if making risky changes

## Common Operations

### Adding a New Package
```nix
# In home-manager/packages.nix or appropriate module
home.packages = with pkgs; [
  existing-package
  new-package  # Add here, check for conflicts
];
```

### Creating a New Module
1. Create file in `home-manager/` (user) or `modules/` (system)
2. Import in `home.nix` or `configuration.nix` respectively
3. Use this template:
```nix
{ config, pkgs, lib, ... }:
{
  # Module configuration here
}
```

### Overriding a Package
```nix
# Prefer explicit overrides in modules
programs.yazi = {
  enable = true;
  package = pkgs.yazi.override { _7zz = pkgs._7zz-rar; };
};
```

## Neovim Keymaps Reference

### File Navigation & Search (Telescope)
- `<leader>ff` - Find files
- `<leader>fg` - Live grep (search in files)
- `<leader>fb` - Find buffers
- `<leader>fh` - Help tags
- `<leader>fo` - Recent files

### File Tree
- `<leader>e` - Toggle NvimTree (open/close)

### Window Navigation
- `<C-h>` - Move to left window
- `<C-j>` - Move to bottom window
- `<C-k>` - Move to top window
- `<C-l>` - Move to right window

### Buffer Navigation
- `<S-l>` - Next buffer
- `<S-h>` - Previous buffer
- `<leader>tn` - Next buffer tab
- `<leader>tp` - Previous buffer tab
- `<leader>tc` - Close buffer tab

### Git & Terminal
- `<leader>gg` - Open LazyGit in new tab
- `<leader>tt` - Toggle fish terminal
- `<leader>t+` - Increase terminal height
- `<leader>t-` - Decrease terminal height
- `<leader>tx` - Hide fish terminal
- `<leader>tk` - Kill fish terminal session

### LSP (Language Server Protocol)
- `gd` - Go to definition
- `gr` - Show references
- `K` - Show hover documentation
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code action

### GitHub Copilot Chat
- `<leader>cc` - Toggle Copilot Chat window
- `<leader>ce` - Explain selected code
- `<leader>cr` - Review selected code
- `<leader>cf` - Fix code issues
- `<leader>co` - Optimize code
- `<leader>cd` - Generate documentation
- `<leader>ct` - Generate tests

### Avante.nvim (AI-Powered Coding)
- `<leader>aa` - Ask Avante (chat with AI about code)
- `<leader>ae` - Edit with Avante (AI code editing)
- `<leader>ar` - Refresh Avante response
- `<leader>ad` - Toggle debug mode
- `co` - Accept "ours" in diff
- `ct` - Accept "theirs" in diff
- `cb` - Accept both in diff
- `]x` - Next diff conflict
- `[x` - Previous diff conflict
- `]]` - Jump to next section
- `[[` - Jump to previous section

### Other
- `<leader>h` - Clear search highlight

## Beginner's Guide: Using Avante & CopilotChat

### Prerequisites
After applying the configuration with `home-manager switch --flake .#rivaldo@thinker`, you need to authenticate GitHub Copilot:
1. Open Neovim: `nvim`
2. Run: `:Copilot auth`
3. Follow the browser prompt to authenticate with your GitHub account

### Using CopilotChat (Quick AI Assistance)

**Best for:** Quick questions, explanations, code reviews, and generating tests/docs

#### Basic Workflow:
1. **Open CopilotChat**: Press `<Space>cc` (leader is Space)
   - A chat window will open on the side

2. **Ask about code**:
   - Select code in visual mode (`v` to enter visual mode)
   - Press `<Space>ce` to explain the selected code
   - Press `<Space>cr` to review the code
   - Press `<Space>cf` to fix issues
   - Press `<Space>co` to optimize code

3. **Generate docs/tests**:
   - Select a function or code block
   - Press `<Space>cd` to generate documentation
   - Press `<Space>ct` to generate tests

4. **General questions**:
   - Type your question in the chat window
   - Press Enter to send

#### Example Use Cases:
- "Explain what this function does" → Select code, press `<Space>ce`
- "Find bugs in this code" → Select code, press `<Space>cr`
- "Add error handling" → Select code, press `<Space>cf`
- "Write unit tests" → Select function, press `<Space>ct`

### Using Avante.nvim (Advanced AI Coding)

**Best for:** Complex refactoring, architectural changes, implementing features with AI thinking enabled

#### Available Models (via GitHub Copilot Pro):
- **Claude Sonnet 4.5** (default) - Best for complex reasoning
- **Claude Haiku 4.5** - Fast responses
- **Gemini 3 Pro** - Google's model
- **GPT-5.1-Codex** - OpenAI's code model
- **Grok Code Fast 1** - xAI's fast model

#### Basic Workflow:

1. **Start Avante**: Press `<Space>aa`
   - A sidebar will open with AI chat interface
   - Thinking mode is enabled by default for deeper reasoning

2. **Ask AI to edit code**:
   - Select code in visual mode
   - Press `<Space>ae` to let AI edit it
   - AI will suggest changes with diff view

3. **Review and apply changes**:
   - Avante shows a diff of proposed changes
   - `co` - Keep your original code ("ours")
   - `ct` - Accept AI's suggestion ("theirs")
   - `cb` - Keep both versions
   - `]x` / `[x` - Navigate between conflicts

4. **Switching models**:
   - In Avante window, you can type commands like:
     - `:AvanteSwitch claude-haiku-4.5` - Switch to faster model
     - `:AvanteSwitch gpt-5.1-codex` - Switch to GPT model
     - `:AvanteSwitch gemini-3-pro` - Switch to Gemini

5. **Refresh response**: Press `<Space>ar` if you want AI to regenerate

#### Example Use Cases:
- "Refactor this function to use async/await" → Select function, `<Space>ae`
- "Convert this class to use TypeScript" → Select class, `<Space>aa`, describe task
- "Add error handling and logging throughout" → Select code, `<Space>ae`
- "Implement authentication for this API" → `<Space>aa`, describe requirements

### When to Use Which Tool?

| Task | Use | Why |
|------|-----|-----|
| Quick explanation | CopilotChat (`<Space>ce`) | Fast, focused answers |
| Code review | CopilotChat (`<Space>cr`) | Quick feedback |
| Bug fixes | CopilotChat (`<Space>cf`) | Simple fixes |
| Complex refactoring | Avante (`<Space>ae`) | Better for multi-step changes |
| Implementing features | Avante (`<Space>aa`) | Thinking mode for planning |
| Generating tests | CopilotChat (`<Space>ct`) | Quick test generation |
| Architecture questions | Avante (`<Space>aa`) | Deeper reasoning with thinking |

### Tips for Better Results:

1. **Be specific**: Instead of "fix this", say "add null checks and error handling"
2. **Provide context**: Select relevant code around the area you're working on
3. **Use thinking mode**: Avante's thinking is enabled by default for complex tasks
4. **Try different models**:
   - Claude Sonnet for complex logic
   - Claude Haiku for speed
   - GPT-Codex for code generation
   - Gemini for alternative perspectives
5. **Iterate**: Review AI suggestions and ask follow-up questions
6. **Visual mode**: Always select code before using commands like `<Space>ce`, `<Space>ae`

### Troubleshooting:

- **Copilot not working**: Run `:Copilot status` to check authentication
- **Avante not responding**: Check `:messages` for errors
- **Model not available**: Ensure GitHub Copilot Pro subscription is active
- **Slow responses**: Try switching to Claude Haiku or Grok Code Fast

## Coding Style & Best Practices
- **Indentation**: 2 spaces, consistent throughout
- **Attributes**: Group logically, sort alphabetically within groups
- **Imports**: Be explicit, avoid `with` unless it significantly reduces duplication
- **Package references**: Use explicit `pkgs.packageName`
- **Wrapper names**: Keep short/lowercase (`y` for Yazi wrapper)
- **Avoid duplicates**: One source per package (prevents path conflicts)
- **Asset management**: Track all new files with `git add` immediately

## Testing & Validation

### Build Validation
```bash
# Always run these in order:
nix flake check                                 # Catch syntax/eval errors
sudo nixos-rebuild dry-build --flake .#thinker  # Test system build
home-manager build --flake .#rivaldo@thinker    # Test home build
```

### Manual Smoke Tests After Changes
- Yazi: `y` command works and returns to last directory
- Bat: `bat --list-themes | grep Catppuccin` shows theme
- Fish: Shell loads with correct prompt/aliases
- Bootloader: Entries appear correctly (check ESP space!)

## Critical Safety Notes

### ESP/Bootloader Constraints
- **ESP Size**: ~247MB - CRITICAL LIMIT!
- Keep `boot.loader.systemd-boot.configurationLimit = 5` or lower
- Clean old generations if space errors: `sudo nix-collect-garbage --delete-older-than 7d`
- Check space before bootloader changes: `df -h /boot`

### Network & Downloads
- Pin all downloaded sources with hashes
- Avoid network fetches at build time
- Use `fetchFromGitHub` with `rev` and `sha256`

### Package Management
- Use Home Manager modules over `home.packages` when module exists
- Never duplicate package installations (causes conflicts)
- Check for existing packages: `nix-env -q | grep package-name`

## Troubleshooting

### Common Issues & Solutions
| Issue | Solution |
|-------|----------|
| "No space left on /boot" | Run `sudo nix-collect-garbage -d` then rebuild |
| "Untracked files" error | `git add` the files or add to `.gitignore` |
| "Attribute not found" | Check spelling, ensure module is imported |
| "Infinite recursion" | Look for circular dependencies in configs |
| Build succeeds but app missing | Check PATH, may need shell reload |

### Debugging Commands
```bash
nix repl '<nixpkgs>'          # Interactive Nix exploration
nix-store --verify --check-contents  # Verify store integrity
nix why-depends <path1> <path2>      # Dependency analysis
journalctl -xe                       # System service logs
```

## Commit & PR Guidelines

### Commit Messages
- Present tense, imperative mood ("Add", "Fix", "Update", not "Added", "Fixed")
- Format: `<verb> <what> [where]`
- Examples:
  - Good: `Add Catppuccin theme to bat`
  - Good: `Fix bootloader space constraints`
  - Bad: `Updated some configs`

### Pull Request Template
```markdown
## Changes
- Main change description
- Secondary changes

## Testing
- [ ] `nix flake check` passes
- [ ] System rebuild tested
- [ ] Home-manager rebuild tested
- [ ] Manual smoke tests performed

## Risks
- Bootloader: [yes/no]
- System services: [affected services]
- User environment: [affected tools]
```

## Agent Learning Log
*Append lessons learned here immediately to preserve knowledge:*

- **2025-11-26**: Both CLAUDE.md and AGENTS.md must stay synchronized for multi-agent collaboration
- **Bootloader**: ESP is only ~247M, always check space before changes
- **Packages**: Avoid duplicates - one source per tool, use overrides in modules
- **Assets**: Untracked files break flake builds, always `git add` new themes/configs
- **Wrapper naming**: Keep it minimal (e.g., `y` for yazi, not `yazi-wrapper`)

## Rollback Procedures
If something goes wrong:
```bash
# List previous generations
sudo nix-env --list-generations -p /nix/var/nix/profiles/system

# Rollback system
sudo nixos-rebuild switch --rollback --flake .#thinker

# Rollback home-manager
home-manager generations  # list
home-manager switch --flake .#rivaldo@thinker --rollback

# Nuclear option: boot previous generation from bootloader menu
```

## Essential Resources
- [NixOS Options Search](https://search.nixos.org/options)
- [Nixpkgs Search](https://search.nixos.org/packages)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
- [Nix Pills](https://nixos.org/guides/nix-pills/) - Deep understanding
- Local flake: Check `flake.nix` for current input versions

---
*Remember: When in doubt, `nix flake check` first, ask questions second!*
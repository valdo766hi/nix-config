{...}: {
  imports = [
    ./atuin.nix
    ./bat.nix
    ./changes-report.nix
    ./claude-code/default.nix
    ./codex/default.nix
    ./dotfiles.nix
    ./eza.nix
    ./git.nix
    ./ghostty.nix
    ./herdr.nix
    ./hunk.nix
    ./kitty.nix
    ./lazygit.nix
    ./nh.nix
    ./nix-index.nix
    ./opencode/default.nix
    ./pi/default.nix
    ./pig/default.nix
    ./nvf/default.nix
    ./nushell.nix
    ./packages.nix
    ./palette.nix
    ./shell.nix
    ./ssh.nix
    ./starship.nix
    ./tmux.nix
    ./yazi/default.nix
    ./zoxide.nix
  ];

  home.file.".gemini/GEMINI.md".source = ./agent-instructions.md;
  home.file.".codex/AGENTS.md".source = ./agent-instructions.md;
}

{...}: {
  imports = [
    ./atuin.nix
    ./bat.nix
    ./claude-code/default.nix
    ./codex/default.nix
    ./eza.nix
    ./git.nix
    ./ghostty.nix
    ./herdr.nix
    ./hunk.nix
    ./kitty.nix
    ./lazygit.nix
    ./opencode/default.nix
    ./pi/default.nix
    ./pig/default.nix
    ./nvf/default.nix
    ./nushell.nix
    ./packages.nix
    ./shell.nix
    ./ssh.nix
    ./starship.nix
    ./tmux.nix
    ./yazi/default.nix
    #./zed.nix
    ./zoxide.nix
  ];

  home.file.".gemini/GEMINI.md".source = ./agent-instructions.md;
}

{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set -gx TERM "xterm-256color"

      ${lib.optionalString pkgs.stdenv.isLinux ''
        set -gx PATH ~/.npm-global/bin $PATH
      ''}

      set fish_greeting

      if test -f ~/.config/fish/secrets.fish
        source ~/.config/fish/secrets.fish
      end

      function envsource
        if test (count $argv) -eq 0; or test "$argv[1]" = "--help"
          echo "Usage: envsource <file>"
          echo ""
          echo "Source bash-style environment files in fish shell"
          echo ""
          echo "Example:"
          echo "  envsource .env"
          echo "  envsource /path/to/my-vars.env"
          echo ""
          echo "Supports formats:"
          echo "  KEY=value"
          echo "  export KEY=value"
          echo '  KEY="value"'
          echo "  KEY='value'"
          return 0
        end

        set -l envfile $argv[1]
        if not test -f $envfile
          echo "Error: File '$envfile' not found"
          return 1
        end

        for line in (cat $envfile | grep -v '^#' | grep -v '^$')
          set item (string split -m 1 '=' -- $line)
          set -l value (string trim --chars='\'"' -- $item[2])
          set -gx $item[1] $value
        end
        echo "Sourced $envfile"
      end

      atuin init fish | sed "s/-k up/up/g" | source

      ${lib.optionalString pkgs.stdenv.isDarwin ''
        eval (/opt/homebrew/bin/brew shellenv fish)

        if test -f /opt/homebrew/opt/asdf/libexec/asdf.fish
          source /opt/homebrew/opt/asdf/libexec/asdf.fish
        end
      ''}

      zoxide init fish | source
      starship init fish | source
    '';

    shellAliases = {
      rebuild = "${if pkgs.stdenv.isLinux then "cd ~/.config/nixos && sudo nixos-rebuild switch --flake .#thinker" else "cd ~/.config/nix-config && darwin-rebuild switch --flake .#darwin"}";
      update-flake = "${if pkgs.stdenv.isLinux then "cd ~/.config/nixos && nix flake update" else "cd ~/.config/nix-config && nix flake update"}";
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph";
      ll = "ls -la";
      vim = "nvim";
      nv = "nvim";
      cd = "z";
      ff = "fastfetch";
    } // lib.optionalAttrs pkgs.stdenv.isLinux {
      bjg = "echo I use NixOS, BTW";
    };
  };
}

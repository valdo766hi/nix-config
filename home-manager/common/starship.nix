{config, ...}: let
  p = config.palette;
in {
  programs.starship = {
    enable = true;
    enableFishIntegration = false;

    settings = {
      add_newline = true;
      format = "$directory${"$"}{custom.dir_endcap}$git_branch$git_status${"$"}{fill}$time\n\n$character";

      character = {
        error_symbol = "[❯](bold fg:${p.red}) ";
        success_symbol = "[❯](bold fg:${p.mauve}) ";
      };

      directory = {
        format = "[ $path ]($style)";
        home_symbol = "~";
        style = "bold fg:${p.subtext0} bg:${p.surface0}";
        truncate_to_repo = false;
        truncation_length = 4;
        truncation_symbol = ".../";
      };

      custom.dir_endcap = {
        command = "echo \"\"";
        format = "[$output](fg:${p.surface0})";
        when = "test -z \"$(git rev-parse --is-inside-work-tree 2>/dev/null)\"";
      };

      git_branch = {
        format = "[](fg:${p.surface0} bg:${p.mauve})[ $symbol $branch ]($style)[](fg:${p.mauve})";
        style = "bold fg:${p.base} bg:${p.mauve}";
        symbol = "";
      };

      git_status = {
        format = " $all_status$ahead_behind";
        conflicted = "[x](bold fg:${p.red})";
        untracked = "[?](bold fg:${p.red})";
        modified = "[!](bold fg:${p.yellow})";
        staged = "[+](bold fg:${p.green})";
        renamed = "";
        deleted = "";
        stashed = "";
        ahead = "[⇡](bold fg:${p.green})";
        behind = "[⇣](bold fg:${p.red})";
        diverged = "[⇕](bold fg:${p.peach})";
        up_to_date = "";
      };

      fill = {
        symbol = " ";
      };

      time = {
        disabled = false;
        format = "[$time]($style)";
        style = "bold fg:${p.mauve}";
        time_format = "%a %b %d %T %:z";
      };
    };
  };
}

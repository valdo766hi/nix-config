{
  config,
  pkgs,
  ...
}: {
  programs.starship = {
    enable = true;
    enableFishIntegration = false;

    settings = {
      add_newline = true;
      format = "$directory${"$"}{custom.dir_endcap}$git_branch$git_status\n\n$character";
      right_format = "$time";

      character = {
        error_symbol = "[❯](bold fg:#f38ba8) ";
        success_symbol = "[❯](bold fg:#cba6f7) ";
      };

      directory = {
        format = "[ $path ]($style)";
        home_symbol = "~";
        style = "bold fg:#a6adc8 bg:#313244";
        truncate_to_repo = false;
        truncation_length = 4;
        truncation_symbol = ".../";
      };

      custom.dir_endcap = {
        command = "echo \"\"";
        format = "[$output](fg:#313244)";
        when = "test -z \"$(git rev-parse --is-inside-work-tree 2>/dev/null)\"";
      };

      git_branch = {
        format = "[](fg:#313244 bg:#cba6f7)[ $symbol $branch ]($style)[](fg:#cba6f7)";
        style = "bold fg:#1e1e2e bg:#cba6f7";
        symbol = "";
      };

      git_status = {
        format = " $all_status$ahead_behind";
        conflicted = "[x](bold fg:#f38ba8)";
        untracked = "[?](bold fg:#f38ba8)";
        modified = "[!](bold fg:#f9e2af)";
        staged = "[+](bold fg:#a6e3a1)";
        renamed = "";
        deleted = "";
        stashed = "";
        ahead = "[⇡](bold fg:#a6e3a1)";
        behind = "[⇣](bold fg:#f38ba8)";
        diverged = "[⇕](bold fg:#fab387)";
        up_to_date = "";
      };

      time = {
        disabled = false;
        format = "[$time]($style)";
        style = "bold fg:#cba6f7";
        time_format = "%a %b %d %T %:z";
      };
    };
  };
}

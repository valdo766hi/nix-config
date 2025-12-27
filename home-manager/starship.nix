# Starship
{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      add_newline = true;
      format = "$directory$git_branch$git_status$status\n\n$character";
      right_format = "$time";

      character = {
        error_symbol = "[❯](bold fg:#f38ba8) ";
        success_symbol = "[❯](bold fg:#cba6f7) ";
      };

      directory = {
        format = "[ $path ]($style)[](fg:#313244 bg:#cba6f7)";
        home_symbol = "~";
        style = "bold fg:#a6adc8 bg:#313244";
        truncate_to_repo = false;
        truncation_length = 4;
        truncation_symbol = ".../";
      };

      git_branch = {
        format = "[ $symbol $branch ]($style)[](fg:#cba6f7)";
        style = "bold fg:#1e1e2e bg:#cba6f7";
        symbol = "";
      };

      git_status = {
        format = " $all_status$ahead_behind";
        conflicted = "[!](bold fg:#f38ba8)";
        untracked = "[?](bold fg:#f38ba8)";
        modified = "[!](bold fg:#f9e2af)";
        staged = "[+](bold fg:#a6e3a1)";
        renamed = "";
        deleted = "";
        stashed = "";
        ahead = "[⇡](bold fg:#a6e3a1)";
        behind = "[⇣](bold fg:#f38ba8)";
        diverged = "[⇕](bold fg:#fab387)";
        up_to_date = "[✓](bold fg:#a6e3a1)";
      };

      status = {
        disabled = false;
        format = "[](fg:#b4befe bg:#f38ba8)[ $status ]($style)[](fg:#f38ba8)";
        style = "fg:#1e1e2e bg:#f38ba8";
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

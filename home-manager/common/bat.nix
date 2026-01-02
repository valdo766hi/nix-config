{...}: {
  programs.bat = {
    enable = true;
    themes = {
      "Catppuccin Mocha" = {
        src = ./Catppuccin-mocha.tmTheme;
      };
    };
    config = {
      theme = "Catppuccin Mocha";
      style = "plain";
      pager = "never";
    };
  };
}

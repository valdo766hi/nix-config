# Yazi - Terminal file manager
{pkgs, ...}: {
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "y";
    package = pkgs.yazi.override {_7zz = pkgs._7zz-rar;};

    settings = {
      mgr = {
        sort_by = "mtime";
        sort_reverse = false;
        sort_sensitive = false;
        linemode = "size";
      };
      preview = {
        max_width = 1000;
        max_height = 1000;
      };
    };
  };

  xdg.configFile."yazi/theme.toml".source = ./catppuccin-mocha-mauve.toml;
}

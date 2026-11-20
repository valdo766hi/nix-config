{
  config,
  pkgs,
  ...
}: let
  p = config.palette;
in {
  programs.lazygit = {
    enable = true;
    settings = {
      gui.theme = {
        activeBorderColor = [p.blue "bold"];
        inactiveBorderColor = [p.subtext0];
        searchingActiveBorderColor = [p.yellow "bold"];
        optionsTextColor = [p.blue];
        selectedLineBgColor = [p.surface0];
        selectedRangeBgColor = [p.surface0];
        cherryPickedCommitBgColor = [p.surface1];
        cherryPickedCommitFgColor = [p.blue];
        unstagedChangesColor = [p.red];
        defaultFgColor = [p.text];
      };
      git.diffRenderers = [
        {
          colorArg = "always";
          command = "${pkgs.delta}/bin/delta --dark --paging=never";
        }
      ];
    };
  };

  home.file."${config.xdg.configHome}/lazygit/config.yml".force = true;
}

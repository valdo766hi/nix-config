{lib, ...}: {
  xdg.configFile."lazygit/config.yml" = {
    force = true;
    text = ''
      gui:
        theme:
          activeBorderColor:
            - '#89b4fa'
            - bold
          inactiveBorderColor:
            - '#a6adc8'
          searchingActiveBorderColor:
            - '#f9e2af'
            - bold
          optionsTextColor:
            - '#89b4fa'
          selectedLineBgColor:
            - '#313244'
          selectedRangeBgColor:
            - '#313244'
          cherryPickedCommitBgColor:
            - '#45475a'
          cherryPickedCommitFgColor:
            - '#89b4fa'
          unstagedChangesColor:
            - '#f38ba8'
          defaultFgColor:
            - '#cdd6f4'
      git:
        pagers:
          - colorArg: always
            pager: delta --dark --paging=never
    '';
  };
}

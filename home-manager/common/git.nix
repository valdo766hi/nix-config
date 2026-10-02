{...}: {
  programs.git = {
    enable = true;

    includes = [
      {
        condition = "gitdir:~/Documents/Work/";
        contents.user = {
          name = "rivaldo-straitpoint";
          email = "rivaldo.silalahi@straitpoint.com";
        };
      }
    ];

    settings = {
      user = {
        name = "valdo766hi";
        email = "rivaldosilalahi13@gmail.com";
      };

      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        lg = "log --oneline --graph --decorate --all";
        amend = "commit --amend --no-edit";
      };

      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "nvim";
      diff.algorithm = "histogram";
      push.autoSetupRemote = true;
    };
  };
}

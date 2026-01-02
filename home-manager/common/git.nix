{
  config,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "vldo766hi";
        email = "rivaldo.silalahi@lintasarta.co.id";
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

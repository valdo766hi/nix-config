{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    mouse = true;

    extraConfig = ''
      set -g extended-keys always
    '';
  };
}

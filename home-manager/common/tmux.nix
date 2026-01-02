{
  config,
  pkgs,
  ...
}: {
  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    mouse = true;

    extraConfig = ''
      set -g default-shell ${pkgs.fish}/bin/fish
    '';
  };
}

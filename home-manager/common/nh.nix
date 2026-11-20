{config, ...}: {
  # `nh os switch` / `nh darwin switch`: build progress, a closure diff, then activation.
  programs.nh = {
    enable = true;
    flake = config.dotfiles.path;
  };
}

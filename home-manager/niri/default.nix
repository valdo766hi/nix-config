{...}: {
  programs.niri.config = builtins.readFile ./niri-config.kdl;

  xdg.configFile."niri/dms/binds.kdl" = {
    source = ./dms/binds.kdl;
    force = true;
  };
}

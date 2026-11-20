{
  config,
  lib,
  ...
}: let
  cfg = config.dotfiles;
in {
  options.dotfiles = {
    mutable = lib.mkEnableOption "linking dotfiles to the repository checkout, so edits apply without a rebuild";

    path = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.configHome}/nix";
      description = "Where this repository is checked out.";
    };

    make = lib.mkOption {
      type = lib.types.functionTo lib.types.raw;
      readOnly = true;
      description = "Turns a repository file into a Home Manager source: its store copy, or a link to the checkout when mutable.";
    };
  };

  config.dotfiles.make = file:
    if cfg.mutable
    then config.lib.file.mkOutOfStoreSymlink "${cfg.path}/${lib.removePrefix "./" (lib.path.removePrefix ../.. file)}"
    else file;
}

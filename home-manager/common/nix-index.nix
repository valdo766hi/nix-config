{inputs, ...}: {
  imports = [inputs.nix-index-database.homeModules.default];

  # Prebuilt index: unknown commands name their package, and `, <cmd>` runs one uninstalled.
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;
}

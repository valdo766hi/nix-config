{lib, ...}: {
  programs.winapps = {
    enable = true;
    manageConfigFile = false;
    manageComposeFile = false;
  };
}

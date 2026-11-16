{...}: {
  programs.herdr = {
    enable = true;
    settings.onboarding = false;
    settings.terminal.default_shell = "fish";
  };

  xdg.configFile."herdr-core/config.toml".text = ''
    shell = ["fish"]
  '';
}

{...}: {
  programs.herdr = {
    enable = true;
    settings.onboarding = false;
    settings.terminal.default_shell = "fish";
  };
}

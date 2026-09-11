{...}: {
  homebrew = {
    casks = ["omniwm"];
  };

  launchd.user.agents.omniwm.serviceConfig = {
    ProgramArguments = [
      "/usr/bin/open"
      "-a"
      "OmniWM"
    ];
    ProcessType = "Interactive";
    RunAtLoad = true;
  };
}

{
  inputs,
  ...
}: {
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  nix-homebrew = {
    enable = true;
    user = "rivaldo";
    enableRosetta = true;
    autoMigrate = false;

    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = false;
  };

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      cleanup = "uninstall";
      upgrade = true;
    };

    brews = [
      "mole"
      "tailscale"
      "uv"
    ];

    casks = [
      "chatgpt"
      "grok-bot"
      "ghostty"
      "google-chrome"
      "iterm2"
      "keepassxc"
      "obs"
      "pritunl"
      "raycast"
      "telegram"
      "vlc"
      "cursor"
    ];

    taps = [
      "homebrew/core"
      "homebrew/cask"
    ];
  };
}

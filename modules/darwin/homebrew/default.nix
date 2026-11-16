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
      "nolight132/homebrew-tap" = inputs.sonora-homebrew;
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
      "claude"
      "grok-bot"
      "ghostty"
      "google-chrome"
      "herdr-app"
      "iterm2"
      "keepassxc"
      "obs"
      "pritunl"
      "raycast"
      "nolight132/tap/sonora"
      "telegram"
      "vlc"
      "cursor"
    ];

    taps = [
      "homebrew/core"
      "homebrew/cask"
      "nolight132/tap"
    ];
  };
}

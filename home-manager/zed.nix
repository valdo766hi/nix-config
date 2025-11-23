# Zed
{
  config,
  pkgs,
  ...
}: {
  programs.zed-editor = {
    enable = true;
    extensions = ["nix" "make"];
    userSettings = {
      assistant = {
        enable = true;
        version = "2";

        default_model = {
          provider = "zed.dev";
          model = "claude-4-5-sonnet-latest";
        };
      };
    };
  };
}

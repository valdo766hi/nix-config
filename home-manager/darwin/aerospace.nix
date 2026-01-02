{ pkgs, lib, ... }:

let
  exec = cmd: "exec-and-forget ${cmd}";
  openApp = app: exec ''open -a "${app}"'';
  openAppNew = app: exec ''open -n -a "${app}"'';

  restartAerospace =
    exec ''launchctl kickstart -k "gui/$(id -u)/org.nixos.aerospace"'';
  stopAerospace =
    exec ''launchctl bootout gui/$(id -u)/org.nixos.aerospace'';

  lockScreen = exec "pmset displaysleepnow";

  floatApps = [
    "System Settings"
    "System Preferences"
    "System Information"
    "Activity Monitor"
    "Calculator"
    "Finder"
    "Archive Utility"
    "App Store"
    "KeePassXC"
  ];

  floatRules = map
    (name: {
      "if" = { "app-name-regex-substring" = name; };
      run = "layout floating";
      "check-further-callbacks" = true;
    })
    floatApps;

in {
  services.aerospace = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    package = pkgs.aerospace;

    settings = {
      start-at-login = false;
      key-mapping.preset = "qwerty";

      gaps = {
        inner = {
          horizontal = 12;
          vertical = 12;
        };
        outer = {
          left = 12;
          right = 12;
          top = 12;
          bottom = 12;
        };
      };

      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";

      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

      mode.main.binding = {
        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";

        alt-shift-h = "swap left";
        alt-shift-j = "swap down";
        alt-shift-k = "swap up";
        alt-shift-l = "swap right";

        alt-ctrl-h = "move left";
        alt-ctrl-j = "move down";
        alt-ctrl-k = "move up";
        alt-ctrl-l = "move right";

        alt-shift-r = "resize width +120";
        alt-shift-e = "resize height +120";

        alt-q = "close";
        alt-f = "fullscreen";
        alt-shift-f = "macos-native-fullscreen";
        alt-shift-space = "layout floating tiling";
        alt-e = "layout horizontal vertical";
        alt-shift-b = "balance-sizes";

        alt-enter = openAppNew "Ghostty";
        alt-b = openApp "Zen";
        alt-d = openApp "Spotlight";

        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";

        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";
        alt-shift-8 = "move-node-to-workspace 8";
        alt-shift-9 = "move-node-to-workspace 9";

        alt-tab = "workspace-back-and-forth";
        alt-p = "workspace --wrap-around prev";
        alt-n = "workspace --wrap-around next";

        ctrl-alt-n = "workspace --wrap-around next";
        ctrl-alt-x = "workspace --wrap-around prev";

        ctrl-alt-1 = "focus-monitor 1";
        ctrl-alt-2 = "focus-monitor 2";
        ctrl-alt-3 = "focus-monitor 3";

        ctrl-shift-alt-1 = "move-node-to-monitor 1";
        ctrl-shift-alt-2 = "move-node-to-monitor 2";
        ctrl-shift-alt-3 = "move-node-to-monitor 3";

        alt-shift-t = "layout tiling floating";
        alt-r = "layout tiles horizontal vertical";

        ctrl-shift-alt-r = restartAerospace;
        ctrl-shift-alt-q = stopAerospace;

        alt-shift-esc = lockScreen;
      };

      "on-window-detected" = floatRules;
    };
  };
}

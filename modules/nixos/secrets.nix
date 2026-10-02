{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/home/rivaldo/.config/sops/age/keys.txt";

    secrets = {
      shell_secrets = {};
      ssh_config = {};
      winapps_rdp_user = {
        owner = "rivaldo";
        group = "users";
        mode = "0400";
      };
      winapps_rdp_pass = {
        owner = "rivaldo";
        group = "users";
        mode = "0400";
      };
    };

    templates = {
      "shell-secrets" = {
        content = config.sops.placeholder.shell_secrets;
        owner = "rivaldo";
        group = "users";
        mode = "0400";
        path = "/home/rivaldo/.config/shell-secrets.env";
      };

      "ssh-config" = {
        content = config.sops.placeholder.ssh_config;
        owner = "rivaldo";
        group = "users";
        mode = "0400";
      };

      "winapps.conf" = {
        content = ''
          # Read at runtime so secret values cannot alter shell syntax.
          RDP_USER="$(cat /run/secrets/winapps_rdp_user)"
          RDP_PASS="$(cat /run/secrets/winapps_rdp_pass)"
          RDP_DOMAIN=""
          RDP_IP="127.0.0.1"
          VM_NAME="RDPWindows"
          WAFLAVOR="podman"
          RDP_SCALE="100"
          REMOVABLE_MEDIA="/run/media"
          RDP_FLAGS="/cert:tofu /sound /microphone +home-drive"
          RDP_FLAGS_NON_WINDOWS=""
          RDP_FLAGS_WINDOWS=""
          DEBUG="true"
          AUTOPAUSE="off"
          AUTOPAUSE_TIME="300"
          FREERDP_COMMAND=""
          PORT_TIMEOUT="5"
          RDP_TIMEOUT="30"
          APP_SCAN_TIMEOUT="60"
          BOOT_TIMEOUT="120"
          HIDEF="on"
        '';
        owner = "rivaldo";
        group = "users";
        mode = "0600";
        path = "/home/rivaldo/.config/winapps/winapps.conf";
      };
    };
  };
}

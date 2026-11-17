{inputs, ...}: {
  imports = [
    ./hardware-configuration.nix
    inputs.self.nixosModules.common
    inputs.self.nixosModules.desktop
    inputs.self.nixosModules.secrets
    inputs.self.nixosModules.virtualisation
  ];

  networking.hostName = "thinker";
}

{inputs, ...}: {
  imports = [
    inputs.self.darwinModules.omniwm
    inputs.self.darwinModules.common
    inputs.self.darwinModules.homebrew
    inputs.self.darwinModules.secrets
  ];
}

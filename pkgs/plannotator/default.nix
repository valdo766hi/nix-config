{
  fetchurl,
  stdenvNoCC,
}: let
  version = "0.27.19";
  sources = {
    x86_64-linux = {
      asset = "plannotator-linux-x64";
      hash = "sha256-eEeDBiIdD/LEdGy4qqA+gSTuMNLHkCGROpIM8t04dO4=";
    };
    aarch64-darwin = {
      asset = "plannotator-darwin-arm64";
      hash = "sha256-AjuEKevn1agh+Giv0y0TMaQAvIJ6/YwVptmYxvJfwkA=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
in
  stdenvNoCC.mkDerivation {
    pname = "plannotator";
    inherit version;
    src = fetchurl {
      url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/${source.asset}";
      inherit (source) hash;
    };
    dontUnpack = true;
    installPhase = ''
      mkdir -p "$out/bin"
      cp "$src" "$out/bin/plannotator"
      chmod +x "$out/bin/plannotator"
    '';
  }

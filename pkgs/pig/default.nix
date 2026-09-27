{
  fetchurl,
  lib,
  stdenvNoCC,
}:
let
  version = "0.2.0";
  sources = {
    x86_64-linux = {
      archive = "linux-amd64";
      hash = "sha256-Mt6g5pOsVR4hAJXRBQU9FosXBUqDF/QQ1USh2+vFSMU=";
    };
    aarch64-darwin = {
      archive = "darwin-arm64";
      hash = "sha256-ho2Zf8DvfyW+QPF5lP3dKcZU1EcdxSJkzz/iY68wXGs=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system}
    or (throw "pig is not packaged for ${stdenvNoCC.hostPlatform.system} in this repository");
in
stdenvNoCC.mkDerivation {
  pname = "pig";
  inherit version;

  src = fetchurl {
    url = "https://github.com/MichaelKinsy/PiG/releases/download/v${version}/pig-${version}-${source.archive}.tar.gz";
    inherit (source) hash;
  };
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    tar -xOzf "$src" "pig-${version}-${source.archive}/pig" > "$out/bin/pig"
    chmod +x "$out/bin/pig"
    runHook postInstall
  '';

  meta = {
    description = "PiG (Pi in Go) coding agent";
    homepage = "https://pi-in-go.dev";
    license = lib.licenses.mit;
    mainProgram = "pig";
    platforms = builtins.attrNames sources;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
}

{lib, runCommand, fetchurl, nodejs_24, python3, bash, coreutils, gnutar, gzip, packageSpecs}: let
  fetchPackage = name: hash: let
    prefix = "npm:${name}@";
    version = lib.removePrefix prefix (lib.findFirst (lib.hasPrefix prefix)
      (throw "Missing Pi package pin: ${name}") packageSpecs);
    basename = lib.last (lib.splitString "/" name);
  in fetchurl {
    url = "https://registry.npmjs.org/${name}/-/${basename}-${version}.tgz";
    inherit hash;
  };
  yolo = fetchPackage "@valdo766hi/pi-yolo" "sha512-tz794xz63VzY1opNgatnusg9ibuHyq/qK+ciT2CHhaxAXcaC2BoJOSrw7yOuqlNIKKhxk04FC46N5JSeSrB5uw==";
  permissions = fetchPackage "@gotgenes/pi-permission-system" "sha512-KjjN4/Cbiyc/MKDdZtFNwRtYSb0HjnOWA8qEMOcyAL+VdgX0uy98KP5M8JKhlfKtoz7TxTreNV/LxT5RLUXCmQ==";
in runCommand "check-pi-tools" {
  nativeBuildInputs = [nodejs_24 python3 bash coreutils gnutar gzip];
} ''
  mkdir -p node_modules/@earendil-works/pi-coding-agent
  cat > node_modules/@earendil-works/pi-coding-agent/package.json <<'EOF'
{"type":"module"}
EOF
  cat > node_modules/@earendil-works/pi-coding-agent/index.js <<'EOF'
export function getAgentDir() {
  return process.env.TEST_AGENT_DIR;
}

export function isToolCallEventType(tool, event) {
  return event.toolName === tool;
}
EOF

  tar -xOf ${yolo} package/yolo.ts > yolo.ts
  tar -xOf ${permissions} package/src/policy/permission-gate.ts > permission-gate.ts
  mkdir -p node_modules/@earendil-works/pi-tui
  cat > node_modules/@earendil-works/pi-tui/package.json <<'EOF'
{"type":"module"}
EOF
  cat > node_modules/@earendil-works/pi-tui/index.js <<'EOF'
export const visibleWidth = text => text.length;
export const truncateToWidth = (text, width) => text.slice(0, width);
EOF

  cp ${./extensions/rtk/rtk.ts} rtk.ts
  cp ${./extensions/token-speed.ts} token-speed.ts
  cp ${./scripts/pi-package-update} pi-package-update
  cp ${./scripts/pi-package-security-check} pi-package-security-check
  cp ${./scripts/pi-tmp-rm.py} pi-tmp-rm.py
  cp ${./extensions/pi-permission-system/config.json} permissions.json
  chmod +x pi-package-update pi-package-security-check
  # The Linux build sandbox does not provide /usr/bin/env.
  substituteInPlace pi-package-update \
    --replace-fail '#!/usr/bin/env bash' '#!${bash}/bin/bash'
  substituteInPlace pi-package-security-check \
    --replace-fail '#!/usr/bin/env bash' '#!${bash}/bin/bash'
  cp ${./pi.test.ts} pi.test.ts
  cat > package.json <<'EOF'
{"type":"module"}
EOF
  node --test pi.test.ts
  touch $out
''

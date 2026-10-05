{runCommand, nodejs_24, python3, bash, coreutils}:
runCommand "check-pi-tools" {
  nativeBuildInputs = [nodejs_24 python3 bash coreutils];
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

  cp ${./extensions/yolo/yolo.ts} yolo.ts
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

import json
import subprocess
import sys
import tempfile
from pathlib import Path

pi = sys.argv[1]
try:
    with tempfile.TemporaryDirectory(prefix="pi-configured-") as temporary:
        home = Path(temporary)
        original = home / ".pi/agent/settings.json"
        original.parent.mkdir(parents=True)
        original.write_text('{"theme":"original"}')
        env = {"HOME": str(home), "PATH": "/usr/bin:/bin", "TERM": "xterm-256color"}
        env["UNRELATED_ENV"] = "filtered-sentinel"
        subprocess.run([pi, "--version"], env=env, check=True, capture_output=True)
        agent = home / ".pi/nix-config/agent"
        settings = json.loads((agent / "settings.json").read_text())
        assert settings["theme"] == "catppuccin-mocha"
        assert settings["defaultTools"] == ["+codemode"]
        assert settings["compaction"]["enabled"]
        roles = settings["subagents"]["agentOverrides"]
        assert set(roles) == {
            "scout", "delegate", "researcher", "evidence-auditor", "context-builder",
            "planner", "worker", "reviewer", "oracle",
        }
        for name, role in roles.items():
            assert not {"mcp", "intercom"} & set(role["tools"])
            assert "contact_supervisor" in role["tools"]
            model = "gpt-6-luna" if name in {"scout", "delegate"} else "gpt-6.1-sol"
            assert role["model"] == f"openai-codex/{model}"
        for name in ["scout", "researcher", "context-builder"]:
            assert {"codemode", "mcp:context7", "mcp:exa"} <= set(roles[name]["tools"])
        assert {"codemode", "mcp:exa"} <= set(roles["evidence-auditor"]["tools"])
        assert "watchdog_diff" in roles["reviewer"]["tools"]
        assert "bash" not in roles["reviewer"]["tools"]
        assert any("pi-subagents@" in package for package in settings["packages"])
        assert all((agent / name).is_symlink() for name in [
            "settings.json", "mcp.json", "APPEND_SYSTEM.md", "extensions/rtk.ts",
            "extensions/pi-permission-system/config.json", "themes/catppuccin-mocha.json",
            "openai-server-compaction.json", "plannotator.json", "pi-fff.json", "lazy-skill.json",
            "agents/planner.md", "agents/context-builder.md",
        ])
        mcp = json.loads((agent / "mcp.json").read_text())
        assert set(mcp["mcpServers"]) == {"context7", "exa"}
        assert mcp["mcpServers"]["context7"]["headers"]["Authorization"] == "Bearer ${CONTEXT7_API_KEY}"
        policy = json.loads((agent / "extensions/pi-permission-system/config.json").read_text())
        assert policy["permission"]["path"]["~/.pi/nix-config/agent/npm/*"] == "allow"
        assert policy["permission"]["path"]["*/auth.json*"] == "deny"
        probe = home / "probe.ts"
        probe.write_text('''import assert from "node:assert/strict";
import {execFileSync} from "node:child_process";
import {readFileSync} from "node:fs";
export default function(pi) {
  pi.on("session_start", () => {
    assert.equal(process.env.UNRELATED_ENV, undefined);
    assert.equal(process.env.PI_TELEMETRY, "0");
    assert.equal(Number(process.env.PI_OPENAI_SERVER_COMPACTION_RATIO), 1);
    assert(process.env.PI_CODING_AGENT_DIR.endsWith("/.pi/nix-config/agent"));
    const settings = JSON.parse(readFileSync(`${process.env.PI_CODING_AGENT_DIR}/settings.json`, "utf8"));
    for (const command of ["bash", "rtk", "git", "node", "npm", "fd", "rg", "pi-tmp-rm", "skill-sec-check.sh", "plannotator"])
      execFileSync(settings.shellPath, ["-lc", `${settings.shellCommandPrefix} command -v "${command}"`]);
    console.error("PI_CONFIGURED_SMOKE_PASS");
  });
}
''')
        result = subprocess.run([
            pi, "--mode", "rpc", "--offline", "--no-session", "--no-context-files",
            "--no-extensions", "--no-skills", "--no-prompt-templates", "--no-themes",
            "--extension", str(probe),
        ], input='{"id":"state","type":"get_state"}\n', text=True, env=env,
            capture_output=True, timeout=60, check=True)
        assert "PI_CONFIGURED_SMOKE_PASS" in result.stderr, (result.stdout, result.stderr)
        assert any(json.loads(line).get("success") for line in result.stdout.splitlines() if line.startswith("{"))
        assert original.read_text() == '{"theme":"original"}'
except (OSError, json.JSONDecodeError) as error:
    raise AssertionError(f"Missing or invalid configured Pi data: {error}") from error
print("Configured Pi smoke test passed")

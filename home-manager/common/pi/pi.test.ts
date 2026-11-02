// @ts-nocheck -- the Nix check supplies Node types and Pi API stubs at runtime.
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { EventEmitter } from "node:events";
import {
	chmodSync,
	existsSync,
	mkdirSync,
	mkdtempSync,
	readFileSync,
	realpathSync,
	rmSync,
	symlinkSync,
	writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import rtkExtension from "./rtk.ts";
import yoloExtension from "./yolo.ts";
import { applyPermissionGate } from "./permission-gate.ts";
import tokenSpeedExtension from "./token-speed.ts";

function tempDir(prefix: string): string {
	return mkdtempSync(join(tmpdir(), prefix));
}

function executable(path: string, text: string): void {
	writeFileSync(path, text);
	chmodSync(path, 0o755);
}

function run(command: string, args: string[], env: Record<string, string>) {
	return spawnSync(command, args, {
		encoding: "utf8",
		env: { ...process.env, ...env },
	});
}

test("package updater leaves the source unchanged when an atomic edit fails", () => {
	const dir = tempDir("pi-update-");
	const config = join(dir, "default.nix");
	const original = `packages = [
  "npm:test-package@1.0.0"
  "npm:test-package@1.0.0"
];
`;
	writeFileSync(config, original);
	executable(
		join(dir, "npm"),
		`#!/bin/sh
if [ "$1" = view ]; then
  printf '"2.0.0"\\n'
  exit 0
fi
exit 99
`,
	);
	const checker = join(dir, "checker");
	executable(checker, "#!/bin/sh\nexit 0\n");

	const result = run("./pi-package-update", ["update"], {
		PATH: `${dir}:${process.env.PATH}`,
		PI_PACKAGES_CONFIG: config,
		PI_PACKAGE_SECURITY_CHECK: checker,
	});

	assert.equal(result.status, 2, result.stderr);
	assert.equal(readFileSync(config, "utf8"), original);
	rmSync(dir, { recursive: true, force: true });
});

test("package updater skips vulnerable candidates and applies secure updates", () => {
	const dir = tempDir("pi-update-mixed-");
	try {
		const config = join(dir, "default.nix");
		const tree = join(dir, "tree");
		mkdirSync(tree);
		writeFileSync(config, 'packages = [ "npm:vulnerable@1.0.0" "npm:secure@1.0.0" ];\n');
		writeFileSync(join(tree, "package.json"), '{"dependencies":{"vulnerable":"1.0.0","secure":"1.0.0"}}\n');
		writeFileSync(join(tree, "package-lock.json"), "{}\n");
		executable(join(dir, "npm"), `#!/bin/sh
if [ "$1" = view ]; then printf '"2.0.0"\\n'; exit 0; fi
if [ "$1" = install ]; then printf '%s\\n' "$*" > candidate; exit 0; fi
status=0
if grep -q 'vulnerable@2.0.0' candidate; then status=1; fi
if [ "$1" = audit ] && [ "$2" = fix ]; then exit "$status"; fi
if [ "$1" = audit ]; then
  printf '{"metadata":{"vulnerabilities":{"total":%s}},"vulnerabilities":{}}\\n' "$status"
  exit "$status"
fi
exit 99
`);
		const result = run("./pi-package-update", ["update"], {
			PATH: `${dir}:${process.env.PATH}`,
			PI_PACKAGES_CONFIG: config,
			PI_PACKAGE_SECURITY_CHECK: join(process.cwd(), "pi-package-security-check"),
			PI_NPM_DIR: tree,
		});
		assert.equal(result.status, 1, result.stderr);
		assert.equal(readFileSync(config, "utf8"), 'packages = [ "npm:vulnerable@1.0.0" "npm:secure@2.0.0" ];\n');
		assert.match(result.stdout, /blocked=1 updated=1 errors=0/);
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("security checker distinguishes clean, vulnerable, and invalid audit results", () => {
	const dir = tempDir("pi-audit-");
	const tree = join(dir, "tree");
	mkdirSync(tree);
	writeFileSync(join(tree, "package.json"), "{}\n");
	writeFileSync(join(tree, "package-lock.json"), "{}\n");
	executable(
		join(dir, "npm"),
		`#!/bin/sh
if [ "$1" != audit ]; then exit 99; fi
printf '%s\\n' "$AUDIT_JSON"
exit "$AUDIT_STATUS"
`,
	);

	const check = (status: number, total: number) =>
		run("./pi-package-security-check", [], {
			PATH: `${dir}:${process.env.PATH}`,
			PI_NPM_DIR: tree,
			AUDIT_STATUS: String(status),
			AUDIT_JSON: JSON.stringify({
				metadata: {
					vulnerabilities: {
						total,
						critical: 0,
						high: total,
						moderate: 0,
						low: 0,
					},
				},
				vulnerabilities: {},
			}),
		});

	assert.equal(check(0, 0).status, 0);
	assert.equal(check(1, 1).status, 1);
	assert.equal(check(1, 0).status, 2);
	rmSync(dir, { recursive: true, force: true });
});

test("candidate check classifies remaining advisories separately from repair errors", () => {
	const dir = tempDir("pi-candidate-");
	const tree = join(dir, "tree");
	mkdirSync(tree);
	writeFileSync(join(tree, "package.json"), '{"dependencies":{"test-package":"1.0.0"}}\n');
	writeFileSync(join(tree, "package-lock.json"), "{}\n");
	executable(join(dir, "npm"), `#!/bin/sh
if [ "$1" = install ]; then exit 0; fi
if [ "$1" = audit ] && [ "$2" = fix ]; then exit "$FIX_STATUS"; fi
if [ "$1" = audit ]; then
  printf '{"metadata":{"vulnerabilities":{"total":%s}},"vulnerabilities":{}}\\n' "$AUDIT_STATUS"
  exit "$AUDIT_STATUS"
fi
exit 99
`);

	for (const [fix, audit, expected] of [[0, 0, 0], [1, 1, 1], [1, 0, 0], [2, 0, 2]]) {
		const result = run("./pi-package-security-check", ["--candidate", "test-package@2.0.0"], {
			PATH: `${dir}:${process.env.PATH}`,
			PI_NPM_DIR: tree,
			FIX_STATUS: String(fix),
			AUDIT_STATUS: String(audit),
		});
		assert.equal(result.status, expected, result.stderr);
	}
	rmSync(dir, { recursive: true, force: true });
});

test("candidate checks pin patched fast-uri without installing Pi host peers", () => {
	const dir = tempDir("pi-candidate-peers-");
	const tree = join(dir, "tree");
	mkdirSync(tree);
	writeFileSync(join(tree, "package.json"), '{"dependencies":{"test-package":"1.0.0"}}\n');
	writeFileSync(join(tree, "package-lock.json"), "{}\n");
	executable(join(dir, "npm"), `#!/bin/sh
if [ "$1" = install ] || [ "$2" = fix ]; then
  case " $* " in *" --legacy-peer-deps "*) ;; *) exit 99 ;; esac
  case " $* " in *" --ignore-scripts "*) ;; *) exit 99 ;; esac
  node -e 'if (require("./package.json").overrides["fast-uri"] !== "3.1.8") process.exit(99)'
  exit $?
fi
printf '%s\\n' '{"metadata":{"vulnerabilities":{"total":0}},"vulnerabilities":{}}'
`);
	const result = run("./pi-package-security-check", ["--candidate", "test-package@2.0.0"], {
		PATH: `${dir}:${process.env.PATH}`,
		PI_NPM_DIR: tree,
		PI_FAST_URI_VERSION: "",
	});
	assert.equal(result.status, 0, result.stderr);
	rmSync(dir, { recursive: true, force: true });
});

test("published YOLO overlay preserves denials, native config, and session isolation", async () => {
	const agentDir = tempDir("pi-yolo-");
	const configDir = join(agentDir, "extensions", "pi-permission-system");
	mkdirSync(configDir, { recursive: true });
	const configPath = join(configDir, "config.json");
	const config = readFileSync("permissions.json", "utf8");
	writeFileSync(configPath, config);
	const previousAgentDir = process.env.TEST_AGENT_DIR;
	process.env.TEST_AGENT_DIR = agentDir;

	function session(id: string) {
		const handlers = new Map<string, any>();
		const commands = new Map<string, any>();
		const events = new EventEmitter();
		const statuses = new Map<string, string>();
		let dialogs = 0;
		const ctx = {
			sessionManager: { getSessionId: () => id },
			abort: () => assert.fail("valid session state must not abort"),
			reload: () => assert.fail("YOLO must not reload Pi"),
			ui: {
				setStatus: (key: string, value: string) => statuses.set(key, value),
				notify() {},
				select: async () => { dialogs++; return "No"; },
				custom: async () => { dialogs++; return { approved: false, state: "denied" }; },
			},
		};
		yoloExtension({
			on: (name: string, handler: any) => handlers.set(name, handler),
			registerCommand: (name: string, command: any) => commands.set(name, command),
			registerFlag() {},
			getFlag: () => false,
			events: { on: (name: string, handler: any) => {
				events.on(name, handler);
				return () => events.off(name, handler);
			} },
		} as any);
		handlers.get("session_start")({}, ctx);
		return {
			ctx, events, statuses,
			command: (mode: string) => commands.get("yolo").handler(mode, ctx),
			stop: () => handlers.get("session_shutdown")({}, ctx),
			toolCall: () => handlers.get("tool_call")({}, ctx),
			dialogs: () => dialogs,
			prompt: () => {
				events.emit("permissions:ui_prompt", { requestId: "request", source: "tool_call" });
				return ctx.ui.custom(() => {}, { overlay: false });
			},
		};
	}

	try {
		const first = session("first");
		assert.equal(first.statuses.get("yolo"), "YOLO: OFF");
		assert.equal((await first.prompt()).approved, false);
		await first.command("on");
		assert.equal(first.statuses.get("yolo"), "YOLO: ON");
		assert.equal((await first.prompt()).approved, true);
		assert.equal(first.dialogs(), 1);
		assert.equal(first.toolCall(), undefined, "the overlay must not override tool decisions");

		const { permission } = JSON.parse(config);
		for (const rule of [permission.path["*/auth.json*"], permission.bash["sudo *"], permission.bash["rm *"]]) {
			const result = await applyPermissionGate({
				state: typeof rule === "string" ? rule : rule.action,
				promptForApproval: () => assert.fail("explicit denials must not open an approval dialog"),
				canGrantForSession: false,
				writeLog() {}, logContext: {}, decidedByRule: { kind: "rule" },
				messages: { denyReason: "denied", refusedReason: () => "refused" },
			});
			assert.equal(result.action, "block");
		}
		assert.equal(await first.ctx.ui.select("Unrelated", ["Yes", "No", "No, provide reason"]), "No");
		first.events.emit("permissions:ui_prompt", { requestId: "expired", source: "tool_call" });
		await Promise.resolve();
		assert.equal((await first.ctx.ui.custom(() => {}, { overlay: false })).approved, false);

		const second = session("second");
		assert.equal(second.statuses.get("yolo"), "YOLO: OFF");
		assert.equal((await second.prompt()).approved, false);
		assert.equal(first.statuses.get("yolo"), "YOLO: ON");
		second.stop();
		first.stop();
		const resumed = session("first");
		assert.equal(resumed.statuses.get("yolo"), "YOLO: ON");
		assert.equal((await resumed.prompt()).approved, true);
		await resumed.command("off");
		assert.equal((await resumed.prompt()).approved, false);
		resumed.stop();
		assert.equal(readFileSync(configPath, "utf8"), config);
	} finally {
		if (previousAgentDir === undefined) delete process.env.TEST_AGENT_DIR;
		else process.env.TEST_AGENT_DIR = previousAgentDir;
		rmSync(agentDir, { recursive: true, force: true });
	}
});

test("permission policy retains hard credential and deletion denials", () => {
	const { permission, yoloMode } = JSON.parse(readFileSync("permissions.json", "utf8"));
	assert.equal(yoloMode, false);
	for (const pattern of ["~/.pi/*", "*/auth.json*", "~/.config/sops*", "~/.kube*"]) {
		assert.equal(permission.path[pattern], "deny", pattern);
	}
	const patterns = Object.keys(permission.path);
	assert.ok(patterns.indexOf("*/auth.json*") > patterns.indexOf("~/.pi/agent/skills/*"));
	assert.equal(permission.external_directory["*"], "ask");
	assert.equal(permission.external_directory["~/.ssh/*"], "allow");
	for (const tool of ["read", "write", "edit", "grep", "find", "ls"]) {
		assert.equal(permission[tool]["~/.ssh*"], "deny", tool);
	}
	for (const tool of ["write", "edit"]) {
		assert.equal(permission[tool]["~/.agents/skills/*"], undefined);
		assert.equal(permission[tool]["~/.pi/agent/skills/*"], "allow");
		assert.ok(Object.keys(permission[tool]).indexOf("~/.pi/agent/skills/*") >
			Object.keys(permission[tool]).indexOf("~/.pi/*"));
	}
	assert.equal(permission.bash["*.ssh*"], "deny");
	const bashPatterns = Object.keys(permission.bash);
	for (const ssh of ["ssh", "/usr/bin/ssh"]) {
		assert.equal(permission.bash[`${ssh} *`], "ask");
		assert.ok(bashPatterns.indexOf(`${ssh} *`) > bashPatterns.indexOf("*.ssh*"));
	}
	assert.equal(permission.bash["rm *"].action, "deny");
	assert.equal(permission.bash["*/rm *"], "deny");
	assert.equal(permission.bash["git clean *"], "deny");
	assert.equal(permission.bash["sudo *"], "deny");
	assert.equal(permission.bash["pi-tmp-rm *"], "allow");
});

test("temp cleanup rejects escapes and never follows directory symlinks", () => {
	const dir = mkdtempSync("/tmp/pi-tmp-rm-");
	const remove = (...paths: string[]) => run("python3", ["-I", "pi-tmp-rm.py", ...paths], {});
	try {
		const file = join(dir, "file with spaces");
		writeFileSync(file, "temporary fixture\n");
		for (const path of ["/tmp", "/private/tmp", "/tmp/../nix/store", "/nix/store", "relative", "--help"]) {
			assert.notEqual(remove(path).status, 0, path);
		}
		assert.notEqual(remove(file, "/nix/store").status, 0);
		assert.ok(existsSync(file), "invalid argument list must not delete its first path");

		const link = join(dir, "link");
		symlinkSync("/nix/store", link);
		assert.notEqual(remove(`${link}/anything`).status, 0);
		assert.equal(remove(link).status, 0, "a leaf symlink is unlinked, never followed");
		assert.ok(existsSync("/nix/store"));

		assert.equal(remove(realpathSync(file)).status, 0);
		assert.ok(!existsSync(file));
		const tree = join(dir, "tree");
		mkdirSync(join(tree, "nested"), { recursive: true });
		writeFileSync(join(tree, "nested", "fixture"), "temporary fixture\n");
		symlinkSync("/nix/store", join(tree, "outside"));
		assert.equal(remove(tree).status, 0);
		assert.ok(!existsSync(tree));
		assert.ok(existsSync("/nix/store"));
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("token speed persists one UI-only rate per response without tool execution time", (t) => {
	let now = 0;
	t.mock.method(performance, "now", () => now);
	const handlers = new Map<string, any>();
	const entries: any[] = [];
	let renderEntry: any;
	const ctx = { mode: "tui" };
	tokenSpeedExtension({
		on: (name: string, handler: any) => handlers.set(name, handler),
		registerEntryRenderer: (_type: string, renderer: any) => { renderEntry = renderer; },
		appendEntry: (customType: string, data: any) => entries.push({ customType, data }),
	} as any);
	const emit = (name: string, message?: any, context = ctx) => handlers.get(name)({ message }, context);
	const assistant = { role: "assistant", usage: { output: 100 } };
	emit("session_start");
	emit("turn_start");
	now = 2000;
	emit("message_end", assistant);
	assert.equal(entries.length, 0);
	now = 9000;
	emit("message_end", { role: "toolResult" });
	emit("turn_end");
	assert.deepEqual(entries, [{ customType: "token-speed", data: { output: 100, elapsedMs: 2000 } }]);
	emit("turn_end");
	assert.equal(entries.length, 1);
	const component = renderEntry(entries[0], {}, { fg: (_color: string, text: string) => text });
	assert.equal(component.render(40)[0], "50.0 tok/s".padStart(40));
	assert.ok(component.render(4)[0].length <= 4);
	for (const data of [undefined, { output: 0, elapsedMs: 1 }, { output: 1, elapsedMs: 0 },
		{ output: NaN, elapsedMs: 1 }, { output: 1, elapsedMs: Infinity }]) {
		assert.equal(renderEntry({ data }, {}, {}), undefined);
	}
	for (const output of [0, NaN]) {
		emit("turn_start");
		now += 1000;
		emit("message_end", { ...assistant, usage: { output } });
		emit("turn_end");
	}
	assert.equal(entries.length, 1);
	emit("turn_start");
	now += 1000;
	emit("message_end", assistant);
	emit("session_start");
	emit("turn_end");
	assert.equal(entries.length, 1);
	for (const mode of ["rpc", "print", "json"]) {
		emit("turn_start", undefined, { mode });
		now += 1000;
		emit("message_end", assistant, { mode });
		emit("turn_end", undefined, { mode });
	}
	assert.equal(entries.length, 1);
});

test("rtk leaves SSH commands unchanged for identity permission checks", async () => {
	let toolHandler: any;
	let rewriteCalls = 0;
	rtkExtension({
		on: (_event: string, handler: any) => { toolHandler = handler; },
		exec: async (_command: string, args: string[]) => {
			rewriteCalls += 1;
			return { code: 3, stdout: `rtk ${args[1]}`, killed: false };
		},
	} as any);
	for (const command of [
		"ssh -o BatchMode=yes -o StrictHostKeyChecking=yes user@host 'hostname'",
		"ssh -i ~/.ssh/id_ed25519 user@host 'ls -lah'",
		"/usr/bin/ssh -i ~/.ssh/id_ed25519 user@host 'ls -lah'",
		"cd /tmp && ssh -i ~/.ssh/id_ed25519 user@host 'ls -lah'",
	]) {
		const event = { toolName: "bash", input: { command } };
		await toolHandler(event, { signal: undefined });
		assert.equal(event.input.command, command);
	}
	assert.equal(rewriteCalls, 0);
	const event = { toolName: "bash", input: { command: "git status" } };
	await toolHandler(event, { signal: undefined });
	assert.equal(event.input.command, "rtk git status");
	assert.equal(rewriteCalls, 1);
});

test("rtk passes a command through when rewriting fails", async () => {
	let toolHandler: ((event: any, ctx: any) => Promise<void>) | undefined;
	let rewriteCalls = 0;
	const pi = {
		exec: async (_command: string, args: string[]) => {
			if (args[0] === "--version") return { code: 0, stdout: "rtk 0.23.0" };
			rewriteCalls += 1;
			return { code: 1, stdout: "", killed: false };
		},
		on: (_event: string, handler: any) => {
			toolHandler = handler;
		},
	};

	await rtkExtension(pi as any);
	const event = {
		type: "tool_call",
		toolName: "bash",
		input: { command: "git status" },
	};
	await toolHandler!(event, { signal: undefined });
	assert.equal(event.input.command, "git status");
	assert.equal(rewriteCalls, 1);
});

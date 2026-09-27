// @ts-nocheck -- the Nix check supplies Node types and Pi API stubs at runtime.
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import {
	chmodSync,
	mkdirSync,
	mkdtempSync,
	readFileSync,
	rmSync,
	writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import rtkExtension from "./rtk.ts";
import yoloExtension from "./yolo.ts";

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

test("candidate check rejects failed npm audit fix", () => {
	const dir = tempDir("pi-candidate-");
	const tree = join(dir, "tree");
	mkdirSync(tree);
	writeFileSync(join(tree, "package.json"), '{"dependencies":{"test-package":"1.0.0"}}\n');
	writeFileSync(join(tree, "package-lock.json"), "{}\n");
	executable(join(dir, "npm"), `#!/bin/sh
if [ "$1" = install ]; then exit 0; fi
if [ "$1" = audit ] && [ "$2" = fix ]; then exit 1; fi
exit 99
`);

	const result = run("./pi-package-security-check", ["--candidate", "test-package@2.0.0"], {
		PATH: `${dir}:${process.env.PATH}`,
		PI_NPM_DIR: tree,
	});
	assert.equal(result.status, 2, result.stderr);
	assert.match(result.stderr, /could not repair the candidate dependency tree/);
	rmSync(dir, { recursive: true, force: true });
});

test("yolo command atomically updates the native permission setting", async () => {
	const agentDir = tempDir("pi-yolo-");
	const configDir = join(agentDir, "extensions", "pi-permission-system");
	mkdirSync(configDir, { recursive: true });
	const configPath = join(configDir, "config.json");
	writeFileSync(configPath, '{"yoloMode":false}\n');
	process.env.TEST_AGENT_DIR = agentDir;

	const handlers = new Map<string, (event: any, ctx: any) => any>();
	const commands = new Map<string, any>();
	const entries: unknown[] = [];
	let reloads = 0;
	const ctx = {
		sessionManager: { getBranch: () => [] },
		ui: { setStatus() {}, notify() {} },
		reload: async () => {
			reloads += 1;
		},
	};
	const pi = {
		on: (event: string, handler: any) => handlers.set(event, handler),
		registerCommand: (name: string, command: any) =>
			commands.set(name, command),
		appendEntry: (_type: string, data: unknown) => entries.push(data),
	};

	yoloExtension(pi as any);
	const sessionStart = handlers.get("session_start");
	assert.ok(sessionStart);
	sessionStart({}, ctx);
	assert.equal(JSON.parse(readFileSync(configPath, "utf8")).yoloMode, false);
	const yolo = commands.get("yolo");
	assert.ok(yolo);
	try {
		await yolo.handler("on", ctx);
	} catch (error) {
		assert.fail(error);
	}
	assert.equal(JSON.parse(readFileSync(configPath, "utf8")).yoloMode, true);
	assert.equal(reloads, 1);
	assert.deepEqual(entries, [{ enabled: true }]);
	try {
		await yolo.handler("off", ctx);
	} catch (error) {
		assert.fail(error);
	}
	assert.equal(JSON.parse(readFileSync(configPath, "utf8")).yoloMode, false);
	assert.equal(reloads, 2);
	rmSync(agentDir, { recursive: true, force: true });
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

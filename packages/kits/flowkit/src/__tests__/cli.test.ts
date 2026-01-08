/**
 * FlowKit CLI Tests
 *
 * Uses vitest for testing.
 */

import { describe, it, expect } from "vitest";
import { EventEmitter } from "node:events";
import { mkdtemp, mkdir, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import type { ChildProcess } from "node:child_process";

import { runFlowFromConfigPath } from "../cli";

const BASE_CONFIG = {
  id: "architecture_assessment",
  displayName: "Architecture Assessment",
  description: "Alignment flow",
  type: "assessment",
  subject: "architecture",
  mode: "full",
  subtype: "alignment",
  canonicalPromptPath:
    "packages/workflows/architecture_assessment/00-overview.md",
  workflowManifestPath:
    "packages/workflows/architecture_assessment/manifest.yaml",
  workflowEntrypoint: "architecture-inventory",
  runtime: {
    type: "http-service",
    url: "http://127.0.0.1:9000",
    autoStart: {
      pythonCommand: "agents/runner/runtime/.venv/bin/python",
      module: "agents.runner.runtime.server"
    }
  }
};

const createTempConfigFile = async (
  contents: Record<string, unknown>,
  filename = "flow.flow.json"
) => {
  const dir = await mkdtemp(join(tmpdir(), "flowkit-cli-"));
  const filePath = join(dir, filename);
  await writeFile(filePath, JSON.stringify(contents), "utf8");
  return filePath;
};

describe("FlowKit CLI", () => {
  it("runFlowFromConfigPath executes the FlowRunner for a valid config", async () => {
    const configPath = await createTempConfigFile(BASE_CONFIG);

    let receivedUrl: string | undefined;
    const previousRunnerUrl = process.env.FLOWKIT_RUNNER_URL;
    process.env.FLOWKIT_RUNNER_URL = "http://runner.internal";

    try {
      const result = await runFlowFromConfigPath(configPath, {
        createHttpRunner: (options) => {
          receivedUrl = options.baseUrl;
          return {
            async run() {
              return {
                result: { ok: true },
                runId: "test-run",
                metadata: { flowName: "architecture_assessment" }
              };
            }
          };
        }
      });

      expect(receivedUrl).toBe("http://runner.internal");
      expect(result.result).toEqual({ ok: true });
      expect(result.runId).toBe("test-run");
    } finally {
      if (previousRunnerUrl === undefined) {
        delete process.env.FLOWKIT_RUNNER_URL;
      } else {
        process.env.FLOWKIT_RUNNER_URL = previousRunnerUrl;
      }
    }
  });

  it("runFlowFromConfigPath fails when the config path does not exist", async () => {
    const missingPath = join(
      tmpdir(),
      `missing-${Date.now()}.flow.json`
    );

    await expect(runFlowFromConfigPath(missingPath)).rejects.toThrow(
      /Flow config not found/
    );
  });

  it("runFlowFromConfigPath rejects non .flow.json files", async () => {
    const invalidPath = await createTempConfigFile(BASE_CONFIG, "flow.json");

    await expect(runFlowFromConfigPath(invalidPath)).rejects.toThrow(
      /must end with '.flow\.json'/
    );
  });

  it("runFlowFromConfigPath surfaces JSON parse errors", async () => {
    const dir = await mkdtemp(join(tmpdir(), "flowkit-cli-invalid-"));
    const filePath = join(dir, "broken.flow.json");
    await writeFile(filePath, "{", "utf8");

    await expect(runFlowFromConfigPath(filePath)).rejects.toThrow(
      /Failed to parse JSON/
    );
  });

  it("runFlowFromConfigPath fails for unsupported runtime types", async () => {
    const configPath = await createTempConfigFile({
      ...BASE_CONFIG,
      runtime: {
        type: "python-module",
        pythonModule: "agents.runner.runtime.assessment.run"
      }
    });

    await expect(runFlowFromConfigPath(configPath)).rejects.toThrow(
      /unsupported runtime type/i
    );
  });

  it("runFlowFromConfigPath resolves relative paths against INIT_CWD", async () => {
    const repoRoot = await mkdtemp(join(tmpdir(), "flowkit-root-"));
    const relativePath =
      "packages/workflows/architecture_assessment/config.flow.json";
    const absoluteConfigPath = join(repoRoot, relativePath);
    await mkdir(dirname(absoluteConfigPath), { recursive: true });
    await writeFile(absoluteConfigPath, JSON.stringify(BASE_CONFIG), "utf8");

    const originalInitCwd = process.env.INIT_CWD;
    const originalWorkspaceRoot = process.env.FLOWKIT_WORKSPACE_ROOT;
    process.env.INIT_CWD = repoRoot;
    delete process.env.FLOWKIT_WORKSPACE_ROOT;
    const originalRunnerUrl = process.env.FLOWKIT_RUNNER_URL;
    process.env.FLOWKIT_RUNNER_URL = "http://runner.internal";

    let receivedWorkspaceRoot: string | undefined;
    try {
      await runFlowFromConfigPath(relativePath, {
        createHttpRunner: () => ({
          async run(request) {
            receivedWorkspaceRoot = request.config.workspaceRoot;
            return {
              result: { ok: true },
              runId: "relative-run",
              metadata: { flowName: request.config.flowName }
            };
          }
        })
      });
    } finally {
      if (originalInitCwd === undefined) {
        delete process.env.INIT_CWD;
      } else {
        process.env.INIT_CWD = originalInitCwd;
      }
      if (originalWorkspaceRoot === undefined) {
        delete process.env.FLOWKIT_WORKSPACE_ROOT;
      } else {
        process.env.FLOWKIT_WORKSPACE_ROOT = originalWorkspaceRoot;
      }
      if (originalRunnerUrl === undefined) {
        delete process.env.FLOWKIT_RUNNER_URL;
      } else {
        process.env.FLOWKIT_RUNNER_URL = originalRunnerUrl;
      }
    }

    expect(receivedWorkspaceRoot).toBe(repoRoot);
  });

  it("runFlowFromConfigPath auto-starts the runner when no FLOWKIT_RUNNER_URL is set", { timeout: 10000 }, async () => {
    // Save and clear env vars to trigger auto-start behavior
    const originalRunnerUrl = process.env.FLOWKIT_RUNNER_URL;
    const originalWorkspaceRoot = process.env.FLOWKIT_WORKSPACE_ROOT;
    delete process.env.FLOWKIT_RUNNER_URL;

    try {
      const repoRoot = await mkdtemp(join(tmpdir(), "flowkit-autostart-"));
      // Set FLOWKIT_WORKSPACE_ROOT so getWorkspaceRoot() returns our temp dir
      process.env.FLOWKIT_WORKSPACE_ROOT = repoRoot;

      const configPath = await createTempConfigFile({
        ...BASE_CONFIG,
        workspaceRoot: repoRoot,
        runtime: {
          type: "http-service",
          url: "http://127.0.0.1:9123",
          autoStart: {
            pythonCommand: "agents/runner/runtime/.venv/bin/python",
            module: "agents.runner.runtime.server",
            host: "127.0.0.1",
            port: 9123,
            readyTimeoutSeconds: 1
          }
        }
      });

      // FakeChild must emit "exit" asynchronously so that stopRunnerProcess's
      // `once(child, "exit")` listener is registered before the event fires.
      class FakeChild extends EventEmitter {
        kill() {
          // Use setImmediate to emit after the current tick, allowing
          // the `once(child, "exit")` listener to be set up first.
          setImmediate(() => this.emit("exit", 0));
          return true;
        }
      }

      const spawnCalls: Array<{ command: string; args: string[] }> = [];
      let healthChecks = 0;

      const result = await runFlowFromConfigPath(configPath, {
        spawnImpl: (command, args) => {
          spawnCalls.push({ command, args: args as string[] });
          return new FakeChild() as unknown as ChildProcess;
        },
        fetchImpl: async () => {
          healthChecks += 1;
          return {
            ok: true,
            status: 200,
            statusText: "OK",
            json: async () => ({}),
            text: async () => ""
          } as Awaited<ReturnType<typeof fetch>>;
        },
        createHttpRunner: (options) => ({
          async run() {
            return {
              result: { ok: true },
              runId: "auto-start",
              metadata: { runnerEndpoint: options.baseUrl }
            };
          }
        })
      });

      expect(result.metadata?.runnerEndpoint).toBe("http://127.0.0.1:9123");
      expect(spawnCalls.length).toBe(1);
      expect(spawnCalls[0].command).toBe(
        join(repoRoot, "agents/runner/runtime/.venv/bin/python")
      );
      expect(spawnCalls[0].args.slice(0, 2)).toEqual([
        "-m",
        "agents.runner.runtime.server"
      ]);
      expect(spawnCalls[0].args.slice(2)).toEqual([
        "--host",
        "127.0.0.1",
        "--port",
        "9123"
      ]);
      expect(healthChecks > 0).toBe(true);
    } finally {
      // Restore env vars
      if (originalRunnerUrl === undefined) {
        delete process.env.FLOWKIT_RUNNER_URL;
      } else {
        process.env.FLOWKIT_RUNNER_URL = originalRunnerUrl;
      }
      if (originalWorkspaceRoot === undefined) {
        delete process.env.FLOWKIT_WORKSPACE_ROOT;
      } else {
        process.env.FLOWKIT_WORKSPACE_ROOT = originalWorkspaceRoot;
      }
    }
  });

  it("runFlowFromConfigPath rejects configs with invalid classification metadata", async () => {
    const configPath = await createTempConfigFile({
      ...BASE_CONFIG,
      type: 123
    } as Record<string, unknown>);

    await expect(runFlowFromConfigPath(configPath)).rejects.toThrow(
      /invalid 'type' metadata/i
    );
  });
});

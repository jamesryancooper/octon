/**
 * FlowKit CLI
 *
 * Command-line interface for FlowKit operations with Harmony-standard flags.
 *
 * Pillar alignment: Speed with Safety, Guided Agentic Autonomy
 */

import { spawn, type ChildProcess } from "node:child_process";
import { once } from "node:events";
import { readFileSync, statSync } from "node:fs";
import { isAbsolute, resolve } from "node:path";
import process from "node:process";
import { pathToFileURL, URL } from "node:url";
import { setTimeout as delay } from "node:timers/promises";

import {
  createHttpFlowRunner,
  type FlowConfig,
  type FlowRunResult,
  type FlowRunner
} from "./index";

/**
 * Standard flags supported by all kits (aligned with kit-base/cli-flags).
 */
interface StandardKitFlags {
  dryRun: boolean;
  stage?: "spec" | "plan" | "implement" | "verify" | "ship" | "operate" | "learn";
  risk?: "T1" | "T2" | "T3";
  idempotencyKey?: string;
  cacheKey?: string;
  trace?: boolean;
  traceParent?: string;
  verbose?: boolean;
  format?: "json" | "text";
}

/**
 * Default flag values.
 */
const DEFAULT_KIT_FLAGS: StandardKitFlags = {
  dryRun: process.env.HARMONY_ENV !== "prod" && process.env.HARMONY_ENV !== "preview",
  verbose: false,
  format: "json", // FlowKit defaults to JSON for machine consumption
};

/**
 * Parse standard kit flags from argv.
 */
function parseStandardFlags(argv: string[]): {
  flags: StandardKitFlags;
  remaining: string[];
} {
  const flags: StandardKitFlags = { ...DEFAULT_KIT_FLAGS };
  const remaining: string[] = [];

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];

    if (arg === "--") {
      remaining.push(...argv.slice(i + 1));
      break;
    }

    if (arg.startsWith("--")) {
      const [rawKey, ...valueParts] = arg.slice(2).split("=");
      const hasValue = valueParts.length > 0;
      const value = hasValue ? valueParts.join("=") : undefined;

      switch (rawKey) {
        case "dry-run":
          flags.dryRun = value ? value === "true" : true;
          continue;
        case "stage":
          flags.stage = (value || argv[++i]) as StandardKitFlags["stage"];
          continue;
        case "risk":
          flags.risk = (value || argv[++i])?.toUpperCase() as StandardKitFlags["risk"];
          continue;
        case "idempotency-key":
          flags.idempotencyKey = value || argv[++i];
          continue;
        case "cache-key":
          flags.cacheKey = value || argv[++i];
          continue;
        case "trace":
          flags.trace = value ? value === "true" : true;
          continue;
        case "trace-parent":
          flags.traceParent = value || argv[++i];
          continue;
        case "verbose":
          flags.verbose = true;
          continue;
        case "format":
          flags.format = (value || argv[++i]) as "json" | "text";
          continue;
      }
    } else if (arg.startsWith("-")) {
      const key = arg.slice(1);
      switch (key) {
        case "n":
          flags.dryRun = true;
          continue;
        case "s":
          if (i + 1 < argv.length && !argv[i + 1].startsWith("-")) {
            flags.stage = argv[++i] as StandardKitFlags["stage"];
          }
          continue;
        case "r":
          if (i + 1 < argv.length && !argv[i + 1].startsWith("-")) {
            flags.risk = argv[++i].toUpperCase() as StandardKitFlags["risk"];
          }
          continue;
        case "t":
          flags.trace = true;
          continue;
        case "v":
          flags.verbose = true;
          continue;
      }
    }

    remaining.push(arg);
  }

  return { flags, remaining };
}

interface FlowConfigFile {
  /**
   * Stable identifier for the flow (used as FlowConfig.flowName).
   */
  id: string;
  /**
   * Human-readable name surfaced in confirmations/logging.
   */
  displayName: string;
  /**
   * Short description used in documentation and CLI confirmations.
   */
  description: string;
  /**
   * Optional flow classification metadata used for discovery/routing.
   */
  type?: string;
  subject?: string;
  mode?: string;
  subtype?: string;
  /**
   * Path to the canonical prompt markdown file (relative to the repo root).
   */
  canonicalPromptPath: string;
  /**
   * Path to the YAML workflow manifest that drives the LangGraph runtime.
   */
  workflowManifestPath: string;
  /**
   * Entry point node id declared for this workflow.
   */
  workflowEntrypoint: string;
  /**
   * Optional workspace root override (defaults to process.cwd()).
   */
  workspaceRoot?: string;
  /**
   * Runtime binding metadata describing how to execute the flow.
   */
  runtime: FlowConfigRuntime;
  /**
   * Optional policy profile identifier for downstream gating.
   */
  policyProfile?: string;
  /**
   * Optional list of gates required for the flow.
   */
  requiredGates?: string[];
  /**
   * Optional observability hints (for example, span naming).
   */
  observability?: {
    spanPrefix?: string;
  };
}

type FlowConfigRuntime = FlowConfigHttpRuntime;

interface FlowConfigHttpRuntime {
  type: "http-service";
  url?: string;
  timeoutSeconds?: number;
  autoStart?: {
    pythonCommand: string;
    module?: string;
    host?: string;
    port?: number;
    readyTimeoutSeconds?: number;
    args?: string[];
    env?: Record<string, string>;
  };
}

interface FlowKitCliDependencies {
  createHttpRunner?: typeof createHttpFlowRunner;
  fetchImpl?: typeof fetch;
  spawnImpl?: typeof spawn;
}

const FLOW_CONFIG_EXTENSION = ".flow.json";
const DEFAULT_RUNNER_MODULE = "agents.runner.runtime.server";
const DEFAULT_RUNNER_PORT = 8410;
const HEALTH_ENDPOINT = "/healthz";

const ensureFetchImpl = (override?: typeof fetch) => {
  const impl = override ?? globalThis.fetch;
  if (!impl) {
    throw new Error(
      "FlowKit CLI requires fetch (Node 18+ or a global polyfill) to contact the runner service."
    );
  }
  return impl;
};

const normalizeBaseUrl = (value: string) => value.replace(/\/$/, "");

const getWorkspaceRoot = (): string => {
  if (process.env.FLOWKIT_WORKSPACE_ROOT) {
    return resolve(process.env.FLOWKIT_WORKSPACE_ROOT);
  }
  if (process.env.INIT_CWD) {
    return resolve(process.env.INIT_CWD);
  }
  return process.cwd();
};

const isNonEmptyString = (value: unknown): value is string =>
  typeof value === "string" && value.trim().length > 0;

const ensureExtension = (path: string) => {
  if (!path.endsWith(FLOW_CONFIG_EXTENSION)) {
    throw new Error(
      `Flow config must end with '${FLOW_CONFIG_EXTENSION}'. Received '${path}'.`
    );
  }
};

const loadConfigFile = (path: string, workspaceRoot: string): FlowConfigFile => {
  const absolutePath = isAbsolute(path) ? path : resolve(workspaceRoot, path);
  ensureExtension(absolutePath);

  let stat;
  try {
    stat = statSync(absolutePath);
  } catch {
    throw new Error(`Flow config not found at '${absolutePath}'.`);
  }

  if (!stat.isFile()) {
    throw new Error(`Flow config path must point to a file: '${absolutePath}'.`);
  }

  const raw = readFileSync(absolutePath, "utf8");
  let parsed: unknown;
  try {
    parsed = JSON.parse(raw);
  } catch (error) {
    throw new Error(
      `Failed to parse JSON in '${absolutePath}': ${(error as Error).message}`
    );
  }

  return validateFlowConfig(parsed, absolutePath);
};

const validateFlowConfig = (
  value: unknown,
  sourcePath: string
): FlowConfigFile => {
  if (typeof value !== "object" || value === null) {
    throw new Error(`Flow config '${sourcePath}' must be a JSON object.`);
  }

  const candidate = value as Partial<FlowConfigFile>;

  if (!isNonEmptyString(candidate.id)) {
    throw new Error(
      `Flow config '${sourcePath}' is missing a non-empty 'id' property.`
    );
  }
  if (!isNonEmptyString(candidate.displayName)) {
    throw new Error(
      `Flow config '${sourcePath}' is missing a non-empty 'displayName' property.`
    );
  }
  if (!isNonEmptyString(candidate.description)) {
    throw new Error(
      `Flow config '${sourcePath}' is missing a non-empty 'description' property.`
    );
  }
  if (!isNonEmptyString(candidate.canonicalPromptPath)) {
    throw new Error(
      `Flow config '${sourcePath}' is missing 'canonicalPromptPath'.`
    );
  }
  if (!isNonEmptyString(candidate.workflowManifestPath)) {
    throw new Error(
      `Flow config '${sourcePath}' is missing 'workflowManifestPath'.`
    );
  }
  if (!isNonEmptyString(candidate.workflowEntrypoint)) {
    throw new Error(
      `Flow config '${sourcePath}' is missing 'workflowEntrypoint'.`
    );
  }
  if (typeof candidate.runtime !== "object" || candidate.runtime === null) {
    throw new Error(`Flow config '${sourcePath}' is missing 'runtime'.`);
  }

  const runtime = candidate.runtime as Partial<FlowConfigHttpRuntime>;
  if (runtime.type !== "http-service") {
    throw new Error(
      `Flow config '${sourcePath}' has unsupported runtime type '${runtime.type}'.`
    );
  }
  if (
    !process.env.FLOWKIT_RUNNER_URL &&
    runtime.url !== undefined &&
    !isNonEmptyString(runtime.url)
  ) {
    throw new Error(
      `Flow config '${sourcePath}' has an empty 'runtime.url' value.`
    );
  }
  if (!process.env.FLOWKIT_RUNNER_URL && !runtime.url) {
    throw new Error(
      `Flow config '${sourcePath}' must define 'runtime.url' when FLOWKIT_RUNNER_URL is not set.`
    );
  }
  if (runtime.autoStart && !isNonEmptyString(runtime.autoStart.pythonCommand)) {
    throw new Error(
      `Flow config '${sourcePath}' is missing 'runtime.autoStart.pythonCommand'.`
    );
  }

  const classificationFields: Array<"type" | "subject" | "mode" | "subtype"> = [
    "type",
    "subject",
    "mode",
    "subtype"
  ];
  for (const field of classificationFields) {
    const value = candidate[field];
    if (value !== undefined && !isNonEmptyString(value)) {
      throw new Error(
        `Flow config '${sourcePath}' has invalid '${field}' metadata (must be a non-empty string when provided).`
      );
    }
  }

  return {
    ...candidate,
    runtime: {
      type: "http-service",
      url: runtime.url,
      timeoutSeconds: runtime.timeoutSeconds,
      autoStart: runtime.autoStart
    }
  } as FlowConfigFile;
};

const resolveRunnerUrl = (config: FlowConfigFile): string => {
  const envUrl = process.env.FLOWKIT_RUNNER_URL;
  if (envUrl) {
    return normalizeBaseUrl(envUrl);
  }
  if (!config.runtime.url) {
    throw new Error(
      "runtime.url must be provided when FLOWKIT_RUNNER_URL is not set."
    );
  }
  return normalizeBaseUrl(config.runtime.url);
};

const deriveHostPort = (
  runnerUrl: string,
  autoStart?: FlowConfigHttpRuntime["autoStart"]
) => {
  const url = new URL(runnerUrl);
  const host = autoStart?.host || url.hostname || "127.0.0.1";
  const port =
    autoStart?.port ||
    (url.port ? Number(url.port) : DEFAULT_RUNNER_PORT);
  return { host, port };
};

const startRunnerProcess = (
  flowConfig: FlowConfigFile,
  workspaceRoot: string,
  runnerUrl: string,
  dependencies?: FlowKitCliDependencies
): ChildProcess => {
  const autoStart = flowConfig.runtime.autoStart;
  if (!autoStart) {
    throw new Error(
      "Flow config runtime.autoStart must be defined to start a local runner."
    );
  }

  const spawnImpl = dependencies?.spawnImpl || spawn;
  const command = autoStart.pythonCommand;
  const executable = isAbsolute(command)
    ? command
    : resolve(workspaceRoot, command);
  const moduleName = autoStart.module || DEFAULT_RUNNER_MODULE;
  const { host, port } = deriveHostPort(runnerUrl, autoStart);
  const args = ["-m", moduleName, "--host", host, "--port", String(port)];
  if (autoStart.args?.length) {
    args.push(...autoStart.args);
  }

  const child = spawnImpl(executable, args, {
    cwd: workspaceRoot,
    env: { ...process.env, ...autoStart.env },
    stdio: "inherit"
  });

  return child;
};

const waitForHealth = async (
  runnerUrl: string,
  timeoutSeconds: number,
  fetchImpl?: typeof fetch
): Promise<void> => {
  const fetchFn = ensureFetchImpl(fetchImpl);
  const healthUrl = `${runnerUrl}${HEALTH_ENDPOINT}`;
  const deadline = Date.now() + timeoutSeconds * 1000;
  let attempt = 0;
  let lastError: unknown;

  while (Date.now() <= deadline) {
    try {
      const response = await fetchFn(healthUrl);
      if (response.ok) {
        return;
      }
      lastError = `${response.status} ${response.statusText}`;
    } catch (error) {
      lastError = error;
    }

    attempt += 1;
    await delay(Math.min(500 * attempt, 1000));
  }

  throw new Error(
    `Timed out waiting for FlowKit runner at ${healthUrl} (last error: ${lastError})`
  );
};

const awaitRunnerReady = async (
  runnerUrl: string,
  timeoutSeconds: number,
  fetchImpl: typeof fetch | undefined,
  child: ChildProcess
) => {
  const errorPromise = once(child, "error").then(([error]) => {
    const reason = error instanceof Error ? error.message : String(error);
    throw new Error(`Failed to start FlowKit runner process: ${reason}`);
  });

  await Promise.race([
    waitForHealth(runnerUrl, timeoutSeconds, fetchImpl),
    errorPromise
  ]).finally(() => {
    child.removeAllListeners("error");
  });
};

const stopRunnerProcess = async (child: ChildProcess) => {
  try {
    child.kill();
    await once(child, "exit");
  } catch {
    // Swallow errors during shutdown.
  }
};

const ensureRunnerLifecycle = async (
  flowConfig: FlowConfigFile,
  workspaceRoot: string,
  dependencies?: FlowKitCliDependencies
): Promise<{ url: string; stop?: () => Promise<void> }> => {
  const runnerUrl = resolveRunnerUrl(flowConfig);
  const autoStart = flowConfig.runtime.autoStart;

  if (process.env.FLOWKIT_RUNNER_URL || !autoStart) {
    return { url: runnerUrl };
  }

  const child = startRunnerProcess(
    flowConfig,
    workspaceRoot,
    runnerUrl,
    dependencies
  );
  await awaitRunnerReady(
    runnerUrl,
    autoStart.readyTimeoutSeconds ?? 60,
    dependencies?.fetchImpl,
    child
  );

  return {
    url: runnerUrl,
    stop: () => stopRunnerProcess(child)
  };
};

export const runFlowFromConfigPath = async (
  configPath: string,
  dependencies?: FlowKitCliDependencies
): Promise<FlowRunResult> => {
  const workspaceRoot = getWorkspaceRoot();
  const flowConfig = loadConfigFile(configPath, workspaceRoot);
  const lifecycle = await ensureRunnerLifecycle(
    flowConfig,
    workspaceRoot,
    dependencies
  );
  const factory = dependencies?.createHttpRunner || createHttpFlowRunner;
  const runner = factory({
    baseUrl: lifecycle.url,
    fetchImpl: dependencies?.fetchImpl
  });

  const requestConfig: FlowConfig = {
    flowName: flowConfig.id,
    canonicalPromptPath: flowConfig.canonicalPromptPath,
    workflowManifestPath: flowConfig.workflowManifestPath,
    workflowEntrypoint: flowConfig.workflowEntrypoint,
    workspaceRoot: flowConfig.workspaceRoot ?? workspaceRoot,
    observability: flowConfig.observability
  };

  try {
    return await runner.run({ config: requestConfig });
  } finally {
    if (lifecycle.stop) {
      await lifecycle.stop();
    }
  }
};

export const runCli = async (
  argv = process.argv,
  dependencies?: FlowKitCliDependencies
) => {
  // Parse standard kit flags
  const { flags, remaining } = parseStandardFlags(argv.slice(2));

  // Check for help
  if (remaining.includes("--help") || remaining.includes("-h")) {
    printUsage();
    return null;
  }

  const configPathArg = remaining[0];
  if (!configPathArg) {
    throw new Error(
      `Missing required argument.\nUsage: pnpm flowkit:run <path/to/flow${FLOW_CONFIG_EXTENSION}> [options]\n\nRun with --help for more information.`
    );
  }

  // In dry-run mode, validate config but don't execute
  if (flags.dryRun) {
    const workspaceRoot = getWorkspaceRoot();
    const flowConfig = loadConfigFile(configPathArg, workspaceRoot);

    const output = {
      status: "dry-run",
      summary: `Validated flow config: ${flowConfig.displayName}`,
      config: {
        id: flowConfig.id,
        displayName: flowConfig.displayName,
        description: flowConfig.description,
        canonicalPromptPath: flowConfig.canonicalPromptPath,
        workflowManifestPath: flowConfig.workflowManifestPath,
        workflowEntrypoint: flowConfig.workflowEntrypoint,
      },
      _kit: {
        name: "flowkit",
        version: "0.1.0",
        dryRun: true,
        stage: flags.stage,
        risk: flags.risk,
        traceEnabled: flags.trace,
        traceParent: flags.traceParent,
      },
    };

    if (flags.format === "text") {
      process.stdout.write(`[FlowKit] Dry-run: validated ${flowConfig.displayName}\n`);
      if (flags.verbose) {
        process.stdout.write(`  Config: ${configPathArg}\n`);
        process.stdout.write(`  Flow ID: ${flowConfig.id}\n`);
        process.stdout.write(`  Prompt: ${flowConfig.canonicalPromptPath}\n`);
        process.stdout.write(`  Manifest: ${flowConfig.workflowManifestPath}\n`);
      }
    } else {
      process.stdout.write(`${JSON.stringify(output, null, 2)}\n`);
    }

    return output;
  }

  const result = await runFlowFromConfigPath(configPathArg, dependencies);

  // Augment result with kit metadata
  const output = {
    ...result,
    _kit: {
      name: "flowkit",
      version: "0.1.0",
      dryRun: false,
      stage: flags.stage,
      risk: flags.risk,
      traceEnabled: flags.trace,
      traceParent: flags.traceParent,
    },
  };

  // Print a deterministic JSON payload so Cursor can show a structured result.
  if (flags.format === "text") {
    process.stdout.write(`[FlowKit] Flow completed: ${result.runId}\n`);
    if (flags.verbose && result.metadata) {
      process.stdout.write(`  Flow: ${result.metadata.flowName}\n`);
      process.stdout.write(`  Endpoint: ${result.metadata.runnerEndpoint}\n`);
    }
  } else {
    process.stdout.write(`${JSON.stringify(output, null, 2)}\n`);
  }

  return output;
};

/**
 * Print usage information.
 */
function printUsage(): void {
  console.log(`
FlowKit CLI - Workflow orchestration for Harmony

USAGE:
  flowkit run <path/to/flow.flow.json> [options]

ARGUMENTS:
  <flow.flow.json>      Path to flow configuration file

STANDARD KIT FLAGS:
  --dry-run, -n         Validate config without executing (default: true in local)
  --stage, -s <stage>   Lifecycle stage: spec|plan|implement|verify|ship|operate|learn
  --risk, -r <tier>     Risk tier: T1|T2|T3
  --idempotency-key <key> Idempotency key for operations
  --cache-key <key>     Cache key for pure operations
  --trace, -t           Enable trace linking
  --trace-parent <id>   Parent trace ID for correlation

OUTPUT OPTIONS:
  --format <format>     Output format: json (default), text
  --verbose, -v         Verbose output

ENVIRONMENT:
  FLOWKIT_RUNNER_URL    Override flow runner URL
  FLOWKIT_WORKSPACE_ROOT Override workspace root
  HARMONY_ENV           Environment (prod|preview disables dry-run default)

EXAMPLES:
  # Run a flow
  flowkit run flows/architecture-assessment.flow.json

  # Dry-run to validate config
  flowkit run flows/architecture-assessment.flow.json --dry-run

  # Run with risk tier and stage for telemetry
  flowkit run flows/architecture-assessment.flow.json --risk T2 --stage implement

  # Verbose text output
  flowkit run flows/architecture-assessment.flow.json --format text -v
`);
}

const entryPoint =
  process.argv[1] && pathToFileURL(process.argv[1]).href === import.meta.url;

if (entryPoint) {
  runCli().catch((error: unknown) => {
    const message = error instanceof Error ? error.message : String(error);
    process.stderr.write(`[FlowKit CLI] ${message}\n`);
    process.exitCode = 1;
  });
}

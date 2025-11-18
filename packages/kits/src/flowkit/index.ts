import { randomUUID } from "node:crypto";

export interface FlowObservabilityConfig {
  /**
   * Prefix applied to spans/trace ids for observability correlation.
   */
  spanPrefix?: string;
}

export interface FlowConfig {
  /**
   * Identifier for the flow to run (e.g., "architecture_assessment").
   */
  flowName: string;

  /**
   * Absolute or repo-relative path to the canonical prompt that defines the flow.
   * Example: "packages/prompts/assessment/architecture/architecture-assessment.md"
   */
  canonicalPromptPath: string;

  /**
   * Optional workspace root to resolve relative paths against.
   */
  workspaceRoot?: string;

  /**
   * Workflow manifest path to propagate to the runtime.
   */
  workflowManifestPath: string;

  /**
   * Optional workflow entrypoint id (falls back to manifest order if omitted).
   */
  workflowEntrypoint?: string;

  /**
   * Optional observability hints (passed through to the runtime).
   */
  observability?: FlowObservabilityConfig;
}

export interface FlowRunRequest {
  config: FlowConfig;

  /**
   * Optional initial state or parameters to seed the flow.
   * Concrete flows should define a typed shape and validate it at the edge.
   */
  params?: Record<string, unknown>;
}

export interface FlowRunMetadata {
  flowName: string;
  workflowManifestPath: string;
  canonicalPromptPath: string;
  workspaceRoot: string;
  runnerEndpoint: string;
  workflowEntrypoint?: string;
  runtimeRunId?: string;
  spanPrefix?: string;
  [key: string]: unknown;
}

export interface FlowRunResult {
  /**
   * Opaque flow-specific result payload, typically a structured summary
   * or report (for example, an alignment report).
   */
  result: unknown;

  /**
   * Stable identifier for this run, used for telemetry and correlation.
   */
  runId: string;

  /**
   * Optional path(s) to artifacts produced by the flow (for example, reports).
   */
  artifacts?: string[];

  /**
   * Optional metadata about the flow run (model config, manifest path, etc.).
   */
  metadata?: FlowRunMetadata;
}

/**
 * FlowRunner defines the minimal contract for running a FlowKit flow.
 *
 * Runtime implementations (for example, a Python LangGraph runner, HTTP service,
 * or local Node orchestration) should implement this interface and be wired up
 * via composition. This package does not prescribe a specific runtime.
 */
export interface FlowRunner {
  run(request: FlowRunRequest): Promise<FlowRunResult>;
}

/**
 * Placeholder/no-op FlowRunner.
 *
 * This default implementation exists so callers can depend on FlowKit types
 * without immediately wiring a runtime. In production, provide a concrete
 * FlowRunner (for example, one that shells out to a Python LangGraph runner
 * or calls a dedicated HTTP service).
 */
export const notImplementedFlowRunner: FlowRunner = {
  async run() {
    throw new Error(
      "FlowKit notImplementedFlowRunner was called. Provide a concrete FlowRunner implementation for your runtime (e.g., Python LangGraph runner or HTTP service)."
    );
  }
};

export interface HttpFlowRunnerOptions {
  /**
   * Base URL of the FlowKit runner service (e.g., http://127.0.0.1:8410).
   */
  baseUrl: string;

  /**
   * Optional fetch implementation (defaults to global fetch).
   */
  fetchImpl?: typeof fetch;
}

const ensureFetch = (override?: typeof fetch) => {
  const impl = override ?? globalThis.fetch;
  if (!impl) {
    throw new Error(
      "FlowKit HTTP runner requires a fetch implementation (Node 18+ or polyfill)."
    );
  }
  return impl;
};

export function createHttpFlowRunner(
  options: HttpFlowRunnerOptions
): FlowRunner {
  const fetchImpl = ensureFetch(options.fetchImpl);
  const baseUrl = options.baseUrl.replace(/\/$/, "");

  return {
    async run(request: FlowRunRequest): Promise<FlowRunResult> {
      const { config, params } = request;
      const runId = randomUUID();
      const workspaceRoot = config.workspaceRoot ?? process.cwd();
      const payload = {
        runId,
        flowName: config.flowName,
        canonicalPromptPath: config.canonicalPromptPath,
        workflowManifestPath: config.workflowManifestPath,
        workflowEntrypoint: config.workflowEntrypoint,
        workspaceRoot,
        observability: config.observability,
        params: params ?? {},
      };

      const response = await fetchImpl(`${baseUrl}/flows/run`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        const errorBody = await response.text();
        throw new Error(
          `FlowKit HTTP runner request failed (${response.status} ${response.statusText}): ${errorBody}`
        );
      }

      const data = await response.json();

      return {
        result: data.result,
        artifacts: data.artifacts ?? undefined,
        runId,
        metadata: {
          flowName: config.flowName,
          workflowManifestPath: config.workflowManifestPath,
          workflowEntrypoint: config.workflowEntrypoint,
          canonicalPromptPath: config.canonicalPromptPath,
          workspaceRoot,
          runnerEndpoint: baseUrl,
          runtimeRunId: data.runtimeRunId,
          spanPrefix: config.observability?.spanPrefix,
          ...(data.metadata ?? {}),
        },
      };
    },
  };
}

export const architectureAssessmentCliRunner: FlowRunner =
  createHttpFlowRunner({
    baseUrl: process.env.FLOWKIT_RUNNER_URL || "http://127.0.0.1:8410",
  });


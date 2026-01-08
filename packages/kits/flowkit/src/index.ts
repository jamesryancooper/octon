/**
 * FlowKit - Workflow orchestration and multi-step execution.
 *
 * FlowKit provides the orchestration layer for running AI-powered workflows,
 * abstracting runtime details (LangGraph, HTTP services, etc.) behind a
 * consistent interface.
 *
 * Pillar alignment:
 * - Speed with Safety: Enables rapid workflow execution with built-in safeguards
 * - Guided Agentic Autonomy: Coordinates AI agents through structured workflows
 *
 * @example
 * ```typescript
 * import { createHttpFlowRunner, type FlowRunRequest } from '@harmony/flowkit';
 *
 * const runner = createHttpFlowRunner({
 *   baseUrl: 'http://127.0.0.1:8410',
 * });
 *
 * const request: FlowRunRequest = {
 *   config: {
 *     flowName: 'architecture_assessment',
 *     canonicalPromptPath: 'packages/workflows/architecture_assessment/00-overview.md',
 *     workflowManifestPath: 'packages/workflows/architecture_assessment/manifest.yaml',
 *   },
 *   params: {
 *     targetPath: './src',
 *   },
 * };
 *
 * const result = await runner.run(request);
 * console.log('Run ID:', result.runId);
 * console.log('Result:', result.result);
 * ```
 */

import { randomUUID } from "node:crypto";
import { SpanStatusCode } from "@opentelemetry/api";
import {
  getKitTracer,
  withKitSpan,
  emitStateTransition,
  emitGateResult,
  getCurrentTraceId,
  type KitSpanContext,
} from "@harmony/kit-base";
import {
  UpstreamProviderError,
  InputValidationError,
} from "@harmony/kit-base";
import {
  createRunRecord,
  safeWriteRunRecord,
  getRunsDirectory,
  type RunRecord,
} from "@harmony/kit-base";
import {
  withIdempotency,
  deriveIdempotencyKey,
  hashInputs,
} from "@harmony/kit-base";

// Re-export all types from types.ts
export type {
  FlowObservabilityConfig,
  FlowConfig,
  FlowRunRequest,
  FlowRunMetadata,
  FlowRunResult,
  FlowRunner,
  HttpFlowRunnerOptions,
  FlowRunStatus,
  FlowStep,
  FlowContext,
} from "./types.js";

// Import types for internal use
import type {
  FlowRunner,
  FlowRunRequest,
  FlowRunResult,
  HttpFlowRunnerOptions,
} from "./types.js";

// Re-export run record utilities for consumers
export { createRunRecord, writeRunRecord, safeWriteRunRecord, getRunsDirectory } from "@harmony/kit-base";
export type { RunRecord } from "@harmony/kit-base";

/** Kit metadata */
const KIT_NAME = "flowkit";
const KIT_VERSION = "0.1.0";

/**
 * Get kit span context for observability.
 */
function getSpanContext(): KitSpanContext {
  return {
    tracer: getKitTracer({ kitName: KIT_NAME, kitVersion: KIT_VERSION }),
    kitName: KIT_NAME,
    kitVersion: KIT_VERSION,
  };
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
    throw new InputValidationError(
      "FlowKit notImplementedFlowRunner was called. Provide a concrete FlowRunner implementation for your runtime (e.g., Python LangGraph runner or HTTP service).",
      { context: { "flow.runner": "notImplemented" } }
    );
  },
};

/**
 * Ensure fetch is available.
 */
const ensureFetch = (override?: typeof fetch) => {
  const impl = override ?? globalThis.fetch;
  if (!impl) {
    throw new InputValidationError(
      "FlowKit HTTP runner requires a fetch implementation (Node 18+ or polyfill).",
      { context: { requirement: "fetch" } }
    );
  }
  return impl;
};

/**
 * Create an HTTP-based FlowRunner that delegates to a remote service.
 *
 * This is the standard adapter for connecting to a Python LangGraph runner
 * or other HTTP-based flow execution service.
 *
 * Observability: Emits `kit.flowkit.run` span wrapping the HTTP call.
 * Idempotency: Uses withIdempotency to prevent duplicate executions.
 *
 * @param options - Configuration for the HTTP runner
 * @returns A FlowRunner implementation
 */
export function createHttpFlowRunner(
  options: HttpFlowRunnerOptions
): FlowRunner {
  const fetchImpl = ensureFetch(options.fetchImpl);
  const baseUrl = options.baseUrl.replace(/\/$/, "");

  return {
    async run(request: FlowRunRequest): Promise<FlowRunResult> {
      const { config, params } = request;
      const workspaceRoot = config.workspaceRoot ?? process.cwd();

      // Derive idempotency key from request or from stable inputs
      // Uses fields from kit.metadata.json: flowName, canonicalPromptPath, workflowManifestPath
      const stableInputs = {
        flowName: config.flowName,
        canonicalPromptPath: config.canonicalPromptPath,
        workflowManifestPath: config.workflowManifestPath,
      };
      const idempotencyKey = request.idempotencyKey ?? deriveIdempotencyKey({
        kitName: KIT_NAME,
        operation: "run",
        stableInputs,
        gitSha: process.env.GIT_SHA,
      });
      const inputsHashValue = hashInputs({ ...stableInputs, params: params ?? {} });

      // Wrap operation with idempotency protection
      const { result: flowResult, cached, runId: idempotencyRunId } = await withIdempotency<FlowRunResult>(
        idempotencyKey,
        KIT_NAME,
        "run",
        { ...stableInputs, params: params ?? {} },
        async () => {
          // This is the actual operation - only executes if not cached
          const runId = randomUUID();
          const startTime = Date.now();
          const ctx = getSpanContext();

          return withKitSpan(
            ctx,
            "run",
            {
              "run.id": runId,
              "flow.name": config.flowName,
              "flow.manifestPath": config.workflowManifestPath,
              "flow.promptPath": config.canonicalPromptPath,
              "flow.entrypoint": config.workflowEntrypoint,
              "runner.endpoint": baseUrl,
              "idempotency.key": idempotencyKey,
            },
            async (span) => {
              const payload = {
                runId,
                flowName: config.flowName,
                canonicalPromptPath: config.canonicalPromptPath,
                workflowManifestPath: config.workflowManifestPath,
                workflowEntrypoint: config.workflowEntrypoint,
                workspaceRoot,
                params: params ?? {},
              };

              // Emit state transition event
              emitStateTransition(span, "idle", "executing");

              let runRecord: RunRecord | undefined;

              try {
                const response = await fetchImpl(`${baseUrl}/flows/run`, {
                  method: "POST",
                  headers: {
                    "Content-Type": "application/json",
                    ...options.headers,
                  },
                  body: JSON.stringify(payload),
                  ...(options.timeoutMs && {
                    signal: AbortSignal.timeout(options.timeoutMs),
                  }),
                });

                if (!response.ok) {
                  const errorBody = await response.text();
                  emitGateResult(span, "http_response", false, `HTTP ${response.status}`);

                  // Generate failure run record with idempotency info
                  if (options.enableRunRecords !== false) {
                    runRecord = createRunRecord({
                      kit: { name: KIT_NAME, version: KIT_VERSION },
                      inputs: { flowName: config.flowName, params: params ?? {} },
                      status: "failure",
                      summary: `HTTP ${response.status}: ${response.statusText}`,
                      stage: "implement",
                      risk: "low",
                      traceId: getCurrentTraceId() || runId,
                      durationMs: Date.now() - startTime,
                      determinism: {
                        idempotencyKey,
                        inputsHash: inputsHashValue,
                      },
                    });

                    const runsDir = options.runsDir || getRunsDirectory(workspaceRoot);
                    safeWriteRunRecord(runRecord, runsDir);
                  }

                  throw new UpstreamProviderError(
                    `FlowKit HTTP runner request failed (${response.status} ${response.statusText}): ${errorBody}`,
                    {
                      provider: "flow-runner",
                      statusCode: response.status,
                      context: {
                        endpoint: `${baseUrl}/flows/run`,
                        flowName: config.flowName,
                      },
                    }
                  );
                }

                const data = await response.json();

                // Record success
                span.setStatus({ code: SpanStatusCode.OK });
                emitStateTransition(span, "executing", "completed");
                emitGateResult(span, "http_response", true);

                // Add result attributes
                if (data.runtimeRunId) {
                  span.setAttribute("runtime.runId", data.runtimeRunId);
                }
                if (data.artifacts?.length) {
                  span.setAttribute("artifacts.count", data.artifacts.length);
                }

                const result: FlowRunResult = {
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

                // Generate success run record with idempotency info and outputs
                if (options.enableRunRecords !== false) {
                  runRecord = createRunRecord({
                    kit: { name: KIT_NAME, version: KIT_VERSION },
                    inputs: { flowName: config.flowName, params: params ?? {} },
                    status: "success",
                    summary: `Flow ${config.flowName} completed successfully`,
                    stage: "implement",
                    risk: "low",
                    traceId: getCurrentTraceId() || runId,
                    artifacts: data.artifacts?.map((a: { path: string; type?: string }) => ({
                      path: a.path,
                      type: a.type || "unknown",
                    })),
                    durationMs: Date.now() - startTime,
                    determinism: {
                      idempotencyKey,
                      inputsHash: inputsHashValue,
                    },
                    outputs: result, // Store result for idempotency cache
                  });

                  const runsDir = options.runsDir || getRunsDirectory(workspaceRoot);
                  safeWriteRunRecord(runRecord, runsDir);
                }

                return result;
              } catch (error) {
                // If we haven't written a run record yet (for non-HTTP errors), write one now
                if (options.enableRunRecords !== false && !runRecord) {
                  runRecord = createRunRecord({
                    kit: { name: KIT_NAME, version: KIT_VERSION },
                    inputs: { flowName: config.flowName, params: params ?? {} },
                    status: "failure",
                    summary: error instanceof Error ? error.message : "Unknown error",
                    stage: "implement",
                    risk: "low",
                    traceId: getCurrentTraceId() || runId,
                    durationMs: Date.now() - startTime,
                    determinism: {
                      idempotencyKey,
                      inputsHash: inputsHashValue,
                    },
                  });

                  const runsDir = options.runsDir || getRunsDirectory(workspaceRoot);
                  safeWriteRunRecord(runRecord, runsDir);
                }
                throw error;
              }
            }
          );
        }
      );

      // If result was cached, log for observability
      if (cached && idempotencyRunId) {
        console.log(`[flowkit] Returning cached result for idempotency key ${idempotencyKey} (runId: ${idempotencyRunId})`);
      }

      return flowResult;
    },
  };
}

/**
 * Default architecture assessment CLI runner.
 *
 * Uses FLOWKIT_RUNNER_URL environment variable or defaults to localhost.
 */
export const architectureAssessmentCliRunner: FlowRunner =
  createHttpFlowRunner({
    baseUrl: process.env.FLOWKIT_RUNNER_URL || "http://127.0.0.1:8410",
  });

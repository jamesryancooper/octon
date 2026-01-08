/**
 * Type definitions for FlowKit - Workflow orchestration and multi-step execution.
 *
 * FlowKit provides the orchestration layer for running AI-powered workflows,
 * abstracting runtime details (LangGraph, HTTP services, etc.) behind a
 * consistent interface.
 */

/**
 * Observability configuration for flow runs.
 */
export interface FlowObservabilityConfig {
  /**
   * Prefix applied to spans/trace ids for observability correlation.
   */
  spanPrefix?: string;

  /**
   * Service name for telemetry.
   */
  serviceName?: string;

  /**
   * Enable trace propagation.
   */
  enableTracing?: boolean;
}

/**
 * Configuration for a FlowKit flow.
 */
export interface FlowConfig {
  /**
   * Identifier for the flow to run (e.g., "architecture_assessment").
   */
  flowName: string;

  /**
   * Absolute or repo-relative path to the canonical prompt that defines the flow.
   * Example: "packages/workflows/architecture_assessment/00-overview.md"
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

/**
 * Request to execute a flow.
 */
export interface FlowRunRequest {
  /**
   * Flow configuration.
   */
  config: FlowConfig;

  /**
   * Optional initial state or parameters to seed the flow.
   * Concrete flows should define a typed shape and validate it at the edge.
   */
  params?: Record<string, unknown>;

  /**
   * Optional idempotency key for this flow run.
   * If not provided, a key will be derived from flowName, canonicalPromptPath,
   * and workflowManifestPath.
   */
  idempotencyKey?: string;
}

/**
 * Metadata about a flow run.
 */
export interface FlowRunMetadata {
  /** Flow name */
  flowName: string;

  /** Workflow manifest path */
  workflowManifestPath: string;

  /** Canonical prompt path */
  canonicalPromptPath: string;

  /** Workspace root */
  workspaceRoot: string;

  /** Runner endpoint */
  runnerEndpoint: string;

  /** Optional workflow entrypoint */
  workflowEntrypoint?: string;

  /** Runtime-assigned run ID */
  runtimeRunId?: string;

  /** Span prefix for observability */
  spanPrefix?: string;

  /** Additional metadata from runtime */
  [key: string]: unknown;
}

/**
 * Result of a flow run.
 */
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
  /**
   * Execute a flow with the given request.
   */
  run(request: FlowRunRequest): Promise<FlowRunResult>;
}

/**
 * Options for HTTP-based flow runner.
 */
export interface HttpFlowRunnerOptions {
  /**
   * Base URL of the FlowKit runner service (e.g., http://127.0.0.1:8410).
   */
  baseUrl: string;

  /**
   * Optional fetch implementation (defaults to global fetch).
   */
  fetchImpl?: typeof fetch;

  /**
   * Optional timeout in milliseconds.
   */
  timeoutMs?: number;

  /**
   * Optional headers to include in requests.
   */
  headers?: Record<string, string>;

  /**
   * Enable run record generation (default: true).
   */
  enableRunRecords?: boolean;

  /**
   * Directory to write run records (default: ./runs).
   */
  runsDir?: string;
}

/**
 * Flow run status.
 */
export type FlowRunStatus =
  | "pending"
  | "running"
  | "completed"
  | "failed"
  | "cancelled";

/**
 * Flow step in a workflow.
 */
export interface FlowStep {
  /** Step identifier */
  stepId: string;

  /** Step name */
  name: string;

  /** Step status */
  status: FlowRunStatus;

  /** Start time */
  startedAt?: string;

  /** End time */
  completedAt?: string;

  /** Duration in milliseconds */
  durationMs?: number;

  /** Step result */
  result?: unknown;

  /** Error if failed */
  error?: string;
}

/**
 * Flow execution context.
 */
export interface FlowContext {
  /** Run ID */
  runId: string;

  /** Flow name */
  flowName: string;

  /** Current step */
  currentStep?: string;

  /** Execution steps */
  steps: FlowStep[];

  /** Start time */
  startedAt: string;

  /** End time */
  completedAt?: string;

  /** Overall status */
  status: FlowRunStatus;
}


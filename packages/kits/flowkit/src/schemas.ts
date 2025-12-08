/**
 * FlowKit Zod Schemas
 *
 * Runtime validation schemas for FlowKit inputs and outputs.
 */

import { z } from "zod";

// ============================================================================
// Input Schemas
// ============================================================================

/**
 * Observability configuration schema.
 */
export const FlowObservabilitySchema = z.object({
  spanPrefix: z.string().optional(),
});

/**
 * Flow configuration schema.
 */
export const FlowConfigSchema = z.object({
  /** Stable identifier for the flow */
  flowName: z.string().min(1),

  /** Path to the canonical prompt markdown file */
  canonicalPromptPath: z.string().min(1),

  /** Path to the YAML workflow manifest */
  workflowManifestPath: z.string().min(1),

  /** Entry point node id declared for this workflow */
  workflowEntrypoint: z.string().min(1),

  /** Workspace root directory */
  workspaceRoot: z.string().optional(),

  /** Observability configuration */
  observability: FlowObservabilitySchema.optional(),
});

/**
 * HTTP runner options schema.
 */
export const HttpFlowRunnerOptionsSchema = z.object({
  /** Base URL for the flow runner service */
  baseUrl: z.string().url(),

  /** Custom fetch implementation */
  fetchImpl: z.function().optional(),

  /** Request timeout in milliseconds */
  timeoutMs: z.number().positive().optional(),

  /** Enable run records (default: true) */
  enableRunRecords: z.boolean().default(true),

  /** Directory to write run records */
  runsDir: z.string().optional(),
});

/**
 * Flow run request schema.
 */
export const FlowRunRequestSchema = z.object({
  /** Flow configuration */
  config: FlowConfigSchema,

  /** Optional parameters for the flow */
  params: z.record(z.unknown()).optional(),

  /**
   * Idempotency key for the run.
   * If not provided, derived from flowName, canonicalPromptPath, workflowManifestPath.
   */
  idempotencyKey: z.string().optional(),

  /** Dry-run mode */
  dryRun: z.boolean().default(false),
});

// ============================================================================
// Output Schemas
// ============================================================================

/**
 * Flow run metadata schema.
 */
export const FlowRunMetadataSchema = z.object({
  flowName: z.string(),
  runnerEndpoint: z.string(),
  startTime: z.string(),
  endTime: z.string().optional(),
  durationMs: z.number().optional(),
});

/**
 * Flow run result schema.
 */
export const FlowRunResultSchema = z.object({
  /** Unique run ID */
  runId: z.string(),

  /** Run status */
  status: z.enum(["success", "failure"]),

  /** Result data */
  result: z.unknown().optional(),

  /** Error message if failed */
  error: z.string().optional(),

  /** Run metadata */
  metadata: FlowRunMetadataSchema.optional(),
});

// ============================================================================
// Type Exports
// ============================================================================

export type FlowConfig = z.infer<typeof FlowConfigSchema>;
export type HttpFlowRunnerOptions = z.infer<typeof HttpFlowRunnerOptionsSchema>;
export type FlowRunRequest = z.infer<typeof FlowRunRequestSchema>;
export type FlowRunResult = z.infer<typeof FlowRunResultSchema>;
export type FlowRunMetadata = z.infer<typeof FlowRunMetadataSchema>;

// ============================================================================
// Validation Functions
// ============================================================================

/**
 * Validate flow configuration.
 */
export function validateFlowConfig(config: unknown): FlowConfig {
  return FlowConfigSchema.parse(config);
}

/**
 * Validate flow run request.
 */
export function validateFlowRunRequest(request: unknown): FlowRunRequest {
  return FlowRunRequestSchema.parse(request);
}

/**
 * Safe validation that returns a result instead of throwing.
 */
export function safeValidateFlowConfig(config: unknown): {
  success: boolean;
  data?: FlowConfig;
  error?: z.ZodError;
} {
  const result = FlowConfigSchema.safeParse(config);
  if (result.success) {
    return { success: true, data: result.data };
  }
  return { success: false, error: result.error };
}


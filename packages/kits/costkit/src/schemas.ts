/**
 * CostKit Zod Schemas
 *
 * Runtime validation schemas for CostKit inputs and outputs.
 */

import { z } from "zod";

// ============================================================================
// Input Schemas
// ============================================================================

/**
 * Risk tier schema.
 */
export const RiskTierSchema = z.enum(["T1", "T2", "T3"]);

/**
 * Workflow stage schema.
 */
export const WorkflowStageSchema = z.enum(["draft", "final"]);

/**
 * Budget period schema.
 */
export const BudgetPeriodSchema = z.enum(["daily", "weekly", "monthly"]);

/**
 * CostKit configuration schema.
 */
export const CostKitConfigSchema = z.object({
  /** Path to cost policy YAML */
  policyPath: z.string().optional(),

  /** Path to cost data file */
  dataPath: z.string().optional(),

  /** Enable run records (default: true) */
  enableRunRecords: z.boolean().default(true),

  /** Directory to write run records */
  runsDir: z.string().optional(),

  /** Idempotency key */
  idempotencyKey: z.string().optional(),

  /** Dry-run mode */
  dryRun: z.boolean().default(false),
});

/**
 * Estimate request schema.
 */
export const EstimateRequestSchema = z.object({
  /** Workflow type */
  workflowType: z.string(),

  /** Risk tier */
  tier: RiskTierSchema.default("T2"),

  /** Workflow stage */
  stage: WorkflowStageSchema.default("final"),

  /** Override model */
  model: z.string().optional(),

  /** Idempotency key */
  idempotencyKey: z.string().optional(),
});

/**
 * Record usage request schema.
 */
export const RecordUsageRequestSchema = z.object({
  /** Model used */
  model: z.string(),

  /** Input tokens */
  inputTokens: z.number().nonnegative(),

  /** Output tokens */
  outputTokens: z.number().nonnegative(),

  /** Workflow type */
  workflowType: z.string(),

  /** Risk tier */
  tier: RiskTierSchema.default("T2"),

  /** Duration in milliseconds */
  durationMs: z.number().nonnegative(),

  /** Whether the operation succeeded */
  success: z.boolean(),

  /** Idempotency key */
  idempotencyKey: z.string().optional(),
});

// ============================================================================
// Output Schemas
// ============================================================================

/**
 * Cost range schema.
 */
export const CostRangeSchema = z.object({
  min: z.number(),
  max: z.number(),
});

/**
 * Token estimate schema - matches TokenEstimate interface.
 */
export const TokenEstimateSchema = z.object({
  /** Estimated input tokens */
  inputTokens: z.number(),

  /** Estimated output tokens */
  outputTokens: z.number(),

  /** Total estimated tokens */
  totalTokens: z.number(),

  /** Confidence level (0-1) */
  confidence: z.number().min(0).max(1),

  /** Basis for the estimate */
  basis: z.enum(["historical", "heuristic", "measured"]),
});

/**
 * LLM provider schema.
 */
export const LLMProviderSchema = z.enum(["openai", "anthropic", "google", "mistral", "local"]);

/**
 * Cost estimate schema - matches CostEstimate interface.
 */
export const CostEstimateSchema = z.object({
  /** Unique identifier for this estimate */
  estimateId: z.string(),

  /** The model to be used */
  model: z.string(),

  /** Provider */
  provider: LLMProviderSchema,

  /** Estimated tokens */
  tokens: TokenEstimateSchema,

  /** Estimated cost in USD */
  estimatedCostUsd: z.number(),

  /** Cost range (min-max) in USD */
  costRange: CostRangeSchema,

  /** Workflow type */
  workflowType: z.string(),

  /** Risk tier */
  tier: RiskTierSchema,

  /** Stage (for T2) */
  stage: WorkflowStageSchema.optional(),

  /** Created timestamp */
  createdAt: z.string(),

  /** Whether this exceeds budget */
  exceedsBudget: z.boolean(),

  /** Budget warnings if any */
  budgetWarnings: z.array(z.string()),
});

/**
 * Usage record schema - matches UsageRecord interface.
 */
export const UsageRecordSchema = z.object({
  /** Unique identifier */
  usageId: z.string(),

  /** Associated estimate ID if pre-flight was done */
  estimateId: z.string().optional(),

  /** Model used */
  model: z.string(),

  /** Provider */
  provider: LLMProviderSchema,

  /** Actual tokens used */
  tokens: z.object({
    input: z.number(),
    output: z.number(),
    total: z.number(),
  }),

  /** Actual cost in USD */
  actualCostUsd: z.number(),

  /** Prompt or workflow type */
  workflowType: z.string(),

  /** Risk tier */
  tier: RiskTierSchema,

  /** Task ID if associated with a task */
  taskId: z.string().optional(),

  /** Timestamp */
  timestamp: z.string(),

  /** Duration in milliseconds */
  durationMs: z.number(),

  /** Whether the operation succeeded */
  success: z.boolean(),

  /** Error message if failed */
  error: z.string().optional(),

  /**
   * Idempotency key for this usage record.
   * If not provided, derived from model, tokens, workflowType.
   */
  idempotencyKey: z.string().optional(),
});

/**
 * Top spending model entry schema.
 */
export const TopModelEntrySchema = z.object({
  model: z.string(),
  spentUsd: z.number(),
  percent: z.number(),
});

/**
 * Top spending workflow entry schema.
 */
export const TopWorkflowEntrySchema = z.object({
  workflowType: z.string(),
  spentUsd: z.number(),
  percent: z.number(),
});

/**
 * Budget status schema - matches BudgetStatus interface.
 */
export const BudgetStatusSchema = z.object({
  /** Budget period */
  period: BudgetPeriodSchema,

  /** Period start date */
  periodStart: z.string(),

  /** Period end date */
  periodEnd: z.string(),

  /** Budget limit in USD */
  limitUsd: z.number(),

  /** Amount spent in USD */
  spentUsd: z.number(),

  /** Remaining budget in USD */
  remainingUsd: z.number(),

  /** Percentage of budget used (0-100) */
  usedPercent: z.number(),

  /** Current status */
  status: z.enum(["healthy", "warning", "critical", "exceeded"]),

  /** Projected end-of-period spend based on current burn rate */
  projectedSpendUsd: z.number(),

  /** Whether projected spend exceeds budget */
  projectedOverBudget: z.boolean(),

  /** Top spending models */
  topModels: z.array(TopModelEntrySchema),

  /** Top spending workflow types */
  topWorkflows: z.array(TopWorkflowEntrySchema),
});

/**
 * Breakdown entry schema (for byModel, byWorkflow, byTier).
 */
export const BreakdownEntrySchema = z.object({
  spentUsd: z.number(),
  tokens: z.number(),
  operations: z.number(),
});

/**
 * Cost trend schema - matches CostSummary.trend interface.
 */
export const CostTrendSchema = z.object({
  previousPeriodSpent: z.number(),
  changePercent: z.number(),
  direction: z.enum(["up", "down", "stable"]),
});

/**
 * Optimization opportunity schema.
 */
export const OptimizationOpportunitySchema = z.object({
  description: z.string(),
  estimatedSavingsUsd: z.number(),
  recommendation: z.string(),
});

/**
 * Cost summary schema - matches CostSummary interface.
 */
export const CostSummarySchema = z.object({
  /** Summary period start */
  periodStart: z.string(),

  /** Summary period end */
  periodEnd: z.string(),

  /** Total spend in USD */
  totalSpentUsd: z.number(),

  /** Total tokens used */
  totalTokens: z.object({
    input: z.number(),
    output: z.number(),
    total: z.number(),
  }),

  /** Number of operations */
  operationCount: z.number(),

  /** Success rate (0-1) */
  successRate: z.number().min(0).max(1),

  /** Average cost per operation */
  avgCostPerOperation: z.number(),

  /** Breakdown by model */
  byModel: z.record(BreakdownEntrySchema),

  /** Breakdown by workflow type */
  byWorkflow: z.record(BreakdownEntrySchema),

  /** Breakdown by tier */
  byTier: z.record(RiskTierSchema, BreakdownEntrySchema),

  /** Cost trend compared to previous period */
  trend: CostTrendSchema,

  /** Optimization opportunities identified */
  optimizationOpportunities: z.array(OptimizationOpportunitySchema),
});

/**
 * Alert severity schema.
 */
export const AlertSeveritySchema = z.enum(["info", "warning", "critical"]);

/**
 * Alert type schema.
 */
export const AlertTypeSchema = z.enum([
  "budget_warning",
  "budget_critical",
  "budget_exceeded",
  "unusual_spend",
  "model_deprecated",
  "pricing_change",
  "estimate_exceeded",
]);

/**
 * Cost alert schema - matches CostAlert interface.
 */
export const CostAlertSchema = z.object({
  /** Unique identifier */
  alertId: z.string(),

  /** Alert type */
  type: AlertTypeSchema,

  /** Severity level */
  severity: AlertSeveritySchema,

  /** Human-readable message */
  message: z.string(),

  /** Detailed description */
  details: z.string(),

  /** Associated data */
  data: z.record(z.unknown()),

  /** When the alert was created */
  createdAt: z.string(),

  /** Whether the alert has been acknowledged */
  acknowledged: z.boolean(),

  /** Who acknowledged it */
  acknowledgedBy: z.string().optional(),

  /** When it was acknowledged */
  acknowledgedAt: z.string().optional(),
});

// ============================================================================
// Type Exports
// ============================================================================

export type RiskTier = z.infer<typeof RiskTierSchema>;
export type WorkflowStage = z.infer<typeof WorkflowStageSchema>;
export type BudgetPeriod = z.infer<typeof BudgetPeriodSchema>;
export type LLMProvider = z.infer<typeof LLMProviderSchema>;
export type CostKitConfig = z.infer<typeof CostKitConfigSchema>;
export type EstimateRequest = z.infer<typeof EstimateRequestSchema>;
export type RecordUsageRequest = z.infer<typeof RecordUsageRequestSchema>;
export type CostRange = z.infer<typeof CostRangeSchema>;
export type TokenEstimate = z.infer<typeof TokenEstimateSchema>;
export type CostEstimate = z.infer<typeof CostEstimateSchema>;
export type UsageRecord = z.infer<typeof UsageRecordSchema>;
export type TopModelEntry = z.infer<typeof TopModelEntrySchema>;
export type TopWorkflowEntry = z.infer<typeof TopWorkflowEntrySchema>;
export type BudgetStatus = z.infer<typeof BudgetStatusSchema>;
export type BreakdownEntry = z.infer<typeof BreakdownEntrySchema>;
export type CostSummary = z.infer<typeof CostSummarySchema>;
export type CostTrend = z.infer<typeof CostTrendSchema>;
export type OptimizationOpportunity = z.infer<typeof OptimizationOpportunitySchema>;
export type AlertSeverity = z.infer<typeof AlertSeveritySchema>;
export type AlertType = z.infer<typeof AlertTypeSchema>;
export type CostAlert = z.infer<typeof CostAlertSchema>;

// ============================================================================
// Validation Functions
// ============================================================================

/**
 * Validate CostKit configuration.
 */
export function validateCostKitConfig(config: unknown): CostKitConfig {
  return CostKitConfigSchema.parse(config);
}

/**
 * Validate estimate request.
 */
export function validateEstimateRequest(request: unknown): EstimateRequest {
  return EstimateRequestSchema.parse(request);
}

/**
 * Validate record usage request.
 */
export function validateRecordUsageRequest(request: unknown): RecordUsageRequest {
  return RecordUsageRequestSchema.parse(request);
}

/**
 * Safe validation that returns a result instead of throwing.
 */
export function safeValidateCostKitConfig(config: unknown): {
  success: boolean;
  data?: CostKitConfig;
  error?: z.ZodError;
} {
  const result = CostKitConfigSchema.safeParse(config);
  if (result.success) {
    return { success: true, data: result.data };
  }
  return { success: false, error: result.error };
}


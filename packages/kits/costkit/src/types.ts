/**
 * Type definitions for CostKit - LLM cost management and optimization.
 */

/**
 * Supported LLM providers.
 */
export type LLMProvider = "openai" | "anthropic" | "google" | "mistral" | "local";

/**
 * Risk tier for model selection.
 */
export type RiskTier = "T1" | "T2" | "T3";

/**
 * Stage in the workflow (affects model selection for T2).
 */
export type WorkflowStage = "draft" | "final";

/**
 * Model pricing information (per 1M tokens).
 */
export interface ModelPricing {
  /** Model identifier (e.g., "gpt-4o", "claude-sonnet") */
  model: string;

  /** Provider */
  provider: LLMProvider;

  /** Price per 1M input tokens in USD */
  inputPricePer1M: number;

  /** Price per 1M output tokens in USD */
  outputPricePer1M: number;

  /** Context window size in tokens */
  contextWindow: number;

  /** Maximum output tokens */
  maxOutputTokens: number;

  /** When this pricing was last updated */
  updatedAt: string;

  /** Whether this model is deprecated */
  deprecated?: boolean;

  /** Replacement model if deprecated */
  replacement?: string;
}

/**
 * Token estimate for a workflow.
 */
export interface TokenEstimate {
  /** Estimated input tokens */
  inputTokens: number;

  /** Estimated output tokens */
  outputTokens: number;

  /** Total estimated tokens */
  totalTokens: number;

  /** Confidence level (0-1) */
  confidence: number;

  /** Basis for the estimate */
  basis: "historical" | "heuristic" | "measured";
}

/**
 * Cost estimate for a single operation.
 */
export interface CostEstimate {
  /** Unique identifier for this estimate */
  estimateId: string;

  /** The model to be used */
  model: string;

  /** Provider */
  provider: LLMProvider;

  /** Estimated tokens */
  tokens: TokenEstimate;

  /** Estimated cost in USD */
  estimatedCostUsd: number;

  /** Cost range (min-max) in USD */
  costRange: {
    min: number;
    max: number;
  };

  /** Prompt or workflow type */
  workflowType: string;

  /** Risk tier */
  tier: RiskTier;

  /** Stage (for T2) */
  stage?: WorkflowStage;

  /** Created timestamp */
  createdAt: string;

  /** Whether this exceeds budget thresholds */
  exceedsBudget: boolean;

  /** Budget warnings if any */
  budgetWarnings: string[];
}

/**
 * Actual usage record for tracking.
 */
export interface UsageRecord {
  /** Unique identifier */
  usageId: string;

  /** Associated estimate ID if pre-flight was done */
  estimateId?: string;

  /** Model used */
  model: string;

  /** Provider */
  provider: LLMProvider;

  /** Actual tokens used */
  tokens: {
    input: number;
    output: number;
    total: number;
  };

  /** Actual cost in USD */
  actualCostUsd: number;

  /** Prompt or workflow type */
  workflowType: string;

  /** Risk tier */
  tier: RiskTier;

  /** Task ID if associated with a task */
  taskId?: string;

  /** Timestamp */
  timestamp: string;

  /** Duration in milliseconds */
  durationMs: number;

  /** Whether the operation succeeded */
  success: boolean;

  /** Error message if failed */
  error?: string;
}

/**
 * Budget period type.
 */
export type BudgetPeriod = "daily" | "weekly" | "monthly";

/**
 * Budget configuration.
 */
export interface BudgetConfig {
  /** Budget period */
  period: BudgetPeriod;

  /** Budget limit in USD */
  limitUsd: number;

  /** Warning threshold as percentage (0-100) */
  warningThresholdPercent: number;

  /** Critical threshold as percentage (0-100) */
  criticalThresholdPercent: number;

  /** Per-model budgets (optional) */
  perModelLimits?: Record<string, number>;

  /** Whether to block operations that exceed budget */
  blockOnExceed: boolean;
}

/**
 * Budget status for a period.
 */
export interface BudgetStatus {
  /** Budget period */
  period: BudgetPeriod;

  /** Period start date */
  periodStart: string;

  /** Period end date */
  periodEnd: string;

  /** Budget limit in USD */
  limitUsd: number;

  /** Amount spent in USD */
  spentUsd: number;

  /** Remaining budget in USD */
  remainingUsd: number;

  /** Percentage of budget used (0-100) */
  usedPercent: number;

  /** Current status */
  status: "healthy" | "warning" | "critical" | "exceeded";

  /** Projected end-of-period spend based on current burn rate */
  projectedSpendUsd: number;

  /** Whether projected spend exceeds budget */
  projectedOverBudget: boolean;

  /** Top spending models */
  topModels: Array<{
    model: string;
    spentUsd: number;
    percent: number;
  }>;

  /** Top spending workflow types */
  topWorkflows: Array<{
    workflowType: string;
    spentUsd: number;
    percent: number;
  }>;
}

/**
 * Alert severity levels.
 */
export type AlertSeverity = "info" | "warning" | "critical";

/**
 * Alert types.
 */
export type AlertType =
  | "budget_warning"
  | "budget_critical"
  | "budget_exceeded"
  | "unusual_spend"
  | "model_deprecated"
  | "pricing_change"
  | "estimate_exceeded";

/**
 * Cost alert.
 */
export interface CostAlert {
  /** Unique identifier */
  alertId: string;

  /** Alert type */
  type: AlertType;

  /** Severity level */
  severity: AlertSeverity;

  /** Human-readable message */
  message: string;

  /** Detailed description */
  details: string;

  /** Associated data */
  data: Record<string, unknown>;

  /** When the alert was created */
  createdAt: string;

  /** Whether the alert has been acknowledged */
  acknowledged: boolean;

  /** Who acknowledged it */
  acknowledgedBy?: string;

  /** When it was acknowledged */
  acknowledgedAt?: string;
}

/**
 * Model selection rules for tiers.
 */
export interface TierModelConfig {
  /** Default model for this tier */
  defaultModel: string;

  /** Allowed models (if empty, only default is allowed) */
  allowedModels: string[];

  /** Maximum cost per operation in USD */
  maxCostPerOperation: number;

  /** Whether to allow fallback to cheaper models */
  allowCheaperFallback: boolean;

  /** Fallback model if primary is unavailable or too expensive */
  fallbackModel?: string;
}

/**
 * Full cost policy configuration.
 */
export interface CostPolicy {
  /** Policy version */
  version: string;

  /** When the policy was last updated */
  updatedAt: string;

  /** Budget configurations */
  budgets: {
    daily?: BudgetConfig;
    weekly?: BudgetConfig;
    monthly: BudgetConfig;
  };

  /** Tier-based model selection */
  tierModels: {
    T1: TierModelConfig;
    T2_draft: TierModelConfig;
    T2_final: TierModelConfig;
    T3: TierModelConfig;
  };

  /** Alert configuration */
  alerts: {
    /** Enable alerts */
    enabled: boolean;

    /** Channels to send alerts (for future use) */
    channels: string[];

    /** Suppress duplicate alerts within this window (minutes) */
    dedupeWindowMinutes: number;
  };

  /** Optimization rules */
  optimization: {
    /** Prefer cheaper models when within budget */
    preferCheaper: boolean;

    /** Use caching for identical prompts */
    enableCaching: boolean;

    /** Cache TTL in seconds */
    cacheTtlSeconds: number;

    /** Minimum savings threshold to suggest optimization (USD) */
    minSavingsThreshold: number;
  };
}

/**
 * Cost summary for reporting.
 */
export interface CostSummary {
  /** Summary period start */
  periodStart: string;

  /** Summary period end */
  periodEnd: string;

  /** Total spend in USD */
  totalSpentUsd: number;

  /** Total tokens used */
  totalTokens: {
    input: number;
    output: number;
    total: number;
  };

  /** Number of operations */
  operationCount: number;

  /** Success rate (0-1) */
  successRate: number;

  /** Average cost per operation */
  avgCostPerOperation: number;

  /** Breakdown by model */
  byModel: Record<
    string,
    {
      spentUsd: number;
      tokens: number;
      operations: number;
    }
  >;

  /** Breakdown by workflow type */
  byWorkflow: Record<
    string,
    {
      spentUsd: number;
      tokens: number;
      operations: number;
    }
  >;

  /** Breakdown by tier */
  byTier: Record<
    RiskTier,
    {
      spentUsd: number;
      tokens: number;
      operations: number;
    }
  >;

  /** Cost trend compared to previous period */
  trend: {
    previousPeriodSpent: number;
    changePercent: number;
    direction: "up" | "down" | "stable";
  };

  /** Optimization opportunities identified */
  optimizationOpportunities: Array<{
    description: string;
    estimatedSavingsUsd: number;
    recommendation: string;
  }>;
}

/**
 * Configuration for CostKit.
 */
export interface CostKitConfig {
  /** Path to cost policy file */
  policyPath?: string;

  /** Inline policy (takes precedence over policyPath) */
  policy?: CostPolicy;

  /** Path to store usage data */
  dataPath?: string;

  /** Enable real-time tracking */
  enableTracking?: boolean;

  /** Enable alerting */
  enableAlerts?: boolean;

  /** Custom alert handler */
  alertHandler?: (alert: CostAlert) => void | Promise<void>;

  /** Enable cost estimates before operations */
  enableEstimates?: boolean;

  /** Require estimates before expensive operations (threshold in USD) */
  requireEstimateThreshold?: number;

  /** Enable run record generation (default: false) */
  enableRunRecords?: boolean;

  /** Directory to write run records (default: ./runs) */
  runsDir?: string;
}


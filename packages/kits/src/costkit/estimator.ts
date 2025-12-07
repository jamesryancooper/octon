/**
 * CostKit Estimator - Pre-flight cost estimation for LLM operations.
 *
 * Provides accurate cost estimates before executing expensive LLM calls,
 * enabling budget checks and cost-aware decision making.
 */

import type {
  CostEstimate,
  TokenEstimate,
  RiskTier,
  WorkflowStage,
  BudgetConfig,
} from "./types.js";
import { getModelPricing, calculateCost, getTierModels } from "./pricing.js";
import { randomUUID } from "crypto";

/**
 * Token estimation heuristics based on workflow types.
 * These are based on observed patterns and should be updated with actual data.
 */
const WORKFLOW_TOKEN_ESTIMATES: Record<
  string,
  {
    avgInputTokens: number;
    avgOutputTokens: number;
    variancePercent: number;
  }
> = {
  // Planning phase
  "spec-from-intent": {
    avgInputTokens: 2000,
    avgOutputTokens: 3000,
    variancePercent: 30,
  },
  "plan-from-spec": {
    avgInputTokens: 4000,
    avgOutputTokens: 2500,
    variancePercent: 25,
  },

  // Implementation phase
  "code-from-plan": {
    avgInputTokens: 5000,
    avgOutputTokens: 4000,
    variancePercent: 40,
  },
  "refactor-safely": {
    avgInputTokens: 6000,
    avgOutputTokens: 5000,
    variancePercent: 35,
  },

  // Verification phase
  "test-from-contract": {
    avgInputTokens: 3000,
    avgOutputTokens: 3500,
    variancePercent: 30,
  },
  "threat-model-from-spec": {
    avgInputTokens: 3500,
    avgOutputTokens: 4000,
    variancePercent: 25,
  },

  // Documentation
  "doc-from-code": {
    avgInputTokens: 4000,
    avgOutputTokens: 2000,
    variancePercent: 25,
  },

  // Maintenance
  "migration-from-schema": {
    avgInputTokens: 3000,
    avgOutputTokens: 2500,
    variancePercent: 30,
  },

  // Generic fallbacks
  default: {
    avgInputTokens: 3000,
    avgOutputTokens: 2500,
    variancePercent: 40,
  },
  simple: {
    avgInputTokens: 1000,
    avgOutputTokens: 1500,
    variancePercent: 30,
  },
  complex: {
    avgInputTokens: 8000,
    avgOutputTokens: 6000,
    variancePercent: 50,
  },
};

/**
 * Tier-based multipliers for token estimation.
 * Higher tiers tend to have more context and require more detailed outputs.
 */
const TIER_MULTIPLIERS: Record<RiskTier, number> = {
  T1: 0.6, // Simpler tasks, less context
  T2: 1.0, // Normal tasks
  T3: 1.5, // Complex tasks, more context and detail
};

/**
 * Options for creating a cost estimate.
 */
export interface EstimateOptions {
  /** Workflow type (e.g., "spec-from-intent", "code-from-plan") */
  workflowType: string;

  /** Risk tier */
  tier: RiskTier;

  /** Workflow stage for T2 */
  stage?: WorkflowStage;

  /** Override model selection */
  model?: string;

  /** Actual input text (for more accurate token counting) */
  inputText?: string;

  /** Expected output size hint */
  outputSizeHint?: "small" | "medium" | "large";

  /** Additional context that affects token count */
  contextSize?: number;

  /** Current budget status for warnings */
  currentBudget?: {
    spentUsd: number;
    limitUsd: number;
  };
}

/**
 * Simple token counter based on character approximation.
 * For more accuracy, use tiktoken or similar library.
 */
export function estimateTokenCount(text: string): number {
  // Rough approximation: 1 token ≈ 4 characters for English text
  // This is a simplification; real tokenization varies by model
  return Math.ceil(text.length / 4);
}

/**
 * Estimate tokens for a workflow.
 */
export function estimateTokens(options: EstimateOptions): TokenEstimate {
  const workflow =
    WORKFLOW_TOKEN_ESTIMATES[options.workflowType] ||
    WORKFLOW_TOKEN_ESTIMATES.default;

  const tierMultiplier = TIER_MULTIPLIERS[options.tier];

  // Base estimates
  let inputTokens = workflow.avgInputTokens * tierMultiplier;
  let outputTokens = workflow.avgOutputTokens * tierMultiplier;

  // Adjust for stage (track multiplier for later blending)
  let stageInputMultiplier = 1.0;
  if (options.stage === "draft") {
    // Drafts are usually quicker
    stageInputMultiplier = 0.8;
    inputTokens *= stageInputMultiplier;
    outputTokens *= 0.7;
  }

  // Adjust for actual input if provided
  if (options.inputText) {
    const actualInputTokens = estimateTokenCount(options.inputText);
    // Blend heuristic with actual measurement, preserving stage adjustment
    inputTokens = actualInputTokens * 1.1 * stageInputMultiplier; // Add 10% for system prompt, apply stage multiplier
  }

  // Adjust for context size
  if (options.contextSize) {
    inputTokens += options.contextSize;
  }

  // Adjust for output size hint
  if (options.outputSizeHint === "small") {
    outputTokens *= 0.5;
  } else if (options.outputSizeHint === "large") {
    outputTokens *= 1.5;
  }

  // Round to reasonable numbers
  inputTokens = Math.round(inputTokens);
  outputTokens = Math.round(outputTokens);

  // Determine confidence based on how much actual data we have
  let confidence = 0.6; // Base confidence for heuristics
  let basis: "historical" | "heuristic" | "measured" = "heuristic";

  if (options.inputText) {
    confidence = 0.8;
    basis = "measured";
  }

  return {
    inputTokens,
    outputTokens,
    totalTokens: inputTokens + outputTokens,
    confidence,
    basis,
  };
}

/**
 * Select the appropriate model for a tier and stage.
 */
export function selectModel(
  tier: RiskTier,
  stage?: WorkflowStage,
  preferredModel?: string
): string {
  // If preferred model is specified, use it
  if (preferredModel) {
    const pricing = getModelPricing(preferredModel);
    if (pricing) {
      return preferredModel;
    }
    // Fall through if unknown model
  }

  // Get tier-appropriate models
  const models = getTierModels(tier, stage);

  // Return first (default) model
  return models[0] || "gpt-4o-mini";
}

/**
 * Create a pre-flight cost estimate.
 */
export function createEstimate(options: EstimateOptions): CostEstimate {
  const estimateId = randomUUID();
  const model = selectModel(options.tier, options.stage, options.model);
  const tokens = estimateTokens(options);

  // Calculate cost
  const pricing = getModelPricing(model);
  if (!pricing) {
    throw new Error(`Unknown model: ${model}`);
  }

  const estimatedCostUsd = calculateCost(
    model,
    tokens.inputTokens,
    tokens.outputTokens
  );

  // Calculate cost range based on variance
  const workflow =
    WORKFLOW_TOKEN_ESTIMATES[options.workflowType] ||
    WORKFLOW_TOKEN_ESTIMATES.default;
  const varianceFactor = workflow.variancePercent / 100;

  const costRange = {
    min: estimatedCostUsd * (1 - varianceFactor),
    max: estimatedCostUsd * (1 + varianceFactor),
  };

  // Check budget warnings
  const budgetWarnings: string[] = [];
  let exceedsBudget = false;

  if (options.currentBudget) {
    const { spentUsd, limitUsd } = options.currentBudget;
    const remainingUsd = limitUsd - spentUsd;
    const usedPercent = (spentUsd / limitUsd) * 100;

    if (estimatedCostUsd > remainingUsd) {
      exceedsBudget = true;
      budgetWarnings.push(
        `Estimated cost ($${estimatedCostUsd.toFixed(4)}) exceeds remaining budget ($${remainingUsd.toFixed(2)})`
      );
    } else if (costRange.max > remainingUsd) {
      budgetWarnings.push(
        `Worst-case cost ($${costRange.max.toFixed(4)}) may exceed remaining budget ($${remainingUsd.toFixed(2)})`
      );
    }

    if (usedPercent >= 80 && usedPercent < 100) {
      budgetWarnings.push(
        `Budget is ${usedPercent.toFixed(1)}% consumed`
      );
    }
  }

  return {
    estimateId,
    model,
    provider: pricing.provider,
    tokens,
    estimatedCostUsd,
    costRange,
    workflowType: options.workflowType,
    tier: options.tier,
    stage: options.stage,
    createdAt: new Date().toISOString(),
    exceedsBudget,
    budgetWarnings,
  };
}

/**
 * Format estimate for human display.
 */
export function formatEstimate(estimate: CostEstimate): string {
  const lines: string[] = [];

  lines.push(`📊 Cost Estimate`);
  lines.push(`─────────────────────────────`);
  lines.push(`Workflow: ${estimate.workflowType}`);
  lines.push(`Tier: ${estimate.tier}${estimate.stage ? ` (${estimate.stage})` : ""}`);
  lines.push(`Model: ${estimate.model} (${estimate.provider})`);
  lines.push(``);
  lines.push(`Tokens:`);
  lines.push(`  Input:  ~${estimate.tokens.inputTokens.toLocaleString()}`);
  lines.push(`  Output: ~${estimate.tokens.outputTokens.toLocaleString()}`);
  lines.push(`  Total:  ~${estimate.tokens.totalTokens.toLocaleString()}`);
  lines.push(``);
  lines.push(`Estimated Cost: $${estimate.estimatedCostUsd.toFixed(4)}`);
  lines.push(
    `Range: $${estimate.costRange.min.toFixed(4)} - $${estimate.costRange.max.toFixed(4)}`
  );
  lines.push(`Confidence: ${(estimate.tokens.confidence * 100).toFixed(0)}%`);

  if (estimate.budgetWarnings.length > 0) {
    lines.push(``);
    lines.push(`⚠️  Warnings:`);
    for (const warning of estimate.budgetWarnings) {
      lines.push(`  • ${warning}`);
    }
  }

  if (estimate.exceedsBudget) {
    lines.push(``);
    lines.push(`❌ EXCEEDS BUDGET - Operation may be blocked`);
  }

  return lines.join("\n");
}

/**
 * Create estimates for a complete workflow (all stages).
 */
export function createWorkflowEstimates(options: {
  intent: string;
  tier: RiskTier;
  currentBudget?: {
    spentUsd: number;
    limitUsd: number;
  };
}): {
  stages: CostEstimate[];
  totalEstimatedCost: number;
  totalCostRange: { min: number; max: number };
} {
  const stages: CostEstimate[] = [];

  // Define workflow stages based on tier
  const workflowStages: Array<{
    workflowType: string;
    stage?: WorkflowStage;
  }> = [];

  // All tiers need spec and plan
  workflowStages.push({ workflowType: "spec-from-intent" });
  workflowStages.push({ workflowType: "plan-from-spec" });

  // T2 has draft and final stages
  if (options.tier === "T2") {
    workflowStages.push({ workflowType: "code-from-plan", stage: "draft" });
    workflowStages.push({ workflowType: "code-from-plan", stage: "final" });
  } else {
    workflowStages.push({ workflowType: "code-from-plan" });
  }

  // All tiers need tests
  workflowStages.push({ workflowType: "test-from-contract" });

  // T2 and T3 need threat model
  if (options.tier !== "T1") {
    workflowStages.push({ workflowType: "threat-model-from-spec" });
  }

  // Create estimates for each stage
  let cumulativeSpent = options.currentBudget?.spentUsd || 0;
  const budgetLimit = options.currentBudget?.limitUsd || Infinity;

  for (const stage of workflowStages) {
    const estimate = createEstimate({
      workflowType: stage.workflowType,
      tier: options.tier,
      stage: stage.stage,
      inputText: options.intent,
      currentBudget: {
        spentUsd: cumulativeSpent,
        limitUsd: budgetLimit,
      },
    });

    stages.push(estimate);
    cumulativeSpent += estimate.estimatedCostUsd;
  }

  // Calculate totals
  const totalEstimatedCost = stages.reduce(
    (sum, s) => sum + s.estimatedCostUsd,
    0
  );
  const totalCostRange = {
    min: stages.reduce((sum, s) => sum + s.costRange.min, 0),
    max: stages.reduce((sum, s) => sum + s.costRange.max, 0),
  };

  return {
    stages,
    totalEstimatedCost,
    totalCostRange,
  };
}

/**
 * Format workflow estimates for human display.
 */
export function formatWorkflowEstimates(estimates: {
  stages: CostEstimate[];
  totalEstimatedCost: number;
  totalCostRange: { min: number; max: number };
}): string {
  const lines: string[] = [];

  lines.push(`📊 Workflow Cost Estimate`);
  lines.push(`══════════════════════════════════════`);
  lines.push(``);

  for (const stage of estimates.stages) {
    const tierStage = stage.stage ? ` (${stage.stage})` : "";
    lines.push(
      `${stage.workflowType}${tierStage}: $${stage.estimatedCostUsd.toFixed(4)} [${stage.model}]`
    );
  }

  lines.push(``);
  lines.push(`──────────────────────────────────────`);
  lines.push(`Total Estimated: $${estimates.totalEstimatedCost.toFixed(4)}`);
  lines.push(
    `Range: $${estimates.totalCostRange.min.toFixed(4)} - $${estimates.totalCostRange.max.toFixed(4)}`
  );

  const hasWarnings = estimates.stages.some((s) => s.budgetWarnings.length > 0);
  const exceedsBudget = estimates.stages.some((s) => s.exceedsBudget);

  if (hasWarnings || exceedsBudget) {
    lines.push(``);
    if (exceedsBudget) {
      lines.push(`❌ This workflow may exceed the budget`);
    } else {
      lines.push(`⚠️  Budget warnings detected - review before proceeding`);
    }
  }

  return lines.join("\n");
}


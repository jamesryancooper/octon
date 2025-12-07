/**
 * CostKit - LLM cost management and optimization.
 *
 * Provides comprehensive cost management for AI-enabled workflows:
 * - Pre-flight cost estimation before expensive operations
 * - Real-time cost tracking and budget management
 * - Alerting when thresholds are crossed
 * - Tier-based model selection for cost optimization
 *
 * @example
 * ```typescript
 * import { CostKit } from '@harmony/kits/costkit';
 *
 * // Initialize with a cost policy
 * const costKit = new CostKit({
 *   policyPath: './cost-policy.yaml',
 *   dataPath: './.harmony/cost-data.json',
 * });
 *
 * // Get pre-flight estimate before running an expensive operation
 * const estimate = costKit.estimate({
 *   workflowType: 'code-from-plan',
 *   tier: 'T2',
 *   stage: 'final',
 * });
 *
 * console.log(`Estimated cost: $${estimate.estimatedCostUsd.toFixed(4)}`);
 *
 * // Check if within budget
 * const budgetCheck = costKit.checkBudget(estimate.estimatedCostUsd);
 * if (!budgetCheck.allowed) {
 *   console.warn('Operation would exceed budget:', budgetCheck.reason);
 * }
 *
 * // Record actual usage after completion
 * costKit.recordUsage({
 *   model: 'gpt-4o',
 *   inputTokens: 5000,
 *   outputTokens: 3000,
 *   workflowType: 'code-from-plan',
 *   tier: 'T2',
 *   estimateId: estimate.estimateId,
 *   durationMs: 12500,
 *   success: true,
 * });
 *
 * // Get budget status
 * const status = costKit.getBudgetStatus();
 * console.log(`Budget: ${status.usedPercent.toFixed(1)}% used`);
 * ```
 */

import type {
  CostKitConfig,
  CostPolicy,
  CostEstimate,
  UsageRecord,
  BudgetStatus,
  BudgetConfig,
  CostSummary,
  CostAlert,
  RiskTier,
  WorkflowStage,
} from "./types.js";

import {
  createEstimate,
  createWorkflowEstimates,
  formatEstimate,
  formatWorkflowEstimates,
  selectModel,
  EstimateOptions,
} from "./estimator.js";

import {
  initTracker,
  recordUsage as doRecordUsage,
  getUsageRecords,
  getUsageForPeriod,
  getBudgetStatus as doGetBudgetStatus,
  checkBudget as doCheckBudget,
  generateCostSummary,
  formatBudgetStatus,
  formatCostSummary,
  compareEstimateWithActual,
  clearUsageRecords,
  getPeriodDates,
} from "./tracker.js";

import {
  checkBudgetAlerts,
  checkUnusualSpendAlert,
  checkDeprecatedModelAlert,
  checkEstimateExceededAlert,
  getAlerts,
  getUnacknowledgedAlerts,
  acknowledgeAlert,
  clearAllAlerts,
  formatAlert,
  formatAlerts,
  getAlertSummary,
} from "./alerts.js";

import {
  MODEL_PRICING,
  MODEL_ALIASES,
  getModelPricing,
  getModelsByProvider,
  getActiveModels,
  getDeprecatedModels,
  calculateCost,
  getCheapestModel,
  compareModelCosts,
  RECOMMENDED_MODELS,
  getTierModels,
} from "./pricing.js";

import { readFileSync, existsSync } from "fs";
import { parse as parseYaml } from "yaml";

/**
 * Default cost policy.
 */
const DEFAULT_POLICY: CostPolicy = {
  version: "1.0.0",
  updatedAt: new Date().toISOString(),

  budgets: {
    monthly: {
      period: "monthly",
      limitUsd: 500,
      warningThresholdPercent: 70,
      criticalThresholdPercent: 90,
      blockOnExceed: false,
    },
  },

  tierModels: {
    T1: {
      defaultModel: "gpt-4o-mini",
      allowedModels: ["gpt-4o-mini", "claude-haiku", "gemini-2.0-flash"],
      maxCostPerOperation: 0.01,
      allowCheaperFallback: true,
      fallbackModel: "gpt-4o-mini",
    },
    T2_draft: {
      defaultModel: "gpt-4o-mini",
      allowedModels: ["gpt-4o-mini", "claude-haiku"],
      maxCostPerOperation: 0.05,
      allowCheaperFallback: true,
      fallbackModel: "gpt-4o-mini",
    },
    T2_final: {
      defaultModel: "gpt-4o",
      allowedModels: ["gpt-4o", "claude-sonnet"],
      maxCostPerOperation: 0.20,
      allowCheaperFallback: true,
      fallbackModel: "gpt-4o-mini",
    },
    T3: {
      defaultModel: "gpt-4o",
      allowedModels: ["gpt-4o", "claude-opus", "o1"],
      maxCostPerOperation: 1.00,
      allowCheaperFallback: false,
    },
  },

  alerts: {
    enabled: true,
    channels: ["console"],
    dedupeWindowMinutes: 60,
  },

  optimization: {
    preferCheaper: true,
    enableCaching: true,
    cacheTtlSeconds: 3600,
    minSavingsThreshold: 0.01,
  },
};

/**
 * CostKit - Main class for cost management.
 */
export class CostKit {
  private config: Required<CostKitConfig>;
  private policy: CostPolicy;
  private alertHandler?: (alert: CostAlert) => void | Promise<void>;

  constructor(config: CostKitConfig = {}) {
    // Set defaults
    this.config = {
      policyPath: config.policyPath || "",
      policy: config.policy || undefined,
      dataPath: config.dataPath || "./.harmony/cost-data.json",
      enableTracking: config.enableTracking !== false,
      enableAlerts: config.enableAlerts !== false,
      enableEstimates: config.enableEstimates !== false,
      requireEstimateThreshold: config.requireEstimateThreshold ?? 0.10,
      alertHandler: config.alertHandler,
    } as Required<CostKitConfig>;

    this.alertHandler = config.alertHandler;

    // Load policy
    this.policy = this.loadPolicy();

    // Initialize tracker
    if (this.config.enableTracking) {
      initTracker(this.config.dataPath);
    }
  }

  /**
   * Load cost policy from file or use defaults.
   */
  private loadPolicy(): CostPolicy {
    // Inline policy takes precedence
    if (this.config.policy) {
      return { ...DEFAULT_POLICY, ...this.config.policy };
    }

    // Try to load from file
    if (this.config.policyPath && existsSync(this.config.policyPath)) {
      try {
        const content = readFileSync(this.config.policyPath, "utf-8");
        const loaded = parseYaml(content) as Partial<CostPolicy>;
        return { ...DEFAULT_POLICY, ...loaded };
      } catch (error) {
        console.warn(`Failed to load cost policy from ${this.config.policyPath}:`, error);
      }
    }

    return DEFAULT_POLICY;
  }

  /**
   * Get the current policy.
   */
  getPolicy(): CostPolicy {
    return { ...this.policy };
  }

  /**
   * Get pre-flight cost estimate.
   */
  estimate(options: Omit<EstimateOptions, "currentBudget">): CostEstimate {
    // Add current budget status for warnings
    const budgetConfig = this.policy.budgets.monthly;
    const budgetStatus = doGetBudgetStatus(budgetConfig);

    return createEstimate({
      ...options,
      currentBudget: {
        spentUsd: budgetStatus.spentUsd,
        limitUsd: budgetStatus.limitUsd,
      },
    });
  }

  /**
   * Get estimates for a complete workflow.
   */
  estimateWorkflow(options: { intent: string; tier: RiskTier }): {
    stages: CostEstimate[];
    totalEstimatedCost: number;
    totalCostRange: { min: number; max: number };
  } {
    const budgetConfig = this.policy.budgets.monthly;
    const budgetStatus = doGetBudgetStatus(budgetConfig);

    return createWorkflowEstimates({
      ...options,
      currentBudget: {
        spentUsd: budgetStatus.spentUsd,
        limitUsd: budgetStatus.limitUsd,
      },
    });
  }

  /**
   * Format estimate for display.
   */
  formatEstimate(estimate: CostEstimate): string {
    return formatEstimate(estimate);
  }

  /**
   * Format workflow estimates for display.
   */
  formatWorkflowEstimates(estimates: {
    stages: CostEstimate[];
    totalEstimatedCost: number;
    totalCostRange: { min: number; max: number };
  }): string {
    return formatWorkflowEstimates(estimates);
  }

  /**
   * Select the appropriate model for a tier.
   */
  selectModel(tier: RiskTier, stage?: WorkflowStage): string {
    const key = tier === "T2" && stage ? `T2_${stage}` : tier;
    const tierConfig = this.policy.tierModels[key as keyof typeof this.policy.tierModels];

    if (tierConfig) {
      return tierConfig.defaultModel;
    }

    return selectModel(tier, stage);
  }

  /**
   * Check if an operation is within budget.
   */
  checkBudget(estimatedCost: number): {
    allowed: boolean;
    reason?: string;
    status: BudgetStatus;
  } {
    const budgetConfig = this.policy.budgets.monthly;
    const result = doCheckBudget(budgetConfig, estimatedCost);

    // Generate alerts if enabled
    if (this.config.enableAlerts) {
      const newAlerts = checkBudgetAlerts(
        result.status,
        this.policy.alerts.dedupeWindowMinutes * 60 * 1000
      );

      for (const alert of newAlerts) {
        this.handleAlert(alert);
      }
    }

    return result;
  }

  /**
   * Record actual LLM usage.
   */
  recordUsage(params: {
    model: string;
    inputTokens: number;
    outputTokens: number;
    workflowType: string;
    tier: RiskTier;
    taskId?: string;
    estimateId?: string;
    durationMs: number;
    success: boolean;
    error?: string;
  }): UsageRecord {
    const record = doRecordUsage(params);

    // Check for alerts if enabled
    if (this.config.enableAlerts) {
      // Check for deprecated model
      const deprecatedAlert = checkDeprecatedModelAlert(
        params.model,
        this.policy.alerts.dedupeWindowMinutes * 60 * 1000
      );
      if (deprecatedAlert) {
        this.handleAlert(deprecatedAlert);
      }

      // Check budget status after recording
      const budgetConfig = this.policy.budgets.monthly;
      const status = doGetBudgetStatus(budgetConfig);
      const budgetAlerts = checkBudgetAlerts(
        status,
        this.policy.alerts.dedupeWindowMinutes * 60 * 1000
      );

      for (const alert of budgetAlerts) {
        this.handleAlert(alert);
      }
    }

    return record;
  }

  /**
   * Get current budget status.
   */
  getBudgetStatus(period: "daily" | "weekly" | "monthly" = "monthly"): BudgetStatus {
    const budgetConfig = this.policy.budgets[period] || this.policy.budgets.monthly;
    return doGetBudgetStatus(budgetConfig);
  }

  /**
   * Format budget status for display.
   */
  formatBudgetStatus(status?: BudgetStatus): string {
    const s = status || this.getBudgetStatus();
    return formatBudgetStatus(s);
  }

  /**
   * Get cost summary for a period.
   */
  getCostSummary(period: "daily" | "weekly" | "monthly" = "monthly"): CostSummary {
    const { start, end } = getPeriodDates(period);

    // Calculate previous period for trend
    const previousStart = new Date(start);
    const previousEnd = new Date(start);

    switch (period) {
      case "daily":
        previousStart.setDate(previousStart.getDate() - 1);
        break;
      case "weekly":
        previousStart.setDate(previousStart.getDate() - 7);
        break;
      case "monthly":
        previousStart.setMonth(previousStart.getMonth() - 1);
        previousEnd.setMonth(previousEnd.getMonth() - 1);
        break;
    }

    return generateCostSummary(start, end, previousStart, previousEnd);
  }

  /**
   * Format cost summary for display.
   */
  formatCostSummary(summary?: CostSummary): string {
    const s = summary || this.getCostSummary();
    return formatCostSummary(s);
  }

  /**
   * Get all usage records.
   */
  getUsageRecords(): UsageRecord[] {
    return getUsageRecords();
  }

  /**
   * Get usage records for a time period.
   */
  getUsageForPeriod(start: Date, end: Date): UsageRecord[] {
    return getUsageForPeriod(start, end);
  }

  /**
   * Get all alerts.
   */
  getAlerts(): CostAlert[] {
    return getAlerts();
  }

  /**
   * Get unacknowledged alerts.
   */
  getUnacknowledgedAlerts(): CostAlert[] {
    return getUnacknowledgedAlerts();
  }

  /**
   * Acknowledge an alert.
   */
  acknowledgeAlert(alertId: string, acknowledgedBy: string = "user"): CostAlert | null {
    return acknowledgeAlert(alertId, acknowledgedBy);
  }

  /**
   * Get alert summary.
   */
  getAlertSummary(): ReturnType<typeof getAlertSummary> {
    return getAlertSummary();
  }

  /**
   * Format alerts for display.
   */
  formatAlerts(alerts?: CostAlert[]): string {
    return formatAlerts(alerts || this.getUnacknowledgedAlerts());
  }

  /**
   * Handle an alert (log and notify).
   */
  private handleAlert(alert: CostAlert): void {
    // Log to console
    if (this.policy.alerts.channels.includes("console")) {
      const emoji =
        alert.severity === "critical"
          ? "🚨"
          : alert.severity === "warning"
            ? "⚠️"
            : "ℹ️";
      console.log(`[CostKit] ${emoji} ${alert.message}`);
    }

    // Call custom handler if provided
    if (this.alertHandler) {
      try {
        const result = this.alertHandler(alert);
        if (result instanceof Promise) {
          result.catch((err) => {
            console.error("[CostKit] Alert handler error:", err);
          });
        }
      } catch (err) {
        console.error("[CostKit] Alert handler error:", err);
      }
    }
  }

  /**
   * Get model pricing information.
   */
  getModelPricing(model: string) {
    return getModelPricing(model);
  }

  /**
   * Calculate cost for token usage.
   */
  calculateCost(model: string, inputTokens: number, outputTokens: number): number {
    return calculateCost(model, inputTokens, outputTokens);
  }

  /**
   * Compare costs between two models.
   */
  compareModels(
    modelA: string,
    modelB: string,
    inputTokens: number,
    outputTokens: number
  ) {
    return compareModelCosts(modelA, modelB, inputTokens, outputTokens);
  }

  /**
   * Get recommended models for a use case.
   */
  getRecommendedModels(useCase: keyof typeof RECOMMENDED_MODELS): string[] {
    return RECOMMENDED_MODELS[useCase] || [];
  }

  /**
   * Get tier-appropriate models.
   */
  getTierModels(tier: RiskTier, stage?: WorkflowStage): string[] {
    return getTierModels(tier, stage);
  }

  /**
   * Clear all data (for testing).
   */
  clearAllData(): void {
    clearUsageRecords();
    clearAllAlerts();
  }
}

// Export types
export type {
  CostKitConfig,
  CostPolicy,
  CostEstimate,
  UsageRecord,
  BudgetStatus,
  BudgetConfig,
  BudgetPeriod,
  CostSummary,
  CostAlert,
  AlertType,
  AlertSeverity,
  RiskTier,
  WorkflowStage,
  TokenEstimate,
  TierModelConfig,
  ModelPricing,
  LLMProvider,
} from "./types.js";

// Export pricing utilities
export {
  MODEL_PRICING,
  MODEL_ALIASES,
  getModelPricing,
  getModelsByProvider,
  getActiveModels,
  getDeprecatedModels,
  calculateCost,
  getCheapestModel,
  compareModelCosts,
  RECOMMENDED_MODELS,
  getTierModels,
} from "./pricing.js";

// Export estimator utilities
export {
  createEstimate,
  createWorkflowEstimates,
  formatEstimate,
  formatWorkflowEstimates,
  selectModel,
  estimateTokenCount,
  estimateTokens,
} from "./estimator.js";

// Export tracker utilities
export {
  initTracker,
  recordUsage as recordUsageDirect,
  getUsageRecords as getUsageRecordsDirect,
  getBudgetStatus as getBudgetStatusDirect,
  generateCostSummary,
  formatBudgetStatus,
  formatCostSummary,
  compareEstimateWithActual,
} from "./tracker.js";

// Export alert utilities
export {
  checkBudgetAlerts,
  checkUnusualSpendAlert,
  checkDeprecatedModelAlert,
  checkEstimateExceededAlert,
  formatAlert,
  formatAlerts,
} from "./alerts.js";


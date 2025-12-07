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
  UsageTracker,
  getPeriodDates,
  formatBudgetStatus,
  formatCostSummary,
  compareEstimateWithActual,
} from "./tracker.js";

import { SpanStatusCode } from "@opentelemetry/api";
import {
  getKitTracer,
  createKitSpan,
  getCurrentTraceId,
  type KitSpanContext,
} from "@harmony/kit-base";
import { PolicyViolationError } from "@harmony/kit-base";
import {
  createRunRecord,
  writeRunRecord,
  getRunsDirectory,
} from "@harmony/kit-base";

import {
  AlertManager,
  formatAlert,
  formatAlerts,
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

/** Kit metadata */
const KIT_NAME = "costkit";
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
 *
 * Pillar alignment: Quality through Determinism
 * - Uses instance-based state management (UsageTracker, AlertManager)
 * - No global mutable state
 * - Pure functions for calculations
 * - Side effects isolated at edges
 */
export class CostKit {
  private config: Required<CostKitConfig>;
  private policy: CostPolicy;
  private alertHandler?: (alert: CostAlert) => void | Promise<void>;

  /** Instance-based usage tracker */
  private tracker: UsageTracker;

  /** Instance-based alert manager */
  private alertManager: AlertManager;

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
      enableRunRecords: config.enableRunRecords ?? false,
      runsDir: config.runsDir,
    } as Required<CostKitConfig>;

    this.alertHandler = config.alertHandler;

    // Load policy
    this.policy = this.loadPolicy();

    // Initialize instance-based components
    this.tracker = new UsageTracker(
      this.config.enableTracking ? this.config.dataPath : undefined
    );
    this.alertManager = new AlertManager();
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
   *
   * Observability: Emits `kit.costkit.estimate` span.
   */
  estimate(options: Omit<EstimateOptions, "currentBudget">): CostEstimate {
    const ctx = getSpanContext();
    const span = createKitSpan(ctx, "estimate", {
      "workflow.type": options.workflowType,
      "tier": options.tier,
      "workflow.stage": options.stage,
    });

    try {
      // Add current budget status for warnings
      const budgetConfig = this.policy.budgets.monthly;
      const budgetStatus = this.tracker.getBudgetStatus(budgetConfig);

      const result = createEstimate({
        ...options,
        currentBudget: {
          spentUsd: budgetStatus.spentUsd,
          limitUsd: budgetStatus.limitUsd,
        },
      });

      // Update span with results
      span.setAttribute("estimate.id", result.estimateId);
      span.setAttribute("estimate.model", result.model);
      span.setAttribute("estimate.costUsd", result.estimatedCostUsd);
      span.setAttribute("estimate.exceedsBudget", result.exceedsBudget);
      span.setStatus({ code: SpanStatusCode.OK });

      // Generate run record if enabled
      if (this.config.enableRunRecords) {
        const runRecord = createRunRecord({
          kit: { name: KIT_NAME, version: KIT_VERSION },
          inputs: { workflowType: options.workflowType, tier: options.tier, stage: options.stage },
          status: "success",
          summary: `Estimated cost: $${result.estimatedCostUsd.toFixed(4)} for ${result.workflowType}`,
          stage: "plan",
          risk: "low",
          traceId: getCurrentTraceId() || result.estimateId,
        });

        const runsDir = this.config.runsDir || getRunsDirectory(process.cwd());
        writeRunRecord(runRecord, runsDir);
      }

      return result;
    } catch (error) {
      span.setStatus({
        code: SpanStatusCode.ERROR,
        message: error instanceof Error ? error.message : "Unknown error",
      });
      if (error instanceof Error) {
        span.recordException(error);
      }
      throw error;
    } finally {
      span.end();
    }
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
    const budgetStatus = this.tracker.getBudgetStatus(budgetConfig);

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
    const result = this.tracker.checkBudget(budgetConfig, estimatedCost);

    // Generate alerts if enabled
    if (this.config.enableAlerts) {
      const newAlerts = this.alertManager.checkBudgetAlerts(
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
   *
   * Observability: Emits `kit.costkit.record` span.
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
    const ctx = getSpanContext();
    const span = createKitSpan(ctx, "record", {
      "model": params.model,
      "workflow.type": params.workflowType,
      "tier": params.tier,
      "tokens.input": params.inputTokens,
      "tokens.output": params.outputTokens,
      "success": params.success,
    });

    try {
      const record = this.tracker.recordUsage(params);

      // Update span with results
      span.setAttribute("usage.id", record.usageId);
      span.setAttribute("usage.costUsd", record.actualCostUsd);

      // Check for alerts if enabled
      if (this.config.enableAlerts) {
        // Check for deprecated model
        const deprecatedAlert = this.alertManager.checkDeprecatedModelAlert(
          params.model,
          this.policy.alerts.dedupeWindowMinutes * 60 * 1000
        );
        if (deprecatedAlert) {
          this.handleAlert(deprecatedAlert);
        }

        // Check budget status after recording
        const budgetConfig = this.policy.budgets.monthly;
        const status = this.tracker.getBudgetStatus(budgetConfig);
        const budgetAlerts = this.alertManager.checkBudgetAlerts(
          status,
          this.policy.alerts.dedupeWindowMinutes * 60 * 1000
        );

        for (const alert of budgetAlerts) {
          this.handleAlert(alert);
        }
      }

      span.setStatus({ code: SpanStatusCode.OK });

      // Generate run record if enabled
      if (this.config.enableRunRecords) {
        const runRecord = createRunRecord({
          kit: { name: KIT_NAME, version: KIT_VERSION },
          inputs: {
            model: params.model,
            workflowType: params.workflowType,
            tier: params.tier,
            inputTokens: params.inputTokens,
            outputTokens: params.outputTokens,
          },
          status: params.success ? "success" : "failure",
          summary: `Recorded usage: $${record.actualCostUsd.toFixed(4)} for ${params.workflowType}`,
          stage: "implement",
          risk: "low",
          traceId: getCurrentTraceId() || record.usageId,
          ai: {
            provider: record.provider,
            model: params.model,
          },
          durationMs: params.durationMs,
        });

        const runsDir = this.config.runsDir || getRunsDirectory(process.cwd());
        writeRunRecord(runRecord, runsDir);
      }

      return record;
    } catch (error) {
      span.setStatus({
        code: SpanStatusCode.ERROR,
        message: error instanceof Error ? error.message : "Unknown error",
      });
      if (error instanceof Error) {
        span.recordException(error);
      }
      throw error;
    } finally {
      span.end();
    }
  }

  /**
   * Get current budget status.
   */
  getBudgetStatus(period: "daily" | "weekly" | "monthly" = "monthly"): BudgetStatus {
    const budgetConfig = this.policy.budgets[period] || this.policy.budgets.monthly;
    return this.tracker.getBudgetStatus(budgetConfig);
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

    return this.tracker.generateCostSummary(start, end, previousStart, previousEnd);
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
    return this.tracker.getUsageRecords();
  }

  /**
   * Get usage records for a time period.
   */
  getUsageForPeriod(start: Date, end: Date): UsageRecord[] {
    return this.tracker.getUsageForPeriod(start, end);
  }

  /**
   * Get all alerts.
   */
  getAlerts(): CostAlert[] {
    return this.alertManager.getAlerts();
  }

  /**
   * Get unacknowledged alerts.
   */
  getUnacknowledgedAlerts(): CostAlert[] {
    return this.alertManager.getUnacknowledgedAlerts();
  }

  /**
   * Acknowledge an alert.
   */
  acknowledgeAlert(alertId: string, acknowledgedBy: string = "user"): CostAlert | null {
    return this.alertManager.acknowledgeAlert(alertId, acknowledgedBy);
  }

  /**
   * Get alert summary.
   */
  getAlertSummary(): ReturnType<AlertManager["getAlertSummary"]> {
    return this.alertManager.getAlertSummary();
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
    this.tracker.clearUsageRecords();
    this.alertManager.clearAllAlerts();
  }

  /**
   * Get the underlying UsageTracker instance.
   * Useful for advanced use cases and testing.
   */
  getTracker(): UsageTracker {
    return this.tracker;
  }

  /**
   * Get the underlying AlertManager instance.
   * Useful for advanced use cases and testing.
   */
  getAlertManager(): AlertManager {
    return this.alertManager;
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

// Export tracker class and utilities
export {
  UsageTracker,
  formatBudgetStatus,
  formatCostSummary,
  compareEstimateWithActual,
  getPeriodDates,
} from "./tracker.js";

// Export alert class and utilities
export {
  AlertManager,
  formatAlert,
  formatAlerts,
} from "./alerts.js";


/**
 * CostKit HTTP Runner - HTTP client for remote CostKit services.
 *
 * Enables cross-language consumption (Python agents, microservices) by
 * providing an HTTP interface that mirrors the programmatic API.
 *
 * ## Protocol
 *
 * The HTTP runner expects a remote service implementing:
 * - POST /cost/estimate - Get pre-flight cost estimate
 * - POST /cost/record - Record actual usage
 * - GET /cost/status - Get budget status
 * - GET /cost/summary - Get cost summary
 * - GET /cost/alerts - Get unacknowledged alerts
 * - POST /cost/alerts/:id/ack - Acknowledge an alert
 *
 * @example
 * ```typescript
 * import { createHttpCostRunner } from '@harmony/costkit';
 *
 * const cost = createHttpCostRunner({
 *   baseUrl: 'http://localhost:8082',
 * });
 *
 * const estimate = await cost.estimate({
 *   workflowType: 'code-from-plan',
 *   tier: 'T2',
 *   stage: 'final',
 * });
 *
 * if (!estimate.exceedsBudget) {
 *   // Proceed with operation
 * }
 * ```
 */

import {
  createKitHttpClient,
  type BaseHttpRunnerOptions,
  type KitHttpClient,
} from "@harmony/kit-base";

import type {
  CostEstimate,
  UsageRecord,
  BudgetStatus,
  CostSummary,
  CostAlert,
  RiskTier,
  WorkflowStage,
  BudgetPeriod,
} from "./types.js";

// ============================================================================
// Types
// ============================================================================

/**
 * Options for creating an HTTP-based CostKit runner.
 */
export interface HttpCostRunnerOptions extends BaseHttpRunnerOptions {
  // CostKit-specific options can be added here
}

/**
 * Options for cost estimation requests.
 */
export interface EstimateOptions {
  /** Workflow type (e.g., 'code-from-plan', 'spec-from-intent') */
  workflowType: string;

  /** Risk tier */
  tier: RiskTier;

  /** Stage (for T2 tier) */
  stage?: WorkflowStage;

  /** Input text for more accurate estimation */
  inputText?: string;
}

/**
 * Options for recording usage.
 */
export interface RecordUsageOptions {
  /** Model used */
  model: string;

  /** Input tokens consumed */
  inputTokens: number;

  /** Output tokens generated */
  outputTokens: number;

  /** Workflow type */
  workflowType: string;

  /** Risk tier */
  tier: RiskTier;

  /** Associated estimate ID if pre-flight was done */
  estimateId?: string;

  /** Task ID if associated with a task */
  taskId?: string;

  /** Duration in milliseconds */
  durationMs: number;

  /** Whether the operation succeeded */
  success: boolean;

  /** Error message if failed */
  error?: string;
}

/**
 * CostKit runner interface - HTTP and local implementations share this contract.
 */
export interface CostRunner {
  /**
   * Get pre-flight cost estimate for an operation.
   *
   * @param options - Estimation options
   * @returns Cost estimate with model selection and budget warnings
   */
  estimate(options: EstimateOptions): Promise<CostEstimate>;

  /**
   * Record actual usage after an operation completes.
   *
   * @param options - Usage details
   * @returns Usage record with actual cost
   */
  recordUsage(options: RecordUsageOptions): Promise<UsageRecord>;

  /**
   * Get current budget status.
   *
   * @param period - Budget period (default: 'monthly')
   * @returns Budget status with spend tracking
   */
  getBudgetStatus(period?: BudgetPeriod): Promise<BudgetStatus>;

  /**
   * Get cost summary for a period.
   *
   * @param period - Summary period (default: 'monthly')
   * @returns Cost summary with breakdowns and trends
   */
  getCostSummary(period?: BudgetPeriod): Promise<CostSummary>;

  /**
   * Get unacknowledged alerts.
   *
   * @returns List of unacknowledged cost alerts
   */
  getAlerts(): Promise<CostAlert[]>;

  /**
   * Acknowledge an alert.
   *
   * @param alertId - Alert ID to acknowledge
   * @param acknowledgedBy - Who acknowledged it
   */
  acknowledgeAlert(alertId: string, acknowledgedBy: string): Promise<void>;

  /**
   * Check if an estimated cost is within budget.
   *
   * @param estimatedCostUsd - Estimated cost in USD
   * @returns Whether the cost is allowed
   */
  checkBudget(estimatedCostUsd: number): Promise<{
    allowed: boolean;
    reason?: string;
  }>;
}

// ============================================================================
// HTTP Runner Implementation
// ============================================================================

/**
 * Create an HTTP-based CostKit runner.
 *
 * This is the standard adapter for connecting to a remote CostKit service,
 * enabling cross-language consumption (Python agents, microservices, etc.).
 *
 * The HTTP runner mirrors the programmatic API 1:1, using the same request/response
 * types and error codes.
 *
 * @param options - Configuration for the HTTP runner
 * @returns A CostRunner implementation
 *
 * @example
 * ```typescript
 * // Basic usage
 * const cost = createHttpCostRunner({
 *   baseUrl: 'http://localhost:8082',
 * });
 *
 * // With options
 * const cost = createHttpCostRunner({
 *   baseUrl: 'http://costkit-service:8082',
 *   timeoutMs: 30000,
 *   headers: { 'X-API-Key': process.env.COSTKIT_API_KEY },
 * });
 *
 * // Get estimate before expensive operation
 * const estimate = await cost.estimate({
 *   workflowType: 'code-from-plan',
 *   tier: 'T2',
 *   stage: 'final',
 * });
 *
 * // Record actual usage
 * await cost.recordUsage({
 *   model: 'gpt-4o',
 *   inputTokens: 5200,
 *   outputTokens: 3800,
 *   workflowType: 'code-from-plan',
 *   tier: 'T2',
 *   estimateId: estimate.estimateId,
 *   durationMs: 12500,
 *   success: true,
 * });
 * ```
 */
export function createHttpCostRunner(options: HttpCostRunnerOptions): CostRunner {
  const client: KitHttpClient = createKitHttpClient({
    baseUrl: options.baseUrl,
    kitName: "costkit",
    fetchImpl: options.fetchImpl,
    timeoutMs: options.timeoutMs,
    headers: options.headers,
  });

  return {
    async estimate(estimateOptions: EstimateOptions): Promise<CostEstimate> {
      const response = await client.post<CostEstimate>("/cost/estimate", estimateOptions);
      return response.data;
    },

    async recordUsage(recordOptions: RecordUsageOptions): Promise<UsageRecord> {
      const response = await client.post<UsageRecord>("/cost/record", recordOptions);
      return response.data;
    },

    async getBudgetStatus(period: BudgetPeriod = "monthly"): Promise<BudgetStatus> {
      const response = await client.get<BudgetStatus>("/cost/status", {
        params: { period },
      });
      return response.data;
    },

    async getCostSummary(period: BudgetPeriod = "monthly"): Promise<CostSummary> {
      const response = await client.get<CostSummary>("/cost/summary", {
        params: { period },
      });
      return response.data;
    },

    async getAlerts(): Promise<CostAlert[]> {
      const response = await client.get<CostAlert[]>("/cost/alerts");
      return response.data;
    },

    async acknowledgeAlert(alertId: string, acknowledgedBy: string): Promise<void> {
      await client.post(`/cost/alerts/${alertId}/ack`, { acknowledgedBy });
    },

    async checkBudget(estimatedCostUsd: number): Promise<{ allowed: boolean; reason?: string }> {
      const response = await client.post<{ allowed: boolean; reason?: string }>(
        "/cost/check-budget",
        { estimatedCostUsd }
      );
      return response.data;
    },
  };
}

/**
 * Placeholder/no-op CostRunner.
 *
 * This default implementation exists so callers can depend on CostKit types
 * without immediately wiring a runtime. In production, provide either:
 * - The `CostKit` class for in-process usage
 * - `createHttpCostRunner()` for remote service usage
 */
export const notImplementedCostRunner: CostRunner = {
  async estimate(): Promise<CostEstimate> {
    throw new Error(
      "CostKit notImplementedCostRunner was called. Provide either a CostKit instance or createHttpCostRunner() for your runtime."
    );
  },

  async recordUsage(): Promise<UsageRecord> {
    throw new Error(
      "CostKit notImplementedCostRunner was called. Provide either a CostKit instance or createHttpCostRunner() for your runtime."
    );
  },

  async getBudgetStatus(): Promise<BudgetStatus> {
    throw new Error(
      "CostKit notImplementedCostRunner was called. Provide either a CostKit instance or createHttpCostRunner() for your runtime."
    );
  },

  async getCostSummary(): Promise<CostSummary> {
    throw new Error(
      "CostKit notImplementedCostRunner was called. Provide either a CostKit instance or createHttpCostRunner() for your runtime."
    );
  },

  async getAlerts(): Promise<CostAlert[]> {
    throw new Error(
      "CostKit notImplementedCostRunner was called. Provide either a CostKit instance or createHttpCostRunner() for your runtime."
    );
  },

  async acknowledgeAlert(): Promise<void> {
    throw new Error(
      "CostKit notImplementedCostRunner was called. Provide either a CostKit instance or createHttpCostRunner() for your runtime."
    );
  },

  async checkBudget(): Promise<{ allowed: boolean; reason?: string }> {
    throw new Error(
      "CostKit notImplementedCostRunner was called. Provide either a CostKit instance or createHttpCostRunner() for your runtime."
    );
  },
};


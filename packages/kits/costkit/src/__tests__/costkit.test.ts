/**
 * CostKit Tests
 *
 * Uses vitest for testing.
 */

import { describe, it, expect, beforeEach } from "vitest";

import { CostKit, UsageTracker, AlertManager } from "../index.js";
import {
  getModelPricing,
  calculateCost,
  getTierModels,
  compareModelCosts,
} from "../pricing.js";
import {
  createEstimate,
  estimateTokens,
  estimateTokenCount,
} from "../estimator.js";

describe("CostKit Pricing", () => {
  it("should get pricing for known models", () => {
    const gpt4o = getModelPricing("gpt-4o");
    expect(gpt4o).toBeDefined();
    expect(gpt4o?.model).toBe("gpt-4o");
    expect(gpt4o?.provider).toBe("openai");
    expect(gpt4o?.inputPricePer1M).toBeGreaterThan(0);
    expect(gpt4o?.outputPricePer1M).toBeGreaterThan(0);
  });

  it("should return undefined for unknown models", () => {
    const unknown = getModelPricing("unknown-model-xyz");
    expect(unknown).toBeUndefined();
  });

  it("should calculate cost correctly", () => {
    // gpt-4o: $2.50/1M input, $10.00/1M output
    const cost = calculateCost("gpt-4o", 1000, 500);
    // Expected: (1000/1M * 2.50) + (500/1M * 10.00) = 0.0025 + 0.005 = 0.0075
    expect(Math.abs(cost - 0.0075)).toBeLessThan(0.0001);
  });

  it("should throw for unknown model in calculateCost", () => {
    expect(() => calculateCost("unknown-model", 1000, 500)).toThrow();
  });

  it("should return tier-appropriate models", () => {
    const t1Models = getTierModels("T1");
    expect(t1Models).toContain("gpt-4o-mini");
    expect(t1Models).not.toContain("claude-opus"); // Opus is T3 only

    const t3Models = getTierModels("T3");
    expect(t3Models).toContain("gpt-4o");
    expect(t3Models).toContain("claude-opus");
  });

  it("should compare model costs correctly", () => {
    const comparison = compareModelCosts("gpt-4o", "gpt-4o-mini", 5000, 3000);
    expect(comparison.cheaperModel).toBe("gpt-4o-mini");
    expect(comparison.savingsUsd).toBeGreaterThan(0);
    expect(comparison.savingsPercent).toBeGreaterThan(0);
  });
});

describe("CostKit Estimator", () => {
  it("should estimate token count from text", () => {
    const text = "This is a test string with about forty characters";
    const tokens = estimateTokenCount(text);
    // ~1 token per 4 chars, so ~12 tokens
    expect(tokens).toBeGreaterThan(0);
    expect(tokens).toBeLessThan(20);
  });

  it("should estimate tokens for a workflow", () => {
    const estimate = estimateTokens({
      workflowType: "spec-from-intent",
      tier: "T2",
    });

    expect(estimate.inputTokens).toBeGreaterThan(0);
    expect(estimate.outputTokens).toBeGreaterThan(0);
    expect(estimate.totalTokens).toBe(estimate.inputTokens + estimate.outputTokens);
    expect(estimate.confidence).toBeGreaterThanOrEqual(0);
    expect(estimate.confidence).toBeLessThanOrEqual(1);
  });

  it("should create a complete estimate", () => {
    const estimate = createEstimate({
      workflowType: "code-from-plan",
      tier: "T2",
      stage: "final",
    });

    expect(estimate.estimateId).toBeDefined();
    expect(estimate.model).toBeDefined();
    expect(estimate.provider).toBeDefined();
    expect(estimate.tokens.inputTokens).toBeGreaterThan(0);
    expect(estimate.estimatedCostUsd).toBeGreaterThan(0);
    expect(estimate.costRange.min).toBeLessThanOrEqual(estimate.estimatedCostUsd);
    expect(estimate.costRange.max).toBeGreaterThanOrEqual(estimate.estimatedCostUsd);
    expect(estimate.workflowType).toBe("code-from-plan");
    expect(estimate.tier).toBe("T2");
    expect(estimate.stage).toBe("final");
  });

  it("should apply tier multipliers", () => {
    const t1Estimate = estimateTokens({ workflowType: "spec-from-intent", tier: "T1" });
    const t3Estimate = estimateTokens({ workflowType: "spec-from-intent", tier: "T3" });

    // T3 should have more tokens than T1
    expect(t3Estimate.totalTokens).toBeGreaterThan(t1Estimate.totalTokens);
  });
});

describe("CostKit Tracker (Class-based)", () => {
  let tracker: UsageTracker;

  beforeEach(() => {
    tracker = new UsageTracker(); // In-memory, no persistence
  });

  it("should record usage", () => {
    const record = tracker.recordUsage({
      model: "gpt-4o",
      inputTokens: 5000,
      outputTokens: 3000,
      workflowType: "code-from-plan",
      tier: "T2",
      durationMs: 12000,
      success: true,
    });

    expect(record.usageId).toBeDefined();
    expect(record.model).toBe("gpt-4o");
    expect(record.tokens.input).toBe(5000);
    expect(record.tokens.output).toBe(3000);
    expect(record.actualCostUsd).toBeGreaterThan(0);
    expect(record.success).toBe(true);
  });

  it("should track budget status", () => {
    // Record some usage
    tracker.recordUsage({
      model: "gpt-4o",
      inputTokens: 100000,
      outputTokens: 50000,
      workflowType: "code-from-plan",
      tier: "T2",
      durationMs: 12000,
      success: true,
    });

    const status = tracker.getBudgetStatus({
      period: "monthly",
      limitUsd: 500,
      warningThresholdPercent: 70,
      criticalThresholdPercent: 90,
      blockOnExceed: false,
    });

    expect(status.spentUsd).toBeGreaterThan(0);
    expect(status.limitUsd).toBe(500);
    expect(status.remainingUsd).toBeLessThanOrEqual(500);
    expect(status.usedPercent).toBeGreaterThanOrEqual(0);
    expect(["healthy", "warning", "critical", "exceeded"]).toContain(status.status);
  });
});

describe("CostKit Alerts (Class-based)", () => {
  let alertManager: AlertManager;

  beforeEach(() => {
    alertManager = new AlertManager();
  });

  it("should generate budget warning alert", () => {
    const alerts = alertManager.checkBudgetAlerts({
      period: "monthly",
      periodStart: new Date().toISOString(),
      periodEnd: new Date().toISOString(),
      limitUsd: 100,
      spentUsd: 75,
      remainingUsd: 25,
      usedPercent: 75,
      status: "warning",
      projectedSpendUsd: 90,
      projectedOverBudget: false,
      topModels: [],
      topWorkflows: [],
    });

    expect(alerts.length).toBeGreaterThan(0);
    expect(alerts[0].type).toBe("budget_warning");
    expect(alerts[0].severity).toBe("warning");
  });

  it("should generate budget exceeded alert", () => {
    const alerts = alertManager.checkBudgetAlerts({
      period: "monthly",
      periodStart: new Date().toISOString(),
      periodEnd: new Date().toISOString(),
      limitUsd: 100,
      spentUsd: 110,
      remainingUsd: 0,
      usedPercent: 110,
      status: "exceeded",
      projectedSpendUsd: 120,
      projectedOverBudget: true,
      topModels: [],
      topWorkflows: [],
    });

    expect(alerts.length).toBeGreaterThan(0);
    expect(alerts[0].type).toBe("budget_exceeded");
    expect(alerts[0].severity).toBe("critical");
  });
});

describe("CostKit Main Class", () => {
  let costKit: CostKit;

  beforeEach(() => {
    costKit = new CostKit({
      enableTracking: false, // Don't persist during tests
    });
  });

  it("should create instance with default policy", () => {
    const policy = costKit.getPolicy();
    expect(policy.version).toBeDefined();
    expect(policy.budgets.monthly).toBeDefined();
    expect(policy.tierModels.T1).toBeDefined();
    expect(policy.tierModels.T3).toBeDefined();
  });

  it("should estimate costs", () => {
    const estimate = costKit.estimate({
      workflowType: "spec-from-intent",
      tier: "T2",
    });

    expect(estimate.estimateId).toBeDefined();
    expect(estimate.estimatedCostUsd).toBeGreaterThan(0);
  });

  it("should select appropriate model for tier", () => {
    const t1Model = costKit.selectModel("T1");
    const t3Model = costKit.selectModel("T3");

    // T1 should get cheaper model
    expect(t1Model).toBe("gpt-4o-mini");
    // T3 should get quality model
    expect(t3Model).toBe("gpt-4o");
  });

  it("should check budget and return status", () => {
    const result = costKit.checkBudget(0.10);

    expect(typeof result.allowed).toBe("boolean");
    expect(result.status).toBeDefined();
    expect(result.status.period).toBeDefined();
  });

  it("should format estimate for display", () => {
    const estimate = costKit.estimate({
      workflowType: "code-from-plan",
      tier: "T2",
    });

    const formatted = costKit.formatEstimate(estimate);
    expect(formatted).toContain("Cost Estimate");
    expect(formatted).toContain("code-from-plan");
    expect(formatted).toContain("$");
  });

  it("should estimate full workflow", () => {
    const workflow = costKit.estimateWorkflow({
      intent: "Add user authentication",
      tier: "T2",
    });

    expect(workflow.stages.length).toBeGreaterThan(0);
    expect(workflow.totalEstimatedCost).toBeGreaterThan(0);
    expect(workflow.totalCostRange.min).toBeLessThanOrEqual(workflow.totalEstimatedCost);
    expect(workflow.totalCostRange.max).toBeGreaterThanOrEqual(workflow.totalEstimatedCost);
  });

  it("should get model pricing", () => {
    const pricing = costKit.getModelPricing("claude-sonnet");
    expect(pricing).toBeDefined();
    expect(pricing?.provider).toBe("anthropic");
  });

  it("should compare models", () => {
    const comparison = costKit.compareModels("gpt-4o", "gpt-4o-mini", 5000, 3000);
    expect(comparison.cheaperModel).toBe("gpt-4o-mini");
  });

  it("should get recommended models for use case", () => {
    const securityModels = costKit.getRecommendedModels("security");
    expect(securityModels.length).toBeGreaterThan(0);
    expect(
      securityModels.includes("claude-opus") || securityModels.includes("o1")
    ).toBe(true);
  });
});

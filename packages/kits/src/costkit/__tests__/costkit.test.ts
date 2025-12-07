/**
 * CostKit Tests
 */

import { describe, it, beforeEach, afterEach } from "node:test";
import assert from "node:assert";

import { CostKit } from "../index.js";
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
import { clearUsageRecords, recordUsage, getBudgetStatus } from "../tracker.js";
import { clearAllAlerts, checkBudgetAlerts } from "../alerts.js";

describe("CostKit Pricing", () => {
  it("should get pricing for known models", () => {
    const gpt4o = getModelPricing("gpt-4o");
    assert.ok(gpt4o);
    assert.strictEqual(gpt4o.model, "gpt-4o");
    assert.strictEqual(gpt4o.provider, "openai");
    assert.ok(gpt4o.inputPricePer1M > 0);
    assert.ok(gpt4o.outputPricePer1M > 0);
  });

  it("should return undefined for unknown models", () => {
    const unknown = getModelPricing("unknown-model-xyz");
    assert.strictEqual(unknown, undefined);
  });

  it("should calculate cost correctly", () => {
    // gpt-4o: $2.50/1M input, $10.00/1M output
    const cost = calculateCost("gpt-4o", 1000, 500);
    // Expected: (1000/1M * 2.50) + (500/1M * 10.00) = 0.0025 + 0.005 = 0.0075
    assert.ok(Math.abs(cost - 0.0075) < 0.0001);
  });

  it("should throw for unknown model in calculateCost", () => {
    assert.throws(() => calculateCost("unknown-model", 1000, 500));
  });

  it("should return tier-appropriate models", () => {
    const t1Models = getTierModels("T1");
    assert.ok(t1Models.includes("gpt-4o-mini"));
    assert.ok(!t1Models.includes("claude-opus")); // Opus is T3 only

    const t3Models = getTierModels("T3");
    assert.ok(t3Models.includes("gpt-4o"));
    assert.ok(t3Models.includes("claude-opus"));
  });

  it("should compare model costs correctly", () => {
    const comparison = compareModelCosts("gpt-4o", "gpt-4o-mini", 5000, 3000);
    assert.strictEqual(comparison.cheaperModel, "gpt-4o-mini");
    assert.ok(comparison.savingsUsd > 0);
    assert.ok(comparison.savingsPercent > 0);
  });
});

describe("CostKit Estimator", () => {
  it("should estimate token count from text", () => {
    const text = "This is a test string with about forty characters";
    const tokens = estimateTokenCount(text);
    // ~1 token per 4 chars, so ~12 tokens
    assert.ok(tokens > 0);
    assert.ok(tokens < 20);
  });

  it("should estimate tokens for a workflow", () => {
    const estimate = estimateTokens({
      workflowType: "spec-from-intent",
      tier: "T2",
    });

    assert.ok(estimate.inputTokens > 0);
    assert.ok(estimate.outputTokens > 0);
    assert.ok(estimate.totalTokens === estimate.inputTokens + estimate.outputTokens);
    assert.ok(estimate.confidence >= 0 && estimate.confidence <= 1);
  });

  it("should create a complete estimate", () => {
    const estimate = createEstimate({
      workflowType: "code-from-plan",
      tier: "T2",
      stage: "final",
    });

    assert.ok(estimate.estimateId);
    assert.ok(estimate.model);
    assert.ok(estimate.provider);
    assert.ok(estimate.tokens.inputTokens > 0);
    assert.ok(estimate.estimatedCostUsd > 0);
    assert.ok(estimate.costRange.min <= estimate.estimatedCostUsd);
    assert.ok(estimate.costRange.max >= estimate.estimatedCostUsd);
    assert.strictEqual(estimate.workflowType, "code-from-plan");
    assert.strictEqual(estimate.tier, "T2");
    assert.strictEqual(estimate.stage, "final");
  });

  it("should apply tier multipliers", () => {
    const t1Estimate = estimateTokens({ workflowType: "spec-from-intent", tier: "T1" });
    const t3Estimate = estimateTokens({ workflowType: "spec-from-intent", tier: "T3" });

    // T3 should have more tokens than T1
    assert.ok(t3Estimate.totalTokens > t1Estimate.totalTokens);
  });
});

describe("CostKit Tracker", () => {
  beforeEach(() => {
    clearUsageRecords();
  });

  afterEach(() => {
    clearUsageRecords();
  });

  it("should record usage", () => {
    const record = recordUsage({
      model: "gpt-4o",
      inputTokens: 5000,
      outputTokens: 3000,
      workflowType: "code-from-plan",
      tier: "T2",
      durationMs: 12000,
      success: true,
    });

    assert.ok(record.usageId);
    assert.strictEqual(record.model, "gpt-4o");
    assert.strictEqual(record.tokens.input, 5000);
    assert.strictEqual(record.tokens.output, 3000);
    assert.ok(record.actualCostUsd > 0);
    assert.strictEqual(record.success, true);
  });

  it("should track budget status", () => {
    // Record some usage
    recordUsage({
      model: "gpt-4o",
      inputTokens: 100000,
      outputTokens: 50000,
      workflowType: "code-from-plan",
      tier: "T2",
      durationMs: 12000,
      success: true,
    });

    const status = getBudgetStatus({
      period: "monthly",
      limitUsd: 500,
      warningThresholdPercent: 70,
      criticalThresholdPercent: 90,
      blockOnExceed: false,
    });

    assert.ok(status.spentUsd > 0);
    assert.strictEqual(status.limitUsd, 500);
    assert.ok(status.remainingUsd <= 500);
    assert.ok(status.usedPercent >= 0);
    assert.ok(["healthy", "warning", "critical", "exceeded"].includes(status.status));
  });
});

describe("CostKit Alerts", () => {
  beforeEach(() => {
    clearAllAlerts();
  });

  afterEach(() => {
    clearAllAlerts();
  });

  it("should generate budget warning alert", () => {
    const alerts = checkBudgetAlerts({
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

    assert.ok(alerts.length > 0);
    assert.strictEqual(alerts[0].type, "budget_warning");
    assert.strictEqual(alerts[0].severity, "warning");
  });

  it("should generate budget exceeded alert", () => {
    const alerts = checkBudgetAlerts({
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

    assert.ok(alerts.length > 0);
    assert.strictEqual(alerts[0].type, "budget_exceeded");
    assert.strictEqual(alerts[0].severity, "critical");
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
    assert.ok(policy.version);
    assert.ok(policy.budgets.monthly);
    assert.ok(policy.tierModels.T1);
    assert.ok(policy.tierModels.T3);
  });

  it("should estimate costs", () => {
    const estimate = costKit.estimate({
      workflowType: "spec-from-intent",
      tier: "T2",
    });

    assert.ok(estimate.estimateId);
    assert.ok(estimate.estimatedCostUsd > 0);
  });

  it("should select appropriate model for tier", () => {
    const t1Model = costKit.selectModel("T1");
    const t3Model = costKit.selectModel("T3");

    // T1 should get cheaper model
    assert.strictEqual(t1Model, "gpt-4o-mini");
    // T3 should get quality model
    assert.strictEqual(t3Model, "gpt-4o");
  });

  it("should check budget and return status", () => {
    const result = costKit.checkBudget(0.10);

    assert.ok(typeof result.allowed === "boolean");
    assert.ok(result.status);
    assert.ok(result.status.period);
  });

  it("should format estimate for display", () => {
    const estimate = costKit.estimate({
      workflowType: "code-from-plan",
      tier: "T2",
    });

    const formatted = costKit.formatEstimate(estimate);
    assert.ok(formatted.includes("Cost Estimate"));
    assert.ok(formatted.includes("code-from-plan"));
    assert.ok(formatted.includes("$"));
  });

  it("should estimate full workflow", () => {
    const workflow = costKit.estimateWorkflow({
      intent: "Add user authentication",
      tier: "T2",
    });

    assert.ok(workflow.stages.length > 0);
    assert.ok(workflow.totalEstimatedCost > 0);
    assert.ok(workflow.totalCostRange.min <= workflow.totalEstimatedCost);
    assert.ok(workflow.totalCostRange.max >= workflow.totalEstimatedCost);
  });

  it("should get model pricing", () => {
    const pricing = costKit.getModelPricing("claude-sonnet");
    assert.ok(pricing);
    assert.strictEqual(pricing?.provider, "anthropic");
  });

  it("should compare models", () => {
    const comparison = costKit.compareModels("gpt-4o", "gpt-4o-mini", 5000, 3000);
    assert.strictEqual(comparison.cheaperModel, "gpt-4o-mini");
  });

  it("should get recommended models for use case", () => {
    const securityModels = costKit.getRecommendedModels("security");
    assert.ok(securityModels.length > 0);
    assert.ok(securityModels.includes("claude-opus") || securityModels.includes("o1"));
  });
});


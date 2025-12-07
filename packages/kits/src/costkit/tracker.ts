/**
 * CostKit Tracker - Cost tracking and budget management.
 *
 * Tracks actual LLM usage and costs, manages budgets,
 * and provides reporting and analytics.
 */

import type {
  UsageRecord,
  BudgetConfig,
  BudgetStatus,
  BudgetPeriod,
  CostSummary,
  RiskTier,
  CostEstimate,
} from "./types.js";
import { calculateCost, getModelPricing } from "./pricing.js";
import { randomUUID } from "crypto";
import { readFileSync, writeFileSync, existsSync, mkdirSync } from "fs";
import { dirname, join } from "path";

/**
 * In-memory storage for usage records.
 * In production, this would be backed by a database.
 */
let usageRecords: UsageRecord[] = [];

/**
 * Path to persistent storage file.
 */
let storagePath: string | null = null;

/**
 * Initialize the tracker with persistent storage.
 */
export function initTracker(dataPath: string): void {
  storagePath = dataPath;

  // Ensure directory exists
  const dir = dirname(dataPath);
  if (!existsSync(dir)) {
    mkdirSync(dir, { recursive: true });
  }

  // Load existing data
  if (existsSync(dataPath)) {
    try {
      const data = readFileSync(dataPath, "utf-8");
      usageRecords = JSON.parse(data);
    } catch {
      // Start fresh if file is corrupted
      usageRecords = [];
    }
  }
}

/**
 * Save records to persistent storage.
 */
function persistRecords(): void {
  if (storagePath) {
    writeFileSync(storagePath, JSON.stringify(usageRecords, null, 2));
  }
}

/**
 * Record an LLM usage event.
 */
export function recordUsage(params: {
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
  const pricing = getModelPricing(params.model);
  const provider = pricing?.provider || "openai";

  const actualCostUsd = calculateCost(
    params.model,
    params.inputTokens,
    params.outputTokens
  );

  const record: UsageRecord = {
    usageId: randomUUID(),
    estimateId: params.estimateId,
    model: params.model,
    provider,
    tokens: {
      input: params.inputTokens,
      output: params.outputTokens,
      total: params.inputTokens + params.outputTokens,
    },
    actualCostUsd,
    workflowType: params.workflowType,
    tier: params.tier,
    taskId: params.taskId,
    timestamp: new Date().toISOString(),
    durationMs: params.durationMs,
    success: params.success,
    error: params.error,
  };

  usageRecords.push(record);
  persistRecords();

  return record;
}

/**
 * Get all usage records.
 */
export function getUsageRecords(): UsageRecord[] {
  return [...usageRecords];
}

/**
 * Get usage records for a time period.
 */
export function getUsageForPeriod(
  start: Date,
  end: Date
): UsageRecord[] {
  return usageRecords.filter((r) => {
    const timestamp = new Date(r.timestamp);
    return timestamp >= start && timestamp <= end;
  });
}

/**
 * Calculate period dates for a budget period.
 */
export function getPeriodDates(period: BudgetPeriod): {
  start: Date;
  end: Date;
} {
  const now = new Date();
  let start: Date;
  let end: Date;

  switch (period) {
    case "daily":
      start = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      end = new Date(start);
      end.setDate(end.getDate() + 1);
      break;

    case "weekly":
      // Start on Monday
      const dayOfWeek = now.getDay();
      const daysToMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1;
      start = new Date(now.getFullYear(), now.getMonth(), now.getDate() - daysToMonday);
      end = new Date(start);
      end.setDate(end.getDate() + 7);
      break;

    case "monthly":
      start = new Date(now.getFullYear(), now.getMonth(), 1);
      end = new Date(now.getFullYear(), now.getMonth() + 1, 1);
      break;
  }

  return { start, end };
}

/**
 * Get budget status for a period.
 */
export function getBudgetStatus(budget: BudgetConfig): BudgetStatus {
  const { start, end } = getPeriodDates(budget.period);
  const records = getUsageForPeriod(start, end);

  const spentUsd = records.reduce((sum, r) => sum + r.actualCostUsd, 0);
  const remainingUsd = Math.max(0, budget.limitUsd - spentUsd);
  const usedPercent = (spentUsd / budget.limitUsd) * 100;

  // Calculate projected spend
  const now = new Date();
  const periodDurationMs = end.getTime() - start.getTime();
  const elapsedMs = now.getTime() - start.getTime();
  const elapsedPercent = elapsedMs / periodDurationMs;

  const burnRate = spentUsd / elapsedPercent;
  const projectedSpendUsd = burnRate;

  // Determine status
  let status: "healthy" | "warning" | "critical" | "exceeded";
  if (usedPercent >= 100) {
    status = "exceeded";
  } else if (usedPercent >= budget.criticalThresholdPercent) {
    status = "critical";
  } else if (usedPercent >= budget.warningThresholdPercent) {
    status = "warning";
  } else {
    status = "healthy";
  }

  // Calculate top models
  const modelSpend: Record<string, number> = {};
  for (const record of records) {
    modelSpend[record.model] = (modelSpend[record.model] || 0) + record.actualCostUsd;
  }

  const topModels = Object.entries(modelSpend)
    .map(([model, spent]) => ({
      model,
      spentUsd: spent,
      percent: (spent / spentUsd) * 100 || 0,
    }))
    .sort((a, b) => b.spentUsd - a.spentUsd)
    .slice(0, 5);

  // Calculate top workflows
  const workflowSpend: Record<string, number> = {};
  for (const record of records) {
    workflowSpend[record.workflowType] =
      (workflowSpend[record.workflowType] || 0) + record.actualCostUsd;
  }

  const topWorkflows = Object.entries(workflowSpend)
    .map(([workflowType, spent]) => ({
      workflowType,
      spentUsd: spent,
      percent: (spent / spentUsd) * 100 || 0,
    }))
    .sort((a, b) => b.spentUsd - a.spentUsd)
    .slice(0, 5);

  return {
    period: budget.period,
    periodStart: start.toISOString(),
    periodEnd: end.toISOString(),
    limitUsd: budget.limitUsd,
    spentUsd,
    remainingUsd,
    usedPercent,
    status,
    projectedSpendUsd,
    projectedOverBudget: projectedSpendUsd > budget.limitUsd,
    topModels,
    topWorkflows,
  };
}

/**
 * Check if an operation would exceed budget.
 */
export function checkBudget(
  budget: BudgetConfig,
  estimatedCost: number
): {
  allowed: boolean;
  reason?: string;
  status: BudgetStatus;
} {
  const status = getBudgetStatus(budget);

  if (status.status === "exceeded") {
    return {
      allowed: !budget.blockOnExceed,
      reason: `Budget exceeded: $${status.spentUsd.toFixed(2)} of $${budget.limitUsd.toFixed(2)} used`,
      status,
    };
  }

  if (estimatedCost > status.remainingUsd) {
    return {
      allowed: !budget.blockOnExceed,
      reason: `Estimated cost ($${estimatedCost.toFixed(4)}) exceeds remaining budget ($${status.remainingUsd.toFixed(2)})`,
      status,
    };
  }

  if (status.status === "critical") {
    return {
      allowed: true,
      reason: `Budget at critical level: ${status.usedPercent.toFixed(1)}% used`,
      status,
    };
  }

  return { allowed: true, status };
}

/**
 * Generate a cost summary for a period.
 */
export function generateCostSummary(
  start: Date,
  end: Date,
  previousStart?: Date,
  previousEnd?: Date
): CostSummary {
  const records = getUsageForPeriod(start, end);

  // Calculate totals
  const totalSpentUsd = records.reduce((sum, r) => sum + r.actualCostUsd, 0);
  const totalTokens = {
    input: records.reduce((sum, r) => sum + r.tokens.input, 0),
    output: records.reduce((sum, r) => sum + r.tokens.output, 0),
    total: records.reduce((sum, r) => sum + r.tokens.total, 0),
  };
  const successCount = records.filter((r) => r.success).length;

  // Breakdown by model
  const byModel: CostSummary["byModel"] = {};
  for (const record of records) {
    if (!byModel[record.model]) {
      byModel[record.model] = { spentUsd: 0, tokens: 0, operations: 0 };
    }
    byModel[record.model].spentUsd += record.actualCostUsd;
    byModel[record.model].tokens += record.tokens.total;
    byModel[record.model].operations++;
  }

  // Breakdown by workflow
  const byWorkflow: CostSummary["byWorkflow"] = {};
  for (const record of records) {
    if (!byWorkflow[record.workflowType]) {
      byWorkflow[record.workflowType] = { spentUsd: 0, tokens: 0, operations: 0 };
    }
    byWorkflow[record.workflowType].spentUsd += record.actualCostUsd;
    byWorkflow[record.workflowType].tokens += record.tokens.total;
    byWorkflow[record.workflowType].operations++;
  }

  // Breakdown by tier
  const byTier: CostSummary["byTier"] = {
    T1: { spentUsd: 0, tokens: 0, operations: 0 },
    T2: { spentUsd: 0, tokens: 0, operations: 0 },
    T3: { spentUsd: 0, tokens: 0, operations: 0 },
  };
  for (const record of records) {
    byTier[record.tier].spentUsd += record.actualCostUsd;
    byTier[record.tier].tokens += record.tokens.total;
    byTier[record.tier].operations++;
  }

  // Calculate trend
  let trend: CostSummary["trend"] = {
    previousPeriodSpent: 0,
    changePercent: 0,
    direction: "stable",
  };

  if (previousStart && previousEnd) {
    const previousRecords = getUsageForPeriod(previousStart, previousEnd);
    const previousSpent = previousRecords.reduce(
      (sum, r) => sum + r.actualCostUsd,
      0
    );

    trend.previousPeriodSpent = previousSpent;
    if (previousSpent > 0) {
      trend.changePercent = ((totalSpentUsd - previousSpent) / previousSpent) * 100;
      trend.direction =
        trend.changePercent > 5
          ? "up"
          : trend.changePercent < -5
            ? "down"
            : "stable";
    }
  }

  // Identify optimization opportunities
  const optimizationOpportunities: CostSummary["optimizationOpportunities"] = [];

  // Check for expensive models in low-risk tiers
  for (const record of records) {
    if (record.tier === "T1" && record.model.includes("gpt-4o") && !record.model.includes("mini")) {
      const savings = record.actualCostUsd * 0.9; // gpt-4o-mini is ~90% cheaper
      if (savings > 0.01) {
        optimizationOpportunities.push({
          description: `Using expensive model (${record.model}) for T1 task`,
          estimatedSavingsUsd: savings,
          recommendation: "Use gpt-4o-mini for trivial tasks",
        });
        break; // One recommendation per type
      }
    }
  }

  // Check for high token usage (only if there are records)
  if (records.length > 0) {
    const avgTokens = totalTokens.total / records.length;
    if (avgTokens > 10000) {
      optimizationOpportunities.push({
        description: "High average token usage per operation",
        estimatedSavingsUsd: totalSpentUsd * 0.2,
        recommendation: "Consider chunking large contexts or using summarization",
      });
    }
  }

  return {
    periodStart: start.toISOString(),
    periodEnd: end.toISOString(),
    totalSpentUsd,
    totalTokens,
    operationCount: records.length,
    successRate: records.length > 0 ? successCount / records.length : 1,
    avgCostPerOperation: records.length > 0 ? totalSpentUsd / records.length : 0,
    byModel,
    byWorkflow,
    byTier,
    trend,
    optimizationOpportunities,
  };
}

/**
 * Format budget status for human display.
 */
export function formatBudgetStatus(status: BudgetStatus): string {
  const lines: string[] = [];

  const statusEmoji = {
    healthy: "✅",
    warning: "⚠️",
    critical: "🔴",
    exceeded: "❌",
  };

  lines.push(`💰 Budget Status (${status.period})`);
  lines.push(`══════════════════════════════════════`);
  lines.push(``);
  lines.push(`Status: ${statusEmoji[status.status]} ${status.status.toUpperCase()}`);
  lines.push(``);
  lines.push(`Spent:     $${status.spentUsd.toFixed(2)}`);
  lines.push(`Budget:    $${status.limitUsd.toFixed(2)}`);
  lines.push(`Remaining: $${status.remainingUsd.toFixed(2)}`);
  lines.push(`Used:      ${status.usedPercent.toFixed(1)}%`);
  lines.push(``);
  lines.push(`Projected: $${status.projectedSpendUsd.toFixed(2)}`);
  if (status.projectedOverBudget) {
    lines.push(`⚠️  Projected to exceed budget`);
  }

  if (status.topModels.length > 0) {
    lines.push(``);
    lines.push(`Top Models:`);
    for (const model of status.topModels.slice(0, 3)) {
      lines.push(`  ${model.model}: $${model.spentUsd.toFixed(2)} (${model.percent.toFixed(1)}%)`);
    }
  }

  if (status.topWorkflows.length > 0) {
    lines.push(``);
    lines.push(`Top Workflows:`);
    for (const workflow of status.topWorkflows.slice(0, 3)) {
      lines.push(
        `  ${workflow.workflowType}: $${workflow.spentUsd.toFixed(2)} (${workflow.percent.toFixed(1)}%)`
      );
    }
  }

  return lines.join("\n");
}

/**
 * Format cost summary for human display.
 */
export function formatCostSummary(summary: CostSummary): string {
  const lines: string[] = [];

  lines.push(`📊 Cost Summary`);
  lines.push(`══════════════════════════════════════`);
  lines.push(`Period: ${summary.periodStart.split("T")[0]} to ${summary.periodEnd.split("T")[0]}`);
  lines.push(``);
  lines.push(`Total Spent: $${summary.totalSpentUsd.toFixed(2)}`);
  lines.push(`Operations:  ${summary.operationCount}`);
  lines.push(`Avg Cost:    $${summary.avgCostPerOperation.toFixed(4)}/op`);
  lines.push(`Success:     ${(summary.successRate * 100).toFixed(1)}%`);
  lines.push(``);
  lines.push(`Tokens Used:`);
  lines.push(`  Input:  ${summary.totalTokens.input.toLocaleString()}`);
  lines.push(`  Output: ${summary.totalTokens.output.toLocaleString()}`);
  lines.push(`  Total:  ${summary.totalTokens.total.toLocaleString()}`);

  const trendEmoji =
    summary.trend.direction === "up"
      ? "📈"
      : summary.trend.direction === "down"
        ? "📉"
        : "➡️";
  lines.push(``);
  lines.push(
    `Trend: ${trendEmoji} ${summary.trend.changePercent >= 0 ? "+" : ""}${summary.trend.changePercent.toFixed(1)}% vs previous period`
  );

  if (summary.optimizationOpportunities.length > 0) {
    lines.push(``);
    lines.push(`💡 Optimization Opportunities:`);
    for (const opp of summary.optimizationOpportunities) {
      lines.push(`  • ${opp.description}`);
      lines.push(`    Potential savings: $${opp.estimatedSavingsUsd.toFixed(2)}`);
      lines.push(`    → ${opp.recommendation}`);
    }
  }

  return lines.join("\n");
}

/**
 * Compare estimate with actual usage.
 */
export function compareEstimateWithActual(
  estimate: CostEstimate,
  record: UsageRecord
): {
  tokenDifference: number;
  tokenDifferencePercent: number;
  costDifference: number;
  costDifferencePercent: number;
  withinRange: boolean;
  accuracy: "accurate" | "underestimate" | "overestimate";
} {
  const tokenDifference = record.tokens.total - estimate.tokens.totalTokens;
  const tokenDifferencePercent =
    (tokenDifference / estimate.tokens.totalTokens) * 100;

  const costDifference = record.actualCostUsd - estimate.estimatedCostUsd;
  const costDifferencePercent = (costDifference / estimate.estimatedCostUsd) * 100;

  const withinRange =
    record.actualCostUsd >= estimate.costRange.min &&
    record.actualCostUsd <= estimate.costRange.max;

  let accuracy: "accurate" | "underestimate" | "overestimate";
  if (Math.abs(costDifferencePercent) <= 20) {
    accuracy = "accurate";
  } else if (costDifference > 0) {
    accuracy = "underestimate";
  } else {
    accuracy = "overestimate";
  }

  return {
    tokenDifference,
    tokenDifferencePercent,
    costDifference,
    costDifferencePercent,
    withinRange,
    accuracy,
  };
}

/**
 * Clear all usage records (for testing).
 */
export function clearUsageRecords(): void {
  usageRecords = [];
  persistRecords();
}


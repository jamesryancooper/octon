#!/usr/bin/env node
/**
 * CostKit CLI
 *
 * Command-line interface for CostKit LLM cost management.
 *
 * Pillar alignment: Speed with Safety, Quality through Determinism
 *
 * @example
 * ```bash
 * # Get cost estimate for a workflow
 * costkit estimate --workflow code-from-plan --tier T2 --stage final
 *
 * # Check current budget status
 * costkit status
 *
 * # Get cost summary for a period
 * costkit summary --period monthly
 *
 * # Record usage (typically called by other kits)
 * costkit record --model gpt-4o --input-tokens 5000 --output-tokens 3000
 * ```
 */

import {
  runKitCli,
  success,
  dryRunSuccess,
  failure,
  withKitMetadata,
  type CliCommand,
  type KitCliConfig,
  type StandardKitFlags,
} from "@harmony/kit-base";
import {
  CostKit,
  type CostEstimate,
  type BudgetStatus,
  type CostSummary,
  type RiskTier,
  type WorkflowStage,
} from "./index.js";

/** Kit metadata */
const KIT_NAME = "costkit";
const KIT_VERSION = "0.1.0";

/**
 * CLI-specific options for CostKit.
 */
interface CostKitCliOptions extends Record<string, unknown> {
  dryRun?: boolean;
  enableRunRecords?: boolean;
  runsDir?: string;
  workflow?: string;
  tier?: string;
  workflowStage?: string;
  model?: string;
  inputTokens?: number;
  outputTokens?: number;
  period?: string;
  policyPath?: string;
  dataPath?: string;
}

/**
 * Create a CostKit instance from CLI options.
 */
function createCostKit(options: CostKitCliOptions): CostKit {
  return new CostKit({
    policyPath: options.policyPath,
    dataPath: options.dataPath,
    enableRunRecords: options.enableRunRecords,
    runsDir: options.runsDir,
  });
}

/**
 * Estimate command - get cost estimate for a workflow.
 */
const estimateCommand: CliCommand<CostKitCliOptions> = {
  name: "estimate",
  description: "Get cost estimate for a workflow",
  args: [],
  options: [
    { name: "workflow", alias: "w", description: "Workflow type (e.g., code-from-plan)", type: "string" },
    { name: "tier", description: "Risk tier: T1|T2|T3", type: "string" },
    { name: "workflow-stage", description: "Workflow stage: draft|final", type: "string" },
    { name: "policy-path", description: "Path to cost policy YAML", type: "string" },
  ],
  async handler(args, options) {
    if (!options.workflow) {
      return failure("--workflow is required for estimate command");
    }

    const tier = (options.tier?.toUpperCase() || "T2") as RiskTier;
    const stage = (options.workflowStage || "final") as WorkflowStage;

    // In dry-run mode, just validate inputs
    if (options.dryRun) {
      return dryRunSuccess(
        withKitMetadata(
          {
            status: "dry-run",
            summary: "Would estimate cost for workflow",
            workflow: options.workflow,
            tier,
            stage,
          },
          KIT_NAME,
          KIT_VERSION,
          options
        ),
        `[CostKit] Dry-run: would estimate cost for ${options.workflow} (${tier}/${stage})`
      );
    }

    const costKit = createCostKit(options);
    const estimate = costKit.estimate({
      workflowType: options.workflow,
      tier,
      stage,
    });

    const output = withKitMetadata(
      {
        status: "success",
        summary: `Estimated cost: $${estimate.estimatedCostUsd.toFixed(4)}`,
        estimate,
      },
      KIT_NAME,
      KIT_VERSION,
      options
    );

    return success(output, formatEstimate(estimate));
  },
};

/**
 * Status command - check current budget status.
 */
const statusCommand: CliCommand<CostKitCliOptions> = {
  name: "status",
  description: "Check current budget status",
  args: [],
  options: [
    { name: "period", alias: "p", description: "Budget period: daily|weekly|monthly", type: "string" },
    { name: "policy-path", description: "Path to cost policy YAML", type: "string" },
    { name: "data-path", description: "Path to cost data file", type: "string" },
  ],
  async handler(args, options) {
    const period = (options.period || "monthly") as "daily" | "weekly" | "monthly";

    // In dry-run mode, just validate inputs
    if (options.dryRun) {
      return dryRunSuccess(
        withKitMetadata(
          {
            status: "dry-run",
            summary: "Would get budget status",
            period,
          },
          KIT_NAME,
          KIT_VERSION,
          options
        ),
        `[CostKit] Dry-run: would get ${period} budget status`
      );
    }

    const costKit = createCostKit(options);
    const status = costKit.getBudgetStatus(period);

    const output = withKitMetadata(
      {
        status: "success",
        summary: `Budget ${status.usedPercent.toFixed(1)}% used`,
        budgetStatus: status,
      },
      KIT_NAME,
      KIT_VERSION,
      options
    );

    return success(output, formatBudgetStatus(status));
  },
};

/**
 * Summary command - get cost summary for a period.
 */
const summaryCommand: CliCommand<CostKitCliOptions> = {
  name: "summary",
  description: "Get cost summary for a period",
  args: [],
  options: [
    { name: "period", alias: "p", description: "Summary period: daily|weekly|monthly", type: "string" },
    { name: "policy-path", description: "Path to cost policy YAML", type: "string" },
    { name: "data-path", description: "Path to cost data file", type: "string" },
  ],
  async handler(args, options) {
    const period = (options.period || "monthly") as "daily" | "weekly" | "monthly";

    // In dry-run mode, just validate inputs
    if (options.dryRun) {
      return dryRunSuccess(
        withKitMetadata(
          {
            status: "dry-run",
            summary: "Would get cost summary",
            period,
          },
          KIT_NAME,
          KIT_VERSION,
          options
        ),
        `[CostKit] Dry-run: would get ${period} cost summary`
      );
    }

    const costKit = createCostKit(options);
    const summary = costKit.getCostSummary(period);

    const output = withKitMetadata(
      {
        status: "success",
        summary: `Total cost: $${summary.totalSpentUsd.toFixed(2)}`,
        costSummary: summary,
      },
      KIT_NAME,
      KIT_VERSION,
      options
    );

    return success(output, formatCostSummary(summary));
  },
};

/**
 * Record command - record actual LLM usage.
 */
const recordCommand: CliCommand<CostKitCliOptions> = {
  name: "record",
  description: "Record actual LLM usage",
  args: [],
  options: [
    { name: "model", alias: "m", description: "Model name (e.g., gpt-4o)", type: "string" },
    { name: "input-tokens", description: "Number of input tokens", type: "number" },
    { name: "output-tokens", description: "Number of output tokens", type: "number" },
    { name: "workflow", alias: "w", description: "Workflow type", type: "string" },
    { name: "tier", description: "Risk tier: T1|T2|T3", type: "string" },
    { name: "policy-path", description: "Path to cost policy YAML", type: "string" },
    { name: "data-path", description: "Path to cost data file", type: "string" },
  ],
  async handler(args, options) {
    if (!options.model) {
      return failure("--model is required for record command");
    }
    if (options.inputTokens === undefined) {
      return failure("--input-tokens is required for record command");
    }
    if (options.outputTokens === undefined) {
      return failure("--output-tokens is required for record command");
    }

    const tier = (options.tier?.toUpperCase() || "T2") as RiskTier;

    // In dry-run mode, just validate inputs
    if (options.dryRun) {
      return dryRunSuccess(
        withKitMetadata(
          {
            status: "dry-run",
            summary: "Would record usage",
            model: options.model,
            inputTokens: options.inputTokens,
            outputTokens: options.outputTokens,
            tier,
          },
          KIT_NAME,
          KIT_VERSION,
          options
        ),
        `[CostKit] Dry-run: would record ${options.inputTokens} input + ${options.outputTokens} output tokens for ${options.model}`
      );
    }

    const costKit = createCostKit(options);
    const record = costKit.recordUsage({
      model: options.model,
      inputTokens: options.inputTokens,
      outputTokens: options.outputTokens,
      workflowType: options.workflow || "cli-record",
      tier,
      durationMs: 0,
      success: true,
    });

    const output = withKitMetadata(
      {
        status: "success",
        summary: `Recorded usage: $${record.actualCostUsd.toFixed(4)}`,
        record,
      },
      KIT_NAME,
      KIT_VERSION,
      options
    );

    return success(
      output,
      `[CostKit] Recorded: $${record.actualCostUsd.toFixed(4)} (${options.model})`
    );
  },
};

/**
 * Alerts command - show unacknowledged alerts.
 */
const alertsCommand: CliCommand<CostKitCliOptions> = {
  name: "alerts",
  description: "Show unacknowledged cost alerts",
  args: [],
  options: [
    { name: "policy-path", description: "Path to cost policy YAML", type: "string" },
    { name: "data-path", description: "Path to cost data file", type: "string" },
  ],
  async handler(args, options) {
    // In dry-run mode, just validate inputs
    if (options.dryRun) {
      return dryRunSuccess(
        withKitMetadata(
          {
            status: "dry-run",
            summary: "Would show alerts",
          },
          KIT_NAME,
          KIT_VERSION,
          options
        ),
        "[CostKit] Dry-run: would show unacknowledged alerts"
      );
    }

    const costKit = createCostKit(options);
    const alerts = costKit.getUnacknowledgedAlerts();

    const output = withKitMetadata(
      {
        status: "success",
        summary: alerts.length === 0 ? "No unacknowledged alerts" : `${alerts.length} unacknowledged alert(s)`,
        alerts,
      },
      KIT_NAME,
      KIT_VERSION,
      options
    );

    if (alerts.length === 0) {
      return success(output, "[CostKit] No unacknowledged alerts");
    }

    return success(output, costKit.formatAlerts(alerts));
  },
};

/**
 * Format cost estimate for text output.
 */
function formatEstimate(estimate: CostEstimate): string {
  const lines: string[] = [];
  lines.push("[CostKit] Cost Estimate");
  lines.push("─────────────────────────────");
  lines.push(`Workflow: ${estimate.workflowType}`);
  lines.push(`Tier: ${estimate.tier}`);
  lines.push(`Model: ${estimate.model}`);
  lines.push("");
  lines.push(`Estimated Cost: $${estimate.estimatedCostUsd.toFixed(4)}`);
  lines.push(`Cost Range: $${estimate.costRange.min.toFixed(4)} - $${estimate.costRange.max.toFixed(4)}`);
  lines.push(`Tokens: ~${estimate.tokens.inputTokens.toLocaleString()} input, ~${estimate.tokens.outputTokens.toLocaleString()} output`);

  if (estimate.exceedsBudget) {
    lines.push("");
    lines.push("Warning: This estimate exceeds the current budget!");
  }

  return lines.join("\n");
}

/**
 * Format budget status for text output.
 */
function formatBudgetStatus(status: BudgetStatus): string {
  const lines: string[] = [];
  lines.push("[CostKit] Budget Status");
  lines.push("─────────────────────────────");
  lines.push(`Period: ${status.period}`);
  lines.push(`Spent: $${status.spentUsd.toFixed(2)} / $${status.limitUsd.toFixed(2)}`);
  lines.push(`Used: ${status.usedPercent.toFixed(1)}%`);
  lines.push(`Remaining: $${status.remainingUsd.toFixed(2)}`);

  if (status.status === "exceeded") {
    lines.push("");
    lines.push("Warning: Over budget!");
  } else if (status.status === "warning" || status.status === "critical") {
    lines.push("");
    lines.push("Warning: Approaching budget limit");
  }

  return lines.join("\n");
}

/**
 * Format cost summary for text output.
 */
function formatCostSummary(summary: CostSummary): string {
  const lines: string[] = [];
  lines.push("[CostKit] Cost Summary");
  lines.push("─────────────────────────────");
  lines.push(`Period: ${summary.periodStart} to ${summary.periodEnd}`);
  lines.push(`Total Cost: $${summary.totalSpentUsd.toFixed(2)}`);
  lines.push(`Total Operations: ${summary.operationCount.toLocaleString()}`);
  lines.push(`Total Tokens: ${summary.totalTokens.total.toLocaleString()}`);

  if (summary.byModel && Object.keys(summary.byModel).length > 0) {
    lines.push("");
    lines.push("By Model:");
    for (const [model, data] of Object.entries(summary.byModel)) {
      lines.push(`  ${model}: $${data.spentUsd.toFixed(2)} (${data.operations} operations)`);
    }
  }

  if (summary.trend) {
    lines.push("");
    const trendIcon = summary.trend.changePercent >= 0 ? "↑" : "↓";
    lines.push(`Trend: ${trendIcon} ${Math.abs(summary.trend.changePercent).toFixed(1)}% vs previous period`);
  }

  return lines.join("\n");
}

/**
 * CostKit CLI configuration.
 */
const cliConfig: KitCliConfig = {
  name: KIT_NAME,
  version: KIT_VERSION,
  description: "LLM cost management: estimation, tracking, budgeting, alerts",
  commands: [estimateCommand, statusCommand, summaryCommand, recordCommand, alertsCommand],
  globalOptions: [
    { name: "policy-path", description: "Path to cost policy YAML", type: "string" },
    { name: "data-path", description: "Path to cost data file", type: "string" },
  ],
};

/**
 * Run the CLI.
 */
runKitCli(cliConfig).then((exitCode) => {
  process.exitCode = exitCode;
});


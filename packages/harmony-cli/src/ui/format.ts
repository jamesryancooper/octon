/**
 * Formatting utilities for Harmony CLI output.
 */

import {
  bold,
  dim,
  muted,
  success,
  error,
  warning,
  info,
  highlight,
  tierColor,
  statusColor,
  symbols,
} from "./colors.js";
import type {
  HarmonyTask,
  SpecSummary,
  PRSummary,
  SystemStatus,
  StatusItem,
  RiskTier,
  WorkflowStatus,
} from "../types/index.js";

/**
 * Format a section header.
 */
export const header = (title: string): string => {
  return `\n${bold(title)}\n${"─".repeat(Math.min(title.length + 4, 60))}`;
};

/**
 * Format a task for display.
 */
export const formatTask = (task: HarmonyTask): string => {
  const tierBadge = tierColor(task.tier, `[${task.tier}]`);
  const statusBadge = formatStatus(task.status);
  const title = bold(task.title);

  let lines = [`${tierBadge} ${statusBadge} ${title}`];

  if (task.description) {
    lines.push(`   ${muted(task.description)}`);
  }

  if (task.prNumber) {
    lines.push(`   ${muted("PR:")} ${highlight(`#${task.prNumber}`)}`);
  }

  if (task.previewUrl) {
    lines.push(`   ${muted("Preview:")} ${highlight(task.previewUrl)}`);
  }

  if (task.warnings && task.warnings.length > 0) {
    for (const w of task.warnings) {
      lines.push(`   ${warning(`${symbols.warning} ${w}`)}`);
    }
  }

  return lines.join("\n");
};

/**
 * Format a workflow status.
 */
export const formatStatus = (status: WorkflowStatus): string => {
  const statusMap: Record<WorkflowStatus, { color: (s: string) => string; label: string }> = {
    pending: { color: muted, label: "pending" },
    planning: { color: info, label: "planning" },
    building: { color: info, label: "building" },
    testing: { color: info, label: "testing" },
    reviewing: { color: warning, label: "needs review" },
    ready: { color: success, label: "ready" },
    shipped: { color: success, label: "shipped" },
    failed: { color: error, label: "failed" },
    paused: { color: warning, label: "paused" },
  };

  const { color, label } = statusMap[status];
  return color(`[${label}]`);
};

/**
 * Format a spec summary for human review.
 */
export const formatSpecSummary = (summary: SpecSummary): string => {
  const lines: string[] = [];

  lines.push(header("Spec Summary"));
  lines.push("");
  lines.push(summary.description);
  lines.push("");

  // Tier
  const tierBadge = tierColor(summary.tier, bold(summary.tier));
  lines.push(`${bold("Risk Tier:")} ${tierBadge}`);
  lines.push(`   ${muted(summary.tierReason)}`);
  lines.push("");

  // Surfaces
  lines.push(`${bold("Surfaces:")} ${summary.surfaces.join(", ")}`);

  // Threat summary (if present)
  if (summary.threatSummary) {
    lines.push("");
    lines.push(`${bold("Threat Check:")}`);
    lines.push(`   ${summary.threatSummary}`);
  }

  // Tests
  lines.push("");
  lines.push(`${bold("Tests:")} ${summary.tests.unit} unit, ${summary.tests.contract} contract, ${summary.tests.e2e} e2e`);

  // Flag
  if (summary.flag) {
    lines.push(`${bold("Flag:")} ${highlight(summary.flag)}`);
  }

  // Rollback
  lines.push(`${bold("Rollback:")} ${summary.rollback}`);

  return lines.join("\n");
};

/**
 * Format a PR summary for human review.
 */
export const formatPRSummary = (summary: PRSummary): string => {
  const lines: string[] = [];

  lines.push(header("PR Summary"));
  lines.push("");
  lines.push(summary.description);
  lines.push("");

  // Changes
  lines.push(
    `${bold("Changes:")} ${summary.filesChanged} files, ${success(`+${summary.linesAdded}`)} ${error(`-${summary.linesRemoved}`)}`
  );

  // Status
  const testStatus =
    summary.testsStatus === "passing"
      ? success("passing")
      : summary.testsStatus === "failing"
        ? error("failing")
        : muted("pending");
  const ciStatus =
    summary.ciStatus === "passing"
      ? success("passing")
      : summary.ciStatus === "failing"
        ? error("failing")
        : muted("pending");

  lines.push(`${bold("Tests:")} ${testStatus}  ${bold("CI:")} ${ciStatus}`);

  // Warnings
  if (summary.warnings.length > 0) {
    lines.push("");
    lines.push(warning(bold("Warnings:")));
    for (const w of summary.warnings) {
      lines.push(`   ${warning(symbols.warning)} ${w}`);
    }
  }

  // Recommendation
  lines.push("");
  const recColor =
    summary.recommendation === "approve"
      ? success
      : summary.recommendation === "review"
        ? warning
        : error;
  lines.push(`${bold("Recommendation:")} ${recColor(summary.recommendation.toUpperCase())}`);

  return lines.join("\n");
};

/**
 * Format the system status.
 */
export const formatSystemStatus = (status: SystemStatus): string => {
  const lines: string[] = [];

  lines.push(header("Harmony Status"));

  // Active tasks
  if (status.activeTasks.length > 0) {
    lines.push("");
    lines.push(bold("Active Tasks:"));
    for (const task of status.activeTasks) {
      lines.push(formatTask(task));
    }
  }

  // Pending review
  if (status.pendingReview.length > 0) {
    lines.push("");
    lines.push(warning(bold("Awaiting Your Review:")));
    for (const task of status.pendingReview) {
      lines.push(formatTask(task));
    }
  }

  // Recently completed
  if (status.recentlyCompleted.length > 0) {
    lines.push("");
    lines.push(muted(bold("Recently Completed:")));
    for (const task of status.recentlyCompleted.slice(0, 3)) {
      lines.push(`   ${success(symbols.tick)} ${task.title}`);
    }
  }

  // Health
  lines.push("");
  lines.push(bold("System Health:"));
  for (const item of status.health) {
    const icon = formatHealthIcon(item.status);
    const msg = statusColor(item.status, item.message);
    lines.push(`   ${icon} ${item.name}: ${msg}`);
  }

  // Cost
  if (status.cost) {
    lines.push("");
    const spent = status.cost.spent.toFixed(2);
    const budget = status.cost.budget.toFixed(2);
    const pct = ((status.cost.spent / status.cost.budget) * 100).toFixed(0);
    const costColor = status.cost.spent > status.cost.budget * 0.8 ? warning : muted;
    lines.push(`${bold("AI Cost:")} ${costColor(`$${spent} / $${budget} (${pct}%)`)}`);
  }

  // No tasks message
  if (
    status.activeTasks.length === 0 &&
    status.pendingReview.length === 0 &&
    status.recentlyCompleted.length === 0
  ) {
    lines.push("");
    lines.push(muted("No active tasks. Run `harmony feature` or `harmony fix` to start."));
  }

  return lines.join("\n");
};

const formatHealthIcon = (status: StatusItem["status"]): string => {
  switch (status) {
    case "ok":
      return success(symbols.tick);
    case "warning":
      return warning(symbols.warning);
    case "error":
      return error(symbols.cross);
    case "pending":
      return muted("○");
  }
};

/**
 * Format a simple key-value table.
 */
export const formatTable = (data: Record<string, string | number | boolean | undefined>): string => {
  const entries = Object.entries(data).filter(([, v]) => v !== undefined);
  if (entries.length === 0) return "";

  const maxKeyLen = Math.max(...entries.map(([k]) => k.length));

  return entries
    .map(([key, value]) => {
      const paddedKey = key.padEnd(maxKeyLen);
      return `${muted(paddedKey)}  ${value}`;
    })
    .join("\n");
};

/**
 * Format help text for a command.
 */
export const formatHelp = (
  command: string,
  description: string,
  usage: string,
  options?: Array<{ flag: string; description: string }>
): string => {
  const lines: string[] = [];

  lines.push(bold(`harmony ${command}`));
  lines.push(muted(description));
  lines.push("");
  lines.push(`${bold("Usage:")} ${usage}`);

  if (options && options.length > 0) {
    lines.push("");
    lines.push(bold("Options:"));
    const maxFlagLen = Math.max(...options.map((o) => o.flag.length));
    for (const opt of options) {
      lines.push(`  ${highlight(opt.flag.padEnd(maxFlagLen))}  ${opt.description}`);
    }
  }

  return lines.join("\n");
};


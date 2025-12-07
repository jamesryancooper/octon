/**
 * CostKit Alerts - Cost alerting and notification system.
 *
 * Provides instance-based alert management with:
 * - Encapsulated state (no module-level mutable globals)
 * - Deduplication to prevent alert spam
 * - Multiple severity levels and alert types
 *
 * Pillar alignment: Quality through Determinism
 * - No global mutable state
 * - Each instance manages its own alerts
 * - Isolated side effects at edges
 *
 * @example
 * ```typescript
 * const alertManager = new AlertManager();
 * const budgetAlerts = alertManager.checkBudgetAlerts(budgetStatus);
 * const unacknowledged = alertManager.getUnacknowledgedAlerts();
 * ```
 */

import type {
  CostAlert,
  AlertType,
  AlertSeverity,
  BudgetStatus,
  UsageRecord,
  CostEstimate,
} from "./types.js";
import { getDeprecatedModels } from "./pricing.js";
import { randomUUID } from "crypto";

/**
 * Default deduplication window in milliseconds (5 minutes).
 */
const DEFAULT_DEDUPE_WINDOW_MS = 5 * 60 * 1000;

/**
 * Alert manager class - encapsulates alert state management.
 *
 * Pillar alignment: Quality through Determinism
 * - No global mutable state
 * - Each instance manages its own alerts
 */
export class AlertManager {
  private alerts: CostAlert[] = [];
  private recentAlertHashes = new Map<string, number>();

  /**
   * Create a hash for deduplication.
   */
  private createAlertHash(type: AlertType, key: string): string {
    return `${type}:${key}`;
  }

  /**
   * Check if an alert should be deduplicated.
   */
  private shouldDedupe(
    type: AlertType,
    key: string,
    windowMs: number = DEFAULT_DEDUPE_WINDOW_MS
  ): boolean {
    const hash = this.createAlertHash(type, key);
    const lastTime = this.recentAlertHashes.get(hash);

    if (lastTime && Date.now() - lastTime < windowMs) {
      return true;
    }

    this.recentAlertHashes.set(hash, Date.now());
    return false;
  }

  /**
   * Create and store an alert.
   */
  private createAlert(params: {
    type: AlertType;
    severity: AlertSeverity;
    message: string;
    details: string;
    data: Record<string, unknown>;
    dedupeKey?: string;
    dedupeWindowMs?: number;
  }): CostAlert | null {
    // Check deduplication
    if (
      params.dedupeKey &&
      this.shouldDedupe(params.type, params.dedupeKey, params.dedupeWindowMs)
    ) {
      return null;
    }

    const alert: CostAlert = {
      alertId: randomUUID(),
      type: params.type,
      severity: params.severity,
      message: params.message,
      details: params.details,
      data: params.data,
      createdAt: new Date().toISOString(),
      acknowledged: false,
    };

    this.alerts.push(alert);
    return alert;
  }

  /**
   * Check budget status and generate alerts if needed.
   */
  checkBudgetAlerts(
    status: BudgetStatus,
    dedupeWindowMs?: number
  ): CostAlert[] {
    const newAlerts: CostAlert[] = [];

    // Budget exceeded
    if (status.status === "exceeded") {
      const alert = this.createAlert({
        type: "budget_exceeded",
        severity: "critical",
        message: `Budget exceeded: $${status.spentUsd.toFixed(2)} spent of $${status.limitUsd.toFixed(2)} ${status.period} limit`,
        details: `The ${status.period} budget has been exceeded. ${
          status.projectedOverBudget
            ? `Projected spend: $${status.projectedSpendUsd.toFixed(2)}.`
            : ""
        } Consider pausing non-critical operations until the next period.`,
        data: {
          period: status.period,
          spentUsd: status.spentUsd,
          limitUsd: status.limitUsd,
          usedPercent: status.usedPercent,
        },
        dedupeKey: `${status.period}-exceeded`,
        dedupeWindowMs,
      });
      if (alert) newAlerts.push(alert);
    }

    // Budget critical
    else if (status.status === "critical") {
      const alert = this.createAlert({
        type: "budget_critical",
        severity: "critical",
        message: `Budget critical: ${status.usedPercent.toFixed(1)}% of ${status.period} budget used`,
        details: `Only $${status.remainingUsd.toFixed(2)} remaining. ${
          status.projectedOverBudget
            ? `At current rate, projected to exceed budget ($${status.projectedSpendUsd.toFixed(2)}).`
            : ""
        }`,
        data: {
          period: status.period,
          spentUsd: status.spentUsd,
          limitUsd: status.limitUsd,
          remainingUsd: status.remainingUsd,
          usedPercent: status.usedPercent,
          projectedSpendUsd: status.projectedSpendUsd,
        },
        dedupeKey: `${status.period}-critical`,
        dedupeWindowMs,
      });
      if (alert) newAlerts.push(alert);
    }

    // Budget warning
    else if (status.status === "warning") {
      const alert = this.createAlert({
        type: "budget_warning",
        severity: "warning",
        message: `Budget warning: ${status.usedPercent.toFixed(1)}% of ${status.period} budget used`,
        details: `$${status.remainingUsd.toFixed(2)} remaining of $${status.limitUsd.toFixed(2)} ${status.period} budget.`,
        data: {
          period: status.period,
          spentUsd: status.spentUsd,
          limitUsd: status.limitUsd,
          remainingUsd: status.remainingUsd,
          usedPercent: status.usedPercent,
        },
        dedupeKey: `${status.period}-warning`,
        dedupeWindowMs,
      });
      if (alert) newAlerts.push(alert);
    }

    // Projected overspend
    if (status.projectedOverBudget && status.status === "healthy") {
      const alert = this.createAlert({
        type: "budget_warning",
        severity: "warning",
        message: `Projected to exceed ${status.period} budget`,
        details: `Current burn rate projects $${status.projectedSpendUsd.toFixed(2)} spend, exceeding the $${status.limitUsd.toFixed(2)} limit.`,
        data: {
          period: status.period,
          projectedSpendUsd: status.projectedSpendUsd,
          limitUsd: status.limitUsd,
        },
        dedupeKey: `${status.period}-projected`,
        dedupeWindowMs,
      });
      if (alert) newAlerts.push(alert);
    }

    return newAlerts;
  }

  /**
   * Check for unusual spending patterns.
   */
  checkUnusualSpendAlert(
    recentRecords: UsageRecord[],
    historicalAvgCost: number,
    dedupeWindowMs?: number
  ): CostAlert | null {
    if (recentRecords.length === 0) return null;

    const recentTotalCost = recentRecords.reduce(
      (sum, r) => sum + r.actualCostUsd,
      0
    );
    const recentAvgCost = recentTotalCost / recentRecords.length;

    // Alert if recent average is 3x historical average
    if (recentAvgCost > historicalAvgCost * 3 && historicalAvgCost > 0) {
      return this.createAlert({
        type: "unusual_spend",
        severity: "warning",
        message: `Unusual spending detected: ${(recentAvgCost / historicalAvgCost).toFixed(1)}x normal`,
        details: `Recent average cost ($${recentAvgCost.toFixed(4)}/op) is significantly higher than historical average ($${historicalAvgCost.toFixed(4)}/op). This could indicate expensive model usage or large context windows.`,
        data: {
          recentAvgCost,
          historicalAvgCost,
          ratio: recentAvgCost / historicalAvgCost,
          recentRecordCount: recentRecords.length,
        },
        dedupeKey: "unusual-spend",
        dedupeWindowMs,
      });
    }

    return null;
  }

  /**
   * Check if a deprecated model is being used.
   */
  checkDeprecatedModelAlert(
    model: string,
    dedupeWindowMs?: number
  ): CostAlert | null {
    const deprecatedModels = getDeprecatedModels();
    const deprecated = deprecatedModels.find((m) => m.model === model);

    if (deprecated) {
      return this.createAlert({
        type: "model_deprecated",
        severity: "warning",
        message: `Deprecated model in use: ${model}`,
        details: deprecated.replacement
          ? `Model "${model}" is deprecated. Consider migrating to "${deprecated.replacement}".`
          : `Model "${model}" is deprecated and should be replaced.`,
        data: {
          model,
          replacement: deprecated.replacement,
        },
        dedupeKey: model,
        dedupeWindowMs,
      });
    }

    return null;
  }

  /**
   * Check if estimate was significantly exceeded.
   */
  checkEstimateExceededAlert(
    estimate: CostEstimate,
    actualCost: number,
    threshold: number = 1.5, // 50% over estimate
    dedupeWindowMs?: number
  ): CostAlert | null {
    if (actualCost > estimate.costRange.max * threshold) {
      const overagePercent =
        ((actualCost - estimate.estimatedCostUsd) / estimate.estimatedCostUsd) * 100;

      return this.createAlert({
        type: "estimate_exceeded",
        severity: "info",
        message: `Actual cost ${overagePercent.toFixed(0)}% over estimate`,
        details: `Estimated: $${estimate.estimatedCostUsd.toFixed(4)}, Actual: $${actualCost.toFixed(4)} for ${estimate.workflowType}. Consider updating estimation heuristics.`,
        data: {
          estimateId: estimate.estimateId,
          workflowType: estimate.workflowType,
          estimatedCost: estimate.estimatedCostUsd,
          actualCost,
          overagePercent,
        },
        dedupeKey: `${estimate.workflowType}-exceeded`,
        dedupeWindowMs,
      });
    }

    return null;
  }

  /**
   * Get all alerts.
   */
  getAlerts(): CostAlert[] {
    return [...this.alerts];
  }

  /**
   * Get unacknowledged alerts.
   */
  getUnacknowledgedAlerts(): CostAlert[] {
    return this.alerts.filter((a) => !a.acknowledged);
  }

  /**
   * Get alerts by severity.
   */
  getAlertsBySeverity(severity: AlertSeverity): CostAlert[] {
    return this.alerts.filter((a) => a.severity === severity);
  }

  /**
   * Get alerts by type.
   */
  getAlertsByType(type: AlertType): CostAlert[] {
    return this.alerts.filter((a) => a.type === type);
  }

  /**
   * Get recent alerts (within time window).
   */
  getRecentAlerts(withinMs: number): CostAlert[] {
    const cutoff = Date.now() - withinMs;
    return this.alerts.filter((a) => new Date(a.createdAt).getTime() > cutoff);
  }

  /**
   * Acknowledge an alert.
   */
  acknowledgeAlert(alertId: string, acknowledgedBy: string): CostAlert | null {
    const alert = this.alerts.find((a) => a.alertId === alertId);
    if (alert && !alert.acknowledged) {
      alert.acknowledged = true;
      alert.acknowledgedBy = acknowledgedBy;
      alert.acknowledgedAt = new Date().toISOString();
      return alert;
    }
    return null;
  }

  /**
   * Acknowledge all alerts of a type.
   */
  acknowledgeAlertsByType(type: AlertType, acknowledgedBy: string): number {
    let count = 0;
    for (const alert of this.alerts) {
      if (alert.type === type && !alert.acknowledged) {
        alert.acknowledged = true;
        alert.acknowledgedBy = acknowledgedBy;
        alert.acknowledgedAt = new Date().toISOString();
        count++;
      }
    }
    return count;
  }

  /**
   * Clear old alerts (older than specified days).
   */
  clearOldAlerts(olderThanDays: number = 30): number {
    const cutoff = Date.now() - olderThanDays * 24 * 60 * 60 * 1000;
    const before = this.alerts.length;
    this.alerts = this.alerts.filter((a) => new Date(a.createdAt).getTime() > cutoff);
    return before - this.alerts.length;
  }

  /**
   * Clear all alerts.
   */
  clearAllAlerts(): void {
    this.alerts = [];
    this.recentAlertHashes.clear();
  }

  /**
   * Get alert summary.
   */
  getAlertSummary(): {
    total: number;
    unacknowledged: number;
    bySeverity: Record<AlertSeverity, number>;
    byType: Record<AlertType, number>;
  } {
    const bySeverity: Record<AlertSeverity, number> = {
      info: 0,
      warning: 0,
      critical: 0,
    };

    const byType: Partial<Record<AlertType, number>> = {};

    for (const alert of this.alerts) {
      bySeverity[alert.severity]++;
      byType[alert.type] = (byType[alert.type] || 0) + 1;
    }

    return {
      total: this.alerts.length,
      unacknowledged: this.alerts.filter((a) => !a.acknowledged).length,
      bySeverity,
      byType: byType as Record<AlertType, number>,
    };
  }
}

// =============================================================================
// Pure Functions (no state, deterministic)
// =============================================================================

/**
 * Format alert for human display.
 * Pure function - no side effects.
 */
export function formatAlert(alert: CostAlert): string {
  const severityEmoji = {
    info: "ℹ️",
    warning: "⚠️",
    critical: "🚨",
  };

  const lines: string[] = [];

  lines.push(`${severityEmoji[alert.severity]} ${alert.message}`);
  lines.push(`─────────────────────────────`);
  lines.push(alert.details);
  lines.push(``);
  lines.push(`Type: ${alert.type}`);
  lines.push(`Time: ${new Date(alert.createdAt).toLocaleString()}`);

  if (alert.acknowledged) {
    lines.push(`Acknowledged by: ${alert.acknowledgedBy}`);
  }

  return lines.join("\n");
}

/**
 * Format multiple alerts for human display.
 * Pure function - no side effects.
 */
export function formatAlerts(alertList: CostAlert[]): string {
  if (alertList.length === 0) {
    return "✅ No alerts";
  }

  const lines: string[] = [];
  lines.push(`🔔 Alerts (${alertList.length})`);
  lines.push(`══════════════════════════════════════`);

  for (const alert of alertList) {
    lines.push(``);
    lines.push(formatAlert(alert));
  }

  return lines.join("\n");
}


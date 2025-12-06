/**
 * Golden test monitoring infrastructure.
 *
 * Provides tools to track AI output quality over time,
 * detect drift, and alert on regressions.
 */

import { readFileSync, writeFileSync, existsSync, mkdirSync } from "node:fs";
import { join } from "node:path";
import type { GoldenTestSummary, GoldenTestResult } from "./golden.js";

/**
 * A single monitoring record.
 */
export interface MonitoringRecord {
  /** Unique run ID */
  runId: string;

  /** When the test was run */
  timestamp: string;

  /** Prompt ID being monitored */
  promptId: string;

  /** Model used for generation */
  model: string;

  /** Temperature setting */
  temperature: number;

  /** Test results summary */
  summary: {
    total: number;
    passed: number;
    failed: number;
    passRate: number;
  };

  /** Individual test results */
  results: GoldenTestResult[];

  /** Any drift detected from previous run */
  drift?: {
    detected: boolean;
    magnitude: number; // 0-1, how much drift
    details: string[];
  };
}

/**
 * Aggregated metrics over time.
 */
export interface MonitoringMetrics {
  /** Prompt ID */
  promptId: string;

  /** Time range */
  startDate: string;
  endDate: string;

  /** Total runs analyzed */
  totalRuns: number;

  /** Average pass rate */
  avgPassRate: number;

  /** Pass rate trend (positive = improving) */
  trend: number;

  /** Consistency score (how stable are results) */
  consistency: number;

  /** Recent failures */
  recentFailures: Array<{
    testId: string;
    runId: string;
    timestamp: string;
    reason: string;
  }>;

  /** Recommendations */
  recommendations: string[];
}

/**
 * Alert for monitoring issues.
 */
export interface MonitoringAlert {
  /** Alert ID */
  id: string;

  /** Alert type */
  type: "pass_rate_drop" | "drift_detected" | "consistency_low" | "new_failure";

  /** Severity */
  severity: "critical" | "warning" | "info";

  /** Prompt affected */
  promptId: string;

  /** Message */
  message: string;

  /** When detected */
  timestamp: string;

  /** Suggested action */
  action: string;
}

/**
 * Monitoring thresholds.
 */
export interface MonitoringThresholds {
  /** Minimum acceptable pass rate (0-1) */
  minPassRate: number;

  /** Maximum acceptable drift (0-1) */
  maxDrift: number;

  /** Minimum consistency score (0-1) */
  minConsistency: number;

  /** Number of consecutive failures to alert */
  consecutiveFailuresAlert: number;
}

const DEFAULT_THRESHOLDS: MonitoringThresholds = {
  minPassRate: 0.9,
  maxDrift: 0.15,
  minConsistency: 0.85,
  consecutiveFailuresAlert: 2,
};

/**
 * Manages golden test monitoring and metrics.
 */
export class GoldenTestMonitor {
  private dataDir: string;
  private thresholds: MonitoringThresholds;

  constructor(dataDir: string, thresholds: Partial<MonitoringThresholds> = {}) {
    this.dataDir = dataDir;
    this.thresholds = { ...DEFAULT_THRESHOLDS, ...thresholds };

    // Ensure data directory exists
    if (!existsSync(this.dataDir)) {
      mkdirSync(this.dataDir, { recursive: true });
    }
  }

  /**
   * Record a golden test run.
   */
  recordRun(
    promptId: string,
    testSummary: GoldenTestSummary,
    model: string,
    temperature: number
  ): MonitoringRecord {
    const runId = `${promptId}_${Date.now()}`;
    const previousRun = this.getLatestRun(promptId);

    const record: MonitoringRecord = {
      runId,
      timestamp: testSummary.timestamp,
      promptId,
      model,
      temperature,
      summary: {
        total: testSummary.total,
        passed: testSummary.passed,
        failed: testSummary.failed,
        passRate: testSummary.total > 0 ? testSummary.passed / testSummary.total : 0,
      },
      results: testSummary.results,
    };

    // Calculate drift from previous run
    if (previousRun) {
      record.drift = this.calculateDrift(previousRun, record);
    }

    // Save the record
    this.saveRecord(record);

    return record;
  }

  /**
   * Calculate drift between two runs.
   */
  private calculateDrift(
    previous: MonitoringRecord,
    current: MonitoringRecord
  ): MonitoringRecord["drift"] {
    const details: string[] = [];
    let driftScore = 0;

    // Pass rate change
    const passRateChange = Math.abs(
      current.summary.passRate - previous.summary.passRate
    );
    if (passRateChange > 0.1) {
      details.push(
        `Pass rate changed by ${(passRateChange * 100).toFixed(1)}%`
      );
      driftScore += passRateChange;
    }

    // Check for new failures
    const previousFailedIds = new Set(
      previous.results.filter((r) => !r.passed).map((r) => r.testId)
    );
    const newFailures = current.results.filter(
      (r) => !r.passed && !previousFailedIds.has(r.testId)
    );

    if (newFailures.length > 0) {
      details.push(`${newFailures.length} new test(s) failed`);
      driftScore += newFailures.length * 0.1;
    }

    // Check for recovered tests
    const currentFailedIds = new Set(
      current.results.filter((r) => !r.passed).map((r) => r.testId)
    );
    const recovered = previous.results.filter(
      (r) => !r.passed && !currentFailedIds.has(r.testId)
    );

    if (recovered.length > 0) {
      details.push(`${recovered.length} test(s) now passing`);
      // Don't add to drift score - this is good
    }

    return {
      detected: driftScore > this.thresholds.maxDrift,
      magnitude: Math.min(1, driftScore),
      details,
    };
  }

  /**
   * Get the latest run for a prompt.
   */
  getLatestRun(promptId: string): MonitoringRecord | null {
    const runs = this.getRuns(promptId, 1);
    return runs.length > 0 ? runs[0] : null;
  }

  /**
   * Get recent runs for a prompt.
   */
  getRuns(promptId: string, limit: number = 10): MonitoringRecord[] {
    const indexPath = join(this.dataDir, `${promptId}_index.json`);

    if (!existsSync(indexPath)) {
      return [];
    }

    const index = JSON.parse(readFileSync(indexPath, "utf-8")) as string[];
    const runs: MonitoringRecord[] = [];

    for (const runId of index.slice(-limit).reverse()) {
      const recordPath = join(this.dataDir, `${runId}.json`);
      if (existsSync(recordPath)) {
        runs.push(JSON.parse(readFileSync(recordPath, "utf-8")));
      }
    }

    return runs;
  }

  /**
   * Calculate metrics for a prompt.
   */
  getMetrics(promptId: string, days: number = 30): MonitoringMetrics {
    const cutoff = Date.now() - days * 24 * 60 * 60 * 1000;
    const allRuns = this.getRuns(promptId, 100);
    const runs = allRuns.filter(
      (r) => new Date(r.timestamp).getTime() > cutoff
    );

    if (runs.length === 0) {
      return {
        promptId,
        startDate: new Date(cutoff).toISOString(),
        endDate: new Date().toISOString(),
        totalRuns: 0,
        avgPassRate: 0,
        trend: 0,
        consistency: 0,
        recentFailures: [],
        recommendations: ["No recent test runs - schedule golden tests"],
      };
    }

    // Calculate average pass rate
    const avgPassRate =
      runs.reduce((sum, r) => sum + r.summary.passRate, 0) / runs.length;

    // Calculate trend (simple linear regression)
    const passRates = runs.map((r) => r.summary.passRate);
    const trend = this.calculateTrend(passRates);

    // Calculate consistency (standard deviation)
    const consistency = 1 - this.calculateStdDev(passRates);

    // Get recent failures
    const recentFailures: MonitoringMetrics["recentFailures"] = [];
    for (const run of runs.slice(0, 5)) {
      for (const result of run.results) {
        if (!result.passed) {
          recentFailures.push({
            testId: result.testId,
            runId: run.runId,
            timestamp: run.timestamp,
            reason: result.differences?.[0] || "Unknown failure",
          });
        }
      }
    }

    // Generate recommendations
    const recommendations: string[] = [];

    if (avgPassRate < this.thresholds.minPassRate) {
      recommendations.push(
        `Pass rate (${(avgPassRate * 100).toFixed(1)}%) is below threshold (${(this.thresholds.minPassRate * 100).toFixed(0)}%)`
      );
    }

    if (trend < -0.1) {
      recommendations.push("Pass rate is declining - investigate recent changes");
    }

    if (consistency < this.thresholds.minConsistency) {
      recommendations.push(
        "Results are inconsistent - consider lowering temperature or adding constraints"
      );
    }

    if (runs.length < 5) {
      recommendations.push("Insufficient data - run more golden tests");
    }

    return {
      promptId,
      startDate: runs[runs.length - 1].timestamp,
      endDate: runs[0].timestamp,
      totalRuns: runs.length,
      avgPassRate,
      trend,
      consistency,
      recentFailures: recentFailures.slice(0, 10),
      recommendations,
    };
  }

  /**
   * Check for alerts.
   */
  checkAlerts(promptId: string): MonitoringAlert[] {
    const alerts: MonitoringAlert[] = [];
    const metrics = this.getMetrics(promptId, 7);
    const latestRun = this.getLatestRun(promptId);

    // Pass rate drop
    if (metrics.avgPassRate < this.thresholds.minPassRate) {
      alerts.push({
        id: `${promptId}_pass_rate_${Date.now()}`,
        type: "pass_rate_drop",
        severity:
          metrics.avgPassRate < this.thresholds.minPassRate - 0.1
            ? "critical"
            : "warning",
        promptId,
        message: `Pass rate dropped to ${(metrics.avgPassRate * 100).toFixed(1)}%`,
        timestamp: new Date().toISOString(),
        action: "Review recent prompt changes and test failures",
      });
    }

    // Drift detected
    if (latestRun?.drift?.detected) {
      alerts.push({
        id: `${promptId}_drift_${Date.now()}`,
        type: "drift_detected",
        severity: latestRun.drift.magnitude > 0.3 ? "critical" : "warning",
        promptId,
        message: `Significant output drift detected: ${latestRun.drift.details.join(", ")}`,
        timestamp: new Date().toISOString(),
        action: "Verify if drift is intentional; update golden tests if needed",
      });
    }

    // Low consistency
    if (metrics.consistency < this.thresholds.minConsistency) {
      alerts.push({
        id: `${promptId}_consistency_${Date.now()}`,
        type: "consistency_low",
        severity: "warning",
        promptId,
        message: `Output consistency is low (${(metrics.consistency * 100).toFixed(1)}%)`,
        timestamp: new Date().toISOString(),
        action: "Consider lowering temperature or adding more specific constraints",
      });
    }

    // New failures
    if (latestRun && latestRun.summary.failed > 0) {
      const recentRuns = this.getRuns(promptId, 3);
      const consecutiveFailures = recentRuns.filter(
        (r) => r.summary.failed > 0
      ).length;

      if (consecutiveFailures >= this.thresholds.consecutiveFailuresAlert) {
        alerts.push({
          id: `${promptId}_failures_${Date.now()}`,
          type: "new_failure",
          severity: "warning",
          promptId,
          message: `${consecutiveFailures} consecutive runs with failures`,
          timestamp: new Date().toISOString(),
          action: "Investigate failing tests and fix or update expectations",
        });
      }
    }

    return alerts;
  }

  /**
   * Generate a monitoring report.
   */
  generateReport(promptId: string): string {
    const metrics = this.getMetrics(promptId, 30);
    const alerts = this.checkAlerts(promptId);
    const latestRun = this.getLatestRun(promptId);

    const lines: string[] = [
      `# Golden Test Monitoring Report: ${promptId}`,
      `Generated: ${new Date().toISOString()}`,
      "",
      "## Summary",
      `- Total Runs (30 days): ${metrics.totalRuns}`,
      `- Average Pass Rate: ${(metrics.avgPassRate * 100).toFixed(1)}%`,
      `- Trend: ${metrics.trend > 0 ? "📈 Improving" : metrics.trend < 0 ? "📉 Declining" : "➡️ Stable"}`,
      `- Consistency: ${(metrics.consistency * 100).toFixed(1)}%`,
      "",
    ];

    if (alerts.length > 0) {
      lines.push("## ⚠️ Alerts");
      for (const alert of alerts) {
        const icon =
          alert.severity === "critical"
            ? "🔴"
            : alert.severity === "warning"
              ? "🟡"
              : "🔵";
        lines.push(`${icon} **${alert.type}**: ${alert.message}`);
        lines.push(`   Action: ${alert.action}`);
      }
      lines.push("");
    }

    if (metrics.recentFailures.length > 0) {
      lines.push("## Recent Failures");
      for (const failure of metrics.recentFailures.slice(0, 5)) {
        lines.push(`- **${failure.testId}**: ${failure.reason}`);
      }
      lines.push("");
    }

    if (latestRun?.drift?.detected) {
      lines.push("## Drift Analysis");
      lines.push(`Magnitude: ${(latestRun.drift.magnitude * 100).toFixed(1)}%`);
      for (const detail of latestRun.drift.details) {
        lines.push(`- ${detail}`);
      }
      lines.push("");
    }

    if (metrics.recommendations.length > 0) {
      lines.push("## Recommendations");
      for (const rec of metrics.recommendations) {
        lines.push(`- ${rec}`);
      }
    }

    return lines.join("\n");
  }

  /**
   * Save a monitoring record.
   */
  private saveRecord(record: MonitoringRecord): void {
    // Save the record
    const recordPath = join(this.dataDir, `${record.runId}.json`);
    writeFileSync(recordPath, JSON.stringify(record, null, 2));

    // Update the index
    const indexPath = join(this.dataDir, `${record.promptId}_index.json`);
    let index: string[] = [];

    if (existsSync(indexPath)) {
      index = JSON.parse(readFileSync(indexPath, "utf-8"));
    }

    index.push(record.runId);

    // Keep only last 100 runs
    if (index.length > 100) {
      index = index.slice(-100);
    }

    writeFileSync(indexPath, JSON.stringify(index, null, 2));
  }

  /**
   * Calculate trend from a series of values.
   */
  private calculateTrend(values: number[]): number {
    if (values.length < 2) return 0;

    const n = values.length;
    const sumX = (n * (n - 1)) / 2;
    const sumY = values.reduce((a, b) => a + b, 0);
    const sumXY = values.reduce((sum, y, i) => sum + i * y, 0);
    const sumX2 = (n * (n - 1) * (2 * n - 1)) / 6;

    const slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    return slope;
  }

  /**
   * Calculate standard deviation.
   */
  private calculateStdDev(values: number[]): number {
    if (values.length < 2) return 0;

    const mean = values.reduce((a, b) => a + b, 0) / values.length;
    const squaredDiffs = values.map((v) => Math.pow(v - mean, 2));
    const avgSquaredDiff =
      squaredDiffs.reduce((a, b) => a + b, 0) / values.length;

    return Math.sqrt(avgSquaredDiff);
  }
}

/**
 * Create a weekly monitoring summary for all prompts.
 */
export function generateWeeklySummary(
  monitor: GoldenTestMonitor,
  promptIds: string[]
): string {
  const lines: string[] = [
    "# Weekly Golden Test Summary",
    `Week of: ${new Date().toISOString().split("T")[0]}`,
    "",
    "## Overview",
    "",
    "| Prompt | Pass Rate | Trend | Alerts |",
    "|--------|-----------|-------|--------|",
  ];

  let totalAlerts = 0;
  let criticalAlerts = 0;

  for (const promptId of promptIds) {
    const metrics = monitor.getMetrics(promptId, 7);
    const alerts = monitor.checkAlerts(promptId);

    const trendIcon =
      metrics.trend > 0.05 ? "📈" : metrics.trend < -0.05 ? "📉" : "➡️";
    const alertCount = alerts.length;
    const alertIcon =
      alerts.some((a) => a.severity === "critical")
        ? "🔴"
        : alertCount > 0
          ? "🟡"
          : "✅";

    lines.push(
      `| ${promptId} | ${(metrics.avgPassRate * 100).toFixed(0)}% | ${trendIcon} | ${alertIcon} ${alertCount} |`
    );

    totalAlerts += alertCount;
    criticalAlerts += alerts.filter((a) => a.severity === "critical").length;
  }

  lines.push("");
  lines.push(`**Total Alerts**: ${totalAlerts} (${criticalAlerts} critical)`);

  return lines.join("\n");
}


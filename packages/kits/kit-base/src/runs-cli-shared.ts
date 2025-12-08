/**
 * Shared CLI utilities for run records commands.
 *
 * Used by both the standalone `kit-runs` CLI and kit-specific
 * `<kit> runs` subcommands.
 */

import type {
  RunRecordSummary,
  RunRecordStats,
  RunRecord,
  CleanupResult,
  ExportResult,
  ListRunRecordsOptions,
} from "./run-record.js";
import type { LifecycleStage, RiskLevel, RunStatus } from "./types.js";

// ============================================================================
// Argument Parsing
// ============================================================================

/**
 * Parsed arguments for runs CLI commands.
 */
export interface RunsCliArgs {
  command: string;
  runId?: string;
  kit?: string;
  status?: RunStatus;
  stage?: LifecycleStage;
  risk?: RiskLevel;
  since?: Date;
  until?: Date;
  limit?: number;
  offset?: number;
  format?: "json" | "text" | "table";
  traceId?: string;
  idempotencyKey?: string;
  maxAge?: string;
  dryRun?: boolean;
  exportFormat?: "json" | "ndjson" | "otlp";
  outputPath?: string;
  collectorUrl?: string;
  runsDir?: string;
  help?: boolean;
  verbose?: boolean;
}

/**
 * Parse duration string to milliseconds.
 * Supports: 30d, 7d, 24h, 60m, 30s
 */
export function parseDuration(duration: string): number | null {
  const match = duration.match(/^(\d+)([dhms])$/);
  if (!match) return null;

  const value = parseInt(match[1], 10);
  const unit = match[2];

  switch (unit) {
    case "d":
      return value * 24 * 60 * 60 * 1000;
    case "h":
      return value * 60 * 60 * 1000;
    case "m":
      return value * 60 * 1000;
    case "s":
      return value * 1000;
    default:
      return null;
  }
}

/**
 * Parse date string or relative time to Date.
 */
export function parseDate(dateStr: string): Date | null {
  // Try ISO date first
  const date = new Date(dateStr);
  if (!isNaN(date.getTime())) {
    return date;
  }

  // Try relative time (e.g., "7d ago", "24h ago")
  const relativeMatch = dateStr.match(/^(\d+)([dhms])\s*ago$/i);
  if (relativeMatch) {
    const ms = parseDuration(`${relativeMatch[1]}${relativeMatch[2]}`);
    if (ms) {
      return new Date(Date.now() - ms);
    }
  }

  return null;
}

/**
 * Parse command-line arguments for runs CLI.
 */
export function parseRunsCliArgs(args: string[]): RunsCliArgs {
  const parsed: RunsCliArgs = {
    command: args[0] || "help",
  };

  for (let i = 1; i < args.length; i++) {
    const arg = args[i];
    const next = args[i + 1];

    switch (arg) {
      case "--kit":
      case "-k":
        parsed.kit = next;
        i++;
        break;
      case "--status":
        // Note: -s is reserved for standard --stage flag
        parsed.status = next as RunStatus;
        i++;
        break;
      case "--stage":
        parsed.stage = next as LifecycleStage;
        i++;
        break;
      case "--risk":
        // Note: -r is reserved for standard --risk flag
        parsed.risk = next as RiskLevel;
        i++;
        break;
      case "--since":
        const since = parseDate(next);
        if (since) parsed.since = since;
        i++;
        break;
      case "--until":
        const until = parseDate(next);
        if (until) parsed.until = until;
        i++;
        break;
      case "--limit":
      case "-l":
        parsed.limit = parseInt(next, 10);
        i++;
        break;
      case "--offset":
        parsed.offset = parseInt(next, 10);
        i++;
        break;
      case "--format":
      case "-f":
        parsed.format = next as "json" | "text" | "table";
        i++;
        break;
      case "--trace":
        // Note: -t is reserved for standard --trace flag (boolean)
        parsed.traceId = next;
        i++;
        break;
      case "--idempotency-key":
      case "--idem-key":
        // Note: -i is reserved for standard --idempotency-key flag
        parsed.idempotencyKey = next;
        i++;
        break;
      case "--max-age":
        parsed.maxAge = next;
        i++;
        break;
      case "--dry-run":
      case "-n":
        parsed.dryRun = true;
        break;
      case "--export-format":
        parsed.exportFormat = next as "json" | "ndjson" | "otlp";
        i++;
        break;
      case "--output":
      case "-o":
        parsed.outputPath = next;
        i++;
        break;
      case "--collector-url":
        parsed.collectorUrl = next;
        i++;
        break;
      case "--runs-dir":
        parsed.runsDir = next;
        i++;
        break;
      case "--help":
      case "-h":
        parsed.help = true;
        break;
      case "--verbose":
      case "-v":
        parsed.verbose = true;
        break;
      default:
        // Positional argument (e.g., runId)
        if (!arg.startsWith("-") && !parsed.runId) {
          parsed.runId = arg;
        }
    }
  }

  return parsed;
}

/**
 * Convert parsed args to ListRunRecordsOptions.
 */
export function toListOptions(args: RunsCliArgs): ListRunRecordsOptions {
  return {
    kit: args.kit,
    status: args.status,
    stage: args.stage,
    risk: args.risk,
    since: args.since,
    until: args.until,
    limit: args.limit,
    offset: args.offset,
  };
}

// ============================================================================
// Output Formatting
// ============================================================================

/**
 * Format a date for display.
 */
function formatDate(isoDate: string): string {
  const date = new Date(isoDate);
  return date.toLocaleString();
}

/**
 * Format duration in milliseconds for display.
 */
function formatDuration(ms: number | undefined): string {
  if (ms === undefined) return "-";
  if (ms < 1000) return `${ms}ms`;
  if (ms < 60000) return `${(ms / 1000).toFixed(1)}s`;
  return `${(ms / 60000).toFixed(1)}m`;
}

/**
 * Truncate string to max length with ellipsis.
 */
function truncate(str: string, maxLen: number): string {
  if (str.length <= maxLen) return str;
  return str.slice(0, maxLen - 3) + "...";
}

/**
 * Pad or truncate string to exact width.
 */
function padTo(str: string, width: number): string {
  if (str.length >= width) return str.slice(0, width);
  return str + " ".repeat(width - str.length);
}

/**
 * Status badge with color hints.
 */
function statusBadge(status: RunStatus): string {
  return status === "success" ? "✓" : "✗";
}

/**
 * Risk level badge.
 */
function riskBadge(risk: RiskLevel): string {
  switch (risk) {
    case "trivial":
      return "T";
    case "low":
      return "L";
    case "medium":
      return "M";
    case "high":
      return "H";
    default:
      return "?";
  }
}

/**
 * Format run records as a table.
 */
export function formatRunRecordTable(summaries: RunRecordSummary[]): string {
  if (summaries.length === 0) {
    return "No run records found.";
  }

  const header = [
    padTo("STATUS", 6),
    padTo("KIT", 12),
    padTo("RISK", 4),
    padTo("STAGE", 10),
    padTo("DURATION", 8),
    padTo("CREATED", 20),
    "RUN ID",
  ].join(" ");

  const separator = "-".repeat(header.length);

  const rows = summaries.map((s) =>
    [
      padTo(statusBadge(s.status), 6),
      padTo(s.kit, 12),
      padTo(riskBadge(s.risk), 4),
      padTo(s.stage, 10),
      padTo(formatDuration(s.durationMs), 8),
      padTo(formatDate(s.createdAt), 20),
      truncate(s.runId, 40),
    ].join(" ")
  );

  return [header, separator, ...rows].join("\n");
}

/**
 * Format run records as text (one per line).
 */
export function formatRunRecordText(summaries: RunRecordSummary[]): string {
  if (summaries.length === 0) {
    return "No run records found.";
  }

  return summaries
    .map(
      (s) =>
        `${statusBadge(s.status)} ${s.runId} (${s.kit}) - ${s.summary}`
    )
    .join("\n");
}

/**
 * Format a single run record for detailed display.
 */
export function formatRunRecordDetail(record: RunRecord): string {
  const lines: string[] = [
    `Run ID:     ${record.runId}`,
    `Kit:        ${record.kit.name} v${record.kit.version}`,
    `Status:     ${record.status}`,
    `Stage:      ${record.stage}`,
    `Risk:       ${record.risk}`,
    `Created:    ${formatDate(record.createdAt)}`,
    `Duration:   ${formatDuration(record.durationMs)}`,
    `Trace ID:   ${record.telemetry.trace_id}`,
    `Summary:    ${record.summary}`,
  ];

  if (record.determinism?.idempotencyKey) {
    lines.push(`Idempotency: ${record.determinism.idempotencyKey}`);
  }

  if (record.determinism?.prompt_hash) {
    lines.push(`Prompt Hash: ${record.determinism.prompt_hash}`);
  }

  if (record.ai) {
    lines.push(`AI Config:  ${record.ai.provider}/${record.ai.model}`);
  }

  if (record.policy) {
    lines.push(`Policy:     ${record.policy.result}`);
  }

  if (record.artifacts && record.artifacts.length > 0) {
    lines.push(`Artifacts:  ${record.artifacts.length} file(s)`);
    for (const artifact of record.artifacts) {
      lines.push(`  - ${artifact.path} (${artifact.type})`);
    }
  }

  lines.push("");
  lines.push("Inputs:");
  lines.push(JSON.stringify(record.inputs, null, 2));

  return lines.join("\n");
}

/**
 * Format run record statistics for display.
 */
export function formatStats(stats: RunRecordStats): string {
  const lines: string[] = [
    `Total Runs: ${stats.totalRuns}`,
    "",
    "By Kit:",
    ...Object.entries(stats.byKit).map(
      ([kit, count]) => `  ${kit}: ${count}`
    ),
    "",
    "By Status:",
    ...Object.entries(stats.byStatus).map(
      ([status, count]) => `  ${status}: ${count}`
    ),
    "",
    "By Stage:",
    ...Object.entries(stats.byStage).map(
      ([stage, count]) => `  ${stage}: ${count}`
    ),
    "",
    "By Risk:",
    ...Object.entries(stats.byRisk).map(
      ([risk, count]) => `  ${risk}: ${count}`
    ),
    "",
    `Average Duration: ${formatDuration(stats.avgDurationMs)}`,
    `Total Duration:   ${formatDuration(stats.totalDurationMs)}`,
  ];

  if (stats.oldestRun) {
    lines.push(`Oldest Run:       ${stats.oldestRun}`);
  }
  if (stats.newestRun) {
    lines.push(`Newest Run:       ${stats.newestRun}`);
  }

  if (stats.period.since || stats.period.until) {
    lines.push("");
    lines.push("Period:");
    if (stats.period.since) {
      lines.push(`  Since: ${formatDate(stats.period.since)}`);
    }
    if (stats.period.until) {
      lines.push(`  Until: ${formatDate(stats.period.until)}`);
    }
  }

  return lines.join("\n");
}

/**
 * Format cleanup result for display.
 */
export function formatCleanupResult(result: CleanupResult): string {
  const lines: string[] = [
    result.dryRun ? "=== DRY RUN ===" : "=== CLEANUP COMPLETE ===",
    "",
    `Deleted:  ${result.deletedCount} record(s)`,
    `Retained: ${result.retainedCount} record(s)`,
    `Freed:    ${formatBytes(result.freedBytes)}`,
  ];

  if (Object.keys(result.deletedByKit).length > 0) {
    lines.push("");
    lines.push("Deleted by Kit:");
    for (const [kit, count] of Object.entries(result.deletedByKit)) {
      if (count > 0) {
        lines.push(`  ${kit}: ${count}`);
      }
    }
  }

  if (result.errors.length > 0) {
    lines.push("");
    lines.push("Errors:");
    for (const error of result.errors) {
      lines.push(`  ${error.path}: ${error.error}`);
    }
  }

  return lines.join("\n");
}

/**
 * Format export result for display.
 */
export function formatExportResult(result: ExportResult): string {
  const lines: string[] = [
    "=== EXPORT COMPLETE ===",
    "",
    `Exported: ${result.exportedCount} record(s)`,
    `Format:   ${result.format}`,
    `Duration: ${formatDuration(result.durationMs)}`,
  ];

  if (result.outputPath) {
    lines.push(`Output:   ${result.outputPath}`);
  }

  if (result.errors.length > 0) {
    lines.push("");
    lines.push("Errors:");
    for (const error of result.errors) {
      lines.push(`  ${error.runId}: ${error.error}`);
    }
  }

  return lines.join("\n");
}

/**
 * Format bytes for display.
 */
function formatBytes(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  if (bytes < 1024 * 1024 * 1024)
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  return `${(bytes / (1024 * 1024 * 1024)).toFixed(1)} GB`;
}

// ============================================================================
// Help Text
// ============================================================================

/**
 * Generate help text for runs CLI.
 */
export function getRunsCliHelp(kitName?: string): string {
  const cmd = kitName ? `${kitName} runs` : "kit-runs";

  return `
Usage: ${cmd} <command> [options]

Commands:
  list           List run records with filtering
  show           Show details of a specific run record
  stats          Show aggregate statistics
  find           Find run records by trace ID or idempotency key
  cleanup        Delete old run records based on retention policy
  export         Export run records to file or OTel collector
  rebuild-index  Rebuild the idempotency key index from run records
  help           Show this help message

Options:
  --kit, -k <name>         Filter by kit name
  --status <status>        Filter by status (success|failure)
  --stage <stage>          Filter by lifecycle stage
  --risk <level>           Filter by risk level (trivial|low|medium|high)
  --since <date>           Filter by creation date (ISO or "7d ago")
  --until <date>           Filter by creation date
  --limit, -l <n>          Maximum records to return
  --offset <n>             Skip first n records
  --format, -f <fmt>       Output format (json|text|table)
  --runs-dir <path>        Runs directory (default: ./runs)
  --help, -h               Show help
  --verbose, -v            Verbose output

Find Options:
  --trace <id>             Find by trace ID
  --idempotency-key <key>  Find by idempotency key (or --idem-key)

Cleanup Options:
  --max-age <duration>     Maximum age (e.g., 30d, 7d, 24h)
  --dry-run, -n            Preview without deleting

Export Options:
  --export-format <fmt>    Export format (json|ndjson|otlp)
  --output, -o <path>      Output file path
  --collector-url <url>    OTel collector URL

Examples:
  ${cmd} list --kit guardkit --limit 20
  ${cmd} show 2025-01-07T10-30-00Z-guardkit-a1b2
  ${cmd} stats --since "7d ago"
  ${cmd} find --trace abc123
  ${cmd} cleanup --max-age 30d --dry-run
  ${cmd} export --export-format ndjson -o backup.ndjson
  ${cmd} rebuild-index
`.trim();
}

// ============================================================================
// Rebuild Index Command
// ============================================================================

import { listRunRecords, readRunRecord, getRunsDirectory } from "./run-record.js";
import { IdempotencyIndexManager } from "./idempotency-index.js";

/**
 * Result of a rebuild-index operation.
 */
export interface RebuildIndexResult {
  /** Number of run records scanned */
  scanned: number;

  /** Number of records with idempotency keys indexed */
  indexed: number;

  /** Number of records without idempotency keys */
  skipped: number;

  /** Duration in milliseconds */
  durationMs: number;

  /** Index file path */
  indexPath: string;
}

/**
 * Rebuild the idempotency key index from existing run records.
 *
 * Use this to:
 * - Recover from a corrupted or missing index
 * - Migrate from O(n) scans to O(1) lookups
 * - Verify index consistency
 *
 * @param runsDir - The runs directory
 * @param verbose - Whether to log progress
 * @returns The rebuild result
 */
export function rebuildIdempotencyIndex(
  runsDir: string,
  verbose = false
): RebuildIndexResult {
  const startTime = Date.now();

  // Create a fresh index manager (will create new index file)
  const indexManager = new IdempotencyIndexManager({
    runsDir,
    autoPersist: false, // We'll persist at the end
  });

  // Clear any existing entries
  indexManager.clear();

  // List all run records
  const summaries = listRunRecords(runsDir, {});

  let scanned = 0;
  let indexed = 0;
  let skipped = 0;

  for (const summary of summaries) {
    scanned++;

    // Only process records that have an idempotency key
    if (!summary.idempotencyKey) {
      skipped++;
      continue;
    }

    // Load the full run record to index it
    const record = readRunRecord(runsDir, summary.path);
    if (record && record.determinism?.idempotencyKey) {
      indexManager.indexRunRecord(record, summary.path);
      indexed++;

      if (verbose) {
        console.log(
          `Indexed: ${record.determinism.idempotencyKey} -> ${summary.path}`
        );
      }
    } else {
      skipped++;
    }
  }

  // Persist the rebuilt index
  indexManager.persist();

  const durationMs = Date.now() - startTime;

  return {
    scanned,
    indexed,
    skipped,
    durationMs,
    indexPath: indexManager.getIndexPath(),
  };
}

/**
 * Format rebuild-index result for display.
 */
export function formatRebuildIndexResult(result: RebuildIndexResult): string {
  const lines: string[] = [
    "=== INDEX REBUILD COMPLETE ===",
    "",
    `Scanned:  ${result.scanned} run record(s)`,
    `Indexed:  ${result.indexed} record(s) with idempotency keys`,
    `Skipped:  ${result.skipped} record(s) without idempotency keys`,
    `Duration: ${result.durationMs}ms`,
    `Index:    ${result.indexPath}`,
  ];

  return lines.join("\n");
}


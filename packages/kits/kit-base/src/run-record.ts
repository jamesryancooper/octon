/**
 * Run record generation and query utilities for Harmony Kits.
 *
 * Run records capture the full context of a kit execution for:
 * - Reproducibility and debugging
 * - Governance and compliance
 * - Observability correlation
 * - Audit trails
 * - Durable idempotency
 */

import { randomUUID } from "node:crypto";
import {
  writeFileSync,
  mkdirSync,
  existsSync,
  readFileSync,
  readdirSync,
  statSync,
  unlinkSync,
} from "node:fs";
import { dirname, join, basename } from "node:path";
import type {
  LifecycleStage,
  RiskLevel,
  RunStatus,
  HITLCheckpoint,
} from "./types.js";

/**
 * Kit reference in a run record.
 */
export interface KitRef {
  name: string;
  version: string;
}

/**
 * AI configuration used in a run.
 */
export interface AIConfig {
  provider: string;
  model: string;
  version?: string;
  temperature?: number;
  top_p?: number;
  seed?: number | string;
}

/**
 * Artifact produced by a run.
 */
export interface RunArtifact {
  path: string;
  type: string;
  hash?: string;
}

/**
 * Policy check result.
 */
export interface PolicyResult {
  ruleset?: string;
  checked?: string[];
  result: "pass" | "fail";
}

/**
 * Evaluation result.
 */
export interface EvalResult {
  suite: string;
  score: number;
  threshold: number;
}

/**
 * Telemetry information.
 */
export interface TelemetryInfo {
  trace_id: string;
  spans?: string[];
}

/**
 * HITL checkpoint information.
 */
export interface HITLInfo {
  checkpoint: HITLCheckpoint;
  state: "approved" | "rejected" | "waived" | "pending";
  approver?: string;
  approvedAt?: string;
  justification?: string;
}

/**
 * Determinism tracking information.
 */
export interface DeterminismInfo {
  prompt_hash?: string;
  idempotencyKey?: string;
  inputsHash?: string;
  cacheKey?: string;
}

/**
 * Complete run record conforming to Harmony methodology v0.2.
 */
export interface RunRecord {
  /** Stable run identifier */
  runId: string;

  /** Kit that produced this record */
  kit: KitRef;

  /** Input parameters (secrets redacted) */
  inputs: Record<string, unknown>;

  /** AI configuration if used */
  ai?: AIConfig;

  /** Artifacts produced */
  artifacts?: RunArtifact[];

  /** Policy check results */
  policy?: PolicyResult;

  /** Evaluation results */
  eval?: EvalResult;

  /** Telemetry correlation */
  telemetry: TelemetryInfo;

  /** Run status */
  status: RunStatus;

  /** Human-readable summary */
  summary: string;

  /** Lifecycle stage */
  stage: LifecycleStage;

  /** Risk level */
  risk: RiskLevel;

  /** HITL checkpoint info */
  hitl?: HITLInfo;

  /** Determinism tracking */
  determinism?: DeterminismInfo;

  /** Operation outputs (for idempotency replay) */
  outputs?: unknown;

  /** ISO8601 timestamp */
  createdAt: string;

  /** Duration in milliseconds */
  durationMs?: number;
}

/**
 * Options for generating a run ID.
 */
export interface RunIdOptions {
  /** Kit name */
  kitName: string;

  /** Optional stable inputs for deterministic ID fragment */
  stableInputs?: string;

  /** Optional git SHA for correlation */
  gitSha?: string;
}

/**
 * Generate a stable, low-cardinality run ID.
 *
 * Format: `<ISO8601-UTC>-<kitName>-<shortId>`
 * Example: `2025-11-07T12-00-01Z-plankit-9f2c`
 */
export function generateRunId(options: RunIdOptions): string {
  const now = new Date();
  const timestamp = now.toISOString().replace(/[:.]/g, "-").slice(0, 19) + "Z";

  // Generate short stable ID from inputs if provided, otherwise use UUID fragment
  let shortId: string;
  if (options.stableInputs || options.gitSha) {
    const combined = `${options.stableInputs || ""}:${options.gitSha || ""}`;
    // Simple hash to 4 hex chars
    let hash = 0;
    for (let i = 0; i < combined.length; i++) {
      const char = combined.charCodeAt(i);
      hash = (hash << 5) - hash + char;
      hash = hash & hash; // Convert to 32bit integer
    }
    shortId = Math.abs(hash).toString(16).slice(0, 4).padStart(4, "0");
  } else {
    shortId = randomUUID().slice(0, 4);
  }

  return `${timestamp}-${options.kitName}-${shortId}`;
}

/**
 * Options for creating a run record.
 */
export interface CreateRunRecordOptions {
  /** Kit reference */
  kit: KitRef;

  /** Input parameters (will be sanitized) */
  inputs: Record<string, unknown>;

  /** Run status */
  status: RunStatus;

  /** Human-readable summary */
  summary: string;

  /** Lifecycle stage */
  stage: LifecycleStage;

  /** Risk level */
  risk: RiskLevel;

  /** Trace ID for correlation */
  traceId: string;

  /** AI configuration if used */
  ai?: AIConfig;

  /** Artifacts produced */
  artifacts?: RunArtifact[];

  /** Policy check results */
  policy?: PolicyResult;

  /** Evaluation results */
  eval?: EvalResult;

  /** Additional span names */
  spans?: string[];

  /** HITL checkpoint info */
  hitl?: HITLInfo;

  /** Determinism tracking */
  determinism?: DeterminismInfo;

  /** Operation outputs (for idempotency replay) */
  outputs?: unknown;

  /** Duration in milliseconds */
  durationMs?: number;

  /** Git SHA for run ID generation */
  gitSha?: string;
}

/**
 * Patterns that indicate sensitive keys to redact.
 */
const SENSITIVE_KEY_PATTERNS = [
  /api[_-]?key/i,
  /secret/i,
  /password/i,
  /token/i,
  /auth/i,
  /credential/i,
  /private[_-]?key/i,
  /access[_-]?key/i,
];

/**
 * Redact sensitive values from inputs.
 */
function redactSensitiveInputs(
  inputs: Record<string, unknown>
): Record<string, unknown> {
  const redacted: Record<string, unknown> = {};

  for (const [key, value] of Object.entries(inputs)) {
    const isSensitive = SENSITIVE_KEY_PATTERNS.some((pattern) =>
      pattern.test(key)
    );

    if (isSensitive) {
      redacted[key] = "<REDACTED>";
    } else if (typeof value === "object" && value !== null && !Array.isArray(value)) {
      redacted[key] = redactSensitiveInputs(value as Record<string, unknown>);
    } else {
      redacted[key] = value;
    }
  }

  return redacted;
}

/**
 * Create a run record conforming to Harmony methodology.
 */
export function createRunRecord(options: CreateRunRecordOptions): RunRecord {
  const runId = generateRunId({
    kitName: options.kit.name,
    stableInputs: JSON.stringify(options.inputs),
    gitSha: options.gitSha,
  });

  return {
    runId,
    kit: options.kit,
    inputs: redactSensitiveInputs(options.inputs),
    status: options.status,
    summary: options.summary,
    stage: options.stage,
    risk: options.risk,
    telemetry: {
      trace_id: options.traceId,
      spans: options.spans,
    },
    ...(options.ai && { ai: options.ai }),
    ...(options.artifacts && { artifacts: options.artifacts }),
    ...(options.policy && { policy: options.policy }),
    ...(options.eval && { eval: options.eval }),
    ...(options.hitl && { hitl: options.hitl }),
    ...(options.determinism && { determinism: options.determinism }),
    ...(options.outputs !== undefined && { outputs: options.outputs }),
    ...(options.durationMs !== undefined && { durationMs: options.durationMs }),
    createdAt: new Date().toISOString(),
  };
}

/**
 * Get the default runs directory for a workspace.
 */
export function getRunsDirectory(workspaceRoot: string): string {
  return join(workspaceRoot, "runs");
}

/**
 * Generate the file path for a run record.
 */
export function getRunRecordPath(runsDir: string, runId: string): string {
  // Extract kit name from runId for subdirectory organization
  const parts = runId.split("-");
  const kitName = parts.length >= 3 ? parts[parts.length - 2] : "unknown";

  return join(runsDir, kitName, `${runId}.json`);
}

/**
 * Result of a safe run record write operation.
 */
export interface WriteRunRecordResult {
  /** Whether the write succeeded */
  success: boolean;
  /** File path if successful */
  path?: string;
  /** Error message if failed */
  error?: string;
}

/**
 * Write a run record to disk.
 *
 * WARNING: This function throws on filesystem errors. For non-critical
 * run record writes (where failure shouldn't crash the main operation),
 * use `safeWriteRunRecord` instead.
 *
 * @throws {Error} If directory creation or file write fails
 */
export function writeRunRecord(
  record: RunRecord,
  outputDir: string
): string {
  const filePath = getRunRecordPath(outputDir, record.runId);
  const dir = dirname(filePath);

  // Ensure directory exists
  if (!existsSync(dir)) {
    mkdirSync(dir, { recursive: true });
  }

  writeFileSync(filePath, JSON.stringify(record, null, 2));

  return filePath;
}

/**
 * Safely write a run record to disk without throwing.
 *
 * This is the recommended function for kit implementations where
 * run record writing is a best-effort operation that shouldn't
 * cause the main operation to fail.
 *
 * Filesystem errors (permissions, disk full, etc.) are caught and
 * logged as warnings. The main kit operation continues regardless.
 *
 * @returns Result object with success status, path, and any error message
 */
export function safeWriteRunRecord(
  record: RunRecord,
  outputDir: string
): WriteRunRecordResult {
  try {
    const path = writeRunRecord(record, outputDir);
    return { success: true, path };
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);

    // Log warning but don't throw - run records are best-effort
    console.warn(
      `[kit-base] Failed to write run record ${record.runId}: ${message}`
    );

    return { success: false, error: message };
  }
}

/**
 * Format a run record as a one-line JSON summary for stdout.
 */
export function formatRunSummary(record: RunRecord): string {
  return JSON.stringify({
    status: record.status,
    summary: record.summary,
    runId: record.runId,
    traceId: record.telemetry.trace_id,
  });
}

// ============================================================================
// Read Path - Query and Retrieval
// ============================================================================

/**
 * Options for listing run records with filtering, sorting, and pagination.
 */
export interface ListRunRecordsOptions {
  /** Filter by kit name */
  kit?: string;
  /** Filter by status */
  status?: RunStatus;
  /** Filter by lifecycle stage */
  stage?: LifecycleStage;
  /** Filter by risk level */
  risk?: RiskLevel;
  /** Filter records created after this date */
  since?: Date;
  /** Filter records created before this date */
  until?: Date;
  /** Maximum number of records to return */
  limit?: number;
  /** Number of records to skip (for pagination) */
  offset?: number;
  /** Field to sort by */
  sortBy?: "createdAt" | "durationMs";
  /** Sort order */
  sortOrder?: "asc" | "desc";
}

/**
 * Summary of a run record for list views.
 */
export interface RunRecordSummary {
  /** Run identifier */
  runId: string;
  /** Kit name */
  kit: string;
  /** Run status */
  status: RunStatus;
  /** Lifecycle stage */
  stage: LifecycleStage;
  /** Risk level */
  risk: RiskLevel;
  /** Human-readable summary */
  summary: string;
  /** ISO8601 creation timestamp */
  createdAt: string;
  /** Duration in milliseconds */
  durationMs?: number;
  /** Trace ID for correlation */
  traceId: string;
  /** Idempotency key if present */
  idempotencyKey?: string;
  /** File path to the run record */
  path: string;
}

/**
 * Aggregate statistics for run records.
 */
export interface RunRecordStats {
  /** Total number of runs */
  totalRuns: number;
  /** Count by kit name */
  byKit: Record<string, number>;
  /** Count by status */
  byStatus: Record<string, number>;
  /** Count by lifecycle stage */
  byStage: Record<string, number>;
  /** Count by risk level */
  byRisk: Record<string, number>;
  /** Average duration in milliseconds */
  avgDurationMs: number;
  /** Total duration in milliseconds */
  totalDurationMs: number;
  /** Oldest run ID */
  oldestRun?: string;
  /** Newest run ID */
  newestRun?: string;
  /** Filter period applied */
  period: { since?: string; until?: string };
}

/**
 * Result of reading a run record.
 */
export interface ReadRunRecordResult {
  /** Whether the read succeeded */
  success: boolean;
  /** The run record if successful */
  record?: RunRecord;
  /** Error message if failed */
  error?: string;
}

/**
 * Read a run record from disk by ID or path.
 *
 * @param runsDir - The runs directory
 * @param runIdOrPath - Either a run ID or a full file path
 * @returns The run record or null if not found
 */
export function readRunRecord(
  runsDir: string,
  runIdOrPath: string
): RunRecord | null {
  const filePath = runIdOrPath.endsWith(".json")
    ? runIdOrPath
    : getRunRecordPath(runsDir, runIdOrPath);

  if (!existsSync(filePath)) {
    return null;
  }

  try {
    const content = readFileSync(filePath, "utf-8");
    return JSON.parse(content) as RunRecord;
  } catch {
    return null;
  }
}

/**
 * Safely read a run record without throwing.
 */
export function safeReadRunRecord(
  runsDir: string,
  runIdOrPath: string
): ReadRunRecordResult {
  try {
    const record = readRunRecord(runsDir, runIdOrPath);
    if (record) {
      return { success: true, record };
    }
    return { success: false, error: "Run record not found" };
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return { success: false, error: message };
  }
}

/**
 * Load a run record from a relative path within the runs directory.
 *
 * @param runsDir - The runs directory
 * @param relativePath - Path relative to the runs directory (e.g., "flowkit/2024-01-01/run-abc.json")
 * @returns The run record or null if not found
 */
export function loadRunRecordFromPath(
  runsDir: string,
  relativePath: string
): RunRecord | null {
  const fullPath = join(runsDir, relativePath);

  if (!existsSync(fullPath)) {
    return null;
  }

  try {
    const content = readFileSync(fullPath, "utf-8");
    return JSON.parse(content) as RunRecord;
  } catch {
    return null;
  }
}

/**
 * List all kit subdirectories in the runs directory.
 */
function listKitDirectories(runsDir: string): string[] {
  if (!existsSync(runsDir)) {
    return [];
  }

  try {
    return readdirSync(runsDir, { withFileTypes: true })
      .filter((dirent) => dirent.isDirectory())
      .map((dirent) => dirent.name);
  } catch {
    return [];
  }
}

/**
 * List all run record files in a kit directory.
 */
function listRunRecordFiles(kitDir: string): string[] {
  if (!existsSync(kitDir)) {
    return [];
  }

  try {
    return readdirSync(kitDir, { withFileTypes: true })
      .filter((dirent) => dirent.isFile() && dirent.name.endsWith(".json"))
      .map((dirent) => join(kitDir, dirent.name));
  } catch {
    return [];
  }
}

/**
 * Convert a run record to a summary.
 */
function toRunRecordSummary(record: RunRecord, path: string): RunRecordSummary {
  return {
    runId: record.runId,
    kit: record.kit.name,
    status: record.status,
    stage: record.stage,
    risk: record.risk,
    summary: record.summary,
    createdAt: record.createdAt,
    durationMs: record.durationMs,
    traceId: record.telemetry.trace_id,
    idempotencyKey: record.determinism?.idempotencyKey,
    path,
  };
}

/**
 * Check if a run record matches the filter options.
 */
function matchesFilter(
  record: RunRecord,
  options: ListRunRecordsOptions
): boolean {
  if (options.kit && record.kit.name !== options.kit) {
    return false;
  }
  if (options.status && record.status !== options.status) {
    return false;
  }
  if (options.stage && record.stage !== options.stage) {
    return false;
  }
  if (options.risk && record.risk !== options.risk) {
    return false;
  }
  if (options.since) {
    const recordDate = new Date(record.createdAt);
    if (recordDate < options.since) {
      return false;
    }
  }
  if (options.until) {
    const recordDate = new Date(record.createdAt);
    if (recordDate > options.until) {
      return false;
    }
  }
  return true;
}

/**
 * List run records with filtering, sorting, and pagination.
 *
 * @param runsDir - The runs directory
 * @param options - Filter, sort, and pagination options
 * @returns Array of run record summaries
 */
export function listRunRecords(
  runsDir: string,
  options: ListRunRecordsOptions = {}
): RunRecordSummary[] {
  const kitDirs = options.kit
    ? [join(runsDir, options.kit)]
    : listKitDirectories(runsDir).map((kit) => join(runsDir, kit));

  const summaries: RunRecordSummary[] = [];

  for (const kitDir of kitDirs) {
    const files = listRunRecordFiles(kitDir);
    for (const filePath of files) {
      const record = readRunRecord(runsDir, filePath);
      if (record && matchesFilter(record, options)) {
        summaries.push(toRunRecordSummary(record, filePath));
      }
    }
  }

  // Sort
  const sortBy = options.sortBy ?? "createdAt";
  const sortOrder = options.sortOrder ?? "desc";
  summaries.sort((a, b) => {
    let comparison = 0;
    if (sortBy === "createdAt") {
      comparison =
        new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime();
    } else if (sortBy === "durationMs") {
      comparison = (a.durationMs ?? 0) - (b.durationMs ?? 0);
    }
    return sortOrder === "asc" ? comparison : -comparison;
  });

  // Pagination
  const offset = options.offset ?? 0;
  const limit = options.limit ?? summaries.length;
  return summaries.slice(offset, offset + limit);
}

/**
 * Get aggregate statistics for run records.
 *
 * @param runsDir - The runs directory
 * @param options - Filter options (kit, since, until)
 * @returns Aggregate statistics
 */
export function getRunRecordStats(
  runsDir: string,
  options: Pick<ListRunRecordsOptions, "kit" | "since" | "until"> = {}
): RunRecordStats {
  const summaries = listRunRecords(runsDir, options);

  const stats: RunRecordStats = {
    totalRuns: summaries.length,
    byKit: {},
    byStatus: {},
    byStage: {},
    byRisk: {},
    avgDurationMs: 0,
    totalDurationMs: 0,
    period: {
      since: options.since?.toISOString(),
      until: options.until?.toISOString(),
    },
  };

  let durationsCount = 0;

  for (const summary of summaries) {
    // By kit
    stats.byKit[summary.kit] = (stats.byKit[summary.kit] ?? 0) + 1;

    // By status
    stats.byStatus[summary.status] = (stats.byStatus[summary.status] ?? 0) + 1;

    // By stage
    stats.byStage[summary.stage] = (stats.byStage[summary.stage] ?? 0) + 1;

    // By risk
    stats.byRisk[summary.risk] = (stats.byRisk[summary.risk] ?? 0) + 1;

    // Duration
    if (summary.durationMs !== undefined) {
      stats.totalDurationMs += summary.durationMs;
      durationsCount++;
    }

    // Track oldest/newest
    if (!stats.oldestRun || summary.createdAt < stats.oldestRun) {
      stats.oldestRun = summary.runId;
    }
    if (!stats.newestRun || summary.createdAt > stats.newestRun) {
      stats.newestRun = summary.runId;
    }
  }

  if (durationsCount > 0) {
    stats.avgDurationMs = Math.round(stats.totalDurationMs / durationsCount);
  }

  return stats;
}

/**
 * Find a run record by trace ID.
 *
 * @param runsDir - The runs directory
 * @param traceId - The trace ID to search for
 * @returns The run record or null if not found
 */
export function findRunRecordByTraceId(
  runsDir: string,
  traceId: string
): RunRecord | null {
  const kitDirs = listKitDirectories(runsDir).map((kit) =>
    join(runsDir, kit)
  );

  for (const kitDir of kitDirs) {
    const files = listRunRecordFiles(kitDir);
    for (const filePath of files) {
      const record = readRunRecord(runsDir, filePath);
      if (record && record.telemetry.trace_id === traceId) {
        return record;
      }
    }
  }

  return null;
}

/**
 * Find a run record by idempotency key.
 *
 * @param runsDir - The runs directory
 * @param idempotencyKey - The idempotency key to search for
 * @returns The run record or null if not found
 */
export function findRunRecordByIdempotencyKey(
  runsDir: string,
  idempotencyKey: string
): RunRecord | null {
  const kitDirs = listKitDirectories(runsDir).map((kit) =>
    join(runsDir, kit)
  );

  for (const kitDir of kitDirs) {
    const files = listRunRecordFiles(kitDir);
    for (const filePath of files) {
      const record = readRunRecord(runsDir, filePath);
      if (record && record.determinism?.idempotencyKey === idempotencyKey) {
        return record;
      }
    }
  }

  return null;
}

/**
 * Find run records by inputs hash (for idempotency verification).
 *
 * @param runsDir - The runs directory
 * @param inputsHash - The inputs hash to search for
 * @returns Array of matching run records
 */
export function findRunRecordsByInputsHash(
  runsDir: string,
  inputsHash: string
): RunRecord[] {
  const results: RunRecord[] = [];
  const kitDirs = listKitDirectories(runsDir).map((kit) =>
    join(runsDir, kit)
  );

  for (const kitDir of kitDirs) {
    const files = listRunRecordFiles(kitDir);
    for (const filePath of files) {
      const record = readRunRecord(runsDir, filePath);
      if (
        record &&
        record.determinism?.idempotencyKey?.includes(inputsHash)
      ) {
        results.push(record);
      }
    }
  }

  return results;
}

// ============================================================================
// Retention and Cleanup
// ============================================================================

/**
 * Retention policy for run records.
 */
export interface RetentionPolicy {
  /** Maximum age in milliseconds (e.g., 30 days = 30 * 24 * 60 * 60 * 1000) */
  maxAgeMs: number;
  /** Maximum count per kit (optional) */
  maxCountPerKit?: number;
  /** Keep failures longer than successes */
  keepFailures?: boolean;
  /** Keep high-risk runs longer */
  keepHighRisk?: boolean;
  /** Multiplier for failure retention (e.g., 2 = 2x normal retention) */
  failureMultiplier?: number;
  /** Multiplier for high-risk retention (e.g., 3 = 3x normal retention) */
  highRiskMultiplier?: number;
}

/**
 * Result of a cleanup operation.
 */
export interface CleanupResult {
  /** Number of records deleted */
  deletedCount: number;
  /** Records deleted by kit */
  deletedByKit: Record<string, number>;
  /** Number of records retained */
  retainedCount: number;
  /** Bytes freed (approximate) */
  freedBytes: number;
  /** Whether this was a dry run */
  dryRun: boolean;
  /** Errors encountered */
  errors: Array<{ path: string; error: string }>;
}

/**
 * Disk usage information for run records.
 */
export interface DiskUsage {
  /** Total bytes used */
  totalBytes: number;
  /** Bytes by kit */
  byKit: Record<string, number>;
  /** File count by kit */
  fileCountByKit: Record<string, number>;
  /** Total file count */
  totalFiles: number;
}

/**
 * Calculate disk usage for run records.
 *
 * @param runsDir - The runs directory
 * @returns Disk usage statistics
 */
export function getRunRecordDiskUsage(runsDir: string): DiskUsage {
  const usage: DiskUsage = {
    totalBytes: 0,
    byKit: {},
    fileCountByKit: {},
    totalFiles: 0,
  };

  const kitDirs = listKitDirectories(runsDir);

  for (const kit of kitDirs) {
    const kitDir = join(runsDir, kit);
    const files = listRunRecordFiles(kitDir);
    usage.byKit[kit] = 0;
    usage.fileCountByKit[kit] = files.length;
    usage.totalFiles += files.length;

    for (const filePath of files) {
      try {
        const stats = statSync(filePath);
        usage.byKit[kit] += stats.size;
        usage.totalBytes += stats.size;
      } catch {
        // Ignore stat errors
      }
    }
  }

  return usage;
}

/**
 * Clean up run records according to a retention policy.
 *
 * @param runsDir - The runs directory
 * @param policy - Retention policy to apply
 * @param dryRun - If true, don't actually delete files
 * @returns Cleanup result with counts and any errors
 */
export function cleanupRunRecords(
  runsDir: string,
  policy: RetentionPolicy,
  dryRun: boolean = false
): CleanupResult {
  const result: CleanupResult = {
    deletedCount: 0,
    deletedByKit: {},
    retainedCount: 0,
    freedBytes: 0,
    dryRun,
    errors: [],
  };

  const now = Date.now();
  const kitDirs = listKitDirectories(runsDir);

  for (const kit of kitDirs) {
    const kitDir = join(runsDir, kit);
    const files = listRunRecordFiles(kitDir);
    result.deletedByKit[kit] = 0;

    // Sort by creation date (newest first) for count-based retention
    const recordsWithMeta: Array<{
      path: string;
      record: RunRecord;
      size: number;
    }> = [];

    for (const filePath of files) {
      const record = readRunRecord(runsDir, filePath);
      if (!record) continue;

      try {
        const stats = statSync(filePath);
        recordsWithMeta.push({ path: filePath, record, size: stats.size });
      } catch {
        recordsWithMeta.push({ path: filePath, record, size: 0 });
      }
    }

    // Sort by createdAt descending (newest first)
    recordsWithMeta.sort(
      (a, b) =>
        new Date(b.record.createdAt).getTime() -
        new Date(a.record.createdAt).getTime()
    );

    let countKept = 0;

    for (const { path: filePath, record, size } of recordsWithMeta) {
      const recordAge = now - new Date(record.createdAt).getTime();

      // Calculate effective max age based on record properties
      let effectiveMaxAge = policy.maxAgeMs;
      if (policy.keepFailures && record.status === "failure") {
        effectiveMaxAge *= policy.failureMultiplier ?? 2;
      }
      if (policy.keepHighRisk && record.risk === "high") {
        effectiveMaxAge *= policy.highRiskMultiplier ?? 3;
      }

      const exceedsAge = recordAge > effectiveMaxAge;
      const exceedsCount =
        policy.maxCountPerKit !== undefined &&
        countKept >= policy.maxCountPerKit;

      if (exceedsAge || exceedsCount) {
        // Delete
        if (!dryRun) {
          try {
            unlinkSync(filePath);
          } catch (error) {
            result.errors.push({
              path: filePath,
              error: error instanceof Error ? error.message : String(error),
            });
            continue;
          }
        }
        result.deletedCount++;
        result.deletedByKit[kit]++;
        result.freedBytes += size;
      } else {
        // Retain
        result.retainedCount++;
        countKept++;
      }
    }
  }

  return result;
}

// ============================================================================
// Export Utilities
// ============================================================================

/**
 * Export format for run records.
 */
export type ExportFormat = "json" | "ndjson" | "otlp";

/**
 * Export destination for run records.
 */
export type ExportDestination = "stdout" | "file" | "otel-collector";

/**
 * Options for exporting run records.
 */
export interface ExportOptions {
  /** Export format */
  format: ExportFormat;
  /** Export destination */
  destination: ExportDestination;
  /** Output file path (for file destination) */
  outputPath?: string;
  /** OTel collector URL (for otel-collector destination) */
  collectorUrl?: string;
  /** Filter options */
  filter?: ListRunRecordsOptions;
  /** Batch size for streaming exports */
  batchSize?: number;
}

/**
 * Result of an export operation.
 */
export interface ExportResult {
  /** Number of records exported */
  exportedCount: number;
  /** Export format used */
  format: ExportFormat;
  /** Export destination used */
  destination: ExportDestination;
  /** Output file path if applicable */
  outputPath?: string;
  /** Duration in milliseconds */
  durationMs: number;
  /** Errors encountered */
  errors: Array<{ runId: string; error: string }>;
}

/**
 * Stream run records as an async generator.
 *
 * @param runsDir - The runs directory
 * @param options - Filter options
 * @yields Run records one at a time
 */
export async function* streamRunRecords(
  runsDir: string,
  options: ListRunRecordsOptions = {}
): AsyncGenerator<RunRecord, void, unknown> {
  const kitDirs = options.kit
    ? [join(runsDir, options.kit)]
    : listKitDirectories(runsDir).map((kit) => join(runsDir, kit));

  for (const kitDir of kitDirs) {
    const files = listRunRecordFiles(kitDir);
    for (const filePath of files) {
      const record = readRunRecord(runsDir, filePath);
      if (record && matchesFilter(record, options)) {
        yield record;
      }
    }
  }
}

/**
 * Convert a run record to OTLP log record format.
 *
 * @param record - The run record to convert
 * @returns OTLP log record structure
 */
export function toOtlpLogRecord(record: RunRecord): Record<string, unknown> {
  return {
    timeUnixNano: new Date(record.createdAt).getTime() * 1_000_000,
    severityNumber: record.status === "success" ? 9 : 17, // INFO or ERROR
    severityText: record.status === "success" ? "INFO" : "ERROR",
    body: {
      stringValue: record.summary,
    },
    attributes: [
      { key: "run.id", value: { stringValue: record.runId } },
      { key: "kit.name", value: { stringValue: record.kit.name } },
      { key: "kit.version", value: { stringValue: record.kit.version } },
      { key: "stage", value: { stringValue: record.stage } },
      { key: "risk", value: { stringValue: record.risk } },
      { key: "status", value: { stringValue: record.status } },
      ...(record.durationMs !== undefined
        ? [{ key: "duration_ms", value: { intValue: record.durationMs } }]
        : []),
      ...(record.determinism?.idempotencyKey
        ? [
            {
              key: "idempotency_key",
              value: { stringValue: record.determinism.idempotencyKey },
            },
          ]
        : []),
      ...(record.determinism?.prompt_hash
        ? [
            {
              key: "prompt_hash",
              value: { stringValue: record.determinism.prompt_hash },
            },
          ]
        : []),
    ],
    traceId: record.telemetry.trace_id,
    spanId: record.telemetry.spans?.[0],
  };
}

/**
 * Export run records to various destinations.
 *
 * @param runsDir - The runs directory
 * @param options - Export options
 * @returns Export result
 */
export async function exportRunRecords(
  runsDir: string,
  options: ExportOptions
): Promise<ExportResult> {
  const startTime = Date.now();
  const result: ExportResult = {
    exportedCount: 0,
    format: options.format,
    destination: options.destination,
    outputPath: options.outputPath,
    durationMs: 0,
    errors: [],
  };

  const records: RunRecord[] = [];

  // Collect records
  for await (const record of streamRunRecords(runsDir, options.filter)) {
    records.push(record);
    result.exportedCount++;
  }

  // Format output
  let output: string;
  switch (options.format) {
    case "json":
      output = JSON.stringify(records, null, 2);
      break;
    case "ndjson":
      output = records.map((r) => JSON.stringify(r)).join("\n");
      break;
    case "otlp":
      const otlpRecords = records.map(toOtlpLogRecord);
      output = JSON.stringify(
        {
          resourceLogs: [
            {
              resource: {
                attributes: [
                  {
                    key: "service.name",
                    value: { stringValue: "harmony.kits" },
                  },
                ],
              },
              scopeLogs: [
                {
                  scope: { name: "harmony.kit-base.run-records" },
                  logRecords: otlpRecords,
                },
              ],
            },
          ],
        },
        null,
        2
      );
      break;
  }

  // Write to destination
  switch (options.destination) {
    case "stdout":
      console.log(output);
      break;
    case "file":
      if (options.outputPath) {
        const dir = dirname(options.outputPath);
        if (!existsSync(dir)) {
          mkdirSync(dir, { recursive: true });
        }
        writeFileSync(options.outputPath, output);
        result.outputPath = options.outputPath;
      }
      break;
    case "otel-collector":
      if (options.collectorUrl && options.format === "otlp") {
        try {
          const response = await fetch(`${options.collectorUrl}/v1/logs`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: output,
          });
          if (!response.ok) {
            result.errors.push({
              runId: "*",
              error: `OTel collector returned ${response.status}`,
            });
          }
        } catch (error) {
          result.errors.push({
            runId: "*",
            error: error instanceof Error ? error.message : String(error),
          });
        }
      }
      break;
  }

  result.durationMs = Date.now() - startTime;
  return result;
}


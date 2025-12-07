/**
 * Run record generation utilities for Harmony Kits.
 *
 * Run records capture the full context of a kit execution for:
 * - Reproducibility and debugging
 * - Governance and compliance
 * - Observability correlation
 */

import { randomUUID } from "node:crypto";
import { writeFileSync, mkdirSync, existsSync } from "node:fs";
import { dirname, join } from "node:path";
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
 * Write a run record to disk.
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


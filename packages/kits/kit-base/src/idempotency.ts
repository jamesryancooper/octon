/**
 * Idempotency key management for Harmony Kits.
 *
 * Provides utilities for generating, validating, and tracking idempotency keys
 * to ensure deterministic, repeatable operations.
 *
 * Supports pluggable storage backends:
 * - In-memory (default, single process)
 * - Run records (durable, survives restarts)
 */

import { createHash, randomUUID } from "node:crypto";
import { IdempotencyConflictError } from "./errors.js";
import type { LifecycleStage } from "./types.js";
import {
  findRunRecordByIdempotencyKey,
  getRunsDirectory,
  loadRunRecordFromPath,
  type RunRecord,
} from "./run-record.js";
import { IdempotencyIndexManager } from "./idempotency-index.js";

// ============================================================================
// Types
// ============================================================================

/**
 * Configuration for idempotency key derivation.
 */
export interface IdempotencyKeyConfig {
  /** Kit name */
  kitName: string;

  /** Operation name */
  operation: string;

  /** Stable inputs to hash (should exclude timestamps and random values) */
  stableInputs: Record<string, unknown>;

  /** Git SHA for additional stability */
  gitSha?: string;

  /** Lifecycle stage */
  stage?: LifecycleStage;
}

/**
 * State of an idempotency record.
 */
export type IdempotencyState = "pending" | "completed" | "failed";

/**
 * Stored idempotency record.
 */
export interface IdempotencyRecord<T = unknown> {
  /** The idempotency key */
  key: string;

  /** When the record was created */
  createdAt: string;

  /** When the operation completed (if completed) */
  completedAt?: string;

  /** Current state */
  state: IdempotencyState;

  /** Kit that created the record */
  kitName: string;

  /** Operation name */
  operation: string;

  /** Run ID associated with this operation */
  runId?: string;

  /** Hash of the inputs for verification */
  inputsHash: string;

  /** Cached result from completed operation */
  cachedResult?: T;
}

/**
 * Options for IdempotencyManager.
 */
export interface IdempotencyManagerOptions {
  /** Time-to-live for pending records in milliseconds (default: 1 hour) */
  pendingTtlMs?: number;

  /** Time-to-live for completed records in milliseconds (default: 24 hours) */
  completedTtlMs?: number;

  /** Storage backend (default: in-memory) */
  storage?: IdempotencyStorage;
}

// ============================================================================
// Storage Abstraction
// ============================================================================

/**
 * Storage backend interface for idempotency records.
 *
 * Implementations can use different storage mechanisms:
 * - In-memory (default, single process)
 * - Run records (file-based, durable)
 * - Redis, database, etc. (external, distributed)
 */
export interface IdempotencyStorage {
  /**
   * Get an idempotency record by key.
   */
  get<T>(key: string): IdempotencyRecord<T> | null;

  /**
   * Set an idempotency record.
   */
  set(key: string, record: IdempotencyRecord<unknown>): void;

  /**
   * Delete an idempotency record.
   */
  delete(key: string): void;

  /**
   * Check if a record exists.
   */
  has(key: string): boolean;

  /**
   * Clear all records (for testing).
   */
  clear(): void;

  /**
   * Clean up expired records.
   */
  cleanupExpired(pendingTtlMs: number, completedTtlMs: number): void;
}

/**
 * In-memory storage backend for idempotency records.
 *
 * Suitable for single-process scenarios and testing.
 * Records are lost when the process exits.
 */
export class InMemoryIdempotencyStorage implements IdempotencyStorage {
  private records = new Map<string, IdempotencyRecord<unknown>>();

  get<T>(key: string): IdempotencyRecord<T> | null {
    const record = this.records.get(key);
    return record ? (record as IdempotencyRecord<T>) : null;
  }

  set(key: string, record: IdempotencyRecord<unknown>): void {
    this.records.set(key, record);
  }

  delete(key: string): void {
    this.records.delete(key);
  }

  has(key: string): boolean {
    return this.records.has(key);
  }

  clear(): void {
    this.records.clear();
  }

  cleanupExpired(pendingTtlMs: number, completedTtlMs: number): void {
    const now = Date.now();

    for (const [key, record] of this.records) {
      const createdAt = new Date(record.createdAt).getTime();
      const completedAt = record.completedAt
        ? new Date(record.completedAt).getTime()
        : null;

      if (record.state === "pending") {
        if (now - createdAt > pendingTtlMs) {
          this.records.delete(key);
        }
      } else if (record.state === "completed" || record.state === "failed") {
        const referenceTime = completedAt || createdAt;
        if (now - referenceTime > completedTtlMs) {
          this.records.delete(key);
        }
      }
    }
  }
}

/**
 * Run record-backed storage for idempotency records.
 *
 * Uses run records as a durable store for idempotency state.
 * Records persist across process restarts.
 *
 * Performance:
 * - Uses an index file for O(1) lookups instead of O(n) file scans
 * - Index is automatically maintained on write
 * - Fallback to file scan if index is corrupted or missing entry
 *
 * Behavior:
 * - On get: O(1) lookup via index, then load run record
 * - On set: Stores in memory (actual run record written by kit)
 * - Pending operations: In-memory only (not durable)
 * - Completed operations: Backed by run records on disk
 */
export class RunRecordIdempotencyStorage implements IdempotencyStorage {
  private runsDir: string;
  // In-memory cache for pending operations (not yet in run records)
  private pendingCache = new Map<string, IdempotencyRecord<unknown>>();
  // Index manager for O(1) lookups
  private indexManager: IdempotencyIndexManager | null = null;

  constructor(runsDir?: string) {
    this.runsDir = runsDir || getRunsDirectory(process.cwd());
  }

  /**
   * Get or create the index manager lazily.
   */
  private getIndexManager(): IdempotencyIndexManager {
    if (!this.indexManager) {
      this.indexManager = new IdempotencyIndexManager({ runsDir: this.runsDir });
    }
    return this.indexManager;
  }

  get<T>(key: string): IdempotencyRecord<T> | null {
    // First check pending cache
    const pending = this.pendingCache.get(key);
    if (pending) {
      return pending as IdempotencyRecord<T>;
    }

    // O(1) lookup via index
    const index = this.getIndexManager();
    const entry = index.get(key);

    if (entry) {
      // Load run record from path in index
      const runRecord = loadRunRecordFromPath(this.runsDir, entry.runRecordPath);
      if (runRecord) {
        return this.runRecordToIdempotencyRecord<T>(runRecord);
      }
      // Index entry exists but run record is missing - clean up index
      index.delete(key);
    }

    // Fallback to file scan (for backward compatibility or corrupted index)
    const runRecord = findRunRecordByIdempotencyKey(this.runsDir, key);
    if (runRecord) {
      return this.runRecordToIdempotencyRecord<T>(runRecord);
    }

    return null;
  }

  set(key: string, record: IdempotencyRecord<unknown>): void {
    // Pending operations go to cache
    // Completed operations will be persisted via run records
    if (record.state === "pending") {
      this.pendingCache.set(key, record);
    } else {
      // Remove from pending cache when completed/failed
      this.pendingCache.delete(key);
      // Note: The actual run record is written by the kit, not here
      // The index is updated via indexRunRecord() when the run record is written
    }
  }

  delete(key: string): void {
    this.pendingCache.delete(key);
    // Note: We don't delete run records - they're append-only audit logs
    // But we do remove from index for lookup purposes
    this.getIndexManager().delete(key);
  }

  has(key: string): boolean {
    if (this.pendingCache.has(key)) {
      return true;
    }

    // O(1) check via index
    const index = this.getIndexManager();
    if (index.has(key)) {
      return true;
    }

    // Fallback to file scan
    const runRecord = findRunRecordByIdempotencyKey(this.runsDir, key);
    return runRecord !== null;
  }

  clear(): void {
    this.pendingCache.clear();
    // Note: We don't clear run records - they're append-only audit logs
    // But we do clear the index
    this.getIndexManager().clear();
  }

  cleanupExpired(pendingTtlMs: number, completedTtlMs: number): void {
    // Clean up pending cache
    const now = Date.now();
    for (const [key, record] of this.pendingCache) {
      const createdAt = new Date(record.createdAt).getTime();
      if (now - createdAt > pendingTtlMs) {
        this.pendingCache.delete(key);
      }
    }

    // Clean up expired index entries
    this.getIndexManager().cleanupExpired(completedTtlMs);
  }

  /**
   * Index a run record for O(1) lookups.
   *
   * Call this after writing a run record with an idempotency key.
   */
  indexRunRecord(runRecord: RunRecord, runRecordPath: string): void {
    this.getIndexManager().indexRunRecord(runRecord, runRecordPath);
  }

  /**
   * Get the index manager for external use (e.g., rebuild command).
   */
  getIndex(): IdempotencyIndexManager {
    return this.getIndexManager();
  }

  /**
   * Convert a run record to an idempotency record.
   */
  private runRecordToIdempotencyRecord<T>(
    runRecord: RunRecord
  ): IdempotencyRecord<T> {
    // Extract result from run record outputs if available
    const cachedResult = (runRecord as RunRecordWithOutputs).outputs as
      | T
      | undefined;

    return {
      key: runRecord.determinism?.idempotencyKey || "",
      createdAt: runRecord.createdAt,
      completedAt: runRecord.createdAt, // Run records are written on completion
      state: runRecord.status === "success" ? "completed" : "failed",
      kitName: runRecord.kit.name,
      operation: this.extractOperation(runRecord),
      runId: runRecord.runId,
      inputsHash: this.extractInputsHash(runRecord),
      cachedResult,
    };
  }

  /**
   * Extract operation name from run record.
   */
  private extractOperation(runRecord: RunRecord): string {
    // Try to extract from telemetry spans
    const spans = runRecord.telemetry.spans;
    if (spans && spans.length > 0) {
      // Span format: kit.<kitName>.<operation>
      const parts = spans[0].split(".");
      if (parts.length >= 3) {
        return parts[2];
      }
    }
    // Fallback to kit name
    return runRecord.kit.name;
  }

  /**
   * Extract inputs hash from run record.
   */
  private extractInputsHash(runRecord: RunRecord): string {
    // If we have the inputs hash stored in determinism, use it
    const determinismAny = runRecord.determinism as
      | (typeof runRecord.determinism & { inputsHash?: string })
      | undefined;
    if (determinismAny?.inputsHash) {
      return determinismAny.inputsHash;
    }
    // Otherwise, hash the inputs
    return hashInputs(runRecord.inputs);
  }
}

/**
 * Extended run record interface with outputs field.
 */
interface RunRecordWithOutputs extends RunRecord {
  outputs?: unknown;
}

// ============================================================================
// Key Generation
// ============================================================================

/**
 * Derive a stable idempotency key from configuration.
 *
 * The key is derived from:
 * - Kit name
 * - Operation name
 * - Stable inputs (JSON stringified with sorted keys)
 * - Git SHA (if provided)
 * - Lifecycle stage (if provided)
 *
 * Format: `<kitName>:<operation>:<hash>`
 */
export function deriveIdempotencyKey(config: IdempotencyKeyConfig): string {
  const { kitName, operation, stableInputs, gitSha, stage } = config;

  // Create a canonical representation of inputs
  const canonicalInputs = JSON.stringify(stableInputs, Object.keys(stableInputs).sort());

  // Combine all stable factors
  const factors = [
    kitName,
    operation,
    canonicalInputs,
    gitSha || "",
    stage || "",
  ].join(":");

  // Generate SHA-256 hash and take first 16 chars for brevity
  const hash = createHash("sha256").update(factors).digest("hex").slice(0, 16);

  return `${kitName}:${operation}:${hash}`;
}

/**
 * Generate a hash of inputs for verification.
 */
export function hashInputs(inputs: Record<string, unknown>): string {
  const canonical = JSON.stringify(inputs, Object.keys(inputs).sort());
  return createHash("sha256").update(canonical).digest("hex").slice(0, 32);
}

/**
 * Parse an idempotency key into its components.
 */
export function parseIdempotencyKey(key: string): {
  kitName: string;
  operation: string;
  hash: string;
} | null {
  const parts = key.split(":");
  if (parts.length !== 3) {
    return null;
  }

  return {
    kitName: parts[0],
    operation: parts[1],
    hash: parts[2],
  };
}

// ============================================================================
// Idempotency Manager
// ============================================================================

/**
 * Idempotency manager for tracking operation state.
 *
 * Supports pluggable storage backends:
 * - In-memory (default, single process)
 * - Run records (durable, survives restarts)
 * - Custom backends implementing IdempotencyStorage
 */
export class IdempotencyManager {
  private storage: IdempotencyStorage;
  private pendingTtlMs: number;
  private completedTtlMs: number;

  constructor(options: IdempotencyManagerOptions = {}) {
    this.pendingTtlMs = options.pendingTtlMs ?? 60 * 60 * 1000; // 1 hour
    this.completedTtlMs = options.completedTtlMs ?? 24 * 60 * 60 * 1000; // 24 hours
    this.storage = options.storage ?? new InMemoryIdempotencyStorage();
  }

  /**
   * Check if an operation can proceed with the given idempotency key.
   *
   * @returns The existing record if found, null if the operation can proceed
   * @throws IdempotencyConflictError if there's a pending operation with the same key
   */
  checkIdempotency<T = unknown>(
    key: string,
    kitName: string,
    operation: string,
    inputsHash: string
  ): IdempotencyRecord<T> | null {
    this.cleanupExpired();

    const existing = this.storage.get<T>(key);
    if (!existing) {
      return null;
    }

    // If completed successfully, return the existing record
    if (existing.state === "completed") {
      // Verify inputs match
      if (existing.inputsHash !== inputsHash) {
        throw new IdempotencyConflictError(
          `Idempotency key ${key} was used with different inputs`,
          {
            idempotencyKey: key,
            conflictingRunId: existing.runId,
          }
        );
      }
      return existing;
    }

    // If failed, allow retry
    if (existing.state === "failed") {
      return null;
    }

    // If pending, check if it's stale
    const createdAt = new Date(existing.createdAt).getTime();
    const isStale = Date.now() - createdAt > this.pendingTtlMs;

    if (isStale) {
      // Remove stale record and allow retry
      this.storage.delete(key);
      return null;
    }

    // Active pending operation - conflict
    throw new IdempotencyConflictError(
      `Operation with idempotency key ${key} is already in progress`,
      {
        idempotencyKey: key,
        conflictingRunId: existing.runId,
      }
    );
  }

  /**
   * Start tracking an operation with the given idempotency key.
   */
  startOperation(
    key: string,
    kitName: string,
    operation: string,
    inputsHash: string,
    runId?: string
  ): IdempotencyRecord<unknown> {
    const record: IdempotencyRecord<unknown> = {
      key,
      createdAt: new Date().toISOString(),
      state: "pending",
      kitName,
      operation,
      runId,
      inputsHash,
    };

    this.storage.set(key, record);
    return record;
  }

  /**
   * Mark an operation as completed and store the result.
   */
  completeOperation<T = unknown>(key: string, result?: T, runId?: string): void {
    const existing = this.storage.get(key);
    if (existing) {
      const updated: IdempotencyRecord<unknown> = {
        ...existing,
        state: "completed",
        completedAt: new Date().toISOString(),
        cachedResult: result,
        ...(runId && { runId }),
      };
      this.storage.set(key, updated);
    }
  }

  /**
   * Mark an operation as failed.
   */
  failOperation(key: string): void {
    const existing = this.storage.get(key);
    if (existing) {
      const updated: IdempotencyRecord<unknown> = {
        ...existing,
        state: "failed",
        completedAt: new Date().toISOString(),
      };
      this.storage.set(key, updated);
    }
  }

  /**
   * Get a record by key.
   */
  getRecord<T = unknown>(key: string): IdempotencyRecord<T> | undefined {
    return this.storage.get<T>(key) ?? undefined;
  }

  /**
   * Clear all records (for testing).
   */
  clear(): void {
    this.storage.clear();
  }

  /**
   * Clean up expired records.
   */
  private cleanupExpired(): void {
    this.storage.cleanupExpired(this.pendingTtlMs, this.completedTtlMs);
  }
}

// ============================================================================
// Singleton Instance
// ============================================================================

let defaultManager: IdempotencyManager | null = null;

/**
 * Get the default idempotency manager instance.
 */
export function getIdempotencyManager(): IdempotencyManager {
  if (!defaultManager) {
    defaultManager = new IdempotencyManager();
  }
  return defaultManager;
}

/**
 * Reset the default idempotency manager (for testing).
 */
export function resetIdempotencyManager(): void {
  defaultManager = null;
}

/**
 * Create an idempotency manager with durable run record storage.
 *
 * Uses run records as the backing store, which:
 * - Survives process restarts
 * - Provides audit trail via run records
 * - Shares retention policy with run records cleanup
 *
 * @param runsDir - Directory containing run records (default: ./runs)
 * @param options - Additional manager options (TTLs)
 */
export function createDurableIdempotencyManager(
  runsDir?: string,
  options?: Omit<IdempotencyManagerOptions, "storage">
): IdempotencyManager {
  return new IdempotencyManager({
    ...options,
    storage: new RunRecordIdempotencyStorage(runsDir),
  });
}

/**
 * Create an idempotency manager with in-memory storage.
 *
 * Records are lost when the process exits. Suitable for:
 * - Single-process scenarios
 * - Testing
 * - Operations where durability isn't required
 *
 * @param options - Manager options (TTLs)
 */
export function createInMemoryIdempotencyManager(
  options?: Omit<IdempotencyManagerOptions, "storage">
): IdempotencyManager {
  return new IdempotencyManager({
    ...options,
    storage: new InMemoryIdempotencyStorage(),
  });
}

/**
 * Set the default idempotency manager to use durable storage.
 *
 * Call this early in your application if you want all kits
 * to use durable idempotency by default.
 *
 * @param runsDir - Directory containing run records (default: ./runs)
 */
export function useDurableIdempotency(runsDir?: string): void {
  defaultManager = createDurableIdempotencyManager(runsDir);
}

// ============================================================================
// Helper Functions
// ============================================================================

/**
 * Execute an operation with idempotency protection.
 *
 * @param key - Idempotency key (or config to derive one)
 * @param kitName - Kit name
 * @param operation - Operation name
 * @param inputs - Operation inputs
 * @param fn - The operation to execute
 * @returns The result of the operation, or the cached result if already completed
 */
export async function withIdempotency<T>(
  key: string | IdempotencyKeyConfig,
  kitName: string,
  operation: string,
  inputs: Record<string, unknown>,
  fn: () => Promise<T>
): Promise<{ result: T; cached: boolean; runId?: string }> {
  const manager = getIdempotencyManager();

  const idempotencyKey =
    typeof key === "string" ? key : deriveIdempotencyKey(key);
  const inputsHash = hashInputs(inputs);

  // Check for existing operation
  const existing = manager.checkIdempotency<T>(
    idempotencyKey,
    kitName,
    operation,
    inputsHash
  );

  if (existing && existing.state === "completed") {
    // Return the cached result from the previous execution
    return {
      result: existing.cachedResult as T,
      cached: true,
      runId: existing.runId,
    };
  }

  // Start new operation
  const runId = randomUUID();
  manager.startOperation(idempotencyKey, kitName, operation, inputsHash, runId);

  try {
    const result = await fn();
    manager.completeOperation(idempotencyKey, result, runId);
    return { result, cached: false, runId };
  } catch (error) {
    manager.failOperation(idempotencyKey);
    throw error;
  }
}

/**
 * Check if an operation should be skipped due to idempotency.
 *
 * Returns the existing record if the operation was already completed,
 * null if the operation should proceed.
 */
export function checkIdempotencyKey<T = unknown>(
  key: string,
  kitName: string,
  operation: string,
  inputs: Record<string, unknown>
): IdempotencyRecord<T> | null {
  const manager = getIdempotencyManager();
  const inputsHash = hashInputs(inputs);
  return manager.checkIdempotency<T>(key, kitName, operation, inputsHash);
}

/**
 * Execute a synchronous operation with idempotency protection.
 *
 * Use this for synchronous kit operations (e.g., CostKit.recordUsage,
 * GuardKit.check, PromptKit.compile).
 *
 * @param key - Idempotency key (or config to derive one)
 * @param kitName - Kit name
 * @param operation - Operation name
 * @param inputs - Operation inputs
 * @param fn - The synchronous operation to execute
 * @returns The result of the operation, or the cached result if already completed
 */
export function withIdempotencySync<T>(
  key: string | IdempotencyKeyConfig,
  kitName: string,
  operation: string,
  inputs: Record<string, unknown>,
  fn: () => T
): { result: T; cached: boolean; runId?: string } {
  const manager = getIdempotencyManager();

  const idempotencyKey =
    typeof key === "string" ? key : deriveIdempotencyKey(key);
  const inputsHash = hashInputs(inputs);

  // Check for existing operation
  const existing = manager.checkIdempotency<T>(
    idempotencyKey,
    kitName,
    operation,
    inputsHash
  );

  if (existing && existing.state === "completed") {
    // Return the cached result from the previous execution
    return {
      result: existing.cachedResult as T,
      cached: true,
      runId: existing.runId,
    };
  }

  // Start new operation
  const runId = randomUUID();
  manager.startOperation(idempotencyKey, kitName, operation, inputsHash, runId);

  try {
    const result = fn();
    manager.completeOperation(idempotencyKey, result, runId);
    return { result, cached: false, runId };
  } catch (error) {
    manager.failOperation(idempotencyKey);
    throw error;
  }
}

// ============================================================================
// Smart Storage Selection
// ============================================================================

/**
 * Context for selecting idempotency storage.
 */
export interface IdempotencyContext {
  /** User-provided idempotency key */
  idempotencyKey?: string;

  /** Whether run records are enabled */
  enableRunRecords?: boolean;

  /** Runs directory */
  runsDir?: string;

  /** Override storage type */
  storageType?: "memory" | "durable";
}

/**
 * Select the appropriate idempotency storage based on context.
 *
 * Selection logic:
 * 1. If explicitly configured, use that
 * 2. If user provided an idempotency key, use durable storage (they expect durability)
 * 3. If run records are enabled, use durable storage
 * 4. Default to in-memory for fast CLI invocations
 */
export function selectIdempotencyStorage(
  context: IdempotencyContext
): IdempotencyStorage {
  // If explicitly configured, use that
  if (context.storageType === "memory") {
    return new InMemoryIdempotencyStorage();
  }
  if (context.storageType === "durable") {
    return new RunRecordIdempotencyStorage(context.runsDir);
  }

  // If user provided an idempotency key, they expect durability
  if (context.idempotencyKey) {
    return new RunRecordIdempotencyStorage(context.runsDir);
  }

  // If run records are enabled, use durable storage
  if (context.enableRunRecords) {
    return new RunRecordIdempotencyStorage(context.runsDir);
  }

  // Default to in-memory for fast CLI invocations
  return new InMemoryIdempotencyStorage();
}

/**
 * Kit configuration with idempotency options.
 */
export interface KitConfigWithIdempotency {
  /** User-provided idempotency key */
  idempotencyKey?: string;

  /** Whether run records are enabled */
  enableRunRecords?: boolean;

  /** Runs directory */
  runsDir?: string;

  /** Idempotency configuration */
  idempotency?: {
    /** Enable idempotency enforcement */
    enabled?: boolean;
    /** Storage backend: "memory" | "durable" */
    storage?: "memory" | "durable";
    /** TTL for pending operations (ms) */
    pendingTtlMs?: number;
    /** TTL for completed operations (ms) */
    completedTtlMs?: number;
  };
}

/**
 * Create an idempotency manager configured for a kit.
 *
 * Uses smart defaults based on kit configuration:
 * - If idempotency.enabled is false, still creates a manager but with no-op behavior
 * - If idempotency.storage is specified, uses that
 * - Otherwise, uses selectIdempotencyStorage() for smart defaults
 *
 * @param kitName - Kit name (for logging)
 * @param config - Kit configuration with idempotency options
 * @returns Configured idempotency manager
 */
export function createIdempotencyManagerForKit(
  kitName: string,
  config: KitConfigWithIdempotency
): IdempotencyManager {
  // If idempotency is disabled, return a manager with in-memory storage
  // (effectively no-op for stateless operations)
  if (config.idempotency?.enabled === false) {
    return new IdempotencyManager({
      storage: new InMemoryIdempotencyStorage(),
      pendingTtlMs: 0, // Immediate expiration
      completedTtlMs: 0,
    });
  }

  const storage = selectIdempotencyStorage({
    idempotencyKey: config.idempotencyKey,
    enableRunRecords: config.enableRunRecords,
    runsDir: config.runsDir,
    storageType: config.idempotency?.storage,
  });

  return new IdempotencyManager({
    storage,
    pendingTtlMs: config.idempotency?.pendingTtlMs,
    completedTtlMs: config.idempotency?.completedTtlMs,
  });
}


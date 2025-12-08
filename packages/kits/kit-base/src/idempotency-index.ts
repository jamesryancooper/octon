/**
 * IdempotencyIndexManager - O(1) lookup for idempotency keys via run records.
 *
 * Maintains a JSON index file that maps idempotency keys to run record paths,
 * enabling fast lookups without scanning all run records.
 */

import { existsSync, readFileSync, writeFileSync, mkdirSync } from "fs";
import { join, dirname } from "path";
import type { RunRecord } from "./run-record.js";

/**
 * Entry in the idempotency index.
 */
export interface IdempotencyIndexEntry {
  /** Run record ID */
  runId: string;

  /** Path to the run record file (relative to runs directory) */
  runRecordPath: string;

  /** Operation status */
  status: "success" | "failure";

  /** When the operation was created */
  createdAt: string;

  /** Hash of the inputs for conflict detection */
  inputsHash: string;

  /** Kit name */
  kitName?: string;

  /** Operation name */
  operation?: string;
}

/**
 * The idempotency index structure.
 */
export interface IdempotencyIndex {
  /** Schema version for forward compatibility */
  version: 1;

  /** Map of idempotency keys to index entries */
  entries: Record<string, IdempotencyIndexEntry>;

  /** Last updated timestamp */
  updatedAt: string;
}

/**
 * Options for the IdempotencyIndexManager.
 */
export interface IdempotencyIndexManagerOptions {
  /** The runs directory path */
  runsDir: string;

  /** Auto-persist changes on each set (default: true) */
  autoPersist?: boolean;

  /** Index file name (default: ".idempotency-index.json") */
  indexFileName?: string;
}

/**
 * Manages the idempotency index for fast key lookups.
 */
export class IdempotencyIndexManager {
  private readonly indexPath: string;
  private readonly runsDir: string;
  private readonly autoPersist: boolean;
  private index: IdempotencyIndex;
  private dirty = false;

  constructor(options: IdempotencyIndexManagerOptions) {
    this.runsDir = options.runsDir;
    this.autoPersist = options.autoPersist ?? true;
    const indexFileName = options.indexFileName ?? ".idempotency-index.json";
    this.indexPath = join(options.runsDir, indexFileName);
    this.index = this.loadOrCreate();
  }

  /**
   * Load the index from disk or create a new one.
   */
  private loadOrCreate(): IdempotencyIndex {
    if (existsSync(this.indexPath)) {
      try {
        const content = readFileSync(this.indexPath, "utf-8");
        const parsed = JSON.parse(content) as IdempotencyIndex;

        // Validate version
        if (parsed.version === 1) {
          return parsed;
        }

        // Unknown version, start fresh
        console.warn(
          `[idempotency-index] Unknown index version ${parsed.version}, creating new index`
        );
      } catch (error) {
        console.warn(
          `[idempotency-index] Failed to load index: ${error instanceof Error ? error.message : error}`
        );
      }
    }

    return {
      version: 1,
      entries: {},
      updatedAt: new Date().toISOString(),
    };
  }

  /**
   * Get an entry by idempotency key.
   * O(1) lookup.
   */
  get(key: string): IdempotencyIndexEntry | null {
    return this.index.entries[key] ?? null;
  }

  /**
   * Check if a key exists in the index.
   */
  has(key: string): boolean {
    return key in this.index.entries;
  }

  /**
   * Set an entry in the index.
   */
  set(key: string, entry: IdempotencyIndexEntry): void {
    this.index.entries[key] = entry;
    this.index.updatedAt = new Date().toISOString();
    this.dirty = true;

    if (this.autoPersist) {
      this.persist();
    }
  }

  /**
   * Remove an entry from the index.
   */
  delete(key: string): boolean {
    if (key in this.index.entries) {
      delete this.index.entries[key];
      this.index.updatedAt = new Date().toISOString();
      this.dirty = true;

      if (this.autoPersist) {
        this.persist();
      }
      return true;
    }
    return false;
  }

  /**
   * Get all keys in the index.
   */
  keys(): string[] {
    return Object.keys(this.index.entries);
  }

  /**
   * Get the number of entries in the index.
   */
  size(): number {
    return Object.keys(this.index.entries).length;
  }

  /**
   * Clear all entries from the index.
   */
  clear(): void {
    this.index.entries = {};
    this.index.updatedAt = new Date().toISOString();
    this.dirty = true;

    if (this.autoPersist) {
      this.persist();
    }
  }

  /**
   * Persist the index to disk.
   */
  persist(): void {
    if (!this.dirty && existsSync(this.indexPath)) {
      return;
    }

    try {
      // Ensure directory exists
      const dir = dirname(this.indexPath);
      if (!existsSync(dir)) {
        mkdirSync(dir, { recursive: true });
      }

      writeFileSync(this.indexPath, JSON.stringify(this.index, null, 2));
      this.dirty = false;
    } catch (error) {
      console.error(
        `[idempotency-index] Failed to persist index: ${error instanceof Error ? error.message : error}`
      );
    }
  }

  /**
   * Index a run record.
   *
   * Extracts the idempotency key from the run record and adds it to the index.
   */
  indexRunRecord(record: RunRecord, runRecordPath: string): void {
    if (!record.determinism?.idempotencyKey) {
      return;
    }

    this.set(record.determinism.idempotencyKey, {
      runId: record.runId,
      runRecordPath,
      status: record.status as "success" | "failure",
      createdAt: record.createdAt,
      inputsHash: record.determinism.inputsHash ?? "",
      kitName: record.kit.name,
      operation: record.summary?.split(" ")[0] ?? "unknown",
    });
  }

  /**
   * Remove expired entries from the index.
   *
   * @param maxAgeMs - Maximum age in milliseconds (default: 24 hours)
   * @returns Number of entries removed
   */
  cleanupExpired(maxAgeMs: number = 24 * 60 * 60 * 1000): number {
    const now = Date.now();
    let removed = 0;

    for (const [key, entry] of Object.entries(this.index.entries)) {
      const entryTime = new Date(entry.createdAt).getTime();
      if (now - entryTime > maxAgeMs) {
        delete this.index.entries[key];
        removed++;
      }
    }

    if (removed > 0) {
      this.index.updatedAt = new Date().toISOString();
      this.dirty = true;

      if (this.autoPersist) {
        this.persist();
      }
    }

    return removed;
  }

  /**
   * Get the path to the index file.
   */
  getIndexPath(): string {
    return this.indexPath;
  }

  /**
   * Get the runs directory.
   */
  getRunsDir(): string {
    return this.runsDir;
  }

  /**
   * Get the raw index data.
   */
  getRawIndex(): Readonly<IdempotencyIndex> {
    return this.index;
  }
}

/**
 * Create an IdempotencyIndexManager for a given runs directory.
 */
export function createIdempotencyIndex(
  runsDir: string,
  options?: Omit<IdempotencyIndexManagerOptions, "runsDir">
): IdempotencyIndexManager {
  return new IdempotencyIndexManager({ runsDir, ...options });
}


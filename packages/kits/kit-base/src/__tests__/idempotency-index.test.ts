/**
 * Tests for IdempotencyIndexManager.
 */

import { describe, it, expect, beforeEach, afterEach } from "vitest";
import { mkdirSync, rmSync, existsSync, writeFileSync, readFileSync } from "fs";
import { join } from "path";
import {
  IdempotencyIndexManager,
  createIdempotencyIndex,
  type IdempotencyIndexEntry,
} from "../idempotency-index.js";
import type { RunRecord } from "../run-record.js";

describe("IdempotencyIndexManager", () => {
  const testDir = join(process.cwd(), ".test-idempotency-index");
  let indexManager: IdempotencyIndexManager;

  beforeEach(() => {
    // Clean up before each test
    if (existsSync(testDir)) {
      rmSync(testDir, { recursive: true });
    }
    mkdirSync(testDir, { recursive: true });
    indexManager = new IdempotencyIndexManager({ runsDir: testDir });
  });

  afterEach(() => {
    // Clean up after each test
    if (existsSync(testDir)) {
      rmSync(testDir, { recursive: true });
    }
  });

  describe("basic operations", () => {
    it("should create a new index if none exists", () => {
      expect(indexManager.size()).toBe(0);
      expect(indexManager.getRawIndex().version).toBe(1);
    });

    it("should set and get an entry", () => {
      const entry: IdempotencyIndexEntry = {
        runId: "test-run-1",
        runRecordPath: "flowkit/2025-01-01/test.json",
        status: "success",
        createdAt: new Date().toISOString(),
        inputsHash: "abc123",
        kitName: "flowkit",
        operation: "run",
      };

      indexManager.set("test-key", entry);
      
      const retrieved = indexManager.get("test-key");
      expect(retrieved).not.toBeNull();
      expect(retrieved?.runId).toBe("test-run-1");
      expect(retrieved?.status).toBe("success");
    });

    it("should check if a key exists", () => {
      expect(indexManager.has("non-existent")).toBe(false);
      
      indexManager.set("exists", {
        runId: "test",
        runRecordPath: "test.json",
        status: "success",
        createdAt: new Date().toISOString(),
        inputsHash: "hash",
      });

      expect(indexManager.has("exists")).toBe(true);
    });

    it("should delete an entry", () => {
      indexManager.set("to-delete", {
        runId: "test",
        runRecordPath: "test.json",
        status: "success",
        createdAt: new Date().toISOString(),
        inputsHash: "hash",
      });

      expect(indexManager.has("to-delete")).toBe(true);
      
      const deleted = indexManager.delete("to-delete");
      expect(deleted).toBe(true);
      expect(indexManager.has("to-delete")).toBe(false);
    });

    it("should return false when deleting non-existent key", () => {
      const deleted = indexManager.delete("non-existent");
      expect(deleted).toBe(false);
    });

    it("should list all keys", () => {
      indexManager.set("key1", {
        runId: "r1",
        runRecordPath: "p1.json",
        status: "success",
        createdAt: new Date().toISOString(),
        inputsHash: "h1",
      });
      indexManager.set("key2", {
        runId: "r2",
        runRecordPath: "p2.json",
        status: "failure",
        createdAt: new Date().toISOString(),
        inputsHash: "h2",
      });

      const keys = indexManager.keys();
      expect(keys).toHaveLength(2);
      expect(keys).toContain("key1");
      expect(keys).toContain("key2");
    });

    it("should clear all entries", () => {
      indexManager.set("key1", {
        runId: "r1",
        runRecordPath: "p1.json",
        status: "success",
        createdAt: new Date().toISOString(),
        inputsHash: "h1",
      });
      indexManager.set("key2", {
        runId: "r2",
        runRecordPath: "p2.json",
        status: "success",
        createdAt: new Date().toISOString(),
        inputsHash: "h2",
      });

      expect(indexManager.size()).toBe(2);
      
      indexManager.clear();
      
      expect(indexManager.size()).toBe(0);
    });
  });

  describe("persistence", () => {
    it("should persist index to disk", () => {
      indexManager.set("persistent-key", {
        runId: "run-1",
        runRecordPath: "test.json",
        status: "success",
        createdAt: new Date().toISOString(),
        inputsHash: "hash",
      });

      // Create a new manager to load from disk
      const newManager = new IdempotencyIndexManager({ runsDir: testDir });
      
      const entry = newManager.get("persistent-key");
      expect(entry).not.toBeNull();
      expect(entry?.runId).toBe("run-1");
    });

    it("should auto-persist when autoPersist is true", () => {
      const entry: IdempotencyIndexEntry = {
        runId: "auto-persist-run",
        runRecordPath: "auto.json",
        status: "success",
        createdAt: new Date().toISOString(),
        inputsHash: "hash",
      };

      indexManager.set("auto-persist-key", entry);

      // Read the file directly
      const indexPath = indexManager.getIndexPath();
      const content = JSON.parse(readFileSync(indexPath, "utf-8"));
      expect(content.entries["auto-persist-key"]).toBeDefined();
    });

    it("should not auto-persist when autoPersist is false", () => {
      const noAutoManager = new IdempotencyIndexManager({
        runsDir: testDir,
        autoPersist: false,
        indexFileName: ".no-auto-index.json",
      });

      noAutoManager.set("no-auto-key", {
        runId: "run",
        runRecordPath: "path.json",
        status: "success",
        createdAt: new Date().toISOString(),
        inputsHash: "hash",
      });

      // File shouldn't exist yet
      const indexPath = noAutoManager.getIndexPath();
      expect(existsSync(indexPath)).toBe(false);

      // Now persist manually
      noAutoManager.persist();
      expect(existsSync(indexPath)).toBe(true);
    });
  });

  describe("indexRunRecord", () => {
    it("should index a run record with idempotency key", () => {
      const runRecord: RunRecord = {
        runId: "2025-01-01T00-00-00Z-flowkit-abc",
        kit: { name: "flowkit", version: "0.1.0" },
        inputs: { flowName: "test" },
        telemetry: { trace_id: "trace-123" },
        status: "success",
        summary: "Test run",
        stage: "implement",
        risk: "low",
        createdAt: new Date().toISOString(),
        determinism: {
          idempotencyKey: "flowkit:run:test123",
          inputsHash: "inputhash123",
        },
      };

      indexManager.indexRunRecord(runRecord, "flowkit/2025-01-01/run.json");

      const entry = indexManager.get("flowkit:run:test123");
      expect(entry).not.toBeNull();
      expect(entry?.runId).toBe("2025-01-01T00-00-00Z-flowkit-abc");
      expect(entry?.runRecordPath).toBe("flowkit/2025-01-01/run.json");
      expect(entry?.inputsHash).toBe("inputhash123");
    });

    it("should skip run records without idempotency key", () => {
      const runRecord: RunRecord = {
        runId: "2025-01-01T00-00-00Z-flowkit-abc",
        kit: { name: "flowkit", version: "0.1.0" },
        inputs: { flowName: "test" },
        telemetry: { trace_id: "trace-123" },
        status: "success",
        summary: "Test run",
        stage: "implement",
        risk: "low",
        createdAt: new Date().toISOString(),
        // No determinism or idempotencyKey
      };

      indexManager.indexRunRecord(runRecord, "flowkit/2025-01-01/run.json");

      expect(indexManager.size()).toBe(0);
    });
  });

  describe("cleanupExpired", () => {
    it("should remove entries older than maxAgeMs", () => {
      // Add an old entry
      const oldDate = new Date(Date.now() - 2 * 24 * 60 * 60 * 1000); // 2 days ago
      indexManager.set("old-key", {
        runId: "old-run",
        runRecordPath: "old.json",
        status: "success",
        createdAt: oldDate.toISOString(),
        inputsHash: "hash",
      });

      // Add a new entry
      indexManager.set("new-key", {
        runId: "new-run",
        runRecordPath: "new.json",
        status: "success",
        createdAt: new Date().toISOString(),
        inputsHash: "hash",
      });

      expect(indexManager.size()).toBe(2);

      // Cleanup entries older than 1 day
      const removed = indexManager.cleanupExpired(24 * 60 * 60 * 1000);

      expect(removed).toBe(1);
      expect(indexManager.size()).toBe(1);
      expect(indexManager.has("old-key")).toBe(false);
      expect(indexManager.has("new-key")).toBe(true);
    });
  });

  describe("createIdempotencyIndex helper", () => {
    it("should create an index manager", () => {
      const index = createIdempotencyIndex(testDir);
      expect(index).toBeInstanceOf(IdempotencyIndexManager);
    });

    it("should pass options to the manager", () => {
      const index = createIdempotencyIndex(testDir, {
        autoPersist: false,
        indexFileName: ".custom-index.json",
      });

      expect(index.getIndexPath()).toContain(".custom-index.json");
    });
  });
});


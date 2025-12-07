/**
 * Tests for PromptKit Hasher module.
 */

import { describe, it, expect } from "vitest";
import {
  computePromptHash,
  verifyPromptHash,
  redactSecrets,
  parseHash,
  shortHash,
  combineHashes,
} from "../hasher";

describe("PromptKit Hasher", () => {
  describe("computePromptHash", () => {
    it("should compute a sha256 hash", () => {
      const hash = computePromptHash("Hello, World!", {});
      expect(hash).toMatch(/^sha256:[a-f0-9]{64}$/);
    });

    it("should produce deterministic hashes", () => {
      const prompt = "Test prompt";
      const variables = { key: "value" };

      const hash1 = computePromptHash(prompt, variables);
      const hash2 = computePromptHash(prompt, variables);

      expect(hash1).toBe(hash2);
    });

    it("should produce different hashes for different prompts", () => {
      const hash1 = computePromptHash("Prompt A", {});
      const hash2 = computePromptHash("Prompt B", {});

      expect(hash1).not.toBe(hash2);
    });

    it("should produce different hashes for different variables", () => {
      const prompt = "Test prompt";
      const hash1 = computePromptHash(prompt, { key: "value1" });
      const hash2 = computePromptHash(prompt, { key: "value2" });

      expect(hash1).not.toBe(hash2);
    });

    it("should include promptId and version in hash", () => {
      const prompt = "Test prompt";
      const variables = {};

      const hash1 = computePromptHash(prompt, variables, "prompt-a", "1.0.0");
      const hash2 = computePromptHash(prompt, variables, "prompt-b", "1.0.0");
      const hash3 = computePromptHash(prompt, variables, "prompt-a", "2.0.0");

      expect(hash1).not.toBe(hash2);
      expect(hash1).not.toBe(hash3);
    });

    it("should handle object key ordering consistently", () => {
      const prompt = "Test";
      const vars1 = { a: 1, b: 2, c: 3 };
      const vars2 = { c: 3, a: 1, b: 2 };

      const hash1 = computePromptHash(prompt, vars1);
      const hash2 = computePromptHash(prompt, vars2);

      expect(hash1).toBe(hash2);
    });

    it("should redact secrets in variables", () => {
      const prompt = "Test";
      const vars1 = { api_key: "secret1" };
      const vars2 = { api_key: "secret2" };

      // Both should produce the same hash since secrets are redacted
      const hash1 = computePromptHash(prompt, vars1);
      const hash2 = computePromptHash(prompt, vars2);

      expect(hash1).toBe(hash2);
    });
  });

  describe("verifyPromptHash", () => {
    it("should verify a correct hash", () => {
      const prompt = "Test prompt";
      const variables = { key: "value" };
      const hash = computePromptHash(prompt, variables);

      expect(verifyPromptHash(prompt, variables, hash)).toBe(true);
    });

    it("should reject an incorrect hash", () => {
      const prompt = "Test prompt";
      const variables = { key: "value" };
      const wrongHash = "sha256:0000000000000000000000000000000000000000000000000000000000000000";

      expect(verifyPromptHash(prompt, variables, wrongHash)).toBe(false);
    });

    it("should reject a tampered prompt", () => {
      const prompt = "Test prompt";
      const variables = { key: "value" };
      const hash = computePromptHash(prompt, variables);

      expect(verifyPromptHash("Modified prompt", variables, hash)).toBe(false);
    });
  });

  describe("redactSecrets", () => {
    it("should redact api_key", () => {
      const result = redactSecrets({ api_key: "secret123" });
      expect(result.api_key).toBe("[REDACTED]");
    });

    it("should redact password", () => {
      const result = redactSecrets({ password: "secret123" });
      expect(result.password).toBe("[REDACTED]");
    });

    it("should redact secret", () => {
      const result = redactSecrets({ client_secret: "secret123" });
      expect(result.client_secret).toBe("[REDACTED]");
    });

    it("should redact token", () => {
      const result = redactSecrets({ access_token: "secret123" });
      expect(result.access_token).toBe("[REDACTED]");
    });

    it("should preserve non-sensitive values", () => {
      const result = redactSecrets({ name: "John", age: 30 });
      expect(result.name).toBe("John");
      expect(result.age).toBe(30);
    });

    it("should handle nested objects", () => {
      const result = redactSecrets({
        user: {
          name: "John",
          api_key: "secret123",
        },
      });
      expect((result.user as Record<string, unknown>).name).toBe("John");
      expect((result.user as Record<string, unknown>).api_key).toBe("[REDACTED]");
    });

    it("should handle arrays", () => {
      const result = redactSecrets({
        users: [{ name: "John", password: "secret" }],
      });
      expect(
        ((result.users as Array<Record<string, unknown>>)[0]).name
      ).toBe("John");
      expect(
        ((result.users as Array<Record<string, unknown>>)[0]).password
      ).toBe("[REDACTED]");
    });
  });

  describe("parseHash", () => {
    it("should parse a valid hash", () => {
      const result = parseHash("sha256:abc123def456");
      expect(result).toEqual({
        algorithm: "sha256",
        digest: "abc123def456",
      });
    });

    it("should return null for invalid hash format", () => {
      expect(parseHash("invalid")).toBeNull();
      expect(parseHash("sha256:")).toBeNull();
      expect(parseHash(":abc123")).toBeNull();
    });
  });

  describe("shortHash", () => {
    it("should shorten a hash", () => {
      const hash = "sha256:abcdef1234567890abcdef1234567890";
      const result = shortHash(hash);
      expect(result).toBe("sha256:abcdef12");
    });

    it("should use custom length", () => {
      const hash = "sha256:abcdef1234567890";
      const result = shortHash(hash, 4);
      expect(result).toBe("sha256:abcd");
    });
  });

  describe("combineHashes", () => {
    it("should combine multiple hashes", () => {
      const hashes = ["sha256:abc123", "sha256:def456", "sha256:ghi789"];
      const result = combineHashes(hashes);
      expect(result).toMatch(/^sha256:[a-f0-9]{64}$/);
    });

    it("should return single hash unchanged", () => {
      const hash = "sha256:abc123def456abc123def456abc123def456abc123def456abc123def456abc1";
      const result = combineHashes([hash]);
      expect(result).toBe(hash);
    });

    it("should throw on empty array", () => {
      expect(() => combineHashes([])).toThrow("Cannot combine empty hash array");
    });

    it("should produce deterministic combined hashes", () => {
      const hashes = ["sha256:abc123", "sha256:def456"];
      const result1 = combineHashes(hashes);
      const result2 = combineHashes(hashes);
      expect(result1).toBe(result2);
    });
  });
});


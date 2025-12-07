/**
 * Tests for PromptKit Tokens module.
 */

import { describe, it, expect } from "vitest";
import {
  estimateTokenCount,
  estimateTokens,
  applyTokenBudget,
  truncateToTokens,
  getContextWindow,
  calculateAvailableOutputTokens,
  fitsInContext,
  getTokenInfo,
  MODEL_CONTEXT_WINDOWS,
} from "../tokens";

describe("PromptKit Tokens", () => {
  describe("estimateTokenCount", () => {
    it("should estimate tokens for text", () => {
      // ~4 chars per token
      const text = "Hello, World!"; // 13 chars
      const result = estimateTokenCount(text);
      expect(result).toBe(4); // ceil(13/4)
    });

    it("should return 0 for empty text", () => {
      expect(estimateTokenCount("")).toBe(0);
    });

    it("should handle long text", () => {
      const text = "a".repeat(1000);
      const result = estimateTokenCount(text);
      expect(result).toBe(250); // 1000/4
    });
  });

  describe("estimateTokens", () => {
    it("should estimate tokens without model adjustment", () => {
      const text = "Hello, World!";
      const result = estimateTokens(text);
      expect(result).toBe(4);
    });

    it("should apply Claude adjustment", () => {
      const text = "a".repeat(100); // 25 base tokens
      const result = estimateTokens(text, "claude-3-sonnet");
      expect(result).toBe(23); // ceil(25 * 0.9)
    });

    it("should not adjust for GPT", () => {
      const text = "a".repeat(100);
      const result = estimateTokens(text, "gpt-4o");
      expect(result).toBe(25);
    });
  });

  describe("getContextWindow", () => {
    it("should return context window for known models", () => {
      expect(getContextWindow("gpt-4o")).toBe(128000);
      expect(getContextWindow("claude-opus")).toBe(200000);
      expect(getContextWindow("gemini-2.0-flash")).toBe(1000000);
    });

    it("should return default for unknown models", () => {
      expect(getContextWindow("unknown-model")).toBe(
        MODEL_CONTEXT_WINDOWS.default
      );
    });

    it("should handle model name variations", () => {
      expect(getContextWindow("gpt-4o-2024-05-13")).toBe(128000);
    });
  });

  describe("applyTokenBudget", () => {
    it("should not truncate text within budget", () => {
      const text = "Hello, World!";
      const result = applyTokenBudget(text, { maxTokens: 100 });

      expect(result.text).toBe(text);
      expect(result.truncated).toBe(false);
      expect(result.originalTokens).toBe(result.finalTokens);
    });

    it("should truncate text exceeding budget", () => {
      const text = "a".repeat(1000); // ~250 tokens
      const result = applyTokenBudget(text, { maxTokens: 50 });

      expect(result.truncated).toBe(true);
      expect(result.finalTokens).toBeLessThanOrEqual(50);
    });

    it("should reserve tokens for output", () => {
      const text = "a".repeat(400); // ~100 tokens
      const result = applyTokenBudget(text, {
        maxTokens: 150,
        reserveOutputTokens: 100,
      });

      // Should truncate to fit in 50 tokens (150 - 100)
      expect(result.truncated).toBe(true);
      expect(result.finalTokens).toBeLessThanOrEqual(50);
    });

    it("should use specified truncation strategy", () => {
      const text = "a".repeat(1000);
      const result = applyTokenBudget(text, {
        maxTokens: 50,
        strategy: "prioritize_start",
      });

      expect(result.strategy).toBe("prioritize_start");
    });
  });

  describe("truncateToTokens", () => {
    it("should return full text if within limit", () => {
      const text = "Hello";
      const result = truncateToTokens(text, 100);
      expect(result).toBe(text);
    });

    it("should truncate with prioritize_start", () => {
      const text = "START_CONTENT " + "middle ".repeat(100) + "END";
      // Use more tokens so there's room for content after the marker
      const result = truncateToTokens(text, 50, "prioritize_start");

      expect(result).toContain("START");
      expect(result).toContain("[...content truncated...]");
      expect(result).not.toContain("END");
    });

    it("should truncate with prioritize_recent", () => {
      const text = "START " + "middle ".repeat(100) + "ENDING_CONTENT";
      // Use more tokens so there's room for content after the marker
      const result = truncateToTokens(text, 50, "prioritize_recent");

      expect(result).toContain("[...earlier content truncated...]");
      expect(result).toContain("ENDING");
    });

    it("should truncate with balanced strategy", () => {
      const text = "START " + "middle ".repeat(100) + "END";
      const result = truncateToTokens(text, 30, "balanced");

      expect(result).toContain("START");
      expect(result).toContain("[...middle content truncated...]");
      expect(result).toContain("END");
    });

    it("should return empty for zero tokens", () => {
      expect(truncateToTokens("Hello", 0)).toBe("");
    });
  });

  describe("calculateAvailableOutputTokens", () => {
    it("should calculate available tokens", () => {
      const result = calculateAvailableOutputTokens(1000, "gpt-4o", 100);
      // Context: 128000, minus 1000 input, minus 100 buffer
      expect(result).toBe(126900);
    });

    it("should return 0 when input exceeds context", () => {
      const result = calculateAvailableOutputTokens(200000, "gpt-4o");
      expect(result).toBe(0);
    });
  });

  describe("fitsInContext", () => {
    it("should return true for text within context", () => {
      const text = "Hello, World!";
      expect(fitsInContext(text, "gpt-4o")).toBe(true);
    });

    it("should return false for text exceeding context", () => {
      // Create text that would exceed even the largest context
      const hugeText = "a".repeat(10000000); // 2.5M tokens
      expect(fitsInContext(hugeText, "gpt-4o")).toBe(false);
    });

    it("should account for reserved output tokens", () => {
      const text = "a".repeat(500000); // ~125k tokens
      // gpt-4o has 128k context
      expect(fitsInContext(text, "gpt-4o", 0)).toBe(true);
      expect(fitsInContext(text, "gpt-4o", 10000)).toBe(false);
    });
  });

  describe("getTokenInfo", () => {
    it("should return comprehensive token info", () => {
      const text = "Hello, World!";
      const result = getTokenInfo(text, "gpt-4o");

      expect(result.tokens).toBeGreaterThan(0);
      expect(result.contextWindow).toBe(128000);
      expect(result.usagePercent).toBeLessThan(1);
      expect(result.fitsInContext).toBe(true);
      expect(result.availableForOutput).toBeGreaterThan(0);
    });

    it("should respect reserved output tokens", () => {
      const text = "a".repeat(500000); // ~125k tokens
      const result = getTokenInfo(text, "gpt-4o", 10000);

      // With 10k reserved, 125k prompt doesn't fit in 128k context
      expect(result.fitsInContext).toBe(false);
    });
  });
});


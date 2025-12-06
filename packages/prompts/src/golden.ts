/**
 * Golden test infrastructure for prompt outputs.
 * Ensures AI behavior remains consistent over time.
 */

import { readFileSync, writeFileSync, existsSync, mkdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { PromptValidator, ValidationResult } from "./validator.js";

/**
 * A golden test case.
 */
export interface GoldenTestCase {
  /** Unique identifier for this test case */
  id: string;

  /** Description of what this test validates */
  description: string;

  /** The input to the prompt */
  input: unknown;

  /** The expected output (or schema to match) */
  expected: unknown;

  /** How to compare: exact, schema, or similarity */
  comparison: "exact" | "schema" | "similarity";

  /** For similarity comparison: minimum threshold (0-1) */
  similarity_threshold?: number;

  /** Tags for filtering tests */
  tags?: string[];

  /** When this golden was created */
  created_at: string;

  /** Last updated */
  updated_at: string;
}

/**
 * Result of running a golden test.
 */
export interface GoldenTestResult {
  /** Test case ID */
  testId: string;

  /** Whether the test passed */
  passed: boolean;

  /** Comparison method used */
  comparison: "exact" | "schema" | "similarity";

  /** Actual output from the prompt */
  actual: unknown;

  /** Expected output */
  expected: unknown;

  /** Detailed differences if failed */
  differences?: string[];

  /** Similarity score for similarity comparisons */
  similarity?: number;

  /** Schema validation result for schema comparisons */
  validation?: ValidationResult;
}

/**
 * Summary of a golden test run.
 */
export interface GoldenTestSummary {
  /** Total tests run */
  total: number;

  /** Tests passed */
  passed: number;

  /** Tests failed */
  failed: number;

  /** Individual results */
  results: GoldenTestResult[];

  /** When the test was run */
  timestamp: string;
}

/**
 * Manages golden tests for a prompt.
 */
export class GoldenTestManager {
  private promptId: string;
  private goldenDir: string;
  private validator: PromptValidator;
  private testCases: GoldenTestCase[];

  constructor(
    promptId: string,
    promptDir: string,
    validator: PromptValidator
  ) {
    this.promptId = promptId;
    this.goldenDir = join(promptDir, "golden");
    this.validator = validator;
    this.testCases = this.loadTestCases();
  }

  /**
   * Load test cases from the golden directory.
   */
  private loadTestCases(): GoldenTestCase[] {
    const indexPath = join(this.goldenDir, "index.json");

    if (!existsSync(indexPath)) {
      return [];
    }

    const content = readFileSync(indexPath, "utf-8");
    return JSON.parse(content) as GoldenTestCase[];
  }

  /**
   * Save test cases to the golden directory.
   */
  private saveTestCases(): void {
    if (!existsSync(this.goldenDir)) {
      mkdirSync(this.goldenDir, { recursive: true });
    }

    const indexPath = join(this.goldenDir, "index.json");
    writeFileSync(indexPath, JSON.stringify(this.testCases, null, 2));
  }

  /**
   * Get all test cases.
   */
  getTestCases(): GoldenTestCase[] {
    return [...this.testCases];
  }

  /**
   * Add a new golden test case.
   */
  addTestCase(
    testCase: Omit<GoldenTestCase, "created_at" | "updated_at">
  ): void {
    const now = new Date().toISOString();

    const existing = this.testCases.findIndex((tc) => tc.id === testCase.id);
    if (existing >= 0) {
      throw new Error(`Test case with ID '${testCase.id}' already exists`);
    }

    this.testCases.push({
      ...testCase,
      created_at: now,
      updated_at: now,
    });

    this.saveTestCases();
  }

  /**
   * Update an existing test case.
   */
  updateTestCase(id: string, updates: Partial<GoldenTestCase>): void {
    const index = this.testCases.findIndex((tc) => tc.id === id);
    if (index < 0) {
      throw new Error(`Test case not found: ${id}`);
    }

    this.testCases[index] = {
      ...this.testCases[index],
      ...updates,
      updated_at: new Date().toISOString(),
    };

    this.saveTestCases();
  }

  /**
   * Remove a test case.
   */
  removeTestCase(id: string): void {
    const index = this.testCases.findIndex((tc) => tc.id === id);
    if (index < 0) {
      throw new Error(`Test case not found: ${id}`);
    }

    this.testCases.splice(index, 1);
    this.saveTestCases();
  }

  /**
   * Run a single golden test.
   */
  runTest(testCase: GoldenTestCase, actual: unknown): GoldenTestResult {
    const result: GoldenTestResult = {
      testId: testCase.id,
      passed: false,
      comparison: testCase.comparison,
      actual,
      expected: testCase.expected,
    };

    switch (testCase.comparison) {
      case "exact":
        result.passed = this.compareExact(actual, testCase.expected);
        if (!result.passed) {
          result.differences = this.findDifferences(actual, testCase.expected);
        }
        break;

      case "schema":
        result.validation = this.validator.validateOutput(this.promptId, actual);
        result.passed = result.validation.valid;
        if (!result.passed) {
          result.differences = result.validation.errors.map(
            (e) => `${e.path}: ${e.message}`
          );
        }
        break;

      case "similarity":
        result.similarity = this.calculateSimilarity(actual, testCase.expected);
        result.passed =
          result.similarity >= (testCase.similarity_threshold ?? 0.9);
        if (!result.passed) {
          result.differences = [
            `Similarity ${result.similarity.toFixed(2)} below threshold ${testCase.similarity_threshold ?? 0.9}`,
          ];
        }
        break;
    }

    return result;
  }

  /**
   * Run all golden tests.
   */
  runAllTests(
    generateOutput: (input: unknown) => Promise<unknown>
  ): Promise<GoldenTestSummary> {
    return this.runTests(this.testCases, generateOutput);
  }

  /**
   * Run tests matching specific tags.
   */
  runTestsByTag(
    tags: string[],
    generateOutput: (input: unknown) => Promise<unknown>
  ): Promise<GoldenTestSummary> {
    const filtered = this.testCases.filter((tc) =>
      tags.some((tag) => tc.tags?.includes(tag))
    );
    return this.runTests(filtered, generateOutput);
  }

  /**
   * Run a set of tests.
   */
  private async runTests(
    testCases: GoldenTestCase[],
    generateOutput: (input: unknown) => Promise<unknown>
  ): Promise<GoldenTestSummary> {
    const results: GoldenTestResult[] = [];

    for (const testCase of testCases) {
      const actual = await generateOutput(testCase.input);
      const result = this.runTest(testCase, actual);
      results.push(result);
    }

    return {
      total: results.length,
      passed: results.filter((r) => r.passed).length,
      failed: results.filter((r) => !r.passed).length,
      results,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * Compare two values for exact equality (deep comparison).
   */
  private compareExact(actual: unknown, expected: unknown): boolean {
    return JSON.stringify(actual) === JSON.stringify(expected);
  }

  /**
   * Find differences between two objects.
   */
  private findDifferences(actual: unknown, expected: unknown): string[] {
    const differences: string[] = [];

    const compare = (a: unknown, e: unknown, path: string) => {
      if (typeof a !== typeof e) {
        differences.push(`${path}: type mismatch (${typeof a} vs ${typeof e})`);
        return;
      }

      if (a === null || e === null) {
        if (a !== e) {
          differences.push(`${path}: ${String(a)} !== ${String(e)}`);
        }
        return;
      }

      if (typeof a === "object" && typeof e === "object") {
        const aObj = a as Record<string, unknown>;
        const eObj = e as Record<string, unknown>;

        const allKeys = new Set([...Object.keys(aObj), ...Object.keys(eObj)]);

        for (const key of allKeys) {
          if (!(key in aObj)) {
            differences.push(`${path}.${key}: missing in actual`);
          } else if (!(key in eObj)) {
            differences.push(`${path}.${key}: unexpected in actual`);
          } else {
            compare(aObj[key], eObj[key], `${path}.${key}`);
          }
        }
      } else if (a !== e) {
        differences.push(`${path}: ${String(a)} !== ${String(e)}`);
      }
    };

    compare(actual, expected, "$");
    return differences;
  }

  /**
   * Calculate similarity between two values.
   * Uses a simple structural similarity for objects.
   * Returns a normalized score between 0 and 1.
   */
  private calculateSimilarity(actual: unknown, expected: unknown): number {
    // For non-objects, use exact match
    if (typeof actual !== "object" || typeof expected !== "object") {
      return actual === expected ? 1 : 0;
    }

    if (actual === null || expected === null) {
      return actual === expected ? 1 : 0;
    }

    const aObj = actual as Record<string, unknown>;
    const eObj = expected as Record<string, unknown>;

    const allKeys = new Set([...Object.keys(aObj), ...Object.keys(eObj)]);
    
    if (allKeys.size === 0) {
      return 1; // Both empty objects are identical
    }

    let totalSimilarity = 0;

    for (const key of allKeys) {
      if (key in aObj && key in eObj) {
        // Key exists in both - calculate similarity for this key (0-1)
        const aVal = aObj[key];
        const eVal = eObj[key];
        
        if (typeof aVal === "object" && typeof eVal === "object") {
          // Nested objects: recursively calculate similarity (already returns 0-1)
          totalSimilarity += this.calculateSimilarity(aVal, eVal);
        } else if (aVal === eVal) {
          // Exact primitive match
          totalSimilarity += 1;
        } else {
          // Values differ but key exists in both - partial credit
          totalSimilarity += 0.5;
        }
      }
      // Keys missing from one side contribute 0 to similarity
    }

    return totalSimilarity / allKeys.size;
  }
}

/**
 * Create a new golden test case from actual output.
 */
export function createGoldenFromOutput(
  id: string,
  description: string,
  input: unknown,
  output: unknown,
  comparison: "exact" | "schema" | "similarity" = "schema"
): Omit<GoldenTestCase, "created_at" | "updated_at"> {
  return {
    id,
    description,
    input,
    expected: output,
    comparison,
    tags: [],
  };
}


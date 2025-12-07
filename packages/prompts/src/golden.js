/**
 * Golden test infrastructure for prompt outputs.
 * Ensures AI behavior remains consistent over time.
 */
import { readFileSync, writeFileSync, existsSync, mkdirSync } from "node:fs";
import { join } from "node:path";
/**
 * Manages golden tests for a prompt.
 */
export class GoldenTestManager {
    constructor(promptId, promptDir, validator) {
        this.promptId = promptId;
        this.goldenDir = join(promptDir, "golden");
        this.validator = validator;
        this.testCases = this.loadTestCases();
    }
    /**
     * Load test cases from the golden directory.
     */
    loadTestCases() {
        const indexPath = join(this.goldenDir, "index.json");
        if (!existsSync(indexPath)) {
            return [];
        }
        const content = readFileSync(indexPath, "utf-8");
        return JSON.parse(content);
    }
    /**
     * Save test cases to the golden directory.
     */
    saveTestCases() {
        if (!existsSync(this.goldenDir)) {
            mkdirSync(this.goldenDir, { recursive: true });
        }
        const indexPath = join(this.goldenDir, "index.json");
        writeFileSync(indexPath, JSON.stringify(this.testCases, null, 2));
    }
    /**
     * Get all test cases.
     */
    getTestCases() {
        return [...this.testCases];
    }
    /**
     * Add a new golden test case.
     */
    addTestCase(testCase) {
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
    updateTestCase(id, updates) {
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
    removeTestCase(id) {
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
    runTest(testCase, actual) {
        const result = {
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
                    result.differences = result.validation.errors.map((e) => `${e.path}: ${e.message}`);
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
    runAllTests(generateOutput) {
        return this.runTests(this.testCases, generateOutput);
    }
    /**
     * Run tests matching specific tags.
     */
    runTestsByTag(tags, generateOutput) {
        const filtered = this.testCases.filter((tc) => tags.some((tag) => tc.tags?.includes(tag)));
        return this.runTests(filtered, generateOutput);
    }
    /**
     * Run a set of tests.
     */
    async runTests(testCases, generateOutput) {
        const results = [];
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
    compareExact(actual, expected) {
        return JSON.stringify(actual) === JSON.stringify(expected);
    }
    /**
     * Find differences between two objects.
     */
    findDifferences(actual, expected) {
        const differences = [];
        const compare = (a, e, path) => {
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
                const aObj = a;
                const eObj = e;
                const allKeys = new Set([...Object.keys(aObj), ...Object.keys(eObj)]);
                for (const key of allKeys) {
                    if (!(key in aObj)) {
                        differences.push(`${path}.${key}: missing in actual`);
                    }
                    else if (!(key in eObj)) {
                        differences.push(`${path}.${key}: unexpected in actual`);
                    }
                    else {
                        compare(aObj[key], eObj[key], `${path}.${key}`);
                    }
                }
            }
            else if (a !== e) {
                differences.push(`${path}: ${String(a)} !== ${String(e)}`);
            }
        };
        compare(actual, expected, "$");
        return differences;
    }
    /**
     * Calculate similarity between two values.
     * Uses a simple structural similarity for objects.
     */
    calculateSimilarity(actual, expected) {
        // For non-objects, use exact match
        if (typeof actual !== "object" || typeof expected !== "object") {
            return actual === expected ? 1 : 0;
        }
        if (actual === null || expected === null) {
            return actual === expected ? 1 : 0;
        }
        const aObj = actual;
        const eObj = expected;
        const allKeys = new Set([...Object.keys(aObj), ...Object.keys(eObj)]);
        let matches = 0;
        for (const key of allKeys) {
            if (key in aObj && key in eObj) {
                if (typeof aObj[key] === "object" && typeof eObj[key] === "object") {
                    matches += this.calculateSimilarity(aObj[key], eObj[key]);
                }
                else if (aObj[key] === eObj[key]) {
                    matches += 1;
                }
                else {
                    matches += 0.5; // Partial credit for having the key
                }
            }
        }
        return allKeys.size > 0 ? matches / allKeys.size : 1;
    }
}
/**
 * Create a new golden test case from actual output.
 */
export function createGoldenFromOutput(id, description, input, output, comparison = "schema") {
    return {
        id,
        description,
        input,
        expected: output,
        comparison,
        tags: [],
    };
}

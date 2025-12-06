import { defineConfig } from "vitest/config";

/**
 * Vitest configuration for running golden tests.
 * Golden tests verify AI output consistency over time.
 *
 * Usage: pnpm test:golden
 */
export default defineConfig({
  test: {
    globals: true,
    environment: "node",
    include: ["src/**/*.golden.test.ts", "core/**/golden/*.test.ts"],
    testTimeout: 60000, // Golden tests may call LLMs
    retry: 0, // Don't retry - we want to see failures
    coverage: {
      enabled: false, // Coverage not meaningful for golden tests
    },
  },
});


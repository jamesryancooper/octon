/**
 * @harmony/prompts
 *
 * Canonical prompt library for Harmony AI agents.
 * Provides structured prompts with schemas, validation, and versioning.
 */

export { PromptCatalog, loadCatalog } from "./catalog.js";
export { PromptValidator, ValidationResult } from "./validator.js";
export { PromptLoader, LoadedPrompt } from "./loader.js";
export {
  GoldenTestManager,
  createGoldenFromOutput,
  type GoldenTestCase,
  type GoldenTestResult,
  type GoldenTestSummary,
} from "./golden.js";
export type { PromptConfig, PromptMetadata, PromptCategory } from "./types.js";

// Re-export utility functions
export { validateInput, validateOutput } from "./validator.js";
export { getPromptPath, listPrompts } from "./loader.js";


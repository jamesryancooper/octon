/**
 * @harmony/prompts
 *
 * Canonical prompt library for Harmony AI agents.
 * Provides structured prompts with schemas, validation, and versioning.
 */
export { PromptCatalog, loadCatalog } from "./catalog.js";
export { PromptValidator } from "./validator.js";
export { PromptLoader } from "./loader.js";
export { GoldenTestManager, createGoldenFromOutput, } from "./golden.js";
// Hallucination detection
export { checkForHallucinations, quickHallucinationCheck, validateWithHallucinationCheck, formatHallucinationReport, HALLUCINATION_INDICATORS, } from "./hallucination.js";
// Monitoring infrastructure
export { GoldenTestMonitor, generateWeeklySummary, } from "./monitoring.js";
// Re-export utility functions
export { validateInput, validateOutput } from "./validator.js";
export { getPromptPath, listPrompts } from "./loader.js";

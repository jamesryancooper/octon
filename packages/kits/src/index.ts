export * from "./flowkit";
export * from "./guardkit";
export * from "./costkit";

// Re-export PromptKit with explicit exports to avoid conflicts with CostKit
export { PromptKit } from "./promptkit";
export type {
  CompiledPrompt,
  CompileOptions,
  PromptInfo,
  PromptKitConfig,
  AssembleComponents,
  AssembledPrompt,
  AssembledMessage,
  TruncationStrategy,
  Variant,
  VariantConfig,
  VariantCondition,
  VariantContext,
  TokenBudgetOptions,
  TokenBudgetResult,
} from "./promptkit";
// Note: PromptMetadata from PromptKit conflicts with @harmony/prompts
// Use import { PromptMetadata as PromptKitMetadata } if needed

// Export PromptKit utilities with prefixed names to avoid conflicts
export {
  compileTemplate,
  validateTemplate,
  checkVariables,
  extractVariables,
  TemplateCompilationError,
} from "./promptkit/compiler";

export {
  computePromptHash,
  verifyPromptHash,
  redactSecrets,
  shortHash,
  combineHashes,
  parseHash,
} from "./promptkit/hasher";

export {
  applyTokenBudget,
  truncateToTokens,
  getTokenInfo,
  getContextWindow,
  calculateAvailableOutputTokens,
  fitsInContext,
  MODEL_CONTEXT_WINDOWS,
} from "./promptkit/tokens";

export {
  selectVariant,
  listVariants,
  validateVariants,
  isVariantEnabled,
  evaluateCondition,
  createContext as createVariantContext,
  getRecommendedVariantId,
  getTiersForVariant,
  DEFAULT_VARIANT_ID,
} from "./promptkit/variants";

export {
  assemble,
  formatAssembled,
  toOpenAIFormat,
  toAnthropicFormat,
  fromString as promptFromString,
  merge as mergePrompts,
  splitIfNeeded as splitPromptIfNeeded,
} from "./promptkit/assembler";

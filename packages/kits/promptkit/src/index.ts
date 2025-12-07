/**
 * PromptKit - Runtime prompt compiler for Harmony
 *
 * PromptKit is the runtime compiler/renderer that transforms static prompt
 * templates from @harmony/prompts into ready-to-use prompts with determinism
 * guarantees.
 *
 * @example
 * ```typescript
 * import { PromptKit } from '@harmony/kits/promptkit';
 *
 * const promptKit = new PromptKit();
 *
 * // Compile a prompt with variables
 * const compiled = promptKit.compile('spec-from-intent', {
 *   intent: 'Add user authentication to the API',
 *   context: { codebase: 'Node.js/TypeScript' },
 *   tier: 'T2',
 * });
 *
 * console.log(compiled.prompt);           // The rendered prompt
 * console.log(compiled.prompt_hash);      // sha256:abc123... (deterministic)
 * console.log(compiled.metadata.model);   // gpt-4o
 * ```
 */

import type {
  CompiledPrompt,
  CompileOptions,
  PromptInfo,
  PromptKitConfig,
  PromptMetadata,
  AssembleComponents,
  AssembledPrompt,
  RiskTier,
  VariantConfig,
  VariantContext,
} from "./types";

import {
  compileTemplate,
  validateTemplate,
  checkVariables,
  extractVariables,
} from "./compiler";

import { computePromptHash, redactSecrets, shortHash } from "./hasher";

import {
  estimateTokens,
  applyTokenBudget,
  getTokenInfo,
  getContextWindow,
} from "./tokens";

import {
  selectVariant,
  listVariants,
  validateVariants,
  DEFAULT_VARIANT_ID,
} from "./variants";

import { assemble, formatAssembled, toOpenAIFormat, toAnthropicFormat } from "./assembler";

// Node.js imports for variant template loading
import { readFileSync, existsSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

// Import from @harmony/prompts
import { PromptCatalog, PromptLoader, PromptValidator } from "@harmony/prompts";
import type { LoadedPrompt, PromptConfig } from "@harmony/prompts";

// OpenTelemetry for observability
import { SpanStatusCode } from "@opentelemetry/api";
import {
  getKitTracer,
  createKitSpan,
  getCurrentTraceId,
  type KitSpanContext,
} from "@harmony/kit-base";
import { InputValidationError } from "@harmony/kit-base";
import {
  createRunRecord,
  writeRunRecord,
  getRunsDirectory,
} from "@harmony/kit-base";

/** Kit metadata */
const KIT_NAME = "promptkit";
const KIT_VERSION = "0.1.0";

/**
 * Get kit span context for observability.
 */
function getSpanContext(): KitSpanContext {
  return {
    tracer: getKitTracer({ kitName: KIT_NAME, kitVersion: KIT_VERSION }),
    kitName: KIT_NAME,
    kitVersion: KIT_VERSION,
  };
}

// Get the prompts package root for resolving variant template paths
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

/**
 * PromptKit - Runtime prompt compiler.
 *
 * Transforms static prompt templates into ready-to-use prompts with:
 * - Template rendering (Nunjucks/Jinja2-like)
 * - Deterministic prompt hashing
 * - Variant selection
 * - Token budget management
 * - Role-based prompt assembly
 */
export class PromptKit {
  private catalog: PromptCatalog;
  private loader: PromptLoader;
  private validator: PromptValidator;
  private config: {
    promptsRoot?: string;
    catalogPath?: string;
    enableTracing: boolean;
    defaultModel: string;
    enableRunRecords: boolean;
    runsDir?: string;
  };

  constructor(config: PromptKitConfig = {}) {
    this.config = {
      promptsRoot: config.promptsRoot,
      catalogPath: config.catalogPath,
      enableTracing: config.enableTracing ?? false,
      defaultModel: config.defaultModel ?? "gpt-4o",
      enableRunRecords: config.enableRunRecords ?? false,
      runsDir: config.runsDir,
    };

    // Initialize from @harmony/prompts
    this.catalog = new PromptCatalog(this.config.catalogPath);
    this.loader = new PromptLoader(this.catalog, this.config.promptsRoot);
    this.validator = new PromptValidator();
  }

  /**
   * Compile a prompt with variables.
   *
   * This is the core method that:
   * 1. Loads the prompt template
   * 2. Selects the appropriate variant
   * 3. Renders the template with variables
   * 4. Computes a deterministic hash
   * 5. Applies token budget if specified
   *
   * Observability: Emits `kit.promptkit.compile` span.
   *
   * @param promptId - The prompt identifier (e.g., "spec-from-intent")
   * @param variables - Variables to substitute into the template
   * @param options - Compilation options
   * @returns The compiled prompt
   */
  compile(
    promptId: string,
    variables: Record<string, unknown>,
    options: CompileOptions = {}
  ): CompiledPrompt {
    // Create observability span
    const ctx = getSpanContext();
    const span = createKitSpan(ctx, "compile", {
      "prompt.id": promptId,
      "options.maxTokens": options.maxTokens,
      "options.variantId": options.variantId,
      "options.model": options.model,
    });

    try {
    // Load the prompt
    const loaded = this.loader.load(promptId);
    const promptConfig = loaded.config;

    // Determine tier from variables or default
    const tier = (variables.tier as RiskTier) || "T2";

    // Select variant
    const variantContext: VariantContext = {
      tier,
      stage: options.variantContext?.stage,
      flags: options.variantContext?.flags,
    };

    const variant = selectVariant(
      promptConfig.variants as Record<string, VariantConfig> | undefined,
      variantContext,
      options.variantId
    );

    // Get the template (use variant template if specified)
    let template = loaded.template;
    if (variant.templatePath && variant.id !== DEFAULT_VARIANT_ID) {
      // Load variant template from the prompts package
      // The templatePath is relative to the prompts package root (e.g., "./core/spec-from-intent/prompt-concise.md")
      const variantTemplatePath = resolve(loaded.directory, "..", variant.templatePath.replace(/^\.\//, "").replace(/^core\/[^/]+\//, ""));
      
      // Try loading from the prompt's directory first
      const directPath = resolve(loaded.directory, variant.templatePath.split("/").pop() || "");
      
      if (existsSync(directPath)) {
        template = readFileSync(directPath, "utf-8");
      } else if (existsSync(variantTemplatePath)) {
        template = readFileSync(variantTemplatePath, "utf-8");
      } else {
        // Fall back to default template with a warning
        console.warn(
          `[PromptKit] Variant template not found: ${variant.templatePath}, using default template`
        );
      }
    }

    // Render the template
    const renderedPrompt = compileTemplate(template, variables);

    // Apply token budget if specified
    let finalPrompt = renderedPrompt;
    let truncated = false;
    let truncationStrategy = options.truncationStrategy;

    if (options.maxTokens) {
      const model = options.model || this.getModelForTier(tier, options.variantContext?.stage);
      const budgetResult = applyTokenBudget(renderedPrompt, {
        maxTokens: options.maxTokens,
        reserveOutputTokens: options.reserveOutputTokens,
        strategy: options.truncationStrategy,
        model,
      });
      finalPrompt = budgetResult.text;
      truncated = budgetResult.truncated;
      truncationStrategy = budgetResult.strategy;
    }

    // Compute hash
    const promptHash = computePromptHash(
      finalPrompt,
      variables,
      promptId,
      promptConfig.version
    );

    // Get model
    const model =
      options.model || this.getModelForTier(tier, options.variantContext?.stage);

    // Estimate tokens
    const tokensEstimated = estimateTokens(finalPrompt, model);

    // Build metadata
    const metadata: PromptMetadata = {
      promptId,
      version: promptConfig.version,
      variant: variant.id,
      model,
      tokens_estimated: tokensEstimated,
      truncated,
      truncation_strategy: truncationStrategy,
    };

    const result = {
      prompt: finalPrompt,
      prompt_hash: promptHash,
      metadata,
      variables_used: redactSecrets(variables),
    };

    // Update span with results
    span.setAttribute("prompt.hash", promptHash);
    span.setAttribute("prompt.variant", variant.id);
    span.setAttribute("prompt.model", model);
    span.setAttribute("prompt.tokens", tokensEstimated);
    span.setAttribute("prompt.truncated", truncated);
    span.setStatus({ code: SpanStatusCode.OK });

    // Generate run record if enabled
    if (this.config.enableRunRecords) {
      const runRecord = createRunRecord({
        kit: { name: KIT_NAME, version: KIT_VERSION },
        inputs: { promptId, variables: redactSecrets(variables) },
        status: "success",
        summary: `Compiled prompt ${promptId} (${shortHash(promptHash)})`,
        stage: "implement",
        risk: "low",
        traceId: getCurrentTraceId() || promptHash,
        determinism: { prompt_hash: promptHash },
        ai: {
          provider: "openai", // Default, could be inferred from model
          model,
        },
      });

      const runsDir = this.config.runsDir || getRunsDirectory(process.cwd());
      writeRunRecord(runRecord, runsDir);
    }

    return result;
    } catch (error) {
      span.setStatus({
        code: SpanStatusCode.ERROR,
        message: error instanceof Error ? error.message : "Unknown error",
      });
      if (error instanceof Error) {
        span.recordException(error);
      }
      throw error;
    } finally {
      span.end();
    }
  }

  /**
   * Select a variant for a prompt.
   *
   * @param promptId - The prompt identifier
   * @param context - Context for variant selection
   * @returns The selected variant
   */
  selectVariant(promptId: string, context?: VariantContext) {
    const loaded = this.loader.load(promptId);
    const promptConfig = loaded.config;

    return selectVariant(
      promptConfig.variants as Record<string, VariantConfig> | undefined,
      context
    );
  }

  /**
   * Assemble components into a chat-format prompt.
   *
   * @param components - The prompt components
   * @param model - Model for token estimation
   * @returns Assembled prompt
   */
  assemble(components: AssembleComponents, model?: string): AssembledPrompt {
    return assemble(components, model || this.config.defaultModel);
  }

  /**
   * List all available prompts.
   */
  listPrompts(): string[] {
    return this.catalog.listPrompts();
  }

  /**
   * Get information about a prompt.
   *
   * @param promptId - The prompt identifier
   * @returns Prompt information
   */
  getPromptInfo(promptId: string): PromptInfo {
    const loaded = this.loader.load(promptId);
    const config = loaded.config;

    const variantList = listVariants(
      config.variants as Record<string, VariantConfig> | undefined
    );

    return {
      id: promptId,
      name: config.name,
      description: config.description,
      version: config.version,
      status: config.status,
      category: config.category,
      tierSupport: config.tier_support,
      variants: variantList.map((v) => v.id),
    };
  }

  /**
   * Validate that a prompt compiles correctly with given variables.
   *
   * @param promptId - The prompt identifier
   * @param variables - Variables to validate
   * @returns Validation result
   */
  validate(
    promptId: string,
    variables: Record<string, unknown>
  ): {
    valid: boolean;
    errors: string[];
    warnings: string[];
  } {
    const errors: string[] = [];
    const warnings: string[] = [];

    try {
      // Load and validate template
      const loaded = this.loader.load(promptId);

      // Check template syntax
      const templateValidation = validateTemplate(loaded.template);
      if (!templateValidation.valid) {
        errors.push(...templateValidation.errors);
      }

      // Check variables
      const variableCheck = checkVariables(loaded.template, variables);
      if (!variableCheck.complete) {
        errors.push(
          `Missing required variables: ${variableCheck.missing.join(", ")}`
        );
      }
      if (variableCheck.unused.length > 0) {
        warnings.push(
          `Unused variables provided: ${variableCheck.unused.join(", ")}`
        );
      }

      // Validate input against schema
      // Register the prompt's schemas with the validator first
      this.validator.registerPrompt(loaded);
      const inputValidation = this.validator.validateInput(promptId, variables);
      if (!inputValidation.valid) {
        errors.push(
          ...inputValidation.errors.map((e) => `Input validation: ${e.path} - ${e.message}`)
        );
      }

      // Check variant configuration
      const variantValidation = validateVariants(
        loaded.config.variants as Record<string, VariantConfig> | undefined
      );
      if (!variantValidation.valid) {
        errors.push(...variantValidation.errors);
      }
      warnings.push(...variantValidation.warnings);
    } catch (error) {
      errors.push(
        `Failed to load prompt: ${error instanceof Error ? error.message : String(error)}`
      );
    }

    return {
      valid: errors.length === 0,
      errors,
      warnings,
    };
  }

  /**
   * Get the recommended model for a tier.
   *
   * @param tier - Risk tier
   * @param stage - Workflow stage
   * @returns Model name
   */
  getModelForTier(tier: RiskTier, stage?: "draft" | "final"): string {
    return this.catalog.getModelForTier(tier, stage);
  }

  /**
   * Get token information for a compiled prompt.
   *
   * @param compiled - The compiled prompt
   * @returns Token information
   */
  getTokenInfo(compiled: CompiledPrompt) {
    return getTokenInfo(
      compiled.prompt,
      compiled.metadata.model,
      4096 // Default reserve for output
    );
  }

  /**
   * Get context window size for a model.
   *
   * @param model - Model name
   * @returns Context window size in tokens
   */
  getContextWindow(model: string): number {
    return getContextWindow(model);
  }

  /**
   * Format a compiled prompt for debugging.
   *
   * @param compiled - The compiled prompt
   * @returns Formatted string
   */
  formatCompiled(compiled: CompiledPrompt): string {
    const lines: string[] = [];

    lines.push("═══════════════════════════════════════");
    lines.push("Compiled Prompt");
    lines.push("═══════════════════════════════════════");
    lines.push(`Prompt ID: ${compiled.metadata.promptId}`);
    lines.push(`Version: ${compiled.metadata.version}`);
    lines.push(`Variant: ${compiled.metadata.variant}`);
    lines.push(`Model: ${compiled.metadata.model}`);
    lines.push(`Hash: ${shortHash(compiled.prompt_hash)}`);
    lines.push(`Tokens: ~${compiled.metadata.tokens_estimated.toLocaleString()}`);
    if (compiled.metadata.truncated) {
      lines.push(`⚠️ Truncated (${compiled.metadata.truncation_strategy})`);
    }
    lines.push("");
    lines.push("─── Prompt ─────────────────────────────");
    lines.push(compiled.prompt);
    lines.push("─────────────────────────────────────────");

    return lines.join("\n");
  }

  /**
   * Format an assembled prompt for debugging.
   */
  formatAssembled(assembled: AssembledPrompt): string {
    return formatAssembled(assembled);
  }

  /**
   * Convert assembled prompt to OpenAI API format.
   */
  toOpenAIFormat(assembled: AssembledPrompt) {
    return toOpenAIFormat(assembled);
  }

  /**
   * Convert assembled prompt to Anthropic API format.
   */
  toAnthropicFormat(assembled: AssembledPrompt) {
    return toAnthropicFormat(assembled);
  }

  /**
   * Get variables expected by a prompt.
   *
   * @param promptId - The prompt identifier
   * @returns Array of variable names
   */
  getExpectedVariables(promptId: string): string[] {
    const loaded = this.loader.load(promptId);
    return extractVariables(loaded.template);
  }

  /**
   * Reload the catalog and clear caches.
   */
  reload(): void {
    this.catalog.reload();
    this.loader.clearCache();
  }
}

// Re-export types
export type {
  CompiledPrompt,
  CompileOptions,
  PromptInfo,
  PromptKitConfig,
  PromptMetadata,
  AssembleComponents,
  AssembledPrompt,
  AssembledMessage,
  RiskTier,
  TruncationStrategy,
  Variant,
  VariantConfig,
  VariantCondition,
  VariantContext,
  TokenBudgetOptions,
  TokenBudgetResult,
} from "./types";

// Re-export compiler utilities
export {
  compileTemplate,
  validateTemplate,
  checkVariables,
  extractVariables,
  TemplateCompilationError,
} from "./compiler";

// Re-export hasher utilities
export {
  computePromptHash,
  verifyPromptHash,
  redactSecrets,
  shortHash,
  combineHashes,
  parseHash,
} from "./hasher";

// Re-export token utilities
export {
  estimateTokens,
  estimateTokenCount,
  applyTokenBudget,
  truncateToTokens,
  getTokenInfo,
  getContextWindow,
  calculateAvailableOutputTokens,
  fitsInContext,
  MODEL_CONTEXT_WINDOWS,
} from "./tokens";

// Re-export variant utilities
export {
  selectVariant,
  listVariants,
  validateVariants,
  isVariantEnabled,
  evaluateCondition,
  createContext,
  getRecommendedVariantId,
  getTiersForVariant,
  DEFAULT_VARIANT_ID,
} from "./variants";

// Re-export assembler utilities
export {
  assemble,
  formatAssembled,
  toOpenAIFormat,
  toAnthropicFormat,
  fromString,
  merge,
  splitIfNeeded,
} from "./assembler";


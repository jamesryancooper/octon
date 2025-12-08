/**
 * PromptKit Types
 *
 * Type definitions for the PromptKit runtime prompt compiler.
 */

/**
 * Risk tier classification for prompts.
 */
export type RiskTier = "T1" | "T2" | "T3";

/**
 * Truncation strategies for token budget management.
 */
export type TruncationStrategy =
  | "prioritize_recent"
  | "prioritize_start"
  | "balanced";

/**
 * A compiled, ready-to-use prompt.
 */
export interface CompiledPrompt {
  /** The fully rendered prompt text */
  prompt: string;

  /** Deterministic hash of the prompt (per AI-Toolkit policy) */
  prompt_hash: string;

  /** Prompt metadata */
  metadata: PromptMetadata;

  /** Input variables used (with secrets redacted) */
  variables_used: Record<string, unknown>;
}

/**
 * Metadata about a compiled prompt.
 */
export interface PromptMetadata {
  /** Prompt identifier (e.g., "spec-from-intent") */
  promptId: string;

  /** Prompt version from catalog */
  version: string;

  /** Selected variant (e.g., "default", "concise") */
  variant: string;

  /** Recommended model for this prompt/tier */
  model: string;

  /** Estimated token count for the prompt */
  tokens_estimated: number;

  /** Whether the prompt was truncated to fit budget */
  truncated: boolean;

  /** Truncation strategy used if truncated */
  truncation_strategy?: TruncationStrategy;
}

/**
 * Options for compiling a prompt.
 */
export interface CompileOptions {
  /** Specific variant to use (overrides automatic selection) */
  variantId?: string;

  /** Maximum tokens for the prompt (triggers truncation if exceeded) */
  maxTokens?: number;

  /** Tokens to reserve for LLM output */
  reserveOutputTokens?: number;

  /** Strategy for truncation when maxTokens is exceeded */
  truncationStrategy?: TruncationStrategy;

  /** Override the default model for this tier */
  model?: string;

  /** Additional context for variant selection */
  variantContext?: VariantContext;

  /**
   * Idempotency key for caching compiled prompts.
   * If not provided, derived from promptId and variablesHash.
   */
  idempotencyKey?: string;
}

/**
 * Context used for automatic variant selection.
 */
export interface VariantContext {
  /** Current risk tier */
  tier?: RiskTier;

  /** Active feature flags */
  flags?: Record<string, boolean>;

  /** Stage of the workflow (draft, final) */
  stage?: "draft" | "final";

  /** Additional custom context */
  [key: string]: unknown;
}

/**
 * A prompt variant configuration.
 */
export interface Variant {
  /** Variant identifier */
  id: string;

  /** Path to the variant's template file */
  templatePath: string;

  /** Human-readable description */
  description?: string;

  /** Conditions under which this variant is enabled */
  enabledWhen?: VariantCondition[];
}

/**
 * Condition for enabling a variant.
 */
export interface VariantCondition {
  /** Flag that must be true */
  flag?: string;

  /** Tier(s) that enable this variant */
  tier?: RiskTier[];

  /** Stage that enables this variant */
  stage?: "draft" | "final";
}

/**
 * Configuration for a variant in the catalog.
 */
export interface VariantConfig {
  /** Path to the template file */
  template_path: string;

  /** Human-readable description */
  description?: string;

  /** Conditions under which this variant is enabled */
  enabled_when?: VariantCondition[];
}

/**
 * Options for token budget management.
 */
export interface TokenBudgetOptions {
  /** Maximum tokens allowed */
  maxTokens: number;

  /** Tokens to reserve for output */
  reserveOutputTokens?: number;

  /** Truncation strategy */
  strategy?: TruncationStrategy;

  /** Model for accurate token counting */
  model?: string;
}

/**
 * Result of applying a token budget.
 */
export interface TokenBudgetResult {
  /** The (potentially truncated) text */
  text: string;

  /** Whether truncation occurred */
  truncated: boolean;

  /** Original token count */
  originalTokens: number;

  /** Final token count */
  finalTokens: number;

  /** Strategy used */
  strategy: TruncationStrategy;
}

/**
 * Components for role-based prompt assembly.
 */
export interface AssembleComponents {
  /** System prompt (optional) */
  system?: CompiledPrompt | string;

  /** User prompt (required) */
  user: CompiledPrompt | string;

  /** Assistant context (optional, for multi-turn) */
  assistant?: string;

  /** Tool/function descriptions (optional) */
  tools?: Array<CompiledPrompt | string>;
}

/**
 * A role-based assembled prompt (chat format).
 */
export interface AssembledPrompt {
  /** Messages in chat format */
  messages: AssembledMessage[];

  /** Combined prompt hash */
  prompt_hash: string;

  /** Total estimated tokens */
  tokens_estimated: number;

  /** Metadata from component prompts */
  components: {
    system?: PromptMetadata;
    user: PromptMetadata | { source: "string" };
    tools?: Array<PromptMetadata | { source: "string" }>;
  };
}

/**
 * A message in assembled prompt format.
 */
export interface AssembledMessage {
  /** Role: system, user, assistant, or tool */
  role: "system" | "user" | "assistant" | "tool";

  /** Message content */
  content: string;

  /** Optional tool name for tool messages */
  name?: string;
}

/**
 * Information about a prompt from the catalog.
 */
export interface PromptInfo {
  /** Prompt identifier */
  id: string;

  /** Human-readable name */
  name: string;

  /** Description */
  description: string;

  /** Current version */
  version: string;

  /** Status (stable, beta, deprecated) */
  status: "stable" | "beta" | "deprecated";

  /** Category */
  category: string;

  /** Supported tiers */
  tierSupport: RiskTier[];

  /** Available variants */
  variants: string[];
}

/**
 * Configuration for PromptKit initialization.
 */
export interface PromptKitConfig {
  /** Path to the prompts package root (auto-detected if not provided) */
  promptsRoot?: string;

  /** Path to the catalog file (defaults to catalog.yaml in promptsRoot) */
  catalogPath?: string;

  /** Enable observability spans */
  enableTracing?: boolean;

  /** Default model to use when tier doesn't specify */
  defaultModel?: string;

  /** Enable run record generation (default: true) */
  enableRunRecords?: boolean;

  /** Directory to write run records (default: ./runs) */
  runsDir?: string;
}

/**
 * Secret patterns for redaction.
 */
export const SECRET_PATTERNS = [
  /api[_-]?key/i,
  /secret/i,
  /password/i,
  /token/i,
  /auth/i,
  /credential/i,
  /private[_-]?key/i,
] as const;

/**
 * Check if a key looks like it contains sensitive data.
 */
export function isSensitiveKey(key: string): boolean {
  return SECRET_PATTERNS.some((pattern) => pattern.test(key));
}


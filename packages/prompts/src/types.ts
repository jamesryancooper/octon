/**
 * Type definitions for the Harmony prompt library.
 */

/**
 * Configuration for a single prompt in the catalog.
 */
export interface PromptConfig {
  /** Human-readable name */
  name: string;

  /** Description of what the prompt does */
  description: string;

  /** Current version (semver) */
  version: string;

  /** Status: stable, beta, deprecated */
  status: "stable" | "beta" | "deprecated";

  /** Category for organization */
  category: PromptCategory;

  /** Path to the prompt directory */
  path: string;

  /** Path to input JSON schema */
  input_schema: string;

  /** Path to output JSON schema */
  output_schema: string;

  /** Which tiers this prompt supports */
  tier_support: Array<"T1" | "T2" | "T3">;

  /** Runtime metrics (populated after usage) */
  metrics: PromptMetrics;

  /** Version changelog */
  changelog: ChangelogEntry[];
}

/**
 * Categories for organizing prompts.
 */
export type PromptCategory =
  | "planning"
  | "implementation"
  | "verification"
  | "security"
  | "documentation"
  | "maintenance";

/**
 * Metadata about a loaded prompt.
 */
export interface PromptMetadata {
  /** Unique identifier (e.g., "spec-from-intent") */
  id: string;

  /** Full configuration */
  config: PromptConfig;

  /** The prompt template content */
  template: string;

  /** Parsed input schema */
  inputSchema: object;

  /** Parsed output schema */
  outputSchema: object;
}

/**
 * Metrics tracked for each prompt.
 */
export interface PromptMetrics {
  /** Success rate (0-1) */
  success_rate: number | null;

  /** How often humans override AI output */
  human_override_rate: number | null;

  /** Average token usage */
  avg_tokens: number | null;
}

/**
 * Entry in the prompt changelog.
 */
export interface ChangelogEntry {
  version: string;
  date: string;
  changes: string;
}

/**
 * Default settings from the catalog.
 */
export interface CatalogDefaults {
  temperature: number;
  max_tokens: number;
  model_tier_mapping: {
    T1: string;
    T2_draft: string;
    T2_final: string;
    T3: string;
  };
}

/**
 * The full prompt catalog structure.
 */
export interface CatalogSchema {
  version: string;
  last_updated: string;
  defaults: CatalogDefaults;
  core_prompts: Record<string, PromptConfig>;
  categories: Record<
    string,
    {
      description: string;
      prompts: string[];
    }
  >;
  validation: {
    format: string;
    schema_validation: string;
    hallucination_checks: string[];
  };
  quality_gates: {
    min_success_rate: number;
    max_override_rate: number;
    require_golden_tests: boolean;
    min_golden_tests: number;
  };
}

/**
 * Tier type for risk classification.
 */
export type RiskTier = "T1" | "T2" | "T3";

/**
 * Input for running a prompt.
 */
export interface PromptInput {
  /** The prompt to run */
  promptId: string;

  /** Input data matching the prompt's input schema */
  input: unknown;

  /** Override the default model */
  model?: string;

  /** Override the default temperature */
  temperature?: number;

  /** Risk tier for model selection */
  tier?: RiskTier;
}

/**
 * Result of running a prompt.
 */
export interface PromptResult<T = unknown> {
  /** Whether the output passed validation */
  valid: boolean;

  /** The generated output */
  output: T;

  /** Validation errors if any */
  errors: string[];

  /** Token usage */
  tokens: {
    input: number;
    output: number;
    total: number;
  };

  /** Cost estimate in USD */
  cost_estimate: number;

  /** Model used */
  model: string;
}


/**
 * PromptKit HTTP Runner - HTTP client for remote PromptKit services.
 *
 * Enables cross-language consumption (Python agents, microservices) by
 * providing an HTTP interface that mirrors the programmatic API.
 *
 * ## Protocol
 *
 * The HTTP runner expects a remote service implementing:
 * - POST /prompt/compile - Compile a prompt with variables
 * - POST /prompt/validate - Validate variables against schema
 * - GET /prompt/info - Get prompt information from catalog
 * - GET /prompt/list - List available prompts
 *
 * @example
 * ```typescript
 * import { createHttpPromptRunner } from '@harmony/promptkit';
 *
 * const prompt = createHttpPromptRunner({
 *   baseUrl: 'http://localhost:8083',
 * });
 *
 * const compiled = await prompt.compile('spec-from-intent', {
 *   intent: 'Add user authentication',
 *   tier: 'T2',
 * });
 *
 * console.log(compiled.prompt_hash);
 * ```
 */

import {
  createKitHttpClient,
  type BaseHttpRunnerOptions,
  type KitHttpClient,
} from "@harmony/kit-base";

import type {
  CompiledPrompt,
  CompileOptions,
  PromptInfo,
  RiskTier,
} from "./types.js";

// ============================================================================
// Types
// ============================================================================

/**
 * Options for creating an HTTP-based PromptKit runner.
 */
export interface HttpPromptRunnerOptions extends BaseHttpRunnerOptions {
  /** Default model to use when tier doesn't specify */
  defaultModel?: string;
}

/**
 * Variables for prompt compilation (tier is commonly passed along).
 */
export interface CompileVariables extends Record<string, unknown> {
  /** Risk tier for model selection */
  tier?: RiskTier;
}

/**
 * Validation result from prompt validation.
 */
export interface ValidationResult {
  /** Whether validation passed */
  valid: boolean;

  /** Validation errors if any */
  errors?: Array<{
    path: string;
    message: string;
  }>;

  /** Missing required variables */
  missingVariables?: string[];

  /** Extra variables not in schema */
  extraVariables?: string[];
}

/**
 * Token count information.
 */
export interface TokenInfo {
  /** Estimated token count */
  estimated: number;

  /** Model used for estimation */
  model: string;

  /** Whether count is exact or estimated */
  exact: boolean;
}

/**
 * PromptKit runner interface - HTTP and local implementations share this contract.
 */
export interface PromptRunner {
  /**
   * Compile a prompt with variables.
   *
   * @param promptId - Prompt identifier (e.g., 'spec-from-intent')
   * @param variables - Variables to inject into the prompt
   * @param options - Compilation options
   * @returns Compiled prompt with metadata and hash
   */
  compile(
    promptId: string,
    variables: CompileVariables,
    options?: CompileOptions
  ): Promise<CompiledPrompt>;

  /**
   * Validate variables against prompt schema.
   *
   * @param promptId - Prompt identifier
   * @param variables - Variables to validate
   * @returns Validation result
   */
  validate(promptId: string, variables: CompileVariables): Promise<ValidationResult>;

  /**
   * Get information about a prompt from the catalog.
   *
   * @param promptId - Prompt identifier
   * @returns Prompt information
   */
  info(promptId: string): Promise<PromptInfo>;

  /**
   * List available prompts.
   *
   * @param category - Filter by category (optional)
   * @returns List of prompt information
   */
  list(category?: string): Promise<PromptInfo[]>;

  /**
   * Get token count for text.
   *
   * @param text - Text to count tokens for
   * @param model - Model to use for counting (optional)
   * @returns Token count information
   */
  tokens(text: string, model?: string): Promise<TokenInfo>;
}

// ============================================================================
// HTTP Runner Implementation
// ============================================================================

/**
 * Create an HTTP-based PromptKit runner.
 *
 * This is the standard adapter for connecting to a remote PromptKit service,
 * enabling cross-language consumption (Python agents, microservices, etc.).
 *
 * The HTTP runner mirrors the programmatic API 1:1, using the same request/response
 * types and error codes.
 *
 * @param options - Configuration for the HTTP runner
 * @returns A PromptRunner implementation
 *
 * @example
 * ```typescript
 * // Basic usage
 * const prompt = createHttpPromptRunner({
 *   baseUrl: 'http://localhost:8083',
 * });
 *
 * // With options
 * const prompt = createHttpPromptRunner({
 *   baseUrl: 'http://promptkit-service:8083',
 *   timeoutMs: 30000,
 *   headers: { 'X-API-Key': process.env.PROMPTKIT_API_KEY },
 *   defaultModel: 'gpt-4o',
 * });
 *
 * // Compile a prompt
 * const compiled = await prompt.compile('spec-from-intent', {
 *   intent: 'Add user authentication with Google OAuth',
 *   tier: 'T2',
 * }, {
 *   variantId: 'concise',
 *   maxTokens: 4000,
 * });
 *
 * // Validate before compiling
 * const validation = await prompt.validate('spec-from-intent', { intent: '' });
 * if (!validation.valid) {
 *   console.error('Validation errors:', validation.errors);
 * }
 * ```
 */
export function createHttpPromptRunner(options: HttpPromptRunnerOptions): PromptRunner {
  const client: KitHttpClient = createKitHttpClient({
    baseUrl: options.baseUrl,
    kitName: "promptkit",
    fetchImpl: options.fetchImpl,
    timeoutMs: options.timeoutMs,
    headers: options.headers,
  });

  return {
    async compile(
      promptId: string,
      variables: CompileVariables,
      compileOptions?: CompileOptions
    ): Promise<CompiledPrompt> {
      const response = await client.post<CompiledPrompt>("/prompt/compile", {
        promptId,
        variables,
        options: compileOptions,
      });
      return response.data;
    },

    async validate(promptId: string, variables: CompileVariables): Promise<ValidationResult> {
      const response = await client.post<ValidationResult>("/prompt/validate", {
        promptId,
        variables,
      });
      return response.data;
    },

    async info(promptId: string): Promise<PromptInfo> {
      const response = await client.get<PromptInfo>(`/prompt/info/${promptId}`);
      return response.data;
    },

    async list(category?: string): Promise<PromptInfo[]> {
      const response = await client.get<PromptInfo[]>("/prompt/list", {
        params: category ? { category } : undefined,
      });
      return response.data;
    },

    async tokens(text: string, model?: string): Promise<TokenInfo> {
      const response = await client.post<TokenInfo>("/prompt/tokens", {
        text,
        model: model ?? options.defaultModel,
      });
      return response.data;
    },
  };
}

/**
 * Placeholder/no-op PromptRunner.
 *
 * This default implementation exists so callers can depend on PromptKit types
 * without immediately wiring a runtime. In production, provide either:
 * - The `PromptKit` class for in-process usage
 * - `createHttpPromptRunner()` for remote service usage
 */
export const notImplementedPromptRunner: PromptRunner = {
  async compile(): Promise<CompiledPrompt> {
    throw new Error(
      "PromptKit notImplementedPromptRunner was called. Provide either a PromptKit instance or createHttpPromptRunner() for your runtime."
    );
  },

  async validate(): Promise<ValidationResult> {
    throw new Error(
      "PromptKit notImplementedPromptRunner was called. Provide either a PromptKit instance or createHttpPromptRunner() for your runtime."
    );
  },

  async info(): Promise<PromptInfo> {
    throw new Error(
      "PromptKit notImplementedPromptRunner was called. Provide either a PromptKit instance or createHttpPromptRunner() for your runtime."
    );
  },

  async list(): Promise<PromptInfo[]> {
    throw new Error(
      "PromptKit notImplementedPromptRunner was called. Provide either a PromptKit instance or createHttpPromptRunner() for your runtime."
    );
  },

  async tokens(): Promise<TokenInfo> {
    throw new Error(
      "PromptKit notImplementedPromptRunner was called. Provide either a PromptKit instance or createHttpPromptRunner() for your runtime."
    );
  },
};


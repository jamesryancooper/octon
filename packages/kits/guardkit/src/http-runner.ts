/**
 * GuardKit HTTP Runner - HTTP client for remote GuardKit services.
 *
 * Enables cross-language consumption (Python agents, microservices) by
 * providing an HTTP interface that mirrors the programmatic API.
 *
 * ## Protocol
 *
 * The HTTP runner expects a remote service implementing:
 * - POST /guard/check - Run full guardrail check
 * - POST /guard/sanitize - Sanitize content
 * - POST /guard/quick-check - Fast safety check
 *
 * @example
 * ```typescript
 * import { createHttpGuardRunner } from '@harmony/guardkit';
 *
 * const guard = createHttpGuardRunner({
 *   baseUrl: 'http://localhost:8081',
 * });
 *
 * const result = await guard.check('AI generated content');
 * if (!result.safe) {
 *   console.error('Issues found:', result.summary);
 * }
 * ```
 */

import {
  createKitHttpClient,
  type BaseHttpRunnerOptions,
  type KitHttpClient,
} from "@harmony/kit-base";

import type {
  GuardrailResult,
  SanitizeResult,
  SanitizeOptions,
  Severity,
} from "./types.js";

// ============================================================================
// Types
// ============================================================================

/**
 * Options for creating an HTTP-based GuardKit runner.
 */
export interface HttpGuardRunnerOptions extends BaseHttpRunnerOptions {
  /** Default severity threshold for blocking (can be overridden per-request) */
  blockThreshold?: Severity;
}

/**
 * Options for check requests.
 */
export interface CheckOptions {
  /** Override block threshold for this request */
  blockThreshold?: Severity;

  /** Enable injection checks */
  checkInjection?: boolean;

  /** Enable hallucination checks */
  checkHallucinations?: boolean;

  /** Enable secret detection */
  checkSecrets?: boolean;

  /** Enable PII detection */
  checkPii?: boolean;

  /** Enable code safety checks */
  checkCodeSafety?: boolean;
}

/**
 * GuardKit runner interface - HTTP and local implementations share this contract.
 */
export interface GuardRunner {
  /**
   * Run all guardrail checks on content.
   *
   * @param content - Content to check
   * @param options - Check options
   * @returns Guardrail result with check details
   */
  check(content: string, options?: CheckOptions): Promise<GuardrailResult>;

  /**
   * Sanitize content for safe use in prompts or storage.
   *
   * @param content - Content to sanitize
   * @param options - Sanitization options
   * @returns Sanitized content with modification details
   */
  sanitize(content: string, options?: SanitizeOptions): Promise<SanitizeResult>;

  /**
   * Quick safety check (fast, less thorough).
   *
   * @param content - Content to check
   * @returns Quick check result
   */
  quickCheck(content: string): Promise<{ safe: boolean; reason?: string }>;
}

// ============================================================================
// HTTP Runner Implementation
// ============================================================================

/**
 * Create an HTTP-based GuardKit runner.
 *
 * This is the standard adapter for connecting to a remote GuardKit service,
 * enabling cross-language consumption (Python agents, microservices, etc.).
 *
 * The HTTP runner mirrors the programmatic API 1:1, using the same request/response
 * types and error codes.
 *
 * @param options - Configuration for the HTTP runner
 * @returns A GuardRunner implementation
 *
 * @example
 * ```typescript
 * // Basic usage
 * const guard = createHttpGuardRunner({
 *   baseUrl: 'http://localhost:8081',
 * });
 *
 * // With options
 * const guard = createHttpGuardRunner({
 *   baseUrl: 'http://guardkit-service:8081',
 *   timeoutMs: 30000,
 *   headers: { 'X-API-Key': process.env.GUARDKIT_API_KEY },
 *   blockThreshold: 'high',
 * });
 *
 * // Check content
 * const result = await guard.check(aiOutput, {
 *   checkInjection: true,
 *   checkSecrets: true,
 * });
 * ```
 */
export function createHttpGuardRunner(options: HttpGuardRunnerOptions): GuardRunner {
  const client: KitHttpClient = createKitHttpClient({
    baseUrl: options.baseUrl,
    kitName: "guardkit",
    fetchImpl: options.fetchImpl,
    timeoutMs: options.timeoutMs,
    headers: options.headers,
  });

  return {
    async check(content: string, checkOptions?: CheckOptions): Promise<GuardrailResult> {
      const response = await client.post<GuardrailResult>("/guard/check", {
        content,
        options: {
          blockThreshold: checkOptions?.blockThreshold ?? options.blockThreshold ?? "high",
          checkInjection: checkOptions?.checkInjection ?? true,
          checkHallucinations: checkOptions?.checkHallucinations ?? true,
          checkSecrets: checkOptions?.checkSecrets ?? true,
          checkPii: checkOptions?.checkPii ?? true,
          checkCodeSafety: checkOptions?.checkCodeSafety ?? true,
        },
      });
      return response.data;
    },

    async sanitize(content: string, sanitizeOptions?: SanitizeOptions): Promise<SanitizeResult> {
      const response = await client.post<SanitizeResult>("/guard/sanitize", {
        content,
        options: sanitizeOptions,
      });
      return response.data;
    },

    async quickCheck(content: string): Promise<{ safe: boolean; reason?: string }> {
      const response = await client.post<{ safe: boolean; reason?: string }>("/guard/quick-check", {
        content,
      });
      return response.data;
    },
  };
}

/**
 * Placeholder/no-op GuardRunner.
 *
 * This default implementation exists so callers can depend on GuardKit types
 * without immediately wiring a runtime. In production, provide either:
 * - The `GuardKit` class for in-process usage
 * - `createHttpGuardRunner()` for remote service usage
 */
export const notImplementedGuardRunner: GuardRunner = {
  async check(): Promise<GuardrailResult> {
    throw new Error(
      "GuardKit notImplementedGuardRunner was called. Provide either a GuardKit instance or createHttpGuardRunner() for your runtime."
    );
  },

  async sanitize(): Promise<SanitizeResult> {
    throw new Error(
      "GuardKit notImplementedGuardRunner was called. Provide either a GuardKit instance or createHttpGuardRunner() for your runtime."
    );
  },

  async quickCheck(): Promise<{ safe: boolean; reason?: string }> {
    throw new Error(
      "GuardKit notImplementedGuardRunner was called. Provide either a GuardKit instance or createHttpGuardRunner() for your runtime."
    );
  },
};


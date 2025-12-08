/**
 * GuardKit Zod Schemas
 *
 * Runtime validation schemas for GuardKit inputs and outputs.
 */

import { z } from "zod";

// ============================================================================
// Input Schemas
// ============================================================================

/**
 * Block threshold levels.
 */
export const BlockThresholdSchema = z.enum(["critical", "high", "medium", "low"]);

/**
 * GuardKit configuration schema.
 */
export const GuardKitConfigSchema = z.object({
  /** Project root for import verification */
  projectRoot: z.string().optional(),

  /** Threshold at which content is blocked */
  blockThreshold: BlockThresholdSchema.default("high"),

  /** Enable run records (default: true) */
  enableRunRecords: z.boolean().default(true),

  /** Directory to write run records */
  runsDir: z.string().optional(),

  /** Dry-run mode */
  dryRun: z.boolean().default(false),

  /** Idempotency key */
  idempotencyKey: z.string().optional(),
});

/**
 * Check options schema.
 */
export const CheckOptionsSchema = z.object({
  /** Skip specific checks */
  skipChecks: z.array(z.string()).optional(),

  /** Additional context for checks */
  context: z.record(z.unknown()).optional(),

  /**
   * Idempotency key for caching check results.
   * If not provided, derived from content hash.
   */
  idempotencyKey: z.string().optional(),
});

// ============================================================================
// Output Schemas
// ============================================================================

/**
 * Severity levels.
 */
export const SeveritySchema = z.enum(["critical", "high", "medium", "low", "info"]);

/**
 * Guardrail category schema.
 */
export const GuardrailCategorySchema = z.enum([
  "prompt_injection",
  "hallucination",
  "pii_exposure",
  "secret_exposure",
  "schema_violation",
  "code_safety",
  "content_safety",
]);

/**
 * Location schema for check results - matches GuardrailCheckResult.location.
 */
export const CheckLocationSchema = z.object({
  start: z.number(),
  end: z.number(),
  context: z.string(),
});

/**
 * Individual guardrail check result schema - matches GuardrailCheckResult interface.
 */
export const GuardrailCheckResultSchema = z.object({
  /** Unique identifier for the check */
  checkId: z.string(),

  /** Human-readable name */
  name: z.string(),

  /** Category of the check */
  category: GuardrailCategorySchema,

  /** Whether the check passed */
  passed: z.boolean(),

  /** Severity if failed */
  severity: SeveritySchema.optional(),

  /** Detailed message */
  message: z.string(),

  /** Location in the content where issue was found */
  location: CheckLocationSchema.optional(),

  /** Suggested fix or action */
  suggestion: z.string().optional(),
});

/**
 * Guardrail result schema - matches GuardrailResult interface.
 */
export const GuardrailResultSchema = z.object({
  /** Whether all critical/high checks passed */
  safe: z.boolean(),

  /** Whether the content can proceed (passed or only low-severity issues) */
  canProceed: z.boolean(),

  /** Total checks run */
  totalChecks: z.number(),

  /** Checks passed */
  passedChecks: z.number(),

  /** Individual check results */
  checks: z.array(GuardrailCheckResultSchema),

  /** Summary of issues by severity */
  summary: z.record(SeveritySchema, z.number()),

  /** Timestamp of the check */
  timestamp: z.string(),
});

/**
 * Sanitize result schema - matches SanitizeResult interface.
 */
export const SanitizeResultSchema = z.object({
  /** Sanitized content */
  sanitized: z.string(),

  /** Original content */
  original: z.string(),

  /** Whether content was modified */
  modified: z.boolean(),

  /** Modifications made */
  modifications: z.array(z.string()),

  /** Content that was redacted (for logging) */
  redactions: z.array(z.string()),
});

/**
 * Quick check result schema.
 */
export const QuickCheckResultSchema = z.object({
  /** Whether content is safe */
  safe: z.boolean(),

  /** Reason if unsafe */
  reason: z.string().optional(),
});

// ============================================================================
// Type Exports
// ============================================================================

export type BlockThreshold = z.infer<typeof BlockThresholdSchema>;
export type GuardKitConfig = z.infer<typeof GuardKitConfigSchema>;
export type CheckOptions = z.infer<typeof CheckOptionsSchema>;
export type Severity = z.infer<typeof SeveritySchema>;
export type GuardrailCategory = z.infer<typeof GuardrailCategorySchema>;
export type CheckLocation = z.infer<typeof CheckLocationSchema>;
export type GuardrailCheckResult = z.infer<typeof GuardrailCheckResultSchema>;
export type GuardrailResult = z.infer<typeof GuardrailResultSchema>;
export type SanitizeResult = z.infer<typeof SanitizeResultSchema>;
export type QuickCheckResult = z.infer<typeof QuickCheckResultSchema>;

// ============================================================================
// Validation Functions
// ============================================================================

/**
 * Validate GuardKit configuration.
 */
export function validateGuardKitConfig(config: unknown): GuardKitConfig {
  return GuardKitConfigSchema.parse(config);
}

/**
 * Safe validation that returns a result instead of throwing.
 */
export function safeValidateGuardKitConfig(config: unknown): {
  success: boolean;
  data?: GuardKitConfig;
  error?: z.ZodError;
} {
  const result = GuardKitConfigSchema.safeParse(config);
  if (result.success) {
    return { success: true, data: result.data };
  }
  return { success: false, error: result.error };
}


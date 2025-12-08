/**
 * Zod-based schema validation for Harmony Kits.
 *
 * Provides runtime validation utilities that mirror the JSON Schema definitions
 * for kit inputs/outputs and metadata. Supports enforcement modes for graceful
 * methodology transitions (Methodology-as-Code sustainability).
 */

import { z } from "zod";
import { InputValidationError } from "./errors.js";

// ============================================================================
// Version Constants
// ============================================================================

/**
 * Current kit metadata schema version.
 */
export const CURRENT_SCHEMA_VERSION = "1.3.0";

/**
 * Current Harmony methodology version.
 */
export const CURRENT_METHODOLOGY_VERSION = "0.2.0";

/**
 * Minimum supported schema version (for backward compatibility).
 */
export const MIN_SUPPORTED_SCHEMA_VERSION = "1.0.0";

// ============================================================================
// Core Type Schemas
// ============================================================================

/**
 * Semver version pattern.
 */
export const SemverSchema = z.string().regex(/^\d+\.\d+\.\d+(-[A-Za-z0-9.-]+)?$/);

/**
 * Strict semver (no prerelease).
 */
export const StrictSemverSchema = z.string().regex(/^\d+\.\d+\.\d+$/);

/**
 * Harmony methodology pillars (structural methodology - rarely changes).
 */
export const HarmonyPillarSchema = z.enum([
  "speed_with_safety",
  "simplicity_over_complexity",
  "quality_through_determinism",
  "guided_agentic_autonomy",
  "evolvable_modularity",
]);

/**
 * Lifecycle stages in the Harmony methodology (structural - rarely changes).
 */
export const LifecycleStageSchema = z.enum([
  "spec",
  "plan",
  "implement",
  "verify",
  "ship",
  "operate",
  "learn",
]);

/**
 * Risk tier classification.
 */
export const RiskTierSchema = z.enum(["T1", "T2", "T3"]);

/**
 * Risk level for HITL gates.
 */
export const RiskLevelSchema = z.enum(["trivial", "low", "medium", "high"]);

/**
 * Run status.
 */
export const RunStatusSchema = z.enum(["success", "failure"]);

/**
 * Enforcement mode for policy and validation (Methodology-as-Code sustainability).
 * - block: Fail on violations (default)
 * - warn: Log warnings but proceed
 * - off: Skip validation entirely
 */
export const EnforcementModeSchema = z.enum(["block", "warn", "off"]);

/**
 * HITL checkpoint types.
 */
export const HITLCheckpointSchema = z.enum([
  "pre-implement",
  "pre-merge",
  "pre-promote",
  "post-promote",
]);

// ============================================================================
// Deprecation Schema
// ============================================================================

/**
 * Deprecation notice with migration guidance.
 */
export const DeprecationSchema = z.object({
  /** Dot-path to deprecated field */
  field: z.string(),
  /** Schema version when deprecation was introduced */
  since: StrictSemverSchema,
  /** Schema version when field will be removed */
  removeAt: StrictSemverSchema.optional(),
  /** Instructions for migrating away from deprecated field */
  migrationNote: z.string(),
});

// ============================================================================
// Kit Metadata Schemas (v1.2)
// ============================================================================

/**
 * Policy configuration schema (operational methodology - may evolve).
 */
export const PolicyConfigSchema = z.object({
  /** Reference to external ruleset */
  rulesetRef: z.string().optional(),
  /** Policy rules this kit enforces */
  rules: z.array(z.string()).optional(),
  /** Version of the ruleset */
  rulesetVersion: z.string().optional(),
  /** Enforcement mode for this kit's policy */
  enforcement: EnforcementModeSchema.default("block"),
  /** Whether to fail closed on policy check errors */
  failClosed: z.boolean().optional(),
});

/**
 * Observability configuration schema.
 */
export const ObservabilityConfigSchema = z.object({
  serviceName: z.string(),
  requiredSpans: z.array(z.string()),
  logRedaction: z.boolean().optional(),
});

/**
 * AI determinism configuration schema.
 */
export const AIConfigSchema = z.object({
  provider: z.string().optional(),
  model: z.string().optional(),
  temperatureMax: z.number().optional(),
  supportsSeed: z.boolean().optional(),
  promptHashAlgorithm: z.string().optional(),
});

/**
 * Determinism configuration schema.
 */
export const DeterminismConfigSchema = z.object({
  ai: AIConfigSchema.nullable().optional(),
  artifactNaming: z.string().optional(),
});

/**
 * HITL configuration schema.
 */
export const HITLConfigSchema = z.object({
  requiredFor: z.array(z.enum(["medium", "high"])).optional(),
});

/**
 * Safety configuration schema.
 */
export const SafetyConfigSchema = z.object({
  hitl: HITLConfigSchema.optional(),
});

/**
 * Idempotency configuration schema.
 */
export const IdempotencyConfigSchema = z.object({
  required: z.boolean().optional(),
  idempotencyKeyFrom: z.array(z.string()).optional(),
});

/**
 * Kit dependencies configuration schema (v1.3).
 * See ARCHITECTURE.md for dependency type semantics.
 */
export const DependenciesConfigSchema = z.object({
  /**
   * Runtime dependencies that must be available.
   * Circular requires are forbidden.
   */
  requires: z.array(z.string()).default([]),
  /**
   * Kits this kit controls/coordinates.
   * The orchestrated kit is unaware of the orchestrator.
   */
  orchestrates: z.array(z.string()).default([]),
  /**
   * Optional integration partners.
   * Bidirectional integratesWith is allowed.
   */
  integratesWith: z.array(z.string()).default([]),
});

/**
 * Compatibility configuration schema (expanded for Methodology-as-Code).
 */
export const CompatibilityConfigSchema = z.object({
  /** Minimum schema version this kit supports */
  minSchemaVersion: StrictSemverSchema.optional(),
  /** Maximum schema version this kit supports */
  maxSchemaVersion: StrictSemverSchema.optional(),
  /** Methodology versions this kit is compatible with */
  supportedMethodologyVersions: z.array(StrictSemverSchema).optional(),
  /** Contract versions this kit implements */
  contracts: z.array(z.string()).optional(),
  /**
   * @deprecated Use `dependencies` instead. Will be removed in v2.0.0.
   */
  kits: z.array(z.string()).optional(),
  /** Policy for breaking changes */
  breakingChangePolicy: z.string().optional(),
  /** Deprecated fields with migration information */
  deprecations: z.array(DeprecationSchema).optional(),
});

/**
 * Dry-run configuration schema.
 */
export const DryRunConfigSchema = z.object({
  supported: z.boolean().optional(),
});

/**
 * Complete kit metadata schema (v1.3 - with typed dependencies).
 * See ARCHITECTURE.md for Kit Granularity Policy.
 */
export const KitMetadataSchema = z.object({
  /** Schema version this metadata conforms to */
  schemaVersion: StrictSemverSchema.default(CURRENT_SCHEMA_VERSION),
  /** Methodology version this kit aligns with */
  methodologyVersion: StrictSemverSchema.default(CURRENT_METHODOLOGY_VERSION),
  /** Kit name */
  name: z.string(),
  /** Kit semantic version */
  version: SemverSchema,
  /** Human-readable description */
  description: z.string().optional(),
  /** Harmony pillars this kit reinforces */
  pillars: z.array(HarmonyPillarSchema).min(1),
  /** Lifecycle stages this kit participates in */
  lifecycleStages: z.array(LifecycleStageSchema).min(1),
  /** Path to inputs JSON schema */
  inputsSchema: z.string(),
  /** Path to outputs JSON schema */
  outputsSchema: z.string(),
  /**
   * Kit dependency declarations (v1.3).
   * See ARCHITECTURE.md for dependency type semantics.
   */
  dependencies: DependenciesConfigSchema.optional(),
  /** Policy configuration */
  policy: PolicyConfigSchema.optional(),
  /** Observability configuration */
  observability: ObservabilityConfigSchema,
  /** Determinism configuration */
  determinism: DeterminismConfigSchema,
  /** Safety configuration */
  safety: SafetyConfigSchema,
  /** Idempotency configuration */
  idempotency: IdempotencyConfigSchema,
  /** Compatibility and versioning */
  compatibility: CompatibilityConfigSchema.optional(),
  /** Dry-run support */
  dryRun: DryRunConfigSchema.optional(),
});

// ============================================================================
// Run Record Schema (v1.1)
// ============================================================================

/**
 * Run record schema for audit/replay.
 */
export const RunRecordSchema = z.object({
  /** Schema version this record conforms to */
  schemaVersion: StrictSemverSchema.default("1.1.0"),
  /** Methodology version active during this run */
  methodologyVersion: StrictSemverSchema.optional(),
  /** Stable run identifier */
  runId: z.string(),
  /** Kit that produced this record */
  kit: z.object({
    name: z.string(),
    version: z.string(),
    schemaVersion: StrictSemverSchema.optional(),
  }),
  /** Input parameters (secrets redacted) */
  inputs: z.record(z.unknown()),
  /** AI configuration if used */
  ai: z
    .object({
      provider: z.string().optional(),
      model: z.string().optional(),
      version: z.string().optional(),
      temperature: z.number().min(0).max(2).optional(),
      top_p: z.number().min(0).max(1).optional(),
      seed: z.union([z.number(), z.string()]).optional(),
    })
    .optional(),
  /** Artifacts produced */
  artifacts: z
    .array(
      z.object({
        path: z.string(),
        type: z.string(),
        hash: z.string().optional(),
      })
    )
    .optional(),
  /** Policy check results */
  policy: z
    .object({
      ruleset: z.string().optional(),
      rulesetVersion: z.string().optional(),
      checked: z.array(z.string()).optional(),
      result: z.enum(["pass", "fail"]).optional(),
      enforcement: EnforcementModeSchema.optional(),
    })
    .optional(),
  /** Evaluation results */
  eval: z
    .object({
      suite: z.string().optional(),
      score: z.number().optional(),
      threshold: z.number().optional(),
    })
    .optional(),
  /** Telemetry correlation */
  telemetry: z.object({
    trace_id: z.string(),
    spans: z.array(z.string()).optional(),
  }),
  /** Run status */
  status: RunStatusSchema,
  /** Human-readable summary */
  summary: z.string(),
  /** Lifecycle stage */
  stage: LifecycleStageSchema,
  /** Risk level */
  risk: RiskLevelSchema,
  /** HITL checkpoint information */
  hitl: z
    .object({
      checkpoint: HITLCheckpointSchema.optional(),
      state: z.enum(["approved", "rejected", "waived", "pending"]).optional(),
      approver: z.string().optional(),
      approvedAt: z.string().optional(),
      justification: z.string().optional(),
    })
    .optional(),
  /** Determinism tracking */
  determinism: z
    .object({
      prompt_hash: z.string().optional(),
      idempotencyKey: z.string().optional(),
      cacheKey: z.string().optional(),
    })
    .optional(),
  /** Deprecation warnings encountered */
  deprecationWarnings: z
    .array(
      z.object({
        field: z.string(),
        message: z.string(),
        removeAt: z.string().optional(),
      })
    )
    .optional(),
  /** ISO8601 timestamp */
  createdAt: z.string(),
  /** Duration in milliseconds */
  durationMs: z.number().int().min(0).optional(),
});

// ============================================================================
// Standard Kit Config Schemas
// ============================================================================

/**
 * Idempotency options schema for configuring idempotency behavior.
 */
export const IdempotencyOptionsSchema = z.object({
  /** Enable idempotency enforcement (default: true) */
  enabled: z.boolean().default(true),

  /**
   * Storage backend: "memory" | "durable"
   * - memory: In-memory, lost on process restart (fast CLI)
   * - durable: Backed by run records, survives restarts
   */
  storage: z.enum(["memory", "durable"]).default("durable"),

  /** Auto-derive keys when not provided (default: true) */
  autoDerive: z.boolean().default(true),

  /** TTL for pending operations in milliseconds (default: 1 hour) */
  pendingTtlMs: z.number().positive().default(60 * 60 * 1000),

  /** TTL for completed operations in milliseconds (default: 24 hours) */
  completedTtlMs: z.number().positive().default(24 * 60 * 60 * 1000),
});

/**
 * Base configuration schema that all kits should extend.
 */
export const BaseKitConfigSchema = z.object({
  /** Enable run record generation (default: true) */
  enableRunRecords: z.boolean().default(true),

  /** Directory to write run records */
  runsDir: z.string().optional(),

  /** Dry-run mode - validate without side effects */
  dryRun: z.boolean().default(false),

  /** Idempotency key for operations */
  idempotencyKey: z.string().optional(),

  /** Enforcement mode override (for testing/transitions) */
  enforcementMode: EnforcementModeSchema.optional(),

  /** Idempotency configuration */
  idempotency: IdempotencyOptionsSchema.optional(),
});

// ============================================================================
// Type Exports (only types unique to validation, not duplicating types.ts)
// ============================================================================

// Note: HarmonyPillar, LifecycleStage, RiskTier, RiskLevel, RunStatus, HITLCheckpoint
// are already exported from types.ts. We only export validation-specific types here.

export type EnforcementMode = z.infer<typeof EnforcementModeSchema>;
export type Deprecation = z.infer<typeof DeprecationSchema>;
export type PolicyConfig = z.infer<typeof PolicyConfigSchema>;
export type DependenciesConfig = z.infer<typeof DependenciesConfigSchema>;
export type ValidationObservabilityConfig = z.infer<
  typeof ObservabilityConfigSchema
>;
export type DeterminismConfig = z.infer<typeof DeterminismConfigSchema>;
export type SafetyConfig = z.infer<typeof SafetyConfigSchema>;
export type IdempotencyConfig = z.infer<typeof IdempotencyConfigSchema>;
export type IdempotencyOptions = z.infer<typeof IdempotencyOptionsSchema>;
export type CompatibilityConfig = z.infer<typeof CompatibilityConfigSchema>;
export type KitMetadataV = z.infer<typeof KitMetadataSchema>;
export type RunRecordV = z.infer<typeof RunRecordSchema>;
export type BaseKitConfig = z.infer<typeof BaseKitConfigSchema>;

// ============================================================================
// Validation Options and Results
// ============================================================================

/**
 * Validation options for enforcement mode support.
 */
export interface ValidationOptions {
  /** Enforcement mode: block (fail), warn (log), off (skip) */
  enforcementMode?: EnforcementMode;
  /** Whether to check for deprecation warnings */
  checkDeprecations?: boolean;
  /** Schema name for error messages */
  schemaName?: string;
}

/**
 * Deprecation warning.
 */
export interface DeprecationWarning {
  field: string;
  message: string;
  since: string;
  removeAt?: string;
}

/**
 * Validation result type with enforcement mode support.
 */
export interface ValidationResult<T> {
  success: boolean;
  data?: T;
  errors?: Array<{
    path: string;
    message: string;
  }>;
  /** Deprecation warnings (if checkDeprecations is enabled) */
  warnings?: DeprecationWarning[];
  /** Enforcement mode that was applied */
  enforcement?: EnforcementMode;
}

// ============================================================================
// Validation Functions
// ============================================================================

/**
 * Validate kit metadata against the Zod schema.
 * Use this for strict runtime validation with detailed error paths.
 */
export function validateKitMetadataStrict(
  metadata: unknown
): ValidationResult<KitMetadataV> {
  const result = KitMetadataSchema.safeParse(metadata);

  if (result.success) {
    return { success: true, data: result.data };
  }

  return {
    success: false,
    errors: result.error.errors.map((e) => ({
      path: e.path.join("."),
      message: e.message,
    })),
  };
}

/**
 * Validate and parse data against a Zod schema.
 * Throws InputValidationError on failure (unless enforcement mode is "warn" or "off").
 */
export function validateWithSchema<T extends z.ZodType>(
  schema: T,
  data: unknown,
  schemaName: string,
  options: ValidationOptions = {}
): z.infer<T> {
  const enforcement = options.enforcementMode ?? "block";

  // Skip validation in "off" mode
  if (enforcement === "off") {
    return data as z.infer<T>;
  }

  const result = schema.safeParse(data);

  if (result.success) {
    return result.data;
  }

  const validationErrors = result.error.errors.map((e) => ({
    path: e.path.join("."),
    message: e.message,
  }));

  // In "warn" mode, log warnings but return data as-is
  if (enforcement === "warn") {
    console.warn(
      `[WARN] Validation warnings for ${schemaName}: ${validationErrors.map((e) => `${e.path}: ${e.message}`).join("; ")}`
    );
    return data as z.infer<T>;
  }

  // In "block" mode (default), throw error
  throw new InputValidationError(
    `Validation failed for ${schemaName}: ${validationErrors.map((e) => `${e.path}: ${e.message}`).join("; ")}`,
    {
      schema: schemaName,
      validationErrors,
    }
  );
}

/**
 * Validate with enforcement mode support, returning a result instead of throwing.
 */
export function validateWithEnforcement<T extends z.ZodType>(
  schema: T,
  data: unknown,
  options: ValidationOptions = {}
): ValidationResult<z.infer<T>> {
  const enforcement = options.enforcementMode ?? "block";
  const schemaName = options.schemaName ?? "unknown";

  // Skip validation in "off" mode
  if (enforcement === "off") {
    return {
      success: true,
      data: data as z.infer<T>,
      enforcement,
    };
  }

  const result = schema.safeParse(data);

  if (result.success) {
    // Check for deprecation warnings if enabled
    const warnings = options.checkDeprecations
      ? checkDeprecations(data, options.schemaName)
      : undefined;

    return {
      success: true,
      data: result.data,
      warnings,
      enforcement,
    };
  }

  const errors = result.error.errors.map((e) => ({
    path: e.path.join("."),
    message: e.message,
  }));

  // In "warn" mode, return success but include errors as warnings
  if (enforcement === "warn") {
    console.warn(
      `[WARN] Validation warnings for ${schemaName}: ${errors.map((e) => `${e.path}: ${e.message}`).join("; ")}`
    );
    return {
      success: true,
      data: data as z.infer<T>,
      warnings: errors.map((e) => ({
        field: e.path,
        message: e.message,
        since: CURRENT_SCHEMA_VERSION,
      })),
      enforcement,
    };
  }

  // In "block" mode (default), return failure
  return {
    success: false,
    errors,
    enforcement,
  };
}

/**
 * Check for deprecated fields in data based on kit metadata.
 * Returns deprecation warnings for any deprecated fields found.
 */
export function checkDeprecations(
  data: unknown,
  schemaName?: string
): DeprecationWarning[] {
  const warnings: DeprecationWarning[] = [];

  // Check if data has compatibility.deprecations
  if (
    typeof data === "object" &&
    data !== null &&
    "compatibility" in data &&
    typeof (data as Record<string, unknown>).compatibility === "object"
  ) {
    const compat = (data as Record<string, unknown>).compatibility as Record<
      string,
      unknown
    >;
    if (Array.isArray(compat.deprecations)) {
      for (const dep of compat.deprecations) {
        if (typeof dep === "object" && dep !== null) {
          const d = dep as Record<string, unknown>;
          warnings.push({
            field: String(d.field ?? ""),
            message: String(d.migrationNote ?? "Field is deprecated"),
            since: String(d.since ?? CURRENT_SCHEMA_VERSION),
            removeAt: d.removeAt ? String(d.removeAt) : undefined,
          });
        }
      }
    }
  }

  return warnings;
}

/**
 * Create a validation function for a specific schema.
 */
export function createValidator<T extends z.ZodType>(
  schema: T,
  schemaName: string
): (data: unknown, options?: ValidationOptions) => z.infer<T> {
  return (data: unknown, options?: ValidationOptions) =>
    validateWithSchema(schema, data, schemaName, options);
}

/**
 * Safe validation that returns a result instead of throwing.
 */
export function safeValidate<T extends z.ZodType>(
  schema: T,
  data: unknown
): ValidationResult<z.infer<T>> {
  const result = schema.safeParse(data);

  if (result.success) {
    return { success: true, data: result.data };
  }

  return {
    success: false,
    errors: result.error.errors.map((e) => ({
      path: e.path.join("."),
      message: e.message,
    })),
  };
}

/**
 * Merge base kit config with kit-specific config.
 */
export function mergeWithBaseConfig<T extends z.ZodRawShape>(
  kitSpecificSchema: z.ZodObject<T>
) {
  return BaseKitConfigSchema.merge(kitSpecificSchema);
}

// ============================================================================
// Version Comparison Utilities
// ============================================================================

/**
 * Parse semver string into components.
 */
export function parseSemver(version: string): {
  major: number;
  minor: number;
  patch: number;
  prerelease?: string;
} {
  const match = version.match(
    /^(\d+)\.(\d+)\.(\d+)(?:-([A-Za-z0-9.-]+))?$/
  );
  if (!match) {
    throw new Error(`Invalid semver: ${version}`);
  }
  return {
    major: parseInt(match[1], 10),
    minor: parseInt(match[2], 10),
    patch: parseInt(match[3], 10),
    prerelease: match[4],
  };
}

/**
 * Compare two semver versions.
 * Returns: -1 if a < b, 0 if a == b, 1 if a > b
 */
export function compareSemver(a: string, b: string): -1 | 0 | 1 {
  const va = parseSemver(a);
  const vb = parseSemver(b);

  if (va.major !== vb.major) return va.major < vb.major ? -1 : 1;
  if (va.minor !== vb.minor) return va.minor < vb.minor ? -1 : 1;
  if (va.patch !== vb.patch) return va.patch < vb.patch ? -1 : 1;

  // Prerelease versions are less than release versions
  if (va.prerelease && !vb.prerelease) return -1;
  if (!va.prerelease && vb.prerelease) return 1;

  return 0;
}

/**
 * Check if a version is within a supported range.
 */
export function isVersionSupported(
  version: string,
  minVersion?: string,
  maxVersion?: string
): boolean {
  if (minVersion && compareSemver(version, minVersion) < 0) {
    return false;
  }
  if (maxVersion && compareSemver(version, maxVersion) > 0) {
    return false;
  }
  return true;
}

/**
 * Get the default enforcement mode based on environment.
 */
export function getDefaultEnforcementMode(): EnforcementMode {
  // Allow override via environment variable
  const envMode = process.env.HARMONY_ENFORCEMENT_MODE;
  if (envMode === "warn" || envMode === "off" || envMode === "block") {
    return envMode;
  }

  // Default to "warn" in development, "block" in production
  return process.env.NODE_ENV === "development" ? "warn" : "block";
}

// ============================================================================
// Re-export Zod for convenience
// ============================================================================

export { z } from "zod";

/**
 * Standard CLI flag parser for Harmony Kits.
 *
 * Provides consistent flag parsing across all kits with support for:
 * - --dry-run (default true in local)
 * - --stage (lifecycle stage)
 * - --risk (T1/T2/T3)
 * - --idempotency-key
 * - --cache-key
 * - --trace / --trace-parent
 */

import type { LifecycleStage, RiskTier, RiskLevel } from "./types.js";

/**
 * Standard flags supported by all kits.
 */
export interface StandardKitFlags {
  /** Dry-run mode - validate without side effects (default: true in local) */
  dryRun: boolean;

  /** Lifecycle stage for telemetry and governance */
  stage?: LifecycleStage;

  /** Risk tier (T1/T2/T3) */
  risk?: RiskTier;

  /** Risk level for gates */
  riskLevel?: RiskLevel;

  /** Idempotency key for mutating operations */
  idempotencyKey?: string;

  /** Cache key for pure/expensive operations */
  cacheKey?: string;

  /** Enable trace linking */
  trace?: boolean;

  /** Parent trace ID for correlation */
  traceParent?: string;

  /** Verbose output */
  verbose?: boolean;

  /** Output format (json, text) */
  format?: "json" | "text";
}

/**
 * Default flag values.
 */
export const DEFAULT_FLAGS: StandardKitFlags = {
  dryRun: process.env.HARMONY_ENV !== "prod" && process.env.HARMONY_ENV !== "preview",
  verbose: false,
  format: "text",
};

/**
 * Flag aliases for convenience.
 */
const FLAG_ALIASES: Record<string, keyof StandardKitFlags> = {
  "dry-run": "dryRun",
  n: "dryRun",
  s: "stage",
  r: "risk",
  i: "idempotencyKey",
  "idempotency-key": "idempotencyKey",
  c: "cacheKey",
  "cache-key": "cacheKey",
  t: "trace",
  "trace-parent": "traceParent",
  v: "verbose",
  f: "format",
};

/**
 * Parse a flag value based on expected type.
 */
function parseValue(key: keyof StandardKitFlags, value: string | boolean): unknown {
  // Boolean flags
  if (key === "dryRun" || key === "trace" || key === "verbose") {
    if (typeof value === "boolean") return value;
    return value === "true" || value === "1" || value === "";
  }

  // Enum flags
  if (key === "stage") {
    const validStages: LifecycleStage[] = [
      "spec", "plan", "implement", "verify", "ship", "operate", "learn"
    ];
    if (validStages.includes(value as LifecycleStage)) {
      return value;
    }
    throw new Error(`Invalid stage: ${value}. Must be one of: ${validStages.join(", ")}`);
  }

  if (key === "risk") {
    const validTiers: RiskTier[] = ["T1", "T2", "T3"];
    const upperValue = String(value).toUpperCase();
    if (validTiers.includes(upperValue as RiskTier)) {
      return upperValue;
    }
    throw new Error(`Invalid risk tier: ${value}. Must be one of: ${validTiers.join(", ")}`);
  }

  if (key === "riskLevel") {
    const validLevels: RiskLevel[] = ["trivial", "low", "medium", "high"];
    const lowerValue = String(value).toLowerCase();
    if (validLevels.includes(lowerValue as RiskLevel)) {
      return lowerValue;
    }
    throw new Error(`Invalid risk level: ${value}. Must be one of: ${validLevels.join(", ")}`);
  }

  if (key === "format") {
    if (value === "json" || value === "text") {
      return value;
    }
    throw new Error(`Invalid format: ${value}. Must be "json" or "text"`);
  }

  // String flags
  return String(value);
}

/**
 * Parse standard flags from command line arguments.
 *
 * Returns the parsed flags and remaining (non-flag) arguments.
 */
export function parseStandardFlags(
  args: string[]
): { flags: StandardKitFlags; remaining: string[] } {
  const flags: StandardKitFlags = { ...DEFAULT_FLAGS };
  const remaining: string[] = [];

  let i = 0;
  while (i < args.length) {
    const arg = args[i];

    // Stop parsing flags after --
    if (arg === "--") {
      remaining.push(...args.slice(i + 1));
      break;
    }

    // Check for long flags (--flag or --flag=value)
    if (arg.startsWith("--")) {
      const [rawKey, ...valueParts] = arg.slice(2).split("=");
      const key = rawKey.replace(/-/g, "");
      const mappedKey = FLAG_ALIASES[rawKey] || key as keyof StandardKitFlags;

      if (mappedKey in DEFAULT_FLAGS || mappedKey in FLAG_ALIASES || isStandardFlag(mappedKey)) {
        let value: string | boolean;

        if (valueParts.length > 0) {
          // --flag=value
          value = valueParts.join("=");
        } else if (
          i + 1 < args.length &&
          !args[i + 1].startsWith("-") &&
          !isBooleanFlag(mappedKey)
        ) {
          // --flag value
          value = args[++i];
        } else {
          // --flag (boolean)
          value = true;
        }

        try {
          (flags as unknown as Record<string, unknown>)[mappedKey] = parseValue(mappedKey, value);
        } catch (error) {
          throw error;
        }
      } else {
        // Unknown flag, pass through
        remaining.push(arg);
      }
      i++;
      continue;
    }

    // Check for short flags (-f or -f value)
    if (arg.startsWith("-") && arg.length === 2) {
      const shortKey = arg[1];
      const mappedKey = FLAG_ALIASES[shortKey];

      if (mappedKey) {
        let value: string | boolean;

        if (
          i + 1 < args.length &&
          !args[i + 1].startsWith("-") &&
          !isBooleanFlag(mappedKey)
        ) {
          value = args[++i];
        } else {
          value = true;
        }

        try {
          (flags as unknown as Record<string, unknown>)[mappedKey] = parseValue(mappedKey, value);
        } catch (error) {
          throw error;
        }
      } else {
        remaining.push(arg);
      }
      i++;
      continue;
    }

    // Not a flag, add to remaining
    remaining.push(arg);
    i++;
  }

  return { flags, remaining };
}

/**
 * Check if a key is a standard flag.
 */
function isStandardFlag(key: string): key is keyof StandardKitFlags {
  return key in DEFAULT_FLAGS ||
    ["stage", "risk", "riskLevel", "idempotencyKey", "cacheKey", "traceParent"].includes(key);
}

/**
 * Check if a flag is a boolean flag.
 */
function isBooleanFlag(key: keyof StandardKitFlags): boolean {
  return key === "dryRun" || key === "trace" || key === "verbose";
}

/**
 * Merge standard flags with kit-specific options.
 */
export function mergeFlags<T extends Record<string, unknown>>(
  standardFlags: StandardKitFlags,
  kitFlags: T
): StandardKitFlags & T {
  return {
    ...standardFlags,
    ...kitFlags,
  };
}

/**
 * Format flags for display.
 */
export function formatFlags(flags: StandardKitFlags): string {
  const lines: string[] = [];

  if (flags.dryRun) lines.push("--dry-run");
  if (flags.stage) lines.push(`--stage=${flags.stage}`);
  if (flags.risk) lines.push(`--risk=${flags.risk}`);
  if (flags.riskLevel) lines.push(`--risk-level=${flags.riskLevel}`);
  if (flags.idempotencyKey) lines.push(`--idempotency-key=${flags.idempotencyKey}`);
  if (flags.cacheKey) lines.push(`--cache-key=${flags.cacheKey}`);
  if (flags.trace) lines.push("--trace");
  if (flags.traceParent) lines.push(`--trace-parent=${flags.traceParent}`);
  if (flags.verbose) lines.push("--verbose");
  if (flags.format && flags.format !== "text") lines.push(`--format=${flags.format}`);

  return lines.join(" ");
}

/**
 * Generate help text for standard flags.
 */
export function getStandardFlagsHelp(): string {
  return `
Standard Flags:
  --dry-run, -n              Validate without side effects (default: true in local)
  --stage, -s <stage>        Lifecycle stage: spec|plan|implement|verify|ship|operate|learn
  --risk, -r <tier>          Risk tier: T1|T2|T3
  --risk-level <level>       Risk level: trivial|low|medium|high
  --idempotency-key, -i <key> Idempotency key for mutating operations
  --cache-key, -c <key>      Cache key for pure/expensive operations
  --trace, -t                Enable trace linking
  --trace-parent <id>        Parent trace ID for correlation
  --verbose, -v              Enable verbose output
  --format, -f <format>      Output format: json|text (default: text)
`.trim();
}

/**
 * Validate that required flags are present for a given risk level.
 */
export function validateFlagsForRisk(
  flags: StandardKitFlags,
  operationType: "mutating" | "pure" | "side-effect"
): { valid: boolean; errors: string[] } {
  const errors: string[] = [];

  // Mutating operations require idempotency key
  if (operationType === "mutating" && !flags.idempotencyKey && !flags.dryRun) {
    errors.push("Mutating operations require --idempotency-key when not in dry-run mode");
  }

  // High-risk operations require explicit stage and risk
  if (flags.riskLevel === "high" || flags.riskLevel === "medium") {
    if (!flags.stage) {
      errors.push("Medium/high risk operations require --stage");
    }
    if (!flags.risk) {
      errors.push("Medium/high risk operations require --risk tier");
    }
  }

  return {
    valid: errors.length === 0,
    errors,
  };
}


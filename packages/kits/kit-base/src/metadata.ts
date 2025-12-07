/**
 * Kit metadata types and loading utilities.
 *
 * Kit metadata follows the Harmony methodology v0.2 specification
 * for machine-readable kit configuration.
 */

import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import type { HarmonyPillar, LifecycleStage } from "./types.js";

/**
 * Observability configuration for a kit.
 */
export interface KitObservabilityConfig {
  /** Service name for OTel (e.g., "harmony.kit.flowkit") */
  serviceName: string;

  /** Required span names this kit must emit */
  requiredSpans: string[];

  /** Whether log redaction is enabled by default */
  logRedaction?: boolean;
}

/**
 * AI determinism configuration.
 */
export interface KitDeterminismConfig {
  ai?: {
    provider?: string;
    model?: string;
    temperatureMax?: number;
    supportsSeed?: boolean;
    promptHashAlgorithm?: string;
  };
  artifactNaming?: string;
}

/**
 * Safety configuration.
 */
export interface KitSafetyConfig {
  hitl?: {
    requiredFor?: Array<"medium" | "high">;
  };
}

/**
 * Idempotency configuration.
 */
export interface KitIdempotencyConfig {
  required?: boolean;
  idempotencyKeyFrom?: string[];
}

/**
 * Compatibility and versioning.
 */
export interface KitCompatibilityConfig {
  contracts?: string[];
  kits?: string[];
  breakingChangePolicy?: string;
  deprecatedSince?: string;
}

/**
 * Policy configuration.
 */
export interface KitPolicyConfig {
  rules?: string[];
  rulesetVersion?: string;
  failClosed?: boolean;
}

/**
 * Complete kit metadata conforming to methodology v0.2.
 */
export interface KitMetadata {
  /** Kit name (e.g., "flowkit") */
  name: string;

  /** Semantic version */
  version: string;

  /** Human-readable description */
  description?: string;

  /** Pillars this kit reinforces */
  pillars: HarmonyPillar[];

  /** Lifecycle stages this kit participates in */
  lifecycleStages: LifecycleStage[];

  /** Path to inputs JSON schema */
  inputsSchema: string;

  /** Path to outputs JSON schema */
  outputsSchema: string;

  /** Policy configuration */
  policy?: KitPolicyConfig;

  /** Observability configuration */
  observability: KitObservabilityConfig;

  /** Determinism configuration */
  determinism?: KitDeterminismConfig;

  /** Safety configuration */
  safety?: KitSafetyConfig;

  /** Idempotency configuration */
  idempotency?: KitIdempotencyConfig;

  /** Compatibility configuration */
  compatibility?: KitCompatibilityConfig;

  /** Dry-run support */
  dryRun?: {
    supported: boolean;
  };
}

/**
 * Validation result for kit metadata.
 */
export interface MetadataValidationResult {
  valid: boolean;
  errors: string[];
  warnings: string[];
}

/**
 * Required fields for kit metadata.
 */
const REQUIRED_FIELDS: Array<keyof KitMetadata> = [
  "name",
  "version",
  "pillars",
  "lifecycleStages",
  "inputsSchema",
  "outputsSchema",
  "observability",
];

/**
 * Valid pillar values.
 */
const VALID_PILLARS: HarmonyPillar[] = [
  "speed_with_safety",
  "simplicity_over_complexity",
  "quality_through_determinism",
  "guided_agentic_autonomy",
  "evolvable_modularity",
];

/**
 * Valid lifecycle stages.
 */
const VALID_STAGES: LifecycleStage[] = [
  "spec",
  "plan",
  "implement",
  "verify",
  "ship",
  "operate",
  "learn",
];

/**
 * Load kit metadata from a file.
 */
export function loadKitMetadata(metadataPath: string): KitMetadata {
  if (!existsSync(metadataPath)) {
    throw new Error(`Kit metadata file not found: ${metadataPath}`);
  }

  const content = readFileSync(metadataPath, "utf-8");
  const metadata = JSON.parse(content) as KitMetadata;

  const validation = validateKitMetadata(metadata);
  if (!validation.valid) {
    throw new Error(
      `Invalid kit metadata: ${validation.errors.join(", ")}`
    );
  }

  return metadata;
}

/**
 * Load kit metadata from a kit package directory.
 */
export function loadKitMetadataFromPackage(kitPath: string): KitMetadata {
  const metadataPath = join(kitPath, "metadata", "kit.metadata.json");
  return loadKitMetadata(metadataPath);
}

/**
 * Validate kit metadata.
 */
export function validateKitMetadata(
  metadata: unknown
): MetadataValidationResult {
  const errors: string[] = [];
  const warnings: string[] = [];

  if (!metadata || typeof metadata !== "object") {
    return {
      valid: false,
      errors: ["Metadata must be an object"],
      warnings: [],
    };
  }

  const md = metadata as Record<string, unknown>;

  // Check required fields
  for (const field of REQUIRED_FIELDS) {
    if (!(field in md)) {
      errors.push(`Missing required field: ${field}`);
    }
  }

  // Validate name
  if (md.name && typeof md.name !== "string") {
    errors.push("name must be a string");
  }

  // Validate version
  if (md.version && typeof md.version !== "string") {
    errors.push("version must be a string");
  } else if (md.version && !/^\d+\.\d+\.\d+/.test(md.version as string)) {
    warnings.push("version should follow semver format");
  }

  // Validate pillars
  if (md.pillars) {
    if (!Array.isArray(md.pillars)) {
      errors.push("pillars must be an array");
    } else {
      for (const pillar of md.pillars) {
        if (!VALID_PILLARS.includes(pillar as HarmonyPillar)) {
          errors.push(`Invalid pillar: ${pillar}`);
        }
      }
    }
  }

  // Validate lifecycleStages
  if (md.lifecycleStages) {
    if (!Array.isArray(md.lifecycleStages)) {
      errors.push("lifecycleStages must be an array");
    } else {
      for (const stage of md.lifecycleStages) {
        if (!VALID_STAGES.includes(stage as LifecycleStage)) {
          errors.push(`Invalid lifecycle stage: ${stage}`);
        }
      }
    }
  }

  // Validate observability
  if (md.observability) {
    const obs = md.observability as Record<string, unknown>;
    if (!obs.serviceName) {
      errors.push("observability.serviceName is required");
    }
    if (!obs.requiredSpans || !Array.isArray(obs.requiredSpans)) {
      errors.push("observability.requiredSpans must be an array");
    }
  }

  // Validate schema paths
  if (md.inputsSchema && typeof md.inputsSchema !== "string") {
    errors.push("inputsSchema must be a string path");
  }
  if (md.outputsSchema && typeof md.outputsSchema !== "string") {
    errors.push("outputsSchema must be a string path");
  }

  return {
    valid: errors.length === 0,
    errors,
    warnings,
  };
}

/**
 * Create a minimal valid kit metadata object.
 */
export function createKitMetadata(options: {
  name: string;
  version: string;
  description?: string;
  pillars: HarmonyPillar[];
  lifecycleStages: LifecycleStage[];
  requiredSpans: string[];
}): KitMetadata {
  return {
    name: options.name,
    version: options.version,
    description: options.description,
    pillars: options.pillars,
    lifecycleStages: options.lifecycleStages,
    inputsSchema: `schema/${options.name}.inputs.v1.json`,
    outputsSchema: `schema/${options.name}.outputs.v1.json`,
    observability: {
      serviceName: `harmony.kit.${options.name}`,
      requiredSpans: options.requiredSpans,
      logRedaction: true,
    },
    dryRun: {
      supported: true,
    },
  };
}

/**
 * Get the expected schema paths for a kit.
 */
export function getSchemaPathsForKit(
  kitName: string,
  version = "v1"
): { inputs: string; outputs: string } {
  return {
    inputs: `schema/${kitName}.inputs.${version}.json`,
    outputs: `schema/${kitName}.outputs.${version}.json`,
  };
}

/**
 * Format kit metadata for display.
 */
export function formatKitMetadata(metadata: KitMetadata): string {
  const lines: string[] = [];

  lines.push(`Kit: ${metadata.name} v${metadata.version}`);
  if (metadata.description) {
    lines.push(`Description: ${metadata.description}`);
  }
  lines.push(`Pillars: ${metadata.pillars.join(", ")}`);
  lines.push(`Lifecycle: ${metadata.lifecycleStages.join(", ")}`);
  lines.push(`Service: ${metadata.observability.serviceName}`);
  lines.push(`Spans: ${metadata.observability.requiredSpans.join(", ")}`);

  return lines.join("\n");
}


/**
 * PromptKit Variant Selection
 *
 * Handles automatic and manual selection of prompt variants
 * based on context (tier, flags, stage).
 */

import type {
  Variant,
  VariantCondition,
  VariantConfig,
  VariantContext,
  RiskTier,
} from "./types";

/**
 * Default variant identifier.
 */
export const DEFAULT_VARIANT_ID = "default";

/**
 * Select the appropriate variant for a prompt.
 *
 * @param variants - Map of variant ID to config
 * @param context - Context for variant selection
 * @param explicitVariantId - Explicit variant override (optional)
 * @returns The selected variant
 */
export function selectVariant(
  variants: Record<string, VariantConfig> | undefined,
  context: VariantContext = {},
  explicitVariantId?: string
): Variant {
  // If no variants defined, return default
  if (!variants || Object.keys(variants).length === 0) {
    return {
      id: DEFAULT_VARIANT_ID,
      templatePath: "", // Will use default path
      description: "Default variant (no variants configured)",
    };
  }

  // If explicit variant requested, use it
  if (explicitVariantId) {
    const explicitVariant = variants[explicitVariantId];
    if (explicitVariant) {
      return {
        id: explicitVariantId,
        templatePath: explicitVariant.template_path,
        description: explicitVariant.description,
        enabledWhen: explicitVariant.enabled_when,
      };
    }
    // Explicit variant not found, fall through to auto-selection
    console.warn(
      `[PromptKit] Requested variant "${explicitVariantId}" not found, using auto-selection`
    );
  }

  // Find first matching variant based on context
  for (const [variantId, config] of Object.entries(variants)) {
    if (variantId === DEFAULT_VARIANT_ID) continue; // Check default last

    if (isVariantEnabled(config, context)) {
      return {
        id: variantId,
        templatePath: config.template_path,
        description: config.description,
        enabledWhen: config.enabled_when,
      };
    }
  }

  // Fall back to default variant
  const defaultConfig = variants[DEFAULT_VARIANT_ID];
  if (defaultConfig) {
    return {
      id: DEFAULT_VARIANT_ID,
      templatePath: defaultConfig.template_path,
      description: defaultConfig.description,
      enabledWhen: defaultConfig.enabled_when,
    };
  }

  // If no default, use first available
  const [firstId, firstConfig] = Object.entries(variants)[0];
  return {
    id: firstId,
    templatePath: firstConfig.template_path,
    description: firstConfig.description,
    enabledWhen: firstConfig.enabled_when,
  };
}

/**
 * Check if a variant is enabled based on its conditions and context.
 *
 * @param config - Variant configuration
 * @param context - Current context
 * @returns Whether the variant is enabled
 */
export function isVariantEnabled(
  config: VariantConfig,
  context: VariantContext
): boolean {
  const conditions = config.enabled_when;

  // No conditions = always enabled
  if (!conditions || conditions.length === 0) {
    return true;
  }

  // All conditions must match
  return conditions.every((condition) => evaluateCondition(condition, context));
}

/**
 * Evaluate a single variant condition.
 *
 * @param condition - The condition to evaluate
 * @param context - The context to evaluate against
 * @returns Whether the condition is met
 */
export function evaluateCondition(
  condition: VariantCondition,
  context: VariantContext
): boolean {
  // Check flag condition
  if (condition.flag) {
    const flagValue = context.flags?.[condition.flag];
    if (!flagValue) {
      return false;
    }
  }

  // Check tier condition
  if (condition.tier) {
    if (!context.tier) {
      return false;
    }
    if (!condition.tier.includes(context.tier)) {
      return false;
    }
  }

  // Check stage condition
  if (condition.stage) {
    if (context.stage !== condition.stage) {
      return false;
    }
  }

  return true;
}

/**
 * List all variants for a prompt.
 *
 * @param variants - Map of variant configs
 * @returns Array of variant information
 */
export function listVariants(
  variants: Record<string, VariantConfig> | undefined
): Array<{
  id: string;
  description?: string;
  conditions: string[];
}> {
  if (!variants) {
    return [
      {
        id: DEFAULT_VARIANT_ID,
        description: "Default (no variants configured)",
        conditions: [],
      },
    ];
  }

  return Object.entries(variants).map(([id, config]) => ({
    id,
    description: config.description,
    conditions: formatConditions(config.enabled_when),
  }));
}

/**
 * Format variant conditions for display.
 */
function formatConditions(conditions?: VariantCondition[]): string[] {
  if (!conditions || conditions.length === 0) {
    return ["Always enabled"];
  }

  return conditions.map((c) => {
    const parts: string[] = [];

    if (c.flag) {
      parts.push(`flag:${c.flag}`);
    }
    if (c.tier) {
      parts.push(`tier:[${c.tier.join(",")}]`);
    }
    if (c.stage) {
      parts.push(`stage:${c.stage}`);
    }

    return parts.join(" AND ");
  });
}

/**
 * Create a context from common inputs.
 *
 * @param tier - Risk tier
 * @param stage - Workflow stage
 * @param flags - Feature flags
 * @returns Variant context
 */
export function createContext(
  tier?: RiskTier,
  stage?: "draft" | "final",
  flags?: Record<string, boolean>
): VariantContext {
  return {
    tier,
    stage,
    flags,
  };
}

/**
 * Get the recommended variant for a tier.
 * This is a convenience function for common tier-based selection.
 *
 * @param variants - Map of variant configs
 * @param tier - Risk tier
 * @param stage - Workflow stage (optional)
 * @returns The recommended variant ID
 */
export function getRecommendedVariantId(
  variants: Record<string, VariantConfig> | undefined,
  tier: RiskTier,
  stage?: "draft" | "final"
): string {
  const context = createContext(tier, stage);
  const variant = selectVariant(variants, context);
  return variant.id;
}

/**
 * Validate variant configuration.
 *
 * @param variants - Map of variant configs to validate
 * @returns Validation result
 */
export function validateVariants(
  variants: Record<string, VariantConfig> | undefined
): VariantValidationResult {
  const errors: string[] = [];
  const warnings: string[] = [];

  if (!variants || Object.keys(variants).length === 0) {
    return {
      valid: true,
      errors: [],
      warnings: ["No variants configured - using default template path"],
    };
  }

  // Check for default variant
  if (!variants[DEFAULT_VARIANT_ID]) {
    warnings.push(
      'No "default" variant defined - first variant will be used as fallback'
    );
  }

  // Validate each variant
  for (const [id, config] of Object.entries(variants)) {
    // Check template path
    if (!config.template_path) {
      errors.push(`Variant "${id}": missing template_path`);
    }

    // Check conditions
    if (config.enabled_when) {
      for (let i = 0; i < config.enabled_when.length; i++) {
        const condition = config.enabled_when[i];

        // Validate tier values
        if (condition.tier) {
          const validTiers: RiskTier[] = ["T1", "T2", "T3"];
          for (const tier of condition.tier) {
            if (!validTiers.includes(tier)) {
              errors.push(
                `Variant "${id}" condition ${i}: invalid tier "${tier}"`
              );
            }
          }
        }

        // Validate stage values
        if (condition.stage && !["draft", "final"].includes(condition.stage)) {
          errors.push(
            `Variant "${id}" condition ${i}: invalid stage "${condition.stage}"`
          );
        }
      }
    }
  }

  return {
    valid: errors.length === 0,
    errors,
    warnings,
  };
}

/**
 * Result of variant validation.
 */
export interface VariantValidationResult {
  valid: boolean;
  errors: string[];
  warnings: string[];
}

/**
 * Find all tiers that would use a specific variant.
 *
 * @param variantId - The variant to check
 * @param variants - Map of variant configs
 * @returns Array of tiers that would select this variant
 */
export function getTiersForVariant(
  variantId: string,
  variants: Record<string, VariantConfig> | undefined
): RiskTier[] {
  const tiers: RiskTier[] = ["T1", "T2", "T3"];
  const result: RiskTier[] = [];

  for (const tier of tiers) {
    const context = createContext(tier);
    const selected = selectVariant(variants, context);
    if (selected.id === variantId) {
      result.push(tier);
    }
  }

  return result;
}


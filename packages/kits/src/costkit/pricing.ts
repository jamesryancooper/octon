/**
 * CostKit Pricing Data - LLM model pricing information.
 *
 * Pricing is per 1 million tokens and should be updated periodically.
 * Last verified: January 2025
 *
 * Sources:
 * - OpenAI: https://openai.com/pricing
 * - Anthropic: https://anthropic.com/pricing
 * - Google: https://ai.google.dev/pricing
 * - Mistral: https://mistral.ai/technology/#pricing
 */

import type { ModelPricing, LLMProvider } from "./types.js";

/**
 * Current model pricing data.
 * Prices are in USD per 1 million tokens.
 */
export const MODEL_PRICING: ModelPricing[] = [
  // ============================================================================
  // OpenAI Models
  // ============================================================================
  {
    model: "gpt-4o",
    provider: "openai",
    inputPricePer1M: 2.5,
    outputPricePer1M: 10.0,
    contextWindow: 128000,
    maxOutputTokens: 16384,
    updatedAt: "2025-01-15",
  },
  {
    model: "gpt-4o-2024-11-20",
    provider: "openai",
    inputPricePer1M: 2.5,
    outputPricePer1M: 10.0,
    contextWindow: 128000,
    maxOutputTokens: 16384,
    updatedAt: "2025-01-15",
  },
  {
    model: "gpt-4o-mini",
    provider: "openai",
    inputPricePer1M: 0.15,
    outputPricePer1M: 0.6,
    contextWindow: 128000,
    maxOutputTokens: 16384,
    updatedAt: "2025-01-15",
  },
  {
    model: "gpt-4o-mini-2024-07-18",
    provider: "openai",
    inputPricePer1M: 0.15,
    outputPricePer1M: 0.6,
    contextWindow: 128000,
    maxOutputTokens: 16384,
    updatedAt: "2025-01-15",
  },
  {
    model: "gpt-4-turbo",
    provider: "openai",
    inputPricePer1M: 10.0,
    outputPricePer1M: 30.0,
    contextWindow: 128000,
    maxOutputTokens: 4096,
    updatedAt: "2025-01-15",
  },
  {
    model: "gpt-4",
    provider: "openai",
    inputPricePer1M: 30.0,
    outputPricePer1M: 60.0,
    contextWindow: 8192,
    maxOutputTokens: 8192,
    updatedAt: "2025-01-15",
    deprecated: true,
    replacement: "gpt-4o",
  },
  {
    model: "gpt-3.5-turbo",
    provider: "openai",
    inputPricePer1M: 0.5,
    outputPricePer1M: 1.5,
    contextWindow: 16385,
    maxOutputTokens: 4096,
    updatedAt: "2025-01-15",
    deprecated: true,
    replacement: "gpt-4o-mini",
  },
  {
    model: "o1",
    provider: "openai",
    inputPricePer1M: 15.0,
    outputPricePer1M: 60.0,
    contextWindow: 200000,
    maxOutputTokens: 100000,
    updatedAt: "2025-01-15",
  },
  {
    model: "o1-mini",
    provider: "openai",
    inputPricePer1M: 3.0,
    outputPricePer1M: 12.0,
    contextWindow: 128000,
    maxOutputTokens: 65536,
    updatedAt: "2025-01-15",
  },
  {
    model: "o3-mini",
    provider: "openai",
    inputPricePer1M: 1.1,
    outputPricePer1M: 4.4,
    contextWindow: 200000,
    maxOutputTokens: 100000,
    updatedAt: "2025-01-15",
  },

  // ============================================================================
  // Anthropic Models
  // ============================================================================
  {
    model: "claude-3-5-sonnet-20241022",
    provider: "anthropic",
    inputPricePer1M: 3.0,
    outputPricePer1M: 15.0,
    contextWindow: 200000,
    maxOutputTokens: 8192,
    updatedAt: "2025-01-15",
  },
  {
    model: "claude-sonnet",
    provider: "anthropic",
    inputPricePer1M: 3.0,
    outputPricePer1M: 15.0,
    contextWindow: 200000,
    maxOutputTokens: 8192,
    updatedAt: "2025-01-15",
  },
  {
    model: "claude-3-5-haiku-20241022",
    provider: "anthropic",
    inputPricePer1M: 0.8,
    outputPricePer1M: 4.0,
    contextWindow: 200000,
    maxOutputTokens: 8192,
    updatedAt: "2025-01-15",
  },
  {
    model: "claude-haiku",
    provider: "anthropic",
    inputPricePer1M: 0.8,
    outputPricePer1M: 4.0,
    contextWindow: 200000,
    maxOutputTokens: 8192,
    updatedAt: "2025-01-15",
  },
  {
    model: "claude-3-opus-20240229",
    provider: "anthropic",
    inputPricePer1M: 15.0,
    outputPricePer1M: 75.0,
    contextWindow: 200000,
    maxOutputTokens: 4096,
    updatedAt: "2025-01-15",
  },
  {
    model: "claude-opus",
    provider: "anthropic",
    inputPricePer1M: 15.0,
    outputPricePer1M: 75.0,
    contextWindow: 200000,
    maxOutputTokens: 4096,
    updatedAt: "2025-01-15",
  },

  // ============================================================================
  // Google Models
  // ============================================================================
  {
    model: "gemini-2.0-flash",
    provider: "google",
    inputPricePer1M: 0.1,
    outputPricePer1M: 0.4,
    contextWindow: 1000000,
    maxOutputTokens: 8192,
    updatedAt: "2025-01-15",
  },
  {
    model: "gemini-1.5-pro",
    provider: "google",
    inputPricePer1M: 1.25,
    outputPricePer1M: 5.0,
    contextWindow: 2000000,
    maxOutputTokens: 8192,
    updatedAt: "2025-01-15",
  },
  {
    model: "gemini-1.5-flash",
    provider: "google",
    inputPricePer1M: 0.075,
    outputPricePer1M: 0.3,
    contextWindow: 1000000,
    maxOutputTokens: 8192,
    updatedAt: "2025-01-15",
  },

  // ============================================================================
  // Mistral Models
  // ============================================================================
  {
    model: "mistral-large",
    provider: "mistral",
    inputPricePer1M: 2.0,
    outputPricePer1M: 6.0,
    contextWindow: 128000,
    maxOutputTokens: 8192,
    updatedAt: "2025-01-15",
  },
  {
    model: "mistral-small",
    provider: "mistral",
    inputPricePer1M: 0.2,
    outputPricePer1M: 0.6,
    contextWindow: 32000,
    maxOutputTokens: 8192,
    updatedAt: "2025-01-15",
  },
  {
    model: "codestral",
    provider: "mistral",
    inputPricePer1M: 0.2,
    outputPricePer1M: 0.6,
    contextWindow: 32000,
    maxOutputTokens: 8192,
    updatedAt: "2025-01-15",
  },

  // ============================================================================
  // Local Models (free but track for comparison)
  // ============================================================================
  {
    model: "ollama-llama3",
    provider: "local",
    inputPricePer1M: 0,
    outputPricePer1M: 0,
    contextWindow: 8192,
    maxOutputTokens: 4096,
    updatedAt: "2025-01-15",
  },
  {
    model: "ollama-codellama",
    provider: "local",
    inputPricePer1M: 0,
    outputPricePer1M: 0,
    contextWindow: 16384,
    maxOutputTokens: 4096,
    updatedAt: "2025-01-15",
  },
];

/**
 * Model aliases for convenience.
 */
export const MODEL_ALIASES: Record<string, string> = {
  // OpenAI aliases
  "gpt4o": "gpt-4o",
  "gpt4o-mini": "gpt-4o-mini",
  "gpt4": "gpt-4o",
  "gpt-4": "gpt-4o",
  "gpt35": "gpt-4o-mini",
  "gpt-3.5": "gpt-4o-mini",

  // Anthropic aliases
  "sonnet": "claude-sonnet",
  "haiku": "claude-haiku",
  "opus": "claude-opus",
  "claude-3.5-sonnet": "claude-3-5-sonnet-20241022",
  "claude-3.5-haiku": "claude-3-5-haiku-20241022",
  "claude-3-opus": "claude-3-opus-20240229",

  // Google aliases
  "gemini-pro": "gemini-1.5-pro",
  "gemini-flash": "gemini-2.0-flash",
  "gemini": "gemini-2.0-flash",

  // Mistral aliases
  "mistral": "mistral-small",
};

/**
 * Get pricing for a model.
 */
export function getModelPricing(model: string): ModelPricing | undefined {
  // Resolve alias first
  const resolvedModel = MODEL_ALIASES[model.toLowerCase()] || model;

  return MODEL_PRICING.find(
    (p) => p.model.toLowerCase() === resolvedModel.toLowerCase()
  );
}

/**
 * Get all models for a provider.
 */
export function getModelsByProvider(provider: LLMProvider): ModelPricing[] {
  return MODEL_PRICING.filter((p) => p.provider === provider);
}

/**
 * Get active (non-deprecated) models.
 */
export function getActiveModels(): ModelPricing[] {
  return MODEL_PRICING.filter((p) => !p.deprecated);
}

/**
 * Get deprecated models.
 */
export function getDeprecatedModels(): ModelPricing[] {
  return MODEL_PRICING.filter((p) => p.deprecated);
}

/**
 * Calculate cost for token usage.
 */
export function calculateCost(
  model: string,
  inputTokens: number,
  outputTokens: number
): number {
  const pricing = getModelPricing(model);
  if (!pricing) {
    throw new Error(`Unknown model: ${model}`);
  }

  const inputCost = (inputTokens / 1_000_000) * pricing.inputPricePer1M;
  const outputCost = (outputTokens / 1_000_000) * pricing.outputPricePer1M;

  return inputCost + outputCost;
}

/**
 * Get the cheapest model that meets requirements.
 */
export function getCheapestModel(options: {
  provider?: LLMProvider;
  minContextWindow?: number;
  minOutputTokens?: number;
  excludeDeprecated?: boolean;
}): ModelPricing | undefined {
  let models = MODEL_PRICING;

  if (options.provider) {
    models = models.filter((m) => m.provider === options.provider);
  }

  if (options.minContextWindow) {
    models = models.filter((m) => m.contextWindow >= options.minContextWindow!);
  }

  if (options.minOutputTokens) {
    models = models.filter((m) => m.maxOutputTokens >= options.minOutputTokens!);
  }

  if (options.excludeDeprecated !== false) {
    models = models.filter((m) => !m.deprecated);
  }

  if (models.length === 0) {
    return undefined;
  }

  // Sort by total cost (assuming equal input/output)
  return models.sort(
    (a, b) =>
      a.inputPricePer1M + a.outputPricePer1M - (b.inputPricePer1M + b.outputPricePer1M)
  )[0];
}

/**
 * Compare costs between two models.
 */
export function compareModelCosts(
  modelA: string,
  modelB: string,
  inputTokens: number,
  outputTokens: number
): {
  modelA: { model: string; cost: number };
  modelB: { model: string; cost: number };
  cheaperModel: string;
  savingsUsd: number;
  savingsPercent: number;
} {
  const costA = calculateCost(modelA, inputTokens, outputTokens);
  const costB = calculateCost(modelB, inputTokens, outputTokens);

  const cheaper = costA <= costB ? modelA : modelB;
  const savings = Math.abs(costA - costB);
  const savingsPercent = (savings / Math.max(costA, costB)) * 100;

  return {
    modelA: { model: modelA, cost: costA },
    modelB: { model: modelB, cost: costB },
    cheaperModel: cheaper,
    savingsUsd: savings,
    savingsPercent,
  };
}

/**
 * Recommended models by use case.
 */
export const RECOMMENDED_MODELS = {
  // Fast, cheap operations
  draft: ["gpt-4o-mini", "claude-haiku", "gemini-2.0-flash", "mistral-small"],

  // Quality code generation
  code: ["gpt-4o", "claude-sonnet", "codestral"],

  // Complex reasoning
  reasoning: ["o1", "claude-opus", "gpt-4o"],

  // Analysis and review
  analysis: ["claude-sonnet", "gpt-4o", "gemini-1.5-pro"],

  // Security-sensitive
  security: ["claude-opus", "o1", "gpt-4o"],

  // Long context
  longContext: ["gemini-1.5-pro", "claude-sonnet", "gpt-4o"],
};

/**
 * Get tier-appropriate models.
 */
export function getTierModels(tier: "T1" | "T2" | "T3", stage?: "draft" | "final"): string[] {
  switch (tier) {
    case "T1":
      // Cheap models for trivial tasks
      return ["gpt-4o-mini", "claude-haiku", "gemini-2.0-flash"];
    case "T2":
      if (stage === "draft") {
        return ["gpt-4o-mini", "claude-haiku"];
      }
      // Final stage needs quality
      return ["gpt-4o", "claude-sonnet"];
    case "T3":
      // High-risk needs best models
      return ["gpt-4o", "claude-opus", "o1"];
    default:
      return ["gpt-4o-mini"];
  }
}


/**
 * Prompt catalog management.
 * Loads and provides access to the prompt catalog configuration.
 */

import { readFileSync, existsSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { parse as parseYaml } from "yaml";
import type {
  CatalogSchema,
  PromptConfig,
  CatalogDefaults,
  RiskTier,
} from "./types.js";

const __dirname = dirname(fileURLToPath(import.meta.url));
const CATALOG_PATH = resolve(__dirname, "..", "catalog.yaml");

/**
 * Manages the prompt catalog - the central registry of all prompts.
 */
export class PromptCatalog {
  private catalog: CatalogSchema;
  private catalogPath: string;

  constructor(catalogPath: string = CATALOG_PATH) {
    this.catalogPath = catalogPath;
    this.catalog = this.loadCatalog();
  }

  private loadCatalog(): CatalogSchema {
    if (!existsSync(this.catalogPath)) {
      throw new Error(`Catalog not found at ${this.catalogPath}`);
    }

    const content = readFileSync(this.catalogPath, "utf-8");
    return parseYaml(content) as CatalogSchema;
  }

  /**
   * Reload the catalog from disk.
   */
  reload(): void {
    this.catalog = this.loadCatalog();
  }

  /**
   * Get the catalog version.
   */
  get version(): string {
    return this.catalog.version;
  }

  /**
   * Get default settings.
   */
  get defaults(): CatalogDefaults {
    return this.catalog.defaults;
  }

  /**
   * Get all prompt IDs.
   */
  listPrompts(): string[] {
    return Object.keys(this.catalog.core_prompts);
  }

  /**
   * Get prompts by category.
   */
  getPromptsByCategory(category: string): string[] {
    return this.catalog.categories[category]?.prompts ?? [];
  }

  /**
   * Get all categories.
   */
  listCategories(): string[] {
    return Object.keys(this.catalog.categories);
  }

  /**
   * Get configuration for a specific prompt.
   */
  getPromptConfig(promptId: string): PromptConfig | undefined {
    return this.catalog.core_prompts[promptId];
  }

  /**
   * Check if a prompt exists.
   */
  hasPrompt(promptId: string): boolean {
    return promptId in this.catalog.core_prompts;
  }

  /**
   * Get the recommended model for a tier and stage.
   */
  getModelForTier(tier: RiskTier, stage: "draft" | "final" = "final"): string {
    const mapping = this.catalog.defaults.model_tier_mapping;

    if (tier === "T1") {
      return mapping.T1;
    }

    if (tier === "T2") {
      return stage === "draft" ? mapping.T2_draft : mapping.T2_final;
    }

    return mapping.T3;
  }

  /**
   * Get quality gate settings.
   */
  get qualityGates() {
    return this.catalog.quality_gates;
  }

  /**
   * Get hallucination checks to run.
   */
  get hallucinationChecks(): string[] {
    return this.catalog.validation.hallucination_checks;
  }

  /**
   * Check if a prompt supports a given tier.
   */
  supportsTier(promptId: string, tier: RiskTier): boolean {
    const config = this.getPromptConfig(promptId);
    return config?.tier_support.includes(tier) ?? false;
  }

  /**
   * Get the full catalog for inspection.
   */
  getRawCatalog(): CatalogSchema {
    return this.catalog;
  }
}

/**
 * Load the prompt catalog from the default location.
 */
export function loadCatalog(path?: string): PromptCatalog {
  return new PromptCatalog(path);
}


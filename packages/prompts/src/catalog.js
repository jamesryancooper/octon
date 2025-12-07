/**
 * Prompt catalog management.
 * Loads and provides access to the prompt catalog configuration.
 */
import { readFileSync, existsSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { parse as parseYaml } from "yaml";
const __dirname = dirname(fileURLToPath(import.meta.url));
const CATALOG_PATH = resolve(__dirname, "..", "catalog.yaml");
/**
 * Manages the prompt catalog - the central registry of all prompts.
 */
export class PromptCatalog {
    constructor(catalogPath = CATALOG_PATH) {
        this.catalogPath = catalogPath;
        this.catalog = this.loadCatalog();
    }
    loadCatalog() {
        if (!existsSync(this.catalogPath)) {
            throw new Error(`Catalog not found at ${this.catalogPath}`);
        }
        const content = readFileSync(this.catalogPath, "utf-8");
        return parseYaml(content);
    }
    /**
     * Reload the catalog from disk.
     */
    reload() {
        this.catalog = this.loadCatalog();
    }
    /**
     * Get the catalog version.
     */
    get version() {
        return this.catalog.version;
    }
    /**
     * Get default settings.
     */
    get defaults() {
        return this.catalog.defaults;
    }
    /**
     * Get all prompt IDs.
     */
    listPrompts() {
        return Object.keys(this.catalog.core_prompts);
    }
    /**
     * Get prompts by category.
     */
    getPromptsByCategory(category) {
        return this.catalog.categories[category]?.prompts ?? [];
    }
    /**
     * Get all categories.
     */
    listCategories() {
        return Object.keys(this.catalog.categories);
    }
    /**
     * Get configuration for a specific prompt.
     */
    getPromptConfig(promptId) {
        return this.catalog.core_prompts[promptId];
    }
    /**
     * Check if a prompt exists.
     */
    hasPrompt(promptId) {
        return promptId in this.catalog.core_prompts;
    }
    /**
     * Get the recommended model for a tier and stage.
     */
    getModelForTier(tier, stage = "final") {
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
    get hallucinationChecks() {
        return this.catalog.validation.hallucination_checks;
    }
    /**
     * Check if a prompt supports a given tier.
     */
    supportsTier(promptId, tier) {
        const config = this.getPromptConfig(promptId);
        return config?.tier_support.includes(tier) ?? false;
    }
    /**
     * Get the full catalog for inspection.
     */
    getRawCatalog() {
        return this.catalog;
    }
}
/**
 * Load the prompt catalog from the default location.
 */
export function loadCatalog(path) {
    return new PromptCatalog(path);
}

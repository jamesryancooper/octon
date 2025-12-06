/**
 * Prompt loading utilities.
 * Loads prompts from disk with their templates and schemas.
 */

import { readFileSync, existsSync, readdirSync } from "node:fs";
import { resolve, dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import type { PromptMetadata, PromptConfig } from "./types.js";
import { PromptCatalog } from "./catalog.js";

const __dirname = dirname(fileURLToPath(import.meta.url));
const PROMPTS_ROOT = resolve(__dirname, "..");

/**
 * A fully loaded prompt with template and schemas.
 */
export interface LoadedPrompt extends PromptMetadata {
  /** Path to the prompt directory */
  directory: string;

  /** Available examples */
  examples: string[];
}

/**
 * Loads prompts from the filesystem.
 */
export class PromptLoader {
  private catalog: PromptCatalog;
  private promptsRoot: string;
  private cache: Map<string, LoadedPrompt>;

  constructor(catalog: PromptCatalog, promptsRoot: string = PROMPTS_ROOT) {
    this.catalog = catalog;
    this.promptsRoot = promptsRoot;
    this.cache = new Map();
  }

  /**
   * Load a prompt by ID.
   */
  load(promptId: string): LoadedPrompt {
    // Check cache
    if (this.cache.has(promptId)) {
      return this.cache.get(promptId)!;
    }

    // Get config from catalog
    const config = this.catalog.getPromptConfig(promptId);
    if (!config) {
      throw new Error(`Prompt not found in catalog: ${promptId}`);
    }

    // Resolve paths
    const promptDir = resolve(this.promptsRoot, config.path);
    const templatePath = join(promptDir, "prompt.md");
    const inputSchemaPath = resolve(this.promptsRoot, config.input_schema);
    const outputSchemaPath = resolve(this.promptsRoot, config.output_schema);

    // Validate files exist
    if (!existsSync(templatePath)) {
      throw new Error(`Prompt template not found: ${templatePath}`);
    }
    if (!existsSync(inputSchemaPath)) {
      throw new Error(`Input schema not found: ${inputSchemaPath}`);
    }
    if (!existsSync(outputSchemaPath)) {
      throw new Error(`Output schema not found: ${outputSchemaPath}`);
    }

    // Load content
    const template = readFileSync(templatePath, "utf-8");
    const inputSchema = JSON.parse(readFileSync(inputSchemaPath, "utf-8"));
    const outputSchema = JSON.parse(readFileSync(outputSchemaPath, "utf-8"));

    // Find examples
    const examplesDir = join(promptDir, "examples");
    const examples = existsSync(examplesDir)
      ? readdirSync(examplesDir).filter(
          (f) => f.endsWith(".yaml") || f.endsWith(".json")
        )
      : [];

    const loaded: LoadedPrompt = {
      id: promptId,
      config,
      template,
      inputSchema,
      outputSchema,
      directory: promptDir,
      examples,
    };

    // Cache it
    this.cache.set(promptId, loaded);

    return loaded;
  }

  /**
   * Load all prompts.
   */
  loadAll(): LoadedPrompt[] {
    const promptIds = this.catalog.listPrompts();
    return promptIds.map((id) => this.load(id));
  }

  /**
   * Load prompts by category.
   */
  loadByCategory(category: string): LoadedPrompt[] {
    const promptIds = this.catalog.getPromptsByCategory(category);
    return promptIds.map((id) => this.load(id));
  }

  /**
   * Clear the cache.
   */
  clearCache(): void {
    this.cache.clear();
  }

  /**
   * Get the path to a prompt's directory.
   */
  getPromptDirectory(promptId: string): string {
    const config = this.catalog.getPromptConfig(promptId);
    if (!config) {
      throw new Error(`Prompt not found: ${promptId}`);
    }
    return resolve(this.promptsRoot, config.path);
  }

  /**
   * Load an example file for a prompt.
   */
  loadExample(promptId: string, exampleName: string): unknown {
    const loaded = this.load(promptId);
    const examplePath = join(loaded.directory, "examples", exampleName);

    if (!existsSync(examplePath)) {
      throw new Error(`Example not found: ${examplePath}`);
    }

    const content = readFileSync(examplePath, "utf-8");

    if (exampleName.endsWith(".json")) {
      return JSON.parse(content);
    }

    // For YAML, we need to import dynamically
    // For now, return raw content
    return content;
  }
}

/**
 * Get the path to a prompt's directory.
 */
export function getPromptPath(promptId: string): string {
  const catalog = new PromptCatalog();
  const config = catalog.getPromptConfig(promptId);

  if (!config) {
    throw new Error(`Prompt not found: ${promptId}`);
  }

  return resolve(PROMPTS_ROOT, config.path);
}

/**
 * List all available prompts.
 */
export function listPrompts(): string[] {
  const catalog = new PromptCatalog();
  return catalog.listPrompts();
}


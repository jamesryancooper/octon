#!/usr/bin/env npx tsx
/**
 * CLI tool to validate prompts in the library.
 * Usage: pnpm validate
 */

import { PromptCatalog } from "./catalog.js";
import { PromptLoader } from "./loader.js";
import { PromptValidator } from "./validator.js";

interface ValidationSummary {
  total: number;
  valid: number;
  invalid: number;
  errors: Array<{ promptId: string; error: string }>;
}

async function validateAllPrompts(): Promise<ValidationSummary> {
  const summary: ValidationSummary = {
    total: 0,
    valid: 0,
    invalid: 0,
    errors: [],
  };

  console.log("🔍 Validating Harmony Prompt Library\n");

  try {
    const catalog = new PromptCatalog();
    const loader = new PromptLoader(catalog);
    const validator = new PromptValidator();

    const promptIds = catalog.listPrompts();
    summary.total = promptIds.length;

    console.log(`Found ${promptIds.length} prompts in catalog\n`);

    for (const promptId of promptIds) {
      process.stdout.write(`  Validating ${promptId}...`);

      try {
        // Load the prompt
        const loaded = loader.load(promptId);

        // Register with validator (validates schema compilation)
        validator.registerPrompt(loaded);

        // Check template exists and has content
        if (!loaded.template || loaded.template.trim().length < 100) {
          throw new Error("Prompt template is empty or too short");
        }

        // Check for required sections in template
        const requiredSections = ["## System Context", "## Input", "## Output"];
        for (const section of requiredSections) {
          if (!loaded.template.includes(section)) {
            throw new Error(`Missing required section: ${section}`);
          }
        }

        // Validate examples if present
        if (loaded.examples.length > 0) {
          // At least check that example files exist (loading tested them)
          console.log(` ✅ (${loaded.examples.length} examples)`);
        } else {
          console.log(" ⚠️  (no examples)");
        }

        summary.valid++;
      } catch (error) {
        console.log(" ❌");
        const errorMessage =
          error instanceof Error ? error.message : String(error);
        summary.errors.push({ promptId, error: errorMessage });
        summary.invalid++;
      }
    }
  } catch (error) {
    console.error("\n❌ Fatal error:", error);
    process.exit(1);
  }

  // Print summary
  console.log("\n" + "=".repeat(50));
  console.log("Validation Summary");
  console.log("=".repeat(50));
  console.log(`Total:   ${summary.total}`);
  console.log(`Valid:   ${summary.valid} ✅`);
  console.log(`Invalid: ${summary.invalid} ❌`);

  if (summary.errors.length > 0) {
    console.log("\nErrors:");
    for (const { promptId, error } of summary.errors) {
      console.log(`  - ${promptId}: ${error}`);
    }
  }

  return summary;
}

// Run if called directly
validateAllPrompts().then((summary) => {
  process.exit(summary.invalid > 0 ? 1 : 0);
});


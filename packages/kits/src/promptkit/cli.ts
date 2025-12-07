#!/usr/bin/env node
/**
 * PromptKit CLI
 *
 * Command-line interface for PromptKit operations.
 *
 * @example
 * ```bash
 * # Compile a prompt
 * promptkit compile spec-from-intent --variables '{"intent":"...", "tier":"T2"}'
 *
 * # List variants
 * promptkit variants spec-from-intent
 *
 * # Validate a prompt compiles correctly
 * promptkit validate spec-from-intent --variables '{"intent":"..."}'
 *
 * # Estimate tokens
 * promptkit tokens spec-from-intent --variables '...'
 *
 * # List all prompts
 * promptkit list
 * ```
 */

import { PromptKit } from "./index";
import { shortHash } from "./hasher";

interface CliOptions {
  variables?: string;
  variant?: string;
  maxTokens?: number;
  model?: string;
  tier?: string;
  format?: "json" | "text";
  verbose?: boolean;
}

/**
 * Parse command line arguments.
 */
function parseArgs(args: string[]): {
  command: string;
  promptId?: string;
  options: CliOptions;
} {
  const options: CliOptions = {};
  let command = "";
  let promptId: string | undefined;

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];

    if (arg.startsWith("--")) {
      const key = arg.slice(2);

      // Handle boolean flags first (no value needed)
      if (key === "verbose" || key === "v") {
        options.verbose = true;
        continue;
      }

      // For value-based flags, consume the next argument
      const value = args[++i];

      switch (key) {
        case "variables":
        case "vars":
          options.variables = value;
          break;
        case "variant":
          options.variant = value;
          break;
        case "max-tokens":
          options.maxTokens = parseInt(value, 10);
          break;
        case "model":
          options.model = value;
          break;
        case "tier":
          options.tier = value;
          break;
        case "format":
          options.format = value as "json" | "text";
          break;
      }
    } else if (arg.startsWith("-")) {
      const key = arg.slice(1);
      switch (key) {
        case "v":
          options.verbose = true;
          break;
        case "j":
          options.format = "json";
          break;
      }
    } else if (!command) {
      command = arg;
    } else if (!promptId) {
      promptId = arg;
    }
  }

  return { command, promptId, options };
}

/**
 * Parse variables from JSON string or file.
 */
function parseVariables(varsString?: string): Record<string, unknown> {
  if (!varsString) {
    return {};
  }

  try {
    return JSON.parse(varsString);
  } catch {
    console.error(`Error: Invalid JSON in --variables: ${varsString}`);
    process.exit(1);
  }
}

/**
 * Main CLI handler.
 */
async function main(): Promise<void> {
  const args = process.argv.slice(2);

  if (args.length === 0 || args[0] === "--help" || args[0] === "-h") {
    printUsage();
    return;
  }

  const { command, promptId, options } = parseArgs(args);
  const promptKit = new PromptKit();

  switch (command) {
    case "compile":
      await cmdCompile(promptKit, promptId, options);
      break;

    case "validate":
      await cmdValidate(promptKit, promptId, options);
      break;

    case "tokens":
      await cmdTokens(promptKit, promptId, options);
      break;

    case "variants":
      await cmdVariants(promptKit, promptId, options);
      break;

    case "list":
      await cmdList(promptKit, options);
      break;

    case "info":
      await cmdInfo(promptKit, promptId, options);
      break;

    case "variables":
      await cmdVariables(promptKit, promptId, options);
      break;

    default:
      console.error(`Unknown command: ${command}`);
      printUsage();
      process.exit(1);
  }
}

/**
 * Print usage information.
 */
function printUsage(): void {
  console.log(`
PromptKit CLI - Runtime prompt compiler for Harmony

USAGE:
  promptkit <command> [prompt-id] [options]

COMMANDS:
  compile <prompt-id>   Compile a prompt with variables
  validate <prompt-id>  Validate a prompt compiles correctly
  tokens <prompt-id>    Estimate tokens for a prompt
  variants <prompt-id>  List available variants for a prompt
  variables <prompt-id> List expected variables for a prompt
  list                  List all available prompts
  info <prompt-id>      Show detailed prompt information

OPTIONS:
  --variables, --vars   JSON string of variables
  --variant             Specific variant to use
  --max-tokens          Maximum tokens (truncates if exceeded)
  --model               Override model selection
  --tier                Risk tier (T1, T2, T3)
  --format              Output format: json, text (default: text)
  -v, --verbose         Verbose output
  -j                    JSON output (shorthand for --format json)

EXAMPLES:
  # Compile a prompt
  promptkit compile spec-from-intent --vars '{"intent":"Add auth","tier":"T2"}'

  # Validate with variables
  promptkit validate spec-from-intent --vars '{"intent":"Add auth"}'

  # Get token estimate
  promptkit tokens spec-from-intent --vars '{"intent":"Add auth"}'

  # List variants
  promptkit variants spec-from-intent

  # List all prompts as JSON
  promptkit list -j
`);
}

/**
 * Compile command.
 */
async function cmdCompile(
  promptKit: PromptKit,
  promptId: string | undefined,
  options: CliOptions
): Promise<void> {
  if (!promptId) {
    console.error("Error: prompt-id is required");
    process.exit(1);
  }

  const variables = parseVariables(options.variables);

  try {
    const compiled = promptKit.compile(promptId, variables, {
      variantId: options.variant,
      maxTokens: options.maxTokens,
      model: options.model,
    });

    if (options.format === "json") {
      console.log(JSON.stringify(compiled, null, 2));
    } else {
      console.log(promptKit.formatCompiled(compiled));
    }
  } catch (error) {
    console.error(
      `Error: ${error instanceof Error ? error.message : String(error)}`
    );
    process.exit(1);
  }
}

/**
 * Validate command.
 */
async function cmdValidate(
  promptKit: PromptKit,
  promptId: string | undefined,
  options: CliOptions
): Promise<void> {
  if (!promptId) {
    console.error("Error: prompt-id is required");
    process.exit(1);
  }

  const variables = parseVariables(options.variables);

  try {
    const result = promptKit.validate(promptId, variables);

    if (options.format === "json") {
      console.log(JSON.stringify(result, null, 2));
    } else {
      if (result.valid) {
        console.log("✅ Prompt is valid");
      } else {
        console.log("❌ Prompt validation failed:");
        for (const error of result.errors) {
          console.log(`  • ${error}`);
        }
      }

      if (result.warnings.length > 0) {
        console.log("\n⚠️  Warnings:");
        for (const warning of result.warnings) {
          console.log(`  • ${warning}`);
        }
      }
    }

    if (!result.valid) {
      process.exit(1);
    }
  } catch (error) {
    console.error(
      `Error: ${error instanceof Error ? error.message : String(error)}`
    );
    process.exit(1);
  }
}

/**
 * Tokens command.
 */
async function cmdTokens(
  promptKit: PromptKit,
  promptId: string | undefined,
  options: CliOptions
): Promise<void> {
  if (!promptId) {
    console.error("Error: prompt-id is required");
    process.exit(1);
  }

  const variables = parseVariables(options.variables);

  try {
    const compiled = promptKit.compile(promptId, variables, {
      variantId: options.variant,
      model: options.model,
    });

    const tokenInfo = promptKit.getTokenInfo(compiled);

    if (options.format === "json") {
      console.log(
        JSON.stringify(
          {
            promptId,
            model: compiled.metadata.model,
            hash: shortHash(compiled.prompt_hash),
            ...tokenInfo,
          },
          null,
          2
        )
      );
    } else {
      console.log("📊 Token Estimate");
      console.log("─────────────────────────────");
      console.log(`Prompt ID: ${promptId}`);
      console.log(`Model: ${compiled.metadata.model}`);
      console.log(`Hash: ${shortHash(compiled.prompt_hash)}`);
      console.log("");
      console.log(`Tokens: ~${tokenInfo.tokens.toLocaleString()}`);
      console.log(`Context Window: ${tokenInfo.contextWindow.toLocaleString()}`);
      console.log(`Usage: ${tokenInfo.usagePercent.toFixed(1)}%`);
      console.log(
        `Available for Output: ~${tokenInfo.availableForOutput.toLocaleString()}`
      );
      console.log("");
      console.log(
        tokenInfo.fitsInContext
          ? "✅ Fits in context"
          : "❌ Exceeds context window"
      );
    }
  } catch (error) {
    console.error(
      `Error: ${error instanceof Error ? error.message : String(error)}`
    );
    process.exit(1);
  }
}

/**
 * Variants command.
 */
async function cmdVariants(
  promptKit: PromptKit,
  promptId: string | undefined,
  options: CliOptions
): Promise<void> {
  if (!promptId) {
    console.error("Error: prompt-id is required");
    process.exit(1);
  }

  try {
    const info = promptKit.getPromptInfo(promptId);

    if (options.format === "json") {
      console.log(
        JSON.stringify(
          {
            promptId,
            variants: info.variants,
          },
          null,
          2
        )
      );
    } else {
      console.log(`Variants for ${promptId}:`);
      console.log("─────────────────────────────");
      for (const variantId of info.variants) {
        console.log(`  • ${variantId}`);
      }
    }
  } catch (error) {
    console.error(
      `Error: ${error instanceof Error ? error.message : String(error)}`
    );
    process.exit(1);
  }
}

/**
 * List command.
 */
async function cmdList(
  promptKit: PromptKit,
  options: CliOptions
): Promise<void> {
  try {
    const prompts = promptKit.listPrompts();

    if (options.format === "json") {
      if (options.verbose) {
        const detailed = prompts.map((id) => promptKit.getPromptInfo(id));
        console.log(JSON.stringify(detailed, null, 2));
      } else {
        console.log(JSON.stringify(prompts, null, 2));
      }
    } else {
      console.log("Available Prompts:");
      console.log("─────────────────────────────");
      for (const id of prompts) {
        if (options.verbose) {
          const info = promptKit.getPromptInfo(id);
          console.log(`  ${id}`);
          console.log(`    ${info.description}`);
          console.log(`    Status: ${info.status} | Tiers: ${info.tierSupport.join(", ")}`);
          console.log("");
        } else {
          console.log(`  • ${id}`);
        }
      }
    }
  } catch (error) {
    console.error(
      `Error: ${error instanceof Error ? error.message : String(error)}`
    );
    process.exit(1);
  }
}

/**
 * Info command.
 */
async function cmdInfo(
  promptKit: PromptKit,
  promptId: string | undefined,
  options: CliOptions
): Promise<void> {
  if (!promptId) {
    console.error("Error: prompt-id is required");
    process.exit(1);
  }

  try {
    const info = promptKit.getPromptInfo(promptId);
    const variables = promptKit.getExpectedVariables(promptId);

    if (options.format === "json") {
      console.log(
        JSON.stringify(
          {
            ...info,
            expectedVariables: variables,
          },
          null,
          2
        )
      );
    } else {
      console.log("Prompt Information");
      console.log("═══════════════════════════════════════");
      console.log(`ID: ${info.id}`);
      console.log(`Name: ${info.name}`);
      console.log(`Description: ${info.description}`);
      console.log(`Version: ${info.version}`);
      console.log(`Status: ${info.status}`);
      console.log(`Category: ${info.category}`);
      console.log(`Tier Support: ${info.tierSupport.join(", ")}`);
      console.log(`Variants: ${info.variants.join(", ")}`);
      console.log("");
      console.log("Expected Variables:");
      for (const v of variables) {
        console.log(`  • ${v}`);
      }
    }
  } catch (error) {
    console.error(
      `Error: ${error instanceof Error ? error.message : String(error)}`
    );
    process.exit(1);
  }
}

/**
 * Variables command.
 */
async function cmdVariables(
  promptKit: PromptKit,
  promptId: string | undefined,
  options: CliOptions
): Promise<void> {
  if (!promptId) {
    console.error("Error: prompt-id is required");
    process.exit(1);
  }

  try {
    const variables = promptKit.getExpectedVariables(promptId);

    if (options.format === "json") {
      console.log(JSON.stringify({ promptId, variables }, null, 2));
    } else {
      console.log(`Expected variables for ${promptId}:`);
      console.log("─────────────────────────────");
      for (const v of variables) {
        console.log(`  • ${v}`);
      }
    }
  } catch (error) {
    console.error(
      `Error: ${error instanceof Error ? error.message : String(error)}`
    );
    process.exit(1);
  }
}

// Run CLI
main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});


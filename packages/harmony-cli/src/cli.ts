#!/usr/bin/env node
/**
 * Harmony CLI - Human-friendly interface for AI-assisted development.
 *
 * This is the main entry point that parses commands and delegates to handlers.
 *
 * Usage:
 *   harmony <command> [options]
 *
 * Commands:
 *   status    - Show current tasks and AI progress
 *   feature   - Start a new feature
 *   fix       - Start a bug fix
 *   build     - AI implements the current task
 *   ship      - Deploy to production
 *   explain   - Get AI explanation for decisions
 *   retry     - Retry with new guidance
 *   pause     - Pause a running task
 *   rollback  - Rollback production
 *   harness   - Install/update Harmony harness in a repository
 *   init      - Alias for "harness install"
 *   help      - Show help
 */

import process from "node:process";
import { pathToFileURL } from "node:url";

import {
  statusCommand,
  featureCommand,
  fixCommand,
  buildCommand,
  shipCommand,
  explainCommand,
  retryCommand,
  pauseCommand,
  rollbackCommand,
  harnessCommand,
  onboardCommand,
  helpCommand,
} from "./commands/index.js";
import { error, bold, muted } from "./ui/index.js";
import type { RiskTier, CommonOptions } from "./types/index.js";

interface ParsedArgs {
  command: string;
  args: string[];
  options: Record<string, string | boolean>;
}

/**
 * Parse command-line arguments.
 */
function parseArgs(argv: string[]): ParsedArgs {
  // Skip node and script path
  const args = argv.slice(2);

  if (args.length === 0) {
    return { command: "help", args: [], options: {} };
  }

  const command = args[0];
  const positionalArgs: string[] = [];
  const options: Record<string, string | boolean> = {};

  let i = 1;
  while (i < args.length) {
    const arg = args[i];

    if (arg.startsWith("--")) {
      const key = arg.slice(2);

      // Check if next arg is a value or another flag
      if (i + 1 < args.length && !args[i + 1].startsWith("-")) {
        options[key] = args[i + 1];
        i += 2;
      } else {
        options[key] = true;
        i += 1;
      }
    } else if (arg.startsWith("-")) {
      // Short flags (e.g., -v)
      const key = arg.slice(1);
      options[key] = true;
      i += 1;
    } else {
      positionalArgs.push(arg);
      i += 1;
    }
  }

  return { command, args: positionalArgs, options };
}

/**
 * Convert parsed options to CommonOptions.
 */
function toCommonOptions(options: Record<string, string | boolean>): CommonOptions {
  const result: CommonOptions = {};

  if (typeof options.tier === "string") {
    const tier = options.tier.toUpperCase();
    if (tier === "T1" || tier === "T2" || tier === "T3") {
      result.tier = tier as RiskTier;
    }
  }

  if (typeof options.context === "string") {
    result.context = options.context;
  }

  if (typeof options.constraint === "string") {
    result.constraint = options.constraint;
  }

  if (typeof options.model === "string") {
    result.model = options.model;
  }

  if (options["dry-run"] === true || options.dryRun === true) {
    result.dryRun = true;
  }

  if (options.verbose === true || options.v === true) {
    result.verbose = true;
  }

  if (options["non-interactive"] === true || options.y === true) {
    result.nonInteractive = true;
  }

  return result;
}

/**
 * Run the CLI.
 */
async function run(argv: string[] = process.argv): Promise<void> {
  const { command, args, options } = parseArgs(argv);
  const commonOptions = toCommonOptions(options);

  try {
    switch (command.toLowerCase()) {
      case "status":
      case "s":
        await statusCommand({ verbose: commonOptions.verbose });
        break;

      case "feature":
      case "feat":
      case "f":
        await featureCommand(args.join(" "), commonOptions);
        break;

      case "fix":
      case "bug":
        await fixCommand(args.join(" "), commonOptions);
        break;

      case "build":
      case "b":
        await buildCommand(args[0], commonOptions);
        break;

      case "ship":
      case "deploy":
      case "d":
        await shipCommand(args[0], { ...commonOptions, force: options.force === true });
        break;

      case "explain":
      case "why":
        await explainCommand(args[0], { question: args.slice(1).join(" ") || undefined });
        break;

      case "retry":
      case "r":
        await retryCommand(args[0], commonOptions);
        break;

      case "pause":
      case "stop":
        await pauseCommand(args[0]);
        break;

      case "rollback":
      case "revert":
        await rollbackCommand({
          deploymentUrl: typeof options["deployment-url"] === "string" ? options["deployment-url"] : undefined,
          force: options.force === true,
        });
        break;

      case "onboard":
      case "onboarding":
        await onboardCommand(args[0], args.slice(1), {
          name: typeof options.name === "string" ? options.name : undefined,
        });
        break;

      case "harness":
        await harnessCommand(args[0], {
          source: typeof options.source === "string" ? options.source : undefined,
          target: typeof options.target === "string" ? options.target : undefined,
          force: options.force === true,
          dryRun: commonOptions.dryRun,
          verbose: commonOptions.verbose,
          skipLinks: options["skip-links"] === true,
        });
        break;

      case "init":
        await harnessCommand("install", {
          source: typeof options.source === "string" ? options.source : undefined,
          target: typeof options.target === "string" ? options.target : undefined,
          force: options.force === true,
          dryRun: commonOptions.dryRun,
          verbose: commonOptions.verbose,
          skipLinks: options["skip-links"] === true,
        });
        break;

      case "help":
      case "h":
      case "--help":
      case "-h":
        helpCommand(args[0]);
        break;

      case "version":
      case "--version":
      case "-v":
        console.log("harmony-cli v0.0.1");
        break;

      default:
        console.log("");
        console.log(error(`Unknown command: ${bold(command)}`));
        console.log("");
        console.log(muted('Run "harmony help" to see available commands.'));
        console.log("");
        process.exitCode = 1;
    }
  } catch (err) {
    console.error("");
    console.error(error("Error:"), err instanceof Error ? err.message : String(err));
    console.error("");
    process.exitCode = 1;
  }
}

// Check if this file is being run directly
const isEntryPoint =
  process.argv[1] && pathToFileURL(process.argv[1]).href === import.meta.url;

if (isEntryPoint) {
  run().catch((err) => {
    console.error("Fatal error:", err);
    process.exitCode = 1;
  });
}

export { run, parseArgs };

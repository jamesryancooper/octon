/**
 * CLI base utilities for Harmony Kits.
 *
 * Provides standardized CLI scaffolding that all kits can extend to ensure
 * consistent user experience and behavior.
 *
 * ## Configuration Precedence
 *
 * For CLI operations, configuration is resolved in this order (highest to lowest):
 * 1. CLI flags (e.g., `--dry-run`, `--stage implement`)
 * 2. Environment variables (e.g., `HARMONY_DRY_RUN=true`)
 * 3. Kit defaults
 *
 * For programmatic API usage, configuration is resolved:
 * 1. Constructor/method config object
 * 2. Environment variables
 * 3. Kit defaults
 *
 * This ensures CLI flags always win, but environment variables provide
 * a way to set defaults for both interfaces.
 */

import { parseStandardFlags, getStandardFlagsHelp, type StandardKitFlags } from "./cli-flags.js";
import { isKitError, ExitCodes, type KitErrorJSON } from "./errors.js";
import type { LifecycleStage, RiskTier, RiskLevel } from "./types.js";

// ============================================================================
// Types
// ============================================================================

/**
 * CLI command definition.
 */
export interface CliCommand<TOptions = Record<string, unknown>> {
  /** Command name */
  name: string;

  /** Short description */
  description: string;

  /** Required arguments */
  args?: Array<{
    name: string;
    description: string;
    required?: boolean;
  }>;

  /** Command-specific options */
  options?: Array<{
    name: string;
    alias?: string;
    description: string;
    type: "string" | "boolean" | "number";
    default?: unknown;
  }>;

  /** Handler function */
  handler: (args: string[], options: TOptions & StandardKitFlags) => Promise<CliResult>;
}

/**
 * CLI result structure.
 */
export interface CliResult {
  /** Exit code (0 for success) */
  exitCode: number;

  /** Data to output (will be formatted based on --format flag) */
  data?: unknown;

  /** Human-readable message for text output */
  message?: string;

  /** Whether this was a dry-run */
  dryRun?: boolean;
}

/**
 * Kit CLI configuration.
 */
export interface KitCliConfig {
  /** Kit name */
  name: string;

  /** Kit version */
  version: string;

  /** Kit description */
  description: string;

  /** Available commands */
  commands: CliCommand[];

  /** Kit-specific options that apply to all commands */
  globalOptions?: Array<{
    name: string;
    alias?: string;
    description: string;
    type: "string" | "boolean" | "number";
    default?: unknown;
  }>;
}

/**
 * Output formatter function type.
 */
export type OutputFormatter = (result: CliResult, format: "json" | "text", verbose: boolean) => string;

// ============================================================================
// CLI Runner
// ============================================================================

/**
 * Create and run a kit CLI.
 *
 * @param config - Kit CLI configuration
 * @param argv - Command line arguments (default: process.argv)
 * @param formatter - Custom output formatter (optional)
 */
export async function runKitCli(
  config: KitCliConfig,
  argv: string[] = process.argv,
  formatter?: OutputFormatter
): Promise<number> {
  const args = argv.slice(2);

  // Parse standard flags first
  const { flags: standardFlags, remaining } = parseStandardFlags(args);

  // Check for help flag
  if (remaining.includes("--help") || remaining.includes("-h") || remaining.length === 0) {
    printHelp(config);
    return 0;
  }

  // Check for version flag
  if (remaining.includes("--version") || remaining.includes("-V")) {
    console.log(`${config.name} v${config.version}`);
    return 0;
  }

  // Get command name
  const commandName = remaining[0];
  const command = config.commands.find((c) => c.name === commandName);

  if (!command) {
    console.error(`Unknown command: ${commandName}`);
    console.error(`Run '${config.name} --help' for usage information.`);
    return 1;
  }

  // Parse command-specific options
  const commandArgs = remaining.slice(1);
  const { options: commandOptions, positionalArgs } = parseCommandOptions(
    commandArgs,
    command.options || [],
    config.globalOptions || []
  );

  // Merge all options
  const allOptions = {
    ...standardFlags,
    ...commandOptions,
  };

  try {
    // Execute command
    const result = await command.handler(positionalArgs, allOptions);

    // Format and output result
    const output = formatOutput(result, standardFlags.format || "text", standardFlags.verbose || false, formatter);
    if (output) {
      console.log(output);
    }

    return result.exitCode;
  } catch (error) {
    return handleCliError(error, config.name, config.version, standardFlags.format || "text");
  }
}

/**
 * Handle CLI errors with consistent formatting.
 *
 * For JSON output, uses the canonical KitErrorJSON format so that
 * CLI error output matches programmatic API and HTTP error responses.
 */
function handleCliError(
  error: unknown,
  kitName: string,
  kitVersion: string,
  format: "json" | "text"
): number {
  if (format === "json") {
    // Use structured error format for JSON output
    if (isKitError(error)) {
      const errorJson = error.toJSON();
      console.log(
        JSON.stringify({
          ...errorJson,
          _kit: { name: kitName, version: kitVersion },
        }, null, 2)
      );
      return error.code;
    }

    // Wrap unknown errors in canonical format
    const message = error instanceof Error ? error.message : String(error);
    const wrappedError: KitErrorJSON & { _kit: { name: string; version: string } } = {
      success: false,
      error: {
        code: "GenericKitError",
        exitCode: ExitCodes.GENERIC_FAILURE,
        message,
        suggestedAction: "Review the error details and retry.",
      },
      _kit: { name: kitName, version: kitVersion },
    };
    console.log(JSON.stringify(wrappedError, null, 2));
    return ExitCodes.GENERIC_FAILURE;
  }

  // Text format
  const message = error instanceof Error ? error.message : String(error);
  console.error(`[${kitName}] Error: ${message}`);

  if (isKitError(error)) {
    console.error(`  Suggested action: ${error.suggestedAction}`);
    return error.code;
  }

  return ExitCodes.GENERIC_FAILURE;
}

// ============================================================================
// Helper Functions
// ============================================================================

/**
 * Parse command-specific options from arguments.
 */
function parseCommandOptions(
  args: string[],
  commandOptions: NonNullable<CliCommand["options"]>,
  globalOptions: NonNullable<KitCliConfig["globalOptions"]>
): { options: Record<string, unknown>; positionalArgs: string[] } {
  const options: Record<string, unknown> = {};
  const positionalArgs: string[] = [];
  const allOptions = [...commandOptions, ...globalOptions];

  // Set defaults
  for (const opt of allOptions) {
    if (opt.default !== undefined) {
      options[toCamelCase(opt.name)] = opt.default;
    }
  }

  let i = 0;
  while (i < args.length) {
    const arg = args[i];

    if (arg === "--") {
      positionalArgs.push(...args.slice(i + 1));
      break;
    }

    if (arg.startsWith("--")) {
      const [rawKey, ...valueParts] = arg.slice(2).split("=");
      const key = rawKey;
      const hasValue = valueParts.length > 0;
      const value = hasValue ? valueParts.join("=") : undefined;

      const opt = allOptions.find((o) => o.name === key);
      if (opt) {
        const camelKey = toCamelCase(opt.name);

        if (opt.type === "boolean") {
          options[camelKey] = value ? value === "true" : true;
        } else {
          const flagValue = value ?? args[++i];
          options[camelKey] = opt.type === "number" ? Number(flagValue) : flagValue;
        }
      }
      i++;
      continue;
    }

    if (arg.startsWith("-") && arg.length === 2) {
      const alias = arg[1];
      const opt = allOptions.find((o) => o.alias === alias);

      if (opt) {
        const camelKey = toCamelCase(opt.name);

        if (opt.type === "boolean") {
          options[camelKey] = true;
        } else {
          const flagValue = args[++i];
          options[camelKey] = opt.type === "number" ? Number(flagValue) : flagValue;
        }
      }
      i++;
      continue;
    }

    positionalArgs.push(arg);
    i++;
  }

  return { options, positionalArgs };
}

/**
 * Convert kebab-case to camelCase.
 */
function toCamelCase(str: string): string {
  return str.replace(/-([a-z])/g, (_, letter) => letter.toUpperCase());
}

/**
 * Format output based on format flag.
 */
function formatOutput(
  result: CliResult,
  format: "json" | "text",
  verbose: boolean,
  customFormatter?: OutputFormatter
): string {
  if (customFormatter) {
    return customFormatter(result, format, verbose);
  }

  if (format === "json") {
    return JSON.stringify(result.data ?? { status: result.exitCode === 0 ? "success" : "failure" }, null, 2);
  }

  // Text format
  if (result.message) {
    return result.message;
  }

  if (result.data) {
    if (typeof result.data === "string") {
      return result.data;
    }
    return JSON.stringify(result.data, null, 2);
  }

  return "";
}

/**
 * Print help for the CLI.
 */
function printHelp(config: KitCliConfig): void {
  console.log(`
${config.name} v${config.version} - ${config.description}

USAGE:
  ${config.name} <command> [options]

COMMANDS:
${config.commands
  .map((c) => {
    const args = c.args?.map((a) => (a.required ? `<${a.name}>` : `[${a.name}]`)).join(" ") ?? "";
    return `  ${c.name.padEnd(16)} ${c.description}${args ? `\n${"".padEnd(18)}Args: ${args}` : ""}`;
  })
  .join("\n")}

${getStandardFlagsHelp()}
${
  config.globalOptions && config.globalOptions.length > 0
    ? `
${config.name.toUpperCase()} OPTIONS:
${config.globalOptions.map((o) => `  --${o.name}${o.alias ? `, -${o.alias}` : ""}`.padEnd(24) + o.description).join("\n")}`
    : ""
}
EXAMPLES:
  ${config.name} ${config.commands[0]?.name ?? "help"} --help
  ${config.name} ${config.commands[0]?.name ?? "run"} --dry-run
  ${config.name} ${config.commands[0]?.name ?? "run"} --format json
`);
}

/**
 * Create a success result.
 */
export function success(data?: unknown, message?: string): CliResult {
  return {
    exitCode: 0,
    data,
    message,
    dryRun: false,
  };
}

/**
 * Create a dry-run success result.
 */
export function dryRunSuccess(data?: unknown, message?: string): CliResult {
  return {
    exitCode: 0,
    data,
    message,
    dryRun: true,
  };
}

/**
 * Create a failure result.
 */
export function failure(message: string, exitCode: number = 1): CliResult {
  return {
    exitCode,
    message,
    dryRun: false,
  };
}

/**
 * Augment result data with kit metadata.
 */
export function withKitMetadata(
  data: unknown,
  kitName: string,
  kitVersion: string,
  flags: StandardKitFlags
): unknown {
  if (typeof data !== "object" || data === null) {
    return {
      result: data,
      _kit: createKitMetadataBlock(kitName, kitVersion, flags),
    };
  }

  return {
    ...data,
    _kit: createKitMetadataBlock(kitName, kitVersion, flags),
  };
}

/**
 * Create the standard _kit metadata block.
 */
function createKitMetadataBlock(
  kitName: string,
  kitVersion: string,
  flags: StandardKitFlags
): Record<string, unknown> {
  return {
    name: kitName,
    version: kitVersion,
    dryRun: flags.dryRun,
    stage: flags.stage,
    risk: flags.risk,
    traceEnabled: flags.trace,
    traceParent: flags.traceParent,
  };
}

// ============================================================================
// Re-exports
// ============================================================================

export { parseStandardFlags, getStandardFlagsHelp } from "./cli-flags.js";
export type { StandardKitFlags } from "./cli-flags.js";


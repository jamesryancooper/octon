#!/usr/bin/env node
/**
 * GuardKit CLI
 *
 * Command-line interface for GuardKit AI output protection.
 *
 * Pillar alignment: Speed with Safety, Quality through Determinism
 *
 * @example
 * ```bash
 * # Check content for issues
 * guardkit check "AI generated content here"
 * guardkit check --file ./output.ts
 *
 * # Sanitize input for safe use in prompts
 * guardkit sanitize "User input with potential issues"
 *
 * # Quick safety check (fast, less thorough)
 * guardkit quick-check "Content to check"
 *
 * # Dry-run mode (default in local)
 * guardkit check --dry-run "Content"
 * ```
 */

import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import {
  runKitCli,
  success,
  dryRunSuccess,
  failure,
  withKitMetadata,
  type CliCommand,
  type KitCliConfig,
  type StandardKitFlags,
} from "@harmony/kit-base";
import { GuardKit, type GuardrailResult, type SanitizeResult } from "./index.js";

/** Kit metadata */
const KIT_NAME = "guardkit";
const KIT_VERSION = "0.1.0";

/**
 * CLI-specific options for GuardKit.
 */
interface GuardKitCliOptions extends Record<string, unknown> {
  dryRun?: boolean;
  enableRunRecords?: boolean;
  runsDir?: string;
  file?: string;
  projectRoot?: string;
  threshold?: string;
}

/**
 * Create a GuardKit instance from CLI options.
 */
function createGuardKit(options: GuardKitCliOptions): GuardKit {
  return new GuardKit({
    projectRoot: options.projectRoot || process.cwd(),
    blockThreshold: (options.threshold as "critical" | "high" | "medium" | "low") || "high",
    enableRunRecords: options.enableRunRecords,
    runsDir: options.runsDir,
  });
}

/**
 * Get content from argument or file.
 */
function getContent(args: string[], options: GuardKitCliOptions): string {
  if (options.file) {
    const filePath = resolve(options.file);
    try {
      return readFileSync(filePath, "utf-8");
    } catch (error) {
      throw new Error(`Failed to read file: ${filePath}`);
    }
  }

  if (args.length === 0) {
    throw new Error("No content provided. Use positional argument or --file flag.");
  }

  return args.join(" ");
}

/**
 * Check command - run all guardrail checks on content.
 */
const checkCommand: CliCommand<GuardKitCliOptions> = {
  name: "check",
  description: "Run all guardrail checks on content",
  args: [
    { name: "content", description: "Content to check", required: false },
  ],
  options: [
    { name: "file", alias: "F", description: "Read content from file", type: "string" },
    { name: "project-root", description: "Project root for import verification", type: "string" },
    { name: "threshold", description: "Block threshold: critical|high|medium|low", type: "string" },
  ],
  async handler(args, options) {
    const content = getContent(args, options);
    const guard = createGuardKit(options);

    // In dry-run mode, just validate inputs
    if (options.dryRun) {
      return dryRunSuccess(
        withKitMetadata(
          {
            status: "dry-run",
            summary: "Would check content for guardrail violations",
            contentLength: content.length,
            threshold: options.threshold || "high",
          },
          KIT_NAME,
          KIT_VERSION,
          options
        ),
        `[GuardKit] Dry-run: would check ${content.length} characters`
      );
    }

    const result = guard.check(content);

    const output = withKitMetadata(
      {
        status: result.safe ? "success" : "failure",
        summary: result.safe
          ? `Content passed all checks (${result.passedChecks}/${result.totalChecks})`
          : `Content blocked: ${result.summary.critical} critical, ${result.summary.high} high issues`,
        result,
      },
      KIT_NAME,
      KIT_VERSION,
      options
    );

    if (!result.safe) {
      return {
        exitCode: 4, // Guard violation exit code
        data: output,
        message: formatCheckResult(result),
      };
    }

    return success(output, formatCheckResult(result));
  },
};

/**
 * Sanitize command - sanitize input for safe use.
 */
const sanitizeCommand: CliCommand<GuardKitCliOptions> = {
  name: "sanitize",
  description: "Sanitize content for safe use in prompts",
  args: [
    { name: "content", description: "Content to sanitize", required: false },
  ],
  options: [
    { name: "file", alias: "F", description: "Read content from file", type: "string" },
  ],
  async handler(args, options) {
    const content = getContent(args, options);
    const guard = createGuardKit(options);

    // In dry-run mode, just validate inputs
    if (options.dryRun) {
      return dryRunSuccess(
        withKitMetadata(
          {
            status: "dry-run",
            summary: "Would sanitize content",
            contentLength: content.length,
          },
          KIT_NAME,
          KIT_VERSION,
          options
        ),
        `[GuardKit] Dry-run: would sanitize ${content.length} characters`
      );
    }

    const result = guard.sanitizeInput(content);

    const output = withKitMetadata(
      {
        status: "success",
        summary: result.modified
          ? `Sanitized content with ${result.modifications.length} modifications`
          : "Content required no sanitization",
        result: {
          sanitized: result.sanitized,
          modified: result.modified,
          modifications: result.modifications,
          redactions: result.redactions,
        },
      },
      KIT_NAME,
      KIT_VERSION,
      options
    );

    return success(output, formatSanitizeResult(result));
  },
};

/**
 * Quick-check command - fast safety check.
 */
const quickCheckCommand: CliCommand<GuardKitCliOptions> = {
  name: "quick-check",
  description: "Fast safety check (less thorough than full check)",
  args: [
    { name: "content", description: "Content to check", required: false },
  ],
  options: [
    { name: "file", alias: "F", description: "Read content from file", type: "string" },
  ],
  async handler(args, options) {
    const content = getContent(args, options);
    const guard = createGuardKit(options);

    // In dry-run mode, just validate inputs
    if (options.dryRun) {
      return dryRunSuccess(
        withKitMetadata(
          {
            status: "dry-run",
            summary: "Would perform quick safety check",
            contentLength: content.length,
          },
          KIT_NAME,
          KIT_VERSION,
          options
        ),
        `[GuardKit] Dry-run: would quick-check ${content.length} characters`
      );
    }

    const result = guard.quickCheck(content);

    const output = withKitMetadata(
      {
        status: result.safe ? "success" : "failure",
        summary: result.safe ? "Quick check passed" : `Quick check failed: ${result.reason}`,
        result,
      },
      KIT_NAME,
      KIT_VERSION,
      options
    );

    if (!result.safe) {
      return {
        exitCode: 4, // Guard violation exit code
        data: output,
        message: `[GuardKit] Quick check failed: ${result.reason}`,
      };
    }

    return success(output, "[GuardKit] Quick check passed");
  },
};

/**
 * Format check result for text output.
 */
function formatCheckResult(result: GuardrailResult): string {
  const lines: string[] = [];

  if (result.safe) {
    lines.push(`[GuardKit] Content passed all checks (${result.passedChecks}/${result.totalChecks})`);
  } else {
    lines.push(`[GuardKit] Content blocked`);
    lines.push(`  Critical: ${result.summary.critical}`);
    lines.push(`  High: ${result.summary.high}`);
    lines.push(`  Medium: ${result.summary.medium}`);
    lines.push(`  Low: ${result.summary.low}`);
  }

  // Show failed checks
  const failedChecks = result.checks.filter((c) => !c.passed);
  if (failedChecks.length > 0) {
    lines.push("");
    lines.push("Failed checks:");
    for (const check of failedChecks) {
      lines.push(`  - [${check.severity}] ${check.name}: ${check.message}`);
      if (check.suggestion) {
        lines.push(`    Suggestion: ${check.suggestion}`);
      }
    }
  }

  return lines.join("\n");
}

/**
 * Format sanitize result for text output.
 */
function formatSanitizeResult(result: SanitizeResult): string {
  const lines: string[] = [];

  if (result.modified) {
    lines.push(`[GuardKit] Content sanitized with ${result.modifications.length} modifications`);

    if (result.modifications.length > 0) {
      lines.push("");
      lines.push("Modifications:");
      for (const mod of result.modifications) {
        lines.push(`  - ${mod}`);
      }
    }

    if (result.redactions.length > 0) {
      lines.push("");
      lines.push("Redactions:");
      for (const red of result.redactions) {
        lines.push(`  - ${red}`);
      }
    }
  } else {
    lines.push("[GuardKit] Content required no sanitization");
  }

  return lines.join("\n");
}

/**
 * GuardKit CLI configuration.
 */
const cliConfig: KitCliConfig = {
  name: KIT_NAME,
  version: KIT_VERSION,
  description: "AI output protection: injection detection, secrets/PII redaction, hallucination checks",
  commands: [checkCommand, sanitizeCommand, quickCheckCommand],
  globalOptions: [
    { name: "file", alias: "F", description: "Read content from file", type: "string" },
    { name: "project-root", description: "Project root for verification", type: "string" },
    { name: "threshold", description: "Block threshold: critical|high|medium|low", type: "string" },
  ],
};

/**
 * Run the CLI.
 */
runKitCli(cliConfig).then((exitCode) => {
  process.exitCode = exitCode;
});


/**
 * `harmony check` - Run guardrail checks on AI output.
 *
 * This command allows humans to verify AI-generated content
 * before accepting it.
 */

import { readFileSync, existsSync } from "node:fs";
import type { CommandResult } from "../types/index.js";
import {
  runGuardrailChecks,
  verifyImports,
  formatGuardrailResults,
} from "../orchestrator/guardrails.js";
import { getWorkspaceRoot } from "../orchestrator/workflow.js";
import { createSpinner, muted, bold, highlight } from "../ui/index.js";

export interface CheckOptions {
  /** Check guardrails (security, hallucinations, etc.) */
  guardrails?: boolean;

  /** Verify imports only */
  verifyImports?: boolean;

  /** File to check */
  file?: string;

  /** Raw content to check (from stdin or argument) */
  content?: string;

  /** Risk tier (affects sensitivity) */
  tier?: "T1" | "T2" | "T3";
}

export async function checkCommand(
  fileOrContent?: string,
  options: CheckOptions = {}
): Promise<CommandResult> {
  const workspaceRoot = getWorkspaceRoot();
  let content: string;

  // Determine content to check
  if (options.file) {
    const filePath = options.file;
    if (!existsSync(filePath)) {
      return {
        success: false,
        message: `File not found: ${filePath}`,
      };
    }
    content = readFileSync(filePath, "utf-8");
  } else if (fileOrContent) {
    // Check if it's a file path or direct content
    if (existsSync(fileOrContent)) {
      content = readFileSync(fileOrContent, "utf-8");
    } else {
      content = fileOrContent;
    }
  } else {
    return {
      success: false,
      message: "No content provided. Use --file <path> or provide content as argument.",
    };
  }

  // Verify imports only
  if (options.verifyImports) {
    const spinner = createSpinner();
    spinner.start("Verifying imports...");

    const result = verifyImports(content, workspaceRoot);

    if (result.valid) {
      spinner.succeed("All imports verified");
      return {
        success: true,
        message: "All imports are valid and present in package.json",
      };
    }

    spinner.warn("Import issues found");

    const lines: string[] = [];

    if (result.missing.length > 0) {
      lines.push("");
      lines.push(bold("Missing packages (not in package.json):"));
      for (const pkg of result.missing) {
        lines.push(`  ${highlight(pkg)}`);
        lines.push(`    → Run: ${muted(`pnpm add ${pkg}`)}`);
      }
    }

    if (result.suspicious.length > 0) {
      lines.push("");
      lines.push(bold("Suspicious packages (may be hallucinated):"));
      for (const pkg of result.suspicious) {
        lines.push(`  ${highlight(pkg)}`);
        lines.push(`    → Verify: ${muted(`npm info ${pkg}`)}`);
      }
    }

    console.log(lines.join("\n"));

    return {
      success: false,
      message: `Found ${result.missing.length} missing and ${result.suspicious.length} suspicious imports`,
      data: { missing: result.missing, suspicious: result.suspicious },
    };
  }

  // Full guardrail check
  const spinner = createSpinner();
  spinner.start("Running guardrail checks...");

  const tier = options.tier ?? "T2";
  const result = await runGuardrailChecks(content, workspaceRoot, tier);

  if (result.passed) {
    spinner.succeed(result.summary);
  } else if (result.canProceed) {
    spinner.warn(result.summary);
  } else {
    spinner.fail(result.summary);
  }

  // Display detailed results
  console.log("");
  console.log(formatGuardrailResults(result));

  return {
    success: result.passed,
    message: result.summary,
    data: {
      safe: result.safe,
      canProceed: result.canProceed,
      critical: result.critical.length,
      warnings: result.warnings.length,
      info: result.info.length,
    },
    nextAction: result.canProceed
      ? result.warnings.length > 0
        ? "Review warnings above, then proceed if acceptable"
        : undefined
      : "Fix critical issues before proceeding",
  };
}

export const checkHelp = {
  command: "check",
  description: "Run guardrail checks on AI output (security, hallucinations, etc.)",
  usage: "harmony check [file-or-content] [options]",
  options: [
    { flag: "--guardrails", description: "Run full guardrail checks (default)" },
    { flag: "--verify-imports", description: "Only verify imports against package.json" },
    { flag: "--file <path>", description: "Path to file to check" },
    { flag: "--tier <T1|T2|T3>", description: "Risk tier (affects check sensitivity)" },
  ],
  examples: [
    "harmony check output.ts",
    "harmony check --verify-imports src/",
    "harmony check --file generated-code.ts --tier T3",
    'harmony check "const x = eval(input)"',
  ],
};


/**
 * `harmony feature` - Start a new feature with AI assistance.
 *
 * This command initiates the spec → plan → build → ship workflow.
 */

import type { CommandResult, RiskTier } from "../types/index.js";
import { startFeature } from "../orchestrator/index.js";
import { formatSpecSummary, formatTask } from "../ui/index.js";
import { createSpinner, bold, highlight, muted } from "../ui/index.js";

export interface FeatureOptions {
  tier?: RiskTier;
  context?: string;
  model?: string;
  dryRun?: boolean;
}

export async function featureCommand(
  description: string,
  options?: FeatureOptions
): Promise<CommandResult> {
  if (!description || description.trim().length === 0) {
    return {
      success: false,
      message: "Please provide a feature description.\n\nUsage: harmony feature \"description\"",
    };
  }

  const spinner = createSpinner();
  spinner.start("AI is analyzing your request...");

  try {
    const result = await startFeature(description, options);

    if (!result.success) {
      spinner.fail(result.message);
      return result;
    }

    spinner.succeed("Spec generated");

    // Display the task
    if (result.task) {
      console.log("");
      console.log(formatTask(result.task));
    }

    // Display spec summary
    if (result.data?.specSummary) {
      console.log("");
      console.log(formatSpecSummary(result.data.specSummary as any));
    }

    // Next action
    if (result.nextAction) {
      console.log("");
      console.log(muted("Next:"), result.nextAction);
    }

    return result;
  } catch (error) {
    spinner.fail("Failed to start feature");
    return {
      success: false,
      message: error instanceof Error ? error.message : String(error),
    };
  }
}

export const featureHelp = {
  command: "feature",
  description: "Start a new feature with AI assistance",
  usage: 'harmony feature "description" [options]',
  options: [
    { flag: "--tier T1|T2|T3", description: "Override the auto-assigned risk tier" },
    { flag: "--context <text>", description: "Provide additional context to AI" },
    { flag: "--model <name>", description: "Use a specific AI model" },
    { flag: "--dry-run", description: "Preview without creating anything" },
  ],
  examples: [
    'harmony feature "Add user profile endpoint"',
    'harmony feature "OAuth login with Google" --tier T3',
    'harmony feature "Dark mode toggle" --context "Use existing theme system"',
  ],
};


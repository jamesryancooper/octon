/**
 * `harmony fix` - Start a bug fix with AI assistance.
 *
 * Similar to `feature` but defaults to T1 tier and fix-oriented prompts.
 */

import type { CommandResult, RiskTier } from "../types/index.js";
import { startFix } from "../orchestrator/index.js";
import { formatSpecSummary, formatTask } from "../ui/index.js";
import { createSpinner, muted } from "../ui/index.js";

export interface FixOptions {
  tier?: RiskTier;
  context?: string;
  model?: string;
  dryRun?: boolean;
}

export async function fixCommand(
  description: string,
  options?: FixOptions
): Promise<CommandResult> {
  if (!description || description.trim().length === 0) {
    return {
      success: false,
      message: 'Please provide a bug description.\n\nUsage: harmony fix "description"',
    };
  }

  const spinner = createSpinner();
  spinner.start("AI is analyzing the bug...");

  try {
    const result = await startFix(description, options);

    if (!result.success) {
      spinner.fail(result.message);
      return result;
    }

    spinner.succeed("Fix spec generated");

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
    spinner.fail("Failed to start fix");
    return {
      success: false,
      message: error instanceof Error ? error.message : String(error),
    };
  }
}

export const fixHelp = {
  command: "fix",
  description: "Start a bug fix with AI assistance",
  usage: 'harmony fix "description" [options]',
  options: [
    { flag: "--tier T1|T2|T3", description: "Override the auto-assigned risk tier" },
    { flag: "--context <text>", description: "Provide additional context" },
    { flag: "--model <name>", description: "Use a specific AI model" },
  ],
  examples: [
    'harmony fix "Button not responding on mobile"',
    'harmony fix "Race condition in checkout" --tier T2',
    'harmony fix "#423" (reference issue number)',
  ],
};


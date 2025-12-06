/**
 * `harmony build` - Trigger AI to implement the current task.
 *
 * This takes a spec/plan and generates code, tests, and a PR.
 */

import type { CommandResult } from "../types/index.js";
import { buildTask, getPRSummary } from "../orchestrator/index.js";
import { formatTask, formatPRSummary } from "../ui/index.js";
import { createSpinner, muted, bold, highlight } from "../ui/index.js";

export interface BuildOptions {
  context?: string;
  constraint?: string;
  model?: string;
}

export async function buildCommand(
  taskIdOrTitle?: string,
  options?: BuildOptions
): Promise<CommandResult> {
  const spinner = createSpinner();
  spinner.start("AI is implementing...");

  try {
    const result = await buildTask(taskIdOrTitle, options);

    if (!result.success) {
      spinner.fail(result.message);
      return result;
    }

    spinner.succeed("Implementation complete");

    // Display the task
    if (result.task) {
      console.log("");
      console.log(formatTask(result.task));

      // If task is ready for review, show PR summary
      if (result.task.status === "reviewing" && result.task.prNumber) {
        console.log("");
        const prSummary = getPRSummary(result.task);
        console.log(formatPRSummary(prSummary));
      }
    }

    // Next action
    if (result.nextAction) {
      console.log("");
      console.log(muted("Next:"), result.nextAction);
    }

    return result;
  } catch (error) {
    spinner.fail("Build failed");
    return {
      success: false,
      message: error instanceof Error ? error.message : String(error),
    };
  }
}

export const buildHelp = {
  command: "build",
  description: "AI implements the current task (generates code, tests, PR)",
  usage: "harmony build [task-id] [options]",
  options: [
    { flag: "--context <text>", description: "Provide additional implementation context" },
    { flag: "--constraint <text>", description: "Add a constraint for AI to follow" },
    { flag: "--model <name>", description: "Use a specific AI model" },
  ],
  examples: [
    "harmony build",
    "harmony build abc123",
    'harmony build --constraint "Use the existing Button component"',
  ],
};


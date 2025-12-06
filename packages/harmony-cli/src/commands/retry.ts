/**
 * `harmony retry` - Retry a failed or paused task with new guidance.
 *
 * Useful when AI output wasn't quite right and you want to try again.
 */

import type { CommandResult } from "../types/index.js";
import { retryTask, getPRSummary } from "../orchestrator/index.js";
import { formatTask, formatPRSummary } from "../ui/index.js";
import { createSpinner, muted } from "../ui/index.js";

export interface RetryOptions {
  context?: string;
  constraint?: string;
  model?: string;
}

export async function retryCommand(
  taskIdOrTitle?: string,
  options?: RetryOptions
): Promise<CommandResult> {
  const spinner = createSpinner();
  spinner.start("Retrying with updated guidance...");

  try {
    const result = await retryTask(taskIdOrTitle, options);

    if (!result.success) {
      spinner.fail(result.message);
      return result;
    }

    spinner.succeed("Retry complete");

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
    spinner.fail("Retry failed");
    return {
      success: false,
      message: error instanceof Error ? error.message : String(error),
    };
  }
}

export const retryHelp = {
  command: "retry",
  description: "Retry a failed or paused task with new guidance",
  usage: "harmony retry [task-id] [options]",
  options: [
    { flag: "--context <text>", description: "Add context for the retry" },
    { flag: "--constraint <text>", description: "Add a constraint AI must follow" },
    { flag: "--model <name>", description: "Try a different AI model" },
  ],
  examples: [
    "harmony retry",
    'harmony retry --constraint "Use the existing auth service"',
    "harmony retry abc123 --model claude-opus",
  ],
};


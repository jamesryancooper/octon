/**
 * `harmony pause` - Pause a running task.
 *
 * Stops AI work on a task without discarding progress.
 */

import type { CommandResult } from "../types/index.js";
import { pauseTask } from "../orchestrator/index.js";
import { formatTask } from "../ui/index.js";
import { createSpinner, muted, warning } from "../ui/index.js";

export interface PauseOptions {}

export async function pauseCommand(
  taskIdOrTitle?: string,
  _options?: PauseOptions
): Promise<CommandResult> {
  const spinner = createSpinner();
  spinner.start("Pausing task...");

  try {
    const result = await pauseTask(taskIdOrTitle, _options);

    if (!result.success) {
      spinner.fail(result.message);
      return result;
    }

    spinner.succeed(warning("Task paused"));

    // Display the task
    if (result.task) {
      console.log("");
      console.log(formatTask(result.task));
    }

    // Next action
    if (result.nextAction) {
      console.log("");
      console.log(muted("Next:"), result.nextAction);
    }

    return result;
  } catch (error) {
    spinner.fail("Failed to pause task");
    return {
      success: false,
      message: error instanceof Error ? error.message : String(error),
    };
  }
}

export const pauseHelp = {
  command: "pause",
  description: "Pause a running task",
  usage: "harmony pause [task-id]",
  options: [],
  examples: [
    "harmony pause",
    "harmony pause abc123",
  ],
};


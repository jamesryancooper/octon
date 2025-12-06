/**
 * `harmony ship` - Deploy a task to production.
 *
 * This merges the PR and promotes the preview to production.
 */

import type { CommandResult, CommonOptions } from "../types/index.js";
import { shipTask } from "../orchestrator/index.js";
import { formatTask } from "../ui/index.js";
import { createSpinner, muted, success, highlight } from "../ui/index.js";

export interface ShipOptions extends CommonOptions {
  force?: boolean;
}

export async function shipCommand(
  taskIdOrTitle?: string,
  options?: ShipOptions
): Promise<CommandResult> {
  const spinner = createSpinner();
  spinner.start("Shipping to production...");

  try {
    const result = await shipTask(taskIdOrTitle, options as CommonOptions);

    if (!result.success) {
      spinner.fail(result.message);
      return result;
    }

    spinner.succeed(success("Shipped successfully!"));

    // Display the task
    if (result.task) {
      console.log("");
      console.log(formatTask(result.task));
    }

    // Show flag info
    if (result.data?.flagName) {
      console.log("");
      console.log(`${muted("Feature flag:")} ${highlight(String(result.data.flagName))}`);
    }

    // Next action
    if (result.nextAction) {
      console.log("");
      console.log(muted("Next:"), result.nextAction);
    }

    return result;
  } catch (error) {
    spinner.fail("Ship failed");
    return {
      success: false,
      message: error instanceof Error ? error.message : String(error),
    };
  }
}

export const shipHelp = {
  command: "ship",
  description: "Deploy a task to production (merge PR, promote preview)",
  usage: "harmony ship [task-id] [options]",
  options: [
    { flag: "--force", description: "Ship even with warnings (use carefully)" },
  ],
  examples: [
    "harmony ship",
    "harmony ship abc123",
  ],
};


/**
 * `harmony explain` - Get AI explanation for a task or decision.
 *
 * Useful when you want to understand AI's reasoning.
 */

import type { CommandResult } from "../types/index.js";
import { explainTask } from "../orchestrator/index.js";
import { bold, muted, info } from "../ui/index.js";
import { createSpinner } from "../ui/index.js";

export interface ExplainOptions {
  question?: string;
}

export async function explainCommand(
  taskIdOrTitle: string,
  options?: ExplainOptions
): Promise<CommandResult> {
  if (!taskIdOrTitle || taskIdOrTitle.trim().length === 0) {
    return {
      success: false,
      message: "Please specify what you want explained.\n\nUsage: harmony explain <task-id> [question]",
    };
  }

  const spinner = createSpinner();
  spinner.start("AI is preparing explanation...");

  try {
    const result = await explainTask(taskIdOrTitle, options?.question);

    if (!result.success) {
      spinner.fail(result.message);
      return result;
    }

    spinner.stop();

    console.log("");
    console.log(info(bold("Explanation")));
    console.log("");
    console.log(result.message);

    if (result.nextAction) {
      console.log("");
      console.log(muted("Next:"), result.nextAction);
    }

    return result;
  } catch (error) {
    spinner.fail("Failed to get explanation");
    return {
      success: false,
      message: error instanceof Error ? error.message : String(error),
    };
  }
}

export const explainHelp = {
  command: "explain",
  description: "Get AI explanation for a task or decision",
  usage: "harmony explain <task-id> [question]",
  options: [],
  examples: [
    "harmony explain abc123",
    'harmony explain abc123 "Why did you use this approach?"',
    'harmony explain "user-profile" "What alternatives did you consider?"',
  ],
};


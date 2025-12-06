/**
 * `harmony status` - Show current system and task status.
 *
 * This is the main "what's happening?" command for humans.
 */

import type { CommandResult } from "../types/index.js";
import { getSystemStatus } from "../orchestrator/index.js";
import { getWorkspaceRoot } from "../orchestrator/workflow.js";
import { formatSystemStatus } from "../ui/index.js";

export interface StatusOptions {
  verbose?: boolean;
}

export async function statusCommand(_options?: StatusOptions): Promise<CommandResult> {
  const workspaceRoot = getWorkspaceRoot();
  const status = getSystemStatus(workspaceRoot);

  console.log(formatSystemStatus(status));

  return {
    success: true,
    message: "",
    data: { status },
  };
}

export const statusHelp = {
  command: "status",
  description: "Show current tasks, AI progress, and system health",
  usage: "harmony status [options]",
  options: [
    { flag: "--verbose", description: "Show detailed status for all tasks" },
  ],
};


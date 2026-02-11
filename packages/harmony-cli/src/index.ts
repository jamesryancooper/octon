/**
 * Harmony CLI - Public API exports.
 *
 * This package provides:
 * - The `harmony` CLI for human developers
 * - Programmatic access to orchestration functions
 */

// Types
export * from "./types/index.js";

// Orchestrator (programmatic access)
export * from "./orchestrator/index.js";

// UI utilities (for extensions)
export * from "./ui/index.js";

// Commands (for extensions or testing)
export {
  statusCommand,
  featureCommand,
  fixCommand,
  buildCommand,
  shipCommand,
  explainCommand,
  retryCommand,
  pauseCommand,
  rollbackCommand,
  harnessCommand,
  helpCommand,
} from "./commands/index.js";

// CLI runner
export { run as runCli, parseArgs } from "./cli.js";

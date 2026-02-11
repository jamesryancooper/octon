/**
 * `harmony help` - Show help information.
 */

import { bold, cyan, muted, highlight, dim } from "../ui/index.js";
import { formatHelp } from "../ui/index.js";

import { statusHelp } from "./status.js";
import { featureHelp } from "./feature.js";
import { fixHelp } from "./fix.js";
import { buildHelp } from "./build.js";
import { shipHelp } from "./ship.js";
import { explainHelp } from "./explain.js";
import { retryHelp } from "./retry.js";
import { pauseHelp } from "./pause.js";
import { rollbackHelp } from "./rollback.js";
import { onboardHelp } from "./onboard.js";
import { harnessHelp } from "./harness.js";

const commands = [
  statusHelp,
  featureHelp,
  fixHelp,
  buildHelp,
  shipHelp,
  explainHelp,
  retryHelp,
  pauseHelp,
  rollbackHelp,
  onboardHelp,
  harnessHelp,
];

export function helpCommand(commandName?: string): void {
  if (commandName) {
    const aliasMap: Record<string, string> = {
      init: "harness",
    };
    const normalized = commandName.toLowerCase();
    const lookup = aliasMap[normalized] ?? normalized;

    const cmd = commands.find(
      (c) => c.command === commandName || c.command === lookup
    );

    if (cmd) {
      console.log("");
      console.log(
        formatHelp(cmd.command, cmd.description, cmd.usage, cmd.options)
      );

      if ("examples" in cmd && Array.isArray(cmd.examples)) {
        console.log("");
        console.log(bold("Examples:"));
        for (const ex of cmd.examples) {
          console.log(`  ${dim("$")} ${ex}`);
        }
      }

      console.log("");
      return;
    }

    console.log(`Unknown command: ${commandName}`);
    console.log('Run "harmony help" to see available commands.');
    return;
  }

  // Show general help
  console.log("");
  console.log(bold("Harmony CLI") + " - AI-assisted software development");
  console.log("");
  console.log(muted("You orchestrate. AI executes. Complexity is hidden."));
  console.log("");

  console.log(bold("Usage:"));
  console.log("  harmony <command> [options]");
  console.log("");

  console.log(bold("Core Commands:"));
  console.log(`  ${highlight("status")}    ${muted("Show current tasks and AI progress")}`);
  console.log(`  ${highlight("feature")}   ${muted("Start a new feature")}`);
  console.log(`  ${highlight("fix")}       ${muted("Start a bug fix")}`);
  console.log(`  ${highlight("build")}     ${muted("AI implements the current task")}`);
  console.log(`  ${highlight("ship")}      ${muted("Deploy to production")}`);
  console.log("");

  console.log(bold("Control Commands:"));
  console.log(`  ${highlight("explain")}   ${muted("Get AI explanation for decisions")}`);
  console.log(`  ${highlight("retry")}     ${muted("Retry with new guidance")}`);
  console.log(`  ${highlight("pause")}     ${muted("Pause a running task")}`);
  console.log(`  ${highlight("rollback")}  ${muted("Rollback production")}`);
  console.log("");

  console.log(bold("Onboarding:"));
  console.log(`  ${highlight("onboard")}   ${muted("AI-guided onboarding for new developers")}`);
  console.log("");

  console.log(bold("Harness:"));
  console.log(`  ${highlight("harness")}   ${muted("Install or update .harmony in this or another repo")}`);
  console.log(`  ${highlight("init")}      ${muted("Alias for: harmony harness install")}`);
  console.log("");

  console.log(bold("Quick Start:"));
  console.log(`  ${dim("$")} harmony feature "Add user profile endpoint"`);
  console.log(`  ${dim("$")} harmony build`);
  console.log(`  ${dim("$")} harmony ship`);
  console.log("");

  console.log(muted('Run "harmony help <command>" for detailed help.'));
  console.log("");
}

export const mainHelp = {
  command: "help",
  description: "Show help information",
  usage: "harmony help [command]",
  options: [],
};

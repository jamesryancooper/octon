/**
 * `harmony harness` - Install/update the Harmony harness in a repository.
 *
 * This command bootstraps `.harmony/` content from a source harness using
 * portable paths declared in `harmony.yml`.
 */

import { cpSync, existsSync, lstatSync, mkdirSync, readdirSync, readFileSync, rmSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { basename, dirname, join, resolve } from "node:path";

import type { CommandResult } from "../types/index.js";
import { getWorkspaceRoot } from "../orchestrator/workflow.js";
import { bold, dim, info, muted, success, warning } from "../ui/index.js";

type HarnessAction = "install" | "update";

interface HarnessOptions {
  source?: string;
  target?: string;
  force?: boolean;
  dryRun?: boolean;
  verbose?: boolean;
  skipLinks?: boolean;
}

interface SyncSummary {
  copied: string[];
  skipped: string[];
  missing: string[];
  configuredLinks: boolean;
  linkScriptPath?: string;
}

const REQUIRED_PORTABLE_PATHS = [
  "harmony.yml",
  "START.md",
  "scope.md",
  "conventions.md",
  "catalog.md",
  "README.md",
  "orchestration/workflows",
];

function normalizeAction(action?: string): HarnessAction | null {
  const normalized = action?.toLowerCase();
  if (normalized === "install" || normalized === "update") {
    return normalized;
  }
  return null;
}

function resolveRepoRoot(pathInput: string): string {
  const resolved = resolve(pathInput);
  if (!existsSync(resolved)) {
    throw new Error(`Path does not exist: ${resolved}`);
  }

  if (basename(resolved) === ".harmony") {
    return dirname(resolved);
  }

  return resolved;
}

function resolveHarnessRoot(pathInput: string): string {
  const resolved = resolve(pathInput);

  if (basename(resolved) === ".harmony" && existsSync(join(resolved, "harmony.yml"))) {
    return resolved;
  }

  const nested = join(resolved, ".harmony");
  if (existsSync(join(nested, "harmony.yml"))) {
    return nested;
  }

  throw new Error(
    `Could not find a harness at "${resolved}". Expected either "<path>/.harmony/harmony.yml" or "<path>/harmony.yml" when passing a .harmony directory.`
  );
}

function parsePortablePaths(manifestContent: string): string[] {
  const lines = manifestContent.split(/\r?\n/);
  const entries: string[] = [];
  let inPortable = false;

  for (const rawLine of lines) {
    const line = rawLine.trimEnd();

    if (!inPortable) {
      if (/^\s*portable:\s*$/.test(line)) {
        inPortable = true;
      }
      continue;
    }

    if (/^\S[^:]*:\s*$/.test(line)) {
      break;
    }

    const match = /^\s*-\s+(.+?)\s*$/.exec(line);
    if (!match) {
      continue;
    }

    const value = match[1].replace(/\s+#.*$/, "").replace(/^['"]|['"]$/g, "");
    if (value.length > 0) {
      entries.push(value);
    }
  }

  return entries;
}

function wildcardToRegExp(segment: string): RegExp {
  const escaped = segment.replace(/[.+^${}()|[\]\\]/g, "\\$&").replace(/\*/g, ".*");
  return new RegExp(`^${escaped}$`);
}

function expandPattern(pattern: string, sourceHarnessRoot: string): string[] {
  const normalized = pattern.replace(/^\.?\//, "").replace(/\/+$/, "");
  const segments = normalized.split("/").filter(Boolean);

  if (segments.length === 0) {
    return [];
  }

  const matches: string[] = [];

  function walk(absCurrent: string, relCurrent: string, index: number): void {
    if (index >= segments.length) {
      if (existsSync(absCurrent)) {
        matches.push(relCurrent);
      }
      return;
    }

    const segment = segments[index];

    if (segment === "**") {
      walk(absCurrent, relCurrent, index + 1);
      if (!existsSync(absCurrent) || !lstatSync(absCurrent).isDirectory()) {
        return;
      }
      for (const entry of readdirSync(absCurrent)) {
        const absNext = join(absCurrent, entry);
        if (!lstatSync(absNext).isDirectory()) {
          continue;
        }
        const relNext = relCurrent ? `${relCurrent}/${entry}` : entry;
        walk(absNext, relNext, index);
      }
      return;
    }

    if (segment.includes("*")) {
      if (!existsSync(absCurrent) || !lstatSync(absCurrent).isDirectory()) {
        return;
      }
      const matcher = wildcardToRegExp(segment);
      for (const entry of readdirSync(absCurrent)) {
        if (!matcher.test(entry)) {
          continue;
        }
        const absNext = join(absCurrent, entry);
        const relNext = relCurrent ? `${relCurrent}/${entry}` : entry;
        walk(absNext, relNext, index + 1);
      }
      return;
    }

    const absNext = join(absCurrent, segment);
    const relNext = relCurrent ? `${relCurrent}/${segment}` : segment;
    walk(absNext, relNext, index + 1);
  }

  walk(sourceHarnessRoot, "", 0);
  return matches;
}

function buildPortableSet(sourceHarnessRoot: string): { portablePaths: string[]; missing: string[] } {
  const manifestPath = join(sourceHarnessRoot, "harmony.yml");
  const manifestContent = readFileSync(manifestPath, "utf8");
  const manifestPaths = parsePortablePaths(manifestContent);

  const seen = new Set<string>();
  const missing: string[] = [];

  const addPath = (pathValue: string): void => {
    const normalized = pathValue.replace(/^\.?\//, "").replace(/\/+$/, "");
    if (!seen.has(normalized)) {
      seen.add(normalized);
    }
  };

  for (const requiredPath of REQUIRED_PORTABLE_PATHS) {
    addPath(requiredPath);
  }

  for (const entry of manifestPaths) {
    const expanded = entry.includes("*") ? expandPattern(entry, sourceHarnessRoot) : [entry];
    if (expanded.length === 0) {
      missing.push(entry);
      continue;
    }
    for (const candidate of expanded) {
      const normalized = candidate.replace(/^\.?\//, "").replace(/\/+$/, "");
      const absCandidate = join(sourceHarnessRoot, normalized);
      if (!existsSync(absCandidate)) {
        missing.push(candidate);
        continue;
      }
      addPath(normalized);
    }
  }

  return {
    portablePaths: [...seen].sort(),
    missing: [...new Set(missing)].sort(),
  };
}

function copyPortablePath(
  sourceHarnessRoot: string,
  targetHarnessRoot: string,
  relativePortablePath: string,
  overwrite: boolean,
  dryRun: boolean
): "copied" | "skipped" | "missing" {
  const sourcePath = join(sourceHarnessRoot, relativePortablePath);
  const targetPath = join(targetHarnessRoot, relativePortablePath);

  if (!existsSync(sourcePath)) {
    return "missing";
  }

  if (resolve(sourcePath) === resolve(targetPath)) {
    return "skipped";
  }

  if (existsSync(targetPath) && !overwrite) {
    return "skipped";
  }

  if (dryRun) {
    return "copied";
  }

  if (existsSync(targetPath) && overwrite) {
    rmSync(targetPath, { recursive: true, force: true });
  }

  mkdirSync(dirname(targetPath), { recursive: true });
  cpSync(sourcePath, targetPath, { recursive: true, force: true, dereference: false });
  return "copied";
}

function findSkillLinkScript(targetHarnessRoot: string): string | undefined {
  const candidates = [
    join(targetHarnessRoot, "capabilities", "skills", "_scripts", "setup-harness-links.sh"),
    join(targetHarnessRoot, "capabilities", "skills", "scripts", "setup-harness-links.sh"),
  ];

  return candidates.find((candidate) => existsSync(candidate));
}

function configureSkillLinks(
  targetRepoRoot: string,
  targetHarnessRoot: string,
  dryRun: boolean,
  skipLinks: boolean,
  verbose: boolean
): { configured: boolean; scriptPath?: string } {
  if (skipLinks) {
    return { configured: false };
  }

  const scriptPath = findSkillLinkScript(targetHarnessRoot);
  if (!scriptPath) {
    return { configured: false };
  }

  if (dryRun) {
    return { configured: true, scriptPath };
  }

  execFileSync("bash", [scriptPath], {
    cwd: targetRepoRoot,
    stdio: verbose ? "inherit" : "pipe",
  });

  return { configured: true, scriptPath };
}

function printSummary(
  action: HarnessAction,
  sourceHarnessRoot: string,
  targetHarnessRoot: string,
  dryRun: boolean,
  summary: SyncSummary,
  verbose: boolean
): void {
  console.log("");
  console.log(success(`${bold("Harmony harness")} ${action} ${dryRun ? "(dry-run) " : ""}complete`));
  console.log("");
  console.log(`${muted("Source:")} ${sourceHarnessRoot}`);
  console.log(`${muted("Target:")} ${targetHarnessRoot}`);
  console.log(`${muted("Copied:")} ${summary.copied.length}`);
  console.log(`${muted("Skipped:")} ${summary.skipped.length}`);
  console.log(`${muted("Missing:")} ${summary.missing.length}`);

  if (summary.configuredLinks) {
    console.log(`${muted("Skill links:")} ${success("configured")}${summary.linkScriptPath ? ` (${summary.linkScriptPath})` : ""}`);
  } else {
    console.log(`${muted("Skill links:")} ${dim("not configured")}`);
  }

  if (verbose) {
    if (summary.copied.length > 0) {
      console.log("");
      console.log(info("Copied paths:"));
      for (const value of summary.copied) {
        console.log(`  ${value}`);
      }
    }

    if (summary.skipped.length > 0) {
      console.log("");
      console.log(warning("Skipped paths:"));
      for (const value of summary.skipped) {
        console.log(`  ${value}`);
      }
    }

    if (summary.missing.length > 0) {
      console.log("");
      console.log(warning("Missing portable entries:"));
      for (const value of summary.missing) {
        console.log(`  ${value}`);
      }
    }
  } else if (summary.missing.length > 0) {
    console.log("");
    console.log(
      warning(
        `Some portable entries were not found in source. Re-run with ${bold("--verbose")} to inspect missing paths.`
      )
    );
  }

  console.log("");
}

export async function harnessCommand(
  actionArg?: string,
  options: HarnessOptions = {}
): Promise<CommandResult> {
  const action = normalizeAction(actionArg);
  if (!action) {
    throw new Error(
      'Usage: harmony harness <install|update> [--source <path>] [--target <path>] [--force] [--dry-run] [--skip-links]'
    );
  }

  const workspaceRoot = getWorkspaceRoot();
  const sourceRepoRoot = resolveRepoRoot(options.source ?? workspaceRoot);
  const targetRepoRoot = resolveRepoRoot(options.target ?? workspaceRoot);
  const sourceHarnessRoot = resolveHarnessRoot(sourceRepoRoot);
  const targetHarnessRoot = join(targetRepoRoot, ".harmony");

  const overwrite = action === "update" || options.force === true;
  const dryRun = options.dryRun === true;
  const verbose = options.verbose === true;
  const skipLinks = options.skipLinks === true;

  const { portablePaths, missing } = buildPortableSet(sourceHarnessRoot);

  const summary: SyncSummary = {
    copied: [],
    skipped: [],
    missing: [...missing],
    configuredLinks: false,
  };

  if (!dryRun) {
    mkdirSync(targetHarnessRoot, { recursive: true });
  }

  for (const portablePath of portablePaths) {
    const result = copyPortablePath(
      sourceHarnessRoot,
      targetHarnessRoot,
      portablePath,
      overwrite,
      dryRun
    );

    if (result === "copied") {
      summary.copied.push(portablePath);
    } else if (result === "skipped") {
      summary.skipped.push(portablePath);
    } else {
      summary.missing.push(portablePath);
    }
  }

  const links = configureSkillLinks(
    targetRepoRoot,
    targetHarnessRoot,
    dryRun,
    skipLinks,
    verbose
  );
  summary.configuredLinks = links.configured;
  summary.linkScriptPath = links.scriptPath;

  printSummary(action, sourceHarnessRoot, targetHarnessRoot, dryRun, summary, verbose);

  return {
    success: true,
    message: `Harness ${action} completed`,
    data: {
      sourceHarnessRoot,
      targetHarnessRoot,
      copied: summary.copied.length,
      skipped: summary.skipped.length,
      missing: summary.missing.length,
      dryRun,
      overwrite,
      skillLinksConfigured: summary.configuredLinks,
    },
    nextAction: dryRun
      ? "Re-run without --dry-run to apply changes."
      : `Run ${bold("bash .harmony/init.sh")} in ${targetHarnessRoot} to verify structure health.`,
  };
}

export const harnessHelp = {
  command: "harness",
  description: "Install or update .harmony in a repository from portable paths",
  usage: "harmony harness <install|update> [options]",
  options: [
    { flag: "--source <path>", description: "Source repo root or .harmony directory (default: current workspace)" },
    { flag: "--target <path>", description: "Target repo root or .harmony directory (default: current workspace)" },
    { flag: "--force", description: "Overwrite existing files during install" },
    { flag: "--dry-run", description: "Show planned changes without writing files" },
    { flag: "--skip-links", description: "Skip skill symlink setup script" },
    { flag: "--verbose", description: "Show copied/skipped/missing path details" },
  ],
  examples: [
    "harmony harness install --target ../my-service",
    "harmony harness install --source ~/repos/harmony --target .",
    "harmony harness update --target ../my-service --verbose",
    "harmony init --target ../my-service",
  ],
};

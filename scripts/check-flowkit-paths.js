#!/usr/bin/env node
/**
 * Validates that FlowKit asset paths referenced in configs, docs, and tests exist.
 *
 * This lightweight drift-prevention check ensures documented example paths and
 * runtime defaults actually resolve to existing files.
 *
 * Usage:
 *   node scripts/check-flowkit-paths.js
 *   pnpm flowkit:check-paths
 *
 * Exit codes:
 *   0 - All paths exist
 *   1 - One or more paths are missing
 */

import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { resolve, join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const REPO_ROOT = resolve(__dirname, "..");

/**
 * Critical paths that must exist for FlowKit to function.
 * These are extracted from:
 * - .flow.json configs
 * - Runtime defaults (graph_factory.py)
 * - Documentation examples (guide.md)
 */
const CRITICAL_PATHS = [
  // Flow configs (packages/workflows/<flowId>/config.flow.json)
  "packages/workflows/architecture_assessment/config.flow.json",
  "packages/workflows/docs_glossary/config.flow.json",

  // Canonical prompts (packages/workflows/<flowId>/00-overview.md)
  "packages/workflows/architecture_assessment/00-overview.md",
  "packages/workflows/docs_glossary/00-overview.md",

  // Workflow manifests (packages/workflows/<flowId>/manifest.yaml)
  "packages/workflows/architecture_assessment/manifest.yaml",
  "packages/workflows/docs_glossary/manifest.yaml",

  // Runtime
  "agents/runner/runtime/server.py",
  "agents/runner/runtime/assessment/graph_factory.py",
  "agents/runner/runtime/glossary/graph_factory.py",
  "agents/runner/runtime/assessment/studio_entry.py",
  "agents/runner/runtime/glossary/studio_entry.py",

  // LangGraph config
  "langgraph.json",

  // FlowKit package
  "packages/kits/flowkit/src/cli.ts",
  "packages/kits/flowkit/src/index.ts",
  "packages/kits/flowkit/src/types.ts",

  // Harmony workflow
  ".harmony/orchestration/workflows/flowkit/run-flow/00-overview.md",
  ".harmony/orchestration/workflows/flowkit/run-flow/01-validate-input.md",
  ".harmony/orchestration/workflows/flowkit/run-flow/02-parse-config.md",
  ".harmony/orchestration/workflows/flowkit/run-flow/03-execute-flow.md",
  ".harmony/orchestration/workflows/flowkit/run-flow/04-report-results.md",

  // Cursor command
  ".cursor/commands/run-flow.md",

  // Docs
  ".harmony/capabilities/services/execution/flow/guide.md",

  // OpenAPI contract
  "packages/contracts/openapi.yaml",
];

/**
 * Validate all critical paths exist.
 */
function validatePaths() {
  const missing = [];
  const present = [];

  for (const relativePath of CRITICAL_PATHS) {
    const absolutePath = resolve(REPO_ROOT, relativePath);
    if (existsSync(absolutePath)) {
      present.push(relativePath);
    } else {
      missing.push(relativePath);
    }
  }

  return { missing, present };
}

/**
 * Dynamically discover .flow.json files and validate their internal paths.
 */
function validateFlowConfigs() {
  const errors = [];

  const workflowsDir = resolve(REPO_ROOT, "packages/workflows");

  if (!existsSync(workflowsDir)) {
    return errors;
  }

  // Simple recursive search for .flow.json files
  function findFlowConfigs(dir) {
    const results = [];
    try {
      const entries = readdirSync(dir);
      for (const entry of entries) {
        const fullPath = join(dir, entry);
        const stat = statSync(fullPath);
        if (stat.isDirectory()) {
          results.push(...findFlowConfigs(fullPath));
        } else if (entry.endsWith(".flow.json")) {
          results.push(fullPath);
        }
      }
    } catch {
      // Ignore permission errors
    }
    return results;
  }

  const flowConfigs = findFlowConfigs(workflowsDir);

  for (const configPath of flowConfigs) {
    try {
      const content = readFileSync(configPath, "utf8");
      const config = JSON.parse(content);
      const configRelative = configPath.replace(REPO_ROOT + "/", "");

      // Validate canonicalPromptPath
      if (config.canonicalPromptPath) {
        const promptPath = resolve(REPO_ROOT, config.canonicalPromptPath);
        if (!existsSync(promptPath)) {
          errors.push(
            `${configRelative}: canonicalPromptPath "${config.canonicalPromptPath}" does not exist`
          );
        }
      }

      // Validate workflowManifestPath
      if (config.workflowManifestPath) {
        const manifestPath = resolve(REPO_ROOT, config.workflowManifestPath);
        if (!existsSync(manifestPath)) {
          errors.push(
            `${configRelative}: workflowManifestPath "${config.workflowManifestPath}" does not exist`
          );
        }
      }
    } catch (error) {
      errors.push(`${configPath}: Failed to parse: ${error.message}`);
    }
  }

  return errors;
}

function main() {
  console.log("FlowKit Path Validation\n");
  console.log("=".repeat(60));

  // Validate critical paths
  const { missing, present } = validatePaths();

  console.log(`\nCritical paths: ${present.length}/${CRITICAL_PATHS.length} present`);

  if (missing.length > 0) {
    console.log("\n❌ Missing critical paths:");
    for (const path of missing) {
      console.log(`   - ${path}`);
    }
  } else {
    console.log("✅ All critical paths exist");
  }

  // Validate flow config internal references
  const configErrors = validateFlowConfigs();

  if (configErrors.length > 0) {
    console.log("\n❌ Flow config path errors:");
    for (const error of configErrors) {
      console.log(`   - ${error}`);
    }
  } else {
    console.log("✅ All flow config paths resolve");
  }

  console.log("\n" + "=".repeat(60));

  const totalErrors = missing.length + configErrors.length;
  if (totalErrors > 0) {
    console.log(`\n❌ FAIL: ${totalErrors} path issue(s) found`);
    process.exitCode = 1;
  } else {
    console.log("\n✅ PASS: All FlowKit paths valid");
  }
}

main();

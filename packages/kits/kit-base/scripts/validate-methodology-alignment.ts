#!/usr/bin/env npx tsx
/**
 * Validate methodology alignment across all kits.
 *
 * This script validates that all kit metadata files conform to the current
 * schema and methodology versions, checking for:
 * - Schema validation errors
 * - Version consistency
 * - Deprecation warnings
 * - Structural methodology compliance
 *
 * Usage:
 *   npx tsx scripts/validate-methodology-alignment.ts
 *   pnpm --filter @harmony/kit-base validate:methodology
 *
 * Exit codes:
 *   0 - All validations passed
 *   1 - Validation errors found
 *   2 - Deprecation warnings found (with --strict)
 */

import * as fs from "fs";
import * as path from "path";
import {
  KitMetadataSchema,
  validateWithEnforcement,
  checkDeprecations,
  compareSemver,
  isVersionSupported,
  CURRENT_SCHEMA_VERSION,
  CURRENT_METHODOLOGY_VERSION,
  MIN_SUPPORTED_SCHEMA_VERSION,
  type EnforcementMode,
  type DeprecationWarning,
} from "../src/validation.js";

// ============================================================================
// Configuration
// ============================================================================

interface ValidationConfig {
  /** Enforcement mode for validation */
  enforcementMode: EnforcementMode;
  /** Whether to fail on deprecation warnings */
  strictDeprecations: boolean;
  /** Whether to output JSON */
  jsonOutput: boolean;
  /** Kit directories to scan */
  kitDirs: string[];
}

const DEFAULT_CONFIG: ValidationConfig = {
  enforcementMode: "block",
  strictDeprecations: false,
  jsonOutput: false,
  kitDirs: [
    "../flowkit",
    "../guardkit",
    "../promptkit",
    "../costkit",
  ],
};

// ============================================================================
// Types
// ============================================================================

interface KitValidationResult {
  kit: string;
  path: string;
  valid: boolean;
  errors: Array<{ path: string; message: string }>;
  warnings: DeprecationWarning[];
  schemaVersion?: string;
  methodologyVersion?: string;
  kitVersion?: string;
}

interface ValidationSummary {
  totalKits: number;
  validKits: number;
  invalidKits: number;
  totalErrors: number;
  totalWarnings: number;
  schemaVersion: string;
  methodologyVersion: string;
  results: KitValidationResult[];
}

// ============================================================================
// Utility Functions
// ============================================================================

function findKitMetadataFiles(baseDir: string, kitDirs: string[]): string[] {
  const metadataFiles: string[] = [];

  for (const kitDir of kitDirs) {
    const fullPath = path.resolve(baseDir, kitDir, "metadata", "kit.metadata.json");
    if (fs.existsSync(fullPath)) {
      metadataFiles.push(fullPath);
    }
  }

  return metadataFiles;
}

function loadJsonFile(filePath: string): unknown {
  const content = fs.readFileSync(filePath, "utf-8");
  return JSON.parse(content);
}

function getKitName(filePath: string): string {
  const parts = filePath.split(path.sep);
  const kitDirIndex = parts.findIndex((p) => p.endsWith("kit"));
  return kitDirIndex >= 0 ? parts[kitDirIndex] : path.basename(path.dirname(path.dirname(filePath)));
}

// ============================================================================
// Validation Functions
// ============================================================================

function validateKitMetadata(
  filePath: string,
  config: ValidationConfig
): KitValidationResult {
  const kitName = getKitName(filePath);

  try {
    const metadata = loadJsonFile(filePath);

    // Validate against schema
    const result = validateWithEnforcement(KitMetadataSchema, metadata, {
      enforcementMode: config.enforcementMode,
      checkDeprecations: true,
      schemaName: `${kitName}/kit.metadata.json`,
    });

    // Extract versions
    const schemaVersion = (metadata as Record<string, unknown>).schemaVersion as string | undefined;
    const methodologyVersion = (metadata as Record<string, unknown>).methodologyVersion as string | undefined;
    const kitVersion = (metadata as Record<string, unknown>).version as string | undefined;

    // Check version compatibility
    const versionErrors: Array<{ path: string; message: string }> = [];

    if (schemaVersion && !isVersionSupported(schemaVersion, MIN_SUPPORTED_SCHEMA_VERSION, CURRENT_SCHEMA_VERSION)) {
      versionErrors.push({
        path: "schemaVersion",
        message: `Schema version ${schemaVersion} is not supported (min: ${MIN_SUPPORTED_SCHEMA_VERSION}, current: ${CURRENT_SCHEMA_VERSION})`,
      });
    }

    // Check for deprecation warnings in the metadata itself
    const deprecationWarnings = checkDeprecations(metadata, kitName);

    return {
      kit: kitName,
      path: filePath,
      valid: result.success && versionErrors.length === 0,
      errors: [...(result.errors ?? []), ...versionErrors],
      warnings: [...(result.warnings ?? []), ...deprecationWarnings],
      schemaVersion,
      methodologyVersion,
      kitVersion,
    };
  } catch (error) {
    return {
      kit: kitName,
      path: filePath,
      valid: false,
      errors: [
        {
          path: "",
          message: error instanceof Error ? error.message : String(error),
        },
      ],
      warnings: [],
    };
  }
}

function validateAllKits(config: ValidationConfig): ValidationSummary {
  const baseDir = path.resolve(__dirname, "..");
  const metadataFiles = findKitMetadataFiles(baseDir, config.kitDirs);

  const results: KitValidationResult[] = [];

  for (const filePath of metadataFiles) {
    const result = validateKitMetadata(filePath, config);
    results.push(result);
  }

  const validKits = results.filter((r) => r.valid).length;
  const totalErrors = results.reduce((sum, r) => sum + r.errors.length, 0);
  const totalWarnings = results.reduce((sum, r) => sum + r.warnings.length, 0);

  return {
    totalKits: results.length,
    validKits,
    invalidKits: results.length - validKits,
    totalErrors,
    totalWarnings,
    schemaVersion: CURRENT_SCHEMA_VERSION,
    methodologyVersion: CURRENT_METHODOLOGY_VERSION,
    results,
  };
}

// ============================================================================
// Output Functions
// ============================================================================

function printTextSummary(summary: ValidationSummary): void {
  console.log("\n=== Methodology Alignment Validation ===\n");
  console.log(`Schema Version:      ${summary.schemaVersion}`);
  console.log(`Methodology Version: ${summary.methodologyVersion}`);
  console.log(`Total Kits:          ${summary.totalKits}`);
  console.log(`Valid:               ${summary.validKits}`);
  console.log(`Invalid:             ${summary.invalidKits}`);
  console.log(`Errors:              ${summary.totalErrors}`);
  console.log(`Warnings:            ${summary.totalWarnings}`);
  console.log("");

  for (const result of summary.results) {
    const status = result.valid ? "✓" : "✗";
    const statusColor = result.valid ? "\x1b[32m" : "\x1b[31m";
    const reset = "\x1b[0m";

    console.log(`${statusColor}${status}${reset} ${result.kit}`);
    console.log(`  Path: ${result.path}`);
    console.log(`  Schema: ${result.schemaVersion ?? "not specified"}`);
    console.log(`  Methodology: ${result.methodologyVersion ?? "not specified"}`);
    console.log(`  Kit Version: ${result.kitVersion ?? "not specified"}`);

    if (result.errors.length > 0) {
      console.log("  Errors:");
      for (const error of result.errors) {
        console.log(`    - ${error.path}: ${error.message}`);
      }
    }

    if (result.warnings.length > 0) {
      console.log("  Warnings:");
      for (const warning of result.warnings) {
        console.log(`    - ${warning.field}: ${warning.message}`);
      }
    }

    console.log("");
  }
}

function printJsonSummary(summary: ValidationSummary): void {
  console.log(JSON.stringify(summary, null, 2));
}

// ============================================================================
// CLI
// ============================================================================

function parseArgs(args: string[]): ValidationConfig {
  const config = { ...DEFAULT_CONFIG };

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];

    switch (arg) {
      case "--strict":
        config.strictDeprecations = true;
        break;
      case "--warn":
        config.enforcementMode = "warn";
        break;
      case "--json":
        config.jsonOutput = true;
        break;
      case "--help":
      case "-h":
        printHelp();
        process.exit(0);
        break;
      default:
        if (!arg.startsWith("-")) {
          // Treat as kit directory
          config.kitDirs.push(arg);
        }
    }
  }

  return config;
}

function printHelp(): void {
  console.log(`
Usage: validate-methodology-alignment [options] [kit-dirs...]

Validate methodology alignment across all kits.

Options:
  --strict    Fail on deprecation warnings (exit code 2)
  --warn      Use warn mode instead of block mode
  --json      Output results as JSON
  -h, --help  Show this help message

Examples:
  npx tsx scripts/validate-methodology-alignment.ts
  npx tsx scripts/validate-methodology-alignment.ts --strict --json
  npx tsx scripts/validate-methodology-alignment.ts ../mykit
`);
}

async function main(): Promise<void> {
  const args = process.argv.slice(2);
  const config = parseArgs(args);

  const summary = validateAllKits(config);

  if (config.jsonOutput) {
    printJsonSummary(summary);
  } else {
    printTextSummary(summary);
  }

  // Determine exit code
  if (summary.invalidKits > 0) {
    process.exit(1);
  }

  if (config.strictDeprecations && summary.totalWarnings > 0) {
    process.exit(2);
  }

  console.log("✓ All methodology alignment checks passed\n");
  process.exit(0);
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});


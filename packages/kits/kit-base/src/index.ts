/**
 * @harmony/kit-base - Shared infrastructure for Harmony Kits
 *
 * Provides foundational utilities that all kits depend on:
 * - Typed errors with standard exit codes
 * - Run record generation
 * - Observability bootstrap (OTel)
 * - Standard CLI flag parsing
 * - Kit metadata types and loading
 */

// Errors
export * from "./errors.js";

// Run Records
export * from "./run-record.js";

// Observability
export * from "./observability.js";

// CLI Flags
export * from "./cli-flags.js";

// Metadata
export * from "./metadata.js";

// Types
export * from "./types.js";


/**
 * @harmony/kit-base - Shared infrastructure for Harmony Kits
 *
 * Provides foundational utilities that all kits depend on:
 * - Typed errors with standard exit codes
 * - Run record generation
 * - Observability bootstrap (OTel)
 * - Standard CLI flag parsing
 * - Kit metadata types and loading
 * - Zod-based validation utilities
 * - Idempotency key management
 * - CLI base utilities
 * - HTTP client utilities for kit runners
 */

// Errors
export * from "./errors.js";

// Run Records
export * from "./run-record.js";

// Observability
export * from "./observability.js";

// CLI Flags
export * from "./cli-flags.js";

// CLI Base
export * from "./cli-base.js";

// Metadata
export * from "./metadata.js";

// Types
export * from "./types.js";

// Validation
export * from "./validation.js";

// Idempotency
export * from "./idempotency.js";

// HTTP Client
export * from "./http-client.js";


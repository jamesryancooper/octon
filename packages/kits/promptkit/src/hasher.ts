/**
 * PromptKit Hasher
 *
 * Deterministic hash computation for prompts per AI-Toolkit policy.
 * Enables reproducibility verification and caching.
 */

import { createHash } from "crypto";
import { isSensitiveKey } from "./types";

/**
 * Compute a deterministic hash of a compiled prompt.
 *
 * The hash includes:
 * - The rendered prompt text
 * - The input variables (with secrets redacted)
 * - The prompt ID and version
 *
 * @param prompt - The rendered prompt text
 * @param variables - Input variables used (will be redacted)
 * @param promptId - The prompt identifier
 * @param version - The prompt version
 * @returns A hash string in the format "sha256:hexdigest"
 */
export function computePromptHash(
  prompt: string,
  variables: Record<string, unknown>,
  promptId?: string,
  version?: string
): string {
  // Create canonical representation
  const canonical = createCanonicalRepresentation({
    prompt,
    variables: redactSecrets(variables),
    promptId: promptId ?? null,
    version: version ?? null,
  });

  // Compute SHA-256 hash
  const hash = createHash("sha256").update(canonical).digest("hex");

  return `sha256:${hash}`;
}

/**
 * Create a canonical JSON representation for hashing.
 * Keys are sorted alphabetically for determinism.
 */
function createCanonicalRepresentation(obj: Record<string, unknown>): string {
  return JSON.stringify(obj, (_, value) => {
    if (value && typeof value === "object" && !Array.isArray(value)) {
      // Sort object keys
      return Object.keys(value)
        .sort()
        .reduce(
          (sorted, key) => {
            sorted[key] = (value as Record<string, unknown>)[key];
            return sorted;
          },
          {} as Record<string, unknown>
        );
    }
    return value;
  });
}

/**
 * Redact sensitive values from variables.
 *
 * @param variables - Variables to redact
 * @returns Variables with sensitive values replaced by "[REDACTED]"
 */
export function redactSecrets(
  variables: Record<string, unknown>
): Record<string, unknown> {
  return Object.entries(variables).reduce(
    (redacted, [key, value]) => {
      if (isSensitiveKey(key)) {
        redacted[key] = "[REDACTED]";
      } else if (value && typeof value === "object") {
        if (Array.isArray(value)) {
          redacted[key] = value.map((item) =>
            typeof item === "object" && item !== null
              ? redactSecrets(item as Record<string, unknown>)
              : item
          );
        } else {
          redacted[key] = redactSecrets(value as Record<string, unknown>);
        }
      } else {
        redacted[key] = value;
      }
      return redacted;
    },
    {} as Record<string, unknown>
  );
}

/**
 * Verify that a prompt matches its expected hash.
 *
 * @param prompt - The prompt text to verify
 * @param variables - Variables used
 * @param expectedHash - The expected hash string
 * @param promptId - Optional prompt identifier
 * @param version - Optional prompt version
 * @returns Whether the computed hash matches the expected hash
 */
export function verifyPromptHash(
  prompt: string,
  variables: Record<string, unknown>,
  expectedHash: string,
  promptId?: string,
  version?: string
): boolean {
  const computedHash = computePromptHash(prompt, variables, promptId, version);
  return timingSafeEqual(computedHash, expectedHash);
}

/**
 * Timing-safe string comparison to prevent timing attacks.
 */
function timingSafeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) {
    return false;
  }

  let result = 0;
  for (let i = 0; i < a.length; i++) {
    result |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return result === 0;
}

/**
 * Parse a hash string to extract algorithm and digest.
 *
 * @param hash - Hash string in format "algorithm:digest"
 * @returns Parsed hash components or null if invalid
 */
export function parseHash(hash: string): ParsedHash | null {
  const match = hash.match(/^([a-z0-9]+):([a-f0-9]+)$/i);
  if (!match) {
    return null;
  }

  return {
    algorithm: match[1],
    digest: match[2],
  };
}

/**
 * Compute a short hash for display purposes.
 *
 * @param hash - Full hash string
 * @param length - Number of characters to include (default: 8)
 * @returns Shortened hash
 */
export function shortHash(hash: string, length = 8): string {
  const parsed = parseHash(hash);
  if (!parsed) {
    return hash.slice(0, length);
  }
  return `${parsed.algorithm}:${parsed.digest.slice(0, length)}`;
}

/**
 * Combine multiple hashes into a single composite hash.
 * Useful for assembled prompts with multiple components.
 *
 * @param hashes - Array of hash strings to combine
 * @returns Combined hash string
 */
export function combineHashes(hashes: string[]): string {
  if (hashes.length === 0) {
    throw new Error("Cannot combine empty hash array");
  }

  if (hashes.length === 1) {
    return hashes[0];
  }

  // Extract digests and combine
  const digests = hashes.map((h) => {
    const parsed = parseHash(h);
    return parsed ? parsed.digest : h;
  });

  const combined = createHash("sha256").update(digests.join(":")).digest("hex");

  return `sha256:${combined}`;
}

/**
 * Parsed hash components.
 */
export interface ParsedHash {
  algorithm: string;
  digest: string;
}


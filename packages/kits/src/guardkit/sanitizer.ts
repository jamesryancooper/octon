/**
 * Input sanitization for prompt injection protection.
 */

import type { SanitizeOptions, SanitizeResult, Severity } from "./types.js";
import { INJECTION_PATTERNS, PII_PATTERNS, SECRET_PATTERNS } from "./patterns.js";

/**
 * Default sanitization options.
 */
const DEFAULT_OPTIONS: Required<SanitizeOptions> = {
  maxLength: 10000,
  stripCode: false,
  escapeInjectionPatterns: true,
  allowedChars: "",
  stripMarkdown: false,
  redactPii: false,
  redactPatterns: [],
};

/**
 * Sanitize input for safe use in AI prompts.
 */
export function sanitize(input: string, options: SanitizeOptions = {}): SanitizeResult {
  const opts = { ...DEFAULT_OPTIONS, ...options };
  const modifications: string[] = [];
  const redactions: string[] = [];
  let sanitized = input;

  // 1. Truncate if too long
  if (sanitized.length > opts.maxLength) {
    sanitized = sanitized.slice(0, opts.maxLength);
    modifications.push(`Truncated from ${input.length} to ${opts.maxLength} characters`);
  }

  // 2. Remove zero-width and invisible characters
  const invisibleChars = /[\u200B-\u200F\u2028-\u202F\uFEFF\u0000-\u001F]/g;
  if (invisibleChars.test(sanitized)) {
    sanitized = sanitized.replace(invisibleChars, "");
    modifications.push("Removed invisible/zero-width characters");
  }

  // 3. Strip code blocks if requested
  if (opts.stripCode) {
    const codeBlockRegex = /```[\s\S]*?```|`[^`]+`/g;
    if (codeBlockRegex.test(sanitized)) {
      sanitized = sanitized.replace(codeBlockRegex, "[CODE_BLOCK_REMOVED]");
      modifications.push("Stripped code blocks");
    }
  }

  // 4. Strip markdown if requested
  if (opts.stripMarkdown) {
    // Remove headers
    sanitized = sanitized.replace(/^#{1,6}\s+/gm, "");
    // Remove bold/italic
    sanitized = sanitized.replace(/\*\*([^*]+)\*\*/g, "$1");
    sanitized = sanitized.replace(/\*([^*]+)\*/g, "$1");
    sanitized = sanitized.replace(/__([^_]+)__/g, "$1");
    sanitized = sanitized.replace(/_([^_]+)_/g, "$1");
    // Remove links
    sanitized = sanitized.replace(/\[([^\]]+)\]\([^)]+\)/g, "$1");
    // Remove images
    sanitized = sanitized.replace(/!\[([^\]]*)\]\([^)]+\)/g, "");
    modifications.push("Stripped markdown formatting");
  }

  // 5. Escape injection patterns if requested
  if (opts.escapeInjectionPatterns) {
    for (const { id, pattern } of INJECTION_PATTERNS) {
      if (pattern.test(sanitized)) {
        // Replace with escaped version
        sanitized = sanitized.replace(pattern, (match) => {
          redactions.push(`[INJECTION:${id}] ${match.slice(0, 50)}...`);
          return `[BLOCKED:${id}]`;
        });
        modifications.push(`Blocked injection pattern: ${id}`);
      }
    }
  }

  // 6. Redact secrets
  for (const { id, pattern } of SECRET_PATTERNS) {
    if (pattern.test(sanitized)) {
      sanitized = sanitized.replace(pattern, (match) => {
        redactions.push(`[SECRET:${id}] ${match.slice(0, 10)}...`);
        return `[REDACTED:${id}]`;
      });
      modifications.push(`Redacted secret: ${id}`);
    }
  }

  // 7. Redact PII if requested
  if (opts.redactPii) {
    for (const pii of PII_PATTERNS) {
      if (pii.pattern.test(sanitized)) {
        sanitized = sanitized.replace(pii.pattern, (match) => {
          redactions.push(`[PII:${pii.id}] ${match.slice(0, 5)}...`);
          return (pii as { redactTo?: string }).redactTo || `[REDACTED:${pii.id}]`;
        });
        modifications.push(`Redacted PII: ${pii.id}`);
      }
    }
  }

  // 8. Apply custom redaction patterns
  for (let i = 0; i < opts.redactPatterns.length; i++) {
    const pattern = opts.redactPatterns[i];
    if (pattern.test(sanitized)) {
      sanitized = sanitized.replace(pattern, (match) => {
        redactions.push(`[CUSTOM:${i}] ${match.slice(0, 20)}...`);
        return `[REDACTED:CUSTOM_${i}]`;
      });
      modifications.push(`Applied custom redaction pattern ${i}`);
    }
  }

  // 9. Filter to allowed characters if specified
  if (opts.allowedChars) {
    const allowedRegex = new RegExp(`[^${opts.allowedChars}]`, "g");
    if (allowedRegex.test(sanitized)) {
      sanitized = sanitized.replace(allowedRegex, "");
      modifications.push("Filtered to allowed character set");
    }
  }

  return {
    sanitized,
    original: input,
    modified: sanitized !== input,
    modifications,
    redactions,
  };
}

/**
 * Quick check if input contains potential injection attempts.
 */
export function containsInjection(input: string): {
  detected: boolean;
  patterns: Array<{ id: string; severity: Severity }>;
} {
  const patterns: Array<{ id: string; severity: Severity }> = [];

  for (const { id, pattern, severity } of INJECTION_PATTERNS) {
    if (pattern.test(input)) {
      patterns.push({ id, severity });
    }
  }

  return {
    detected: patterns.length > 0,
    patterns,
  };
}

/**
 * Quick check if input contains secrets.
 */
export function containsSecrets(input: string): {
  detected: boolean;
  types: string[];
} {
  const types: string[] = [];

  for (const { id, pattern } of SECRET_PATTERNS) {
    if (pattern.test(input)) {
      types.push(id);
    }
  }

  return {
    detected: types.length > 0,
    types,
  };
}

/**
 * Quick check if input contains PII.
 */
export function containsPii(input: string): {
  detected: boolean;
  types: string[];
} {
  const types: string[] = [];

  for (const { id, pattern } of PII_PATTERNS) {
    if (pattern.test(input)) {
      types.push(id);
    }
  }

  return {
    detected: types.length > 0,
    types,
  };
}

/**
 * Sanitize for safe inclusion in a prompt.
 * This is a convenience function with sensible defaults for prompt safety.
 */
export function sanitizeForPrompt(
  input: string,
  userInput: boolean = true
): SanitizeResult {
  return sanitize(input, {
    maxLength: userInput ? 5000 : 50000,
    escapeInjectionPatterns: userInput,
    redactPii: userInput,
    stripCode: false, // Allow code in prompts, but escape injection
  });
}

/**
 * Sanitize AI output before storing or displaying.
 * Ensures no secrets or sensitive data leak through AI responses.
 */
export function sanitizeOutput(output: string): SanitizeResult {
  return sanitize(output, {
    maxLength: 100000,
    escapeInjectionPatterns: false, // AI output doesn't need injection escape
    redactPii: false, // Don't redact, but flag it
    stripCode: false,
  });
}


/**
 * GuardKit - AI output guardrails and protection.
 *
 * Provides comprehensive protection against:
 * - Prompt injection attacks
 * - AI hallucinations (fake imports, functions, APIs)
 * - Secret/PII exposure
 * - Unsafe code patterns
 *
 * @example
 * ```typescript
 * import { GuardKit } from '@harmony/kits/guardkit';
 *
 * const guard = new GuardKit({
 *   projectRoot: process.cwd(),
 *   packageJson: require('./package.json'),
 * });
 *
 * // Check AI output before using
 * const result = await guard.check(aiOutput);
 * if (!result.safe) {
 *   console.error('Issues detected:', result.checks.filter(c => !c.passed));
 * }
 * ```
 */

import type {
  GuardrailResult,
  GuardrailCheckResult,
  SanitizeOptions,
  SanitizeResult,
  HallucinationCheckConfig,
  HallucinationCheckResult,
  CodeSafetyConfig,
  Severity,
} from "./types.js";

import {
  sanitize,
  sanitizeForPrompt,
  sanitizeOutput,
  containsInjection,
  containsSecrets,
  containsPii,
} from "./sanitizer.js";

import {
  detectHallucinations,
  checkCodeSafety,
  quickHallucinationCheck,
  verifyImports,
} from "./detector.js";

import {
  INJECTION_PATTERNS,
  SECRET_PATTERNS,
  PII_PATTERNS,
  CODE_SAFETY_PATTERNS,
  HALLUCINATION_PATTERNS,
  HUMAN_RED_FLAGS,
  matchesPatterns,
} from "./patterns.js";

/**
 * Configuration for GuardKit.
 */
export interface GuardKitConfig {
  /** Project root for file verification */
  projectRoot?: string;

  /** package.json content for import verification */
  packageJson?: Record<string, unknown>;

  /** Known files in the project (for hallucination detection) */
  knownFiles?: string[];

  /** Known exports/functions in the project */
  knownExports?: string[];

  /** Enable prompt injection checks */
  checkInjection?: boolean;

  /** Enable hallucination detection */
  checkHallucinations?: boolean;

  /** Enable secret detection */
  checkSecrets?: boolean;

  /** Enable PII detection */
  checkPii?: boolean;

  /** Enable code safety checks */
  checkCodeSafety?: boolean;

  /** Severity threshold for blocking (critical, high, medium, low) */
  blockThreshold?: Severity;
}

/**
 * Default configuration.
 */
const DEFAULT_CONFIG: Required<GuardKitConfig> = {
  projectRoot: "",
  packageJson: {},
  knownFiles: [],
  knownExports: [],
  checkInjection: true,
  checkHallucinations: true,
  checkSecrets: true,
  checkPii: true,
  checkCodeSafety: true,
  blockThreshold: "high",
};

/**
 * Severity ordering for comparison.
 */
const SEVERITY_ORDER: Record<Severity, number> = {
  critical: 4,
  high: 3,
  medium: 2,
  low: 1,
  info: 0,
};

/**
 * GuardKit - Comprehensive AI output protection.
 */
export class GuardKit {
  private config: Required<GuardKitConfig>;

  constructor(config: GuardKitConfig = {}) {
    this.config = { ...DEFAULT_CONFIG, ...config };
  }

  /**
   * Run all guardrail checks on content.
   */
  check(content: string): GuardrailResult {
    const checks: GuardrailCheckResult[] = [];
    const timestamp = new Date().toISOString();

    // 1. Prompt injection checks
    if (this.config.checkInjection) {
      const injectionResult = containsInjection(content);
      for (const { id, severity } of injectionResult.patterns) {
        checks.push({
          checkId: `injection_${id}`,
          name: `Injection: ${id}`,
          category: "prompt_injection",
          passed: false,
          severity,
          message: `Prompt injection pattern detected: ${id}`,
          suggestion: "Remove or escape the injection attempt",
        });
      }

      if (injectionResult.patterns.length === 0) {
        checks.push({
          checkId: "injection_none",
          name: "Injection Check",
          category: "prompt_injection",
          passed: true,
          message: "No prompt injection patterns detected",
        });
      }
    }

    // 2. Secret checks
    if (this.config.checkSecrets) {
      const secretResult = containsSecrets(content);
      for (const type of secretResult.types) {
        const pattern = SECRET_PATTERNS.find((p) => p.id === type);
        checks.push({
          checkId: `secret_${type}`,
          name: `Secret: ${type}`,
          category: "secret_exposure",
          passed: false,
          severity: pattern?.severity || "high",
          message: `Secret detected: ${type}`,
          suggestion: "Remove or redact the secret immediately",
        });
      }

      if (secretResult.types.length === 0) {
        checks.push({
          checkId: "secret_none",
          name: "Secret Check",
          category: "secret_exposure",
          passed: true,
          message: "No secrets detected",
        });
      }
    }

    // 3. PII checks
    if (this.config.checkPii) {
      const piiResult = containsPii(content);
      for (const type of piiResult.types) {
        const pattern = PII_PATTERNS.find((p) => p.id === type);
        checks.push({
          checkId: `pii_${type}`,
          name: `PII: ${type}`,
          category: "pii_exposure",
          passed: false,
          severity: pattern?.severity || "medium",
          message: `PII detected: ${type}`,
          suggestion: "Redact or remove personally identifiable information",
        });
      }

      if (piiResult.types.length === 0) {
        checks.push({
          checkId: "pii_none",
          name: "PII Check",
          category: "pii_exposure",
          passed: true,
          message: "No PII detected",
        });
      }
    }

    // 4. Hallucination checks
    if (this.config.checkHallucinations) {
      const hallucinationResult = detectHallucinations(content, {
        projectRoot: this.config.projectRoot,
        packageJson: this.config.packageJson,
        knownFiles: this.config.knownFiles,
        knownExports: this.config.knownExports,
        verifyImports: true,
        verifyFilePaths: !!this.config.projectRoot,
        verifyFunctions: this.config.knownExports.length > 0,
      });

      for (const issue of hallucinationResult.issues) {
        checks.push({
          checkId: `hallucination_${issue.type}_${checks.length}`,
          name: `Hallucination: ${issue.type}`,
          category: "hallucination",
          passed: false,
          severity: hallucinationResult.confidence > 0.5 ? "high" : "medium",
          message: issue.description,
          location: issue.location
            ? { start: 0, end: 0, context: issue.location }
            : undefined,
          suggestion: issue.suggestion,
        });
      }

      if (hallucinationResult.issues.length === 0) {
        checks.push({
          checkId: "hallucination_none",
          name: "Hallucination Check",
          category: "hallucination",
          passed: true,
          message: "No obvious hallucinations detected",
        });
      }
    }

    // 5. Code safety checks
    if (this.config.checkCodeSafety) {
      const safetyResults = checkCodeSafety(content);
      checks.push(...safetyResults);
    }

    // Calculate summary
    const summary: Record<Severity, number> = {
      critical: 0,
      high: 0,
      medium: 0,
      low: 0,
      info: 0,
    };

    for (const check of checks) {
      if (!check.passed && check.severity) {
        summary[check.severity]++;
      }
    }

    // Determine if safe based on threshold
    const thresholdLevel = SEVERITY_ORDER[this.config.blockThreshold];
    const blocked = Object.entries(summary).some(
      ([sev, count]) => count > 0 && SEVERITY_ORDER[sev as Severity] >= thresholdLevel
    );

    return {
      safe: !blocked,
      canProceed:
        summary.critical === 0 &&
        summary.high === 0 &&
        (this.config.blockThreshold !== "medium" || summary.medium === 0),
      totalChecks: checks.length,
      passedChecks: checks.filter((c) => c.passed).length,
      checks,
      summary,
      timestamp,
    };
  }

  /**
   * Sanitize input before using in a prompt.
   */
  sanitizeInput(input: string, options?: SanitizeOptions): SanitizeResult {
    return sanitize(input, options);
  }

  /**
   * Sanitize for safe inclusion in a prompt (convenience method).
   */
  sanitizeForPrompt(input: string, isUserInput: boolean = true): SanitizeResult {
    return sanitizeForPrompt(input, isUserInput);
  }

  /**
   * Sanitize AI output before storing or displaying.
   */
  sanitizeOutput(output: string): SanitizeResult {
    return sanitizeOutput(output);
  }

  /**
   * Quick check if content is likely safe (fast, less thorough).
   */
  quickCheck(content: string): { safe: boolean; reason?: string } {
    // Quick injection check
    const injection = containsInjection(content);
    if (injection.detected) {
      const critical = injection.patterns.find((p) => p.severity === "critical");
      if (critical) {
        return { safe: false, reason: `Injection detected: ${critical.id}` };
      }
    }

    // Quick secret check
    const secrets = containsSecrets(content);
    if (secrets.detected) {
      return { safe: false, reason: `Secret detected: ${secrets.types[0]}` };
    }

    // Quick hallucination check
    if (quickHallucinationCheck(content)) {
      return { safe: false, reason: "Possible hallucination patterns detected" };
    }

    return { safe: true };
  }

  /**
   * Get human-readable red flags for reviewers.
   */
  static getRedFlags(): typeof HUMAN_RED_FLAGS {
    return HUMAN_RED_FLAGS;
  }

  /**
   * Verify imports in code against package.json.
   */
  verifyImports(code: string): string[] {
    return verifyImports(code, this.config.packageJson);
  }

  /**
   * Detect hallucinations with detailed analysis.
   */
  detectHallucinations(content: string): HallucinationCheckResult {
    return detectHallucinations(content, {
      projectRoot: this.config.projectRoot,
      packageJson: this.config.packageJson,
      knownFiles: this.config.knownFiles,
      knownExports: this.config.knownExports,
    });
  }
}

// Export types
export type {
  GuardrailResult,
  GuardrailCheckResult,
  SanitizeOptions,
  SanitizeResult,
  HallucinationCheckConfig,
  HallucinationCheckResult,
  CodeSafetyConfig,
  Severity,
  GuardrailCategory,
} from "./types.js";

// Export utilities
export {
  sanitize,
  sanitizeForPrompt,
  sanitizeOutput,
  containsInjection,
  containsSecrets,
  containsPii,
} from "./sanitizer.js";

export {
  detectHallucinations,
  checkCodeSafety,
  quickHallucinationCheck,
  verifyImports,
} from "./detector.js";

export {
  INJECTION_PATTERNS,
  SECRET_PATTERNS,
  PII_PATTERNS,
  CODE_SAFETY_PATTERNS,
  HALLUCINATION_PATTERNS,
  HUMAN_RED_FLAGS,
  matchesPatterns,
} from "./patterns.js";


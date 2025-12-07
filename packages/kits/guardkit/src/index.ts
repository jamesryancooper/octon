/**
 * GuardKit - AI output guardrails and protection.
 *
 * Provides comprehensive protection against:
 * - Prompt injection attacks
 * - AI hallucinations (fake imports, functions, APIs)
 * - Secret/PII exposure
 * - Unsafe code patterns
 *
 * Pillar alignment:
 * - Speed with Safety: Enables safe AI output processing
 * - Quality through Determinism: Consistent guardrail checking
 *
 * @example
 * ```typescript
 * import { GuardKit } from '@harmony/guardkit';
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

import { SpanStatusCode } from "@opentelemetry/api";
import {
  getKitTracer,
  withKitSpan,
  createKitSpan,
  emitGateResult,
  getCurrentTraceId,
  type KitSpanContext,
} from "@harmony/kit-base";
import { GuardViolationError } from "@harmony/kit-base";
import {
  createRunRecord,
  safeWriteRunRecord,
  getRunsDirectory,
} from "@harmony/kit-base";

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

/** Kit metadata */
const KIT_NAME = "guardkit";
const KIT_VERSION = "0.1.0";

/**
 * Get kit span context for observability.
 */
function getSpanContext(): KitSpanContext {
  return {
    tracer: getKitTracer({ kitName: KIT_NAME, kitVersion: KIT_VERSION }),
    kitName: KIT_NAME,
    kitVersion: KIT_VERSION,
  };
}

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

  /** Enable run record generation (default: true) */
  enableRunRecords?: boolean;

  /** Directory to write run records (default: ./runs) */
  runsDir?: string;
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
  enableRunRecords: true,
  runsDir: "",
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
 *
 * Observability: Emits spans for check and sanitize operations.
 */
export class GuardKit {
  private config: Required<GuardKitConfig>;

  constructor(config: GuardKitConfig = {}) {
    this.config = { ...DEFAULT_CONFIG, ...config };
  }

  /**
   * Run all guardrail checks on content.
   *
   * Observability: Emits `kit.guardkit.check` span.
   */
  check(content: string): GuardrailResult {
    const ctx = getSpanContext();
    const span = createKitSpan(ctx, "check", {
      "content.length": content.length,
      "config.checkInjection": this.config.checkInjection,
      "config.checkSecrets": this.config.checkSecrets,
      "config.checkPii": this.config.checkPii,
      "config.checkHallucinations": this.config.checkHallucinations,
      "config.checkCodeSafety": this.config.checkCodeSafety,
      "config.blockThreshold": this.config.blockThreshold,
    });

    try {
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

      const result: GuardrailResult = {
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

      // Update span with results
      span.setAttribute("result.safe", result.safe);
      span.setAttribute("result.canProceed", result.canProceed);
      span.setAttribute("result.totalChecks", result.totalChecks);
      span.setAttribute("result.passedChecks", result.passedChecks);
      span.setAttribute("result.summary.critical", summary.critical);
      span.setAttribute("result.summary.high", summary.high);
      span.setAttribute("result.summary.medium", summary.medium);
      span.setAttribute("result.summary.low", summary.low);

      // Emit gate event
      if (result.safe) {
        emitGateResult(span, "guardrail_check", true);
      } else {
        emitGateResult(
          span,
          "guardrail_check",
          false,
          `Blocked: ${summary.critical} critical, ${summary.high} high issues`
        );
      }

      span.setStatus({ code: SpanStatusCode.OK });

      // Generate run record if enabled
      if (this.config.enableRunRecords) {
        const runRecord = createRunRecord({
          kit: { name: KIT_NAME, version: KIT_VERSION },
          inputs: { contentLength: content.length, config: {
            checkInjection: this.config.checkInjection,
            checkSecrets: this.config.checkSecrets,
            checkPii: this.config.checkPii,
            checkHallucinations: this.config.checkHallucinations,
            checkCodeSafety: this.config.checkCodeSafety,
          }},
          status: result.safe ? "success" : "failure",
          summary: result.safe
            ? `GuardKit check passed (${result.passedChecks}/${result.totalChecks} checks)`
            : `GuardKit check blocked: ${summary.critical} critical, ${summary.high} high issues`,
          stage: "verify",
          risk: summary.critical > 0 ? "high" : summary.high > 0 ? "medium" : "low",
          traceId: getCurrentTraceId() || timestamp,
          policy: result.safe
            ? { result: "pass", checked: ["injection", "secrets", "pii", "hallucination", "code_safety"] }
            : { result: "fail", checked: ["injection", "secrets", "pii", "hallucination", "code_safety"] },
        });

        const runsDir = this.config.runsDir || getRunsDirectory(this.config.projectRoot || process.cwd());
        safeWriteRunRecord(runRecord, runsDir);
      }

      return result;
    } catch (error) {
      span.setStatus({
        code: SpanStatusCode.ERROR,
        message: error instanceof Error ? error.message : "Unknown error",
      });
      if (error instanceof Error) {
        span.recordException(error);
      }
      throw error;
    } finally {
      span.end();
    }
  }

  /**
   * Sanitize input before using in a prompt.
   *
   * Observability: Emits `kit.guardkit.sanitize` span.
   */
  sanitizeInput(input: string, options?: SanitizeOptions): SanitizeResult {
    const ctx = getSpanContext();
    const span = createKitSpan(ctx, "sanitize", {
      "input.length": input.length,
      "mode": "input",
    });

    try {
      const result = sanitize(input, options);
      span.setAttribute("result.modified", result.modified);
      span.setAttribute("result.modifications", result.modifications.length);
      span.setAttribute("result.redactions", result.redactions.length);
      span.setStatus({ code: SpanStatusCode.OK });
      return result;
    } catch (error) {
      span.setStatus({
        code: SpanStatusCode.ERROR,
        message: error instanceof Error ? error.message : "Unknown error",
      });
      if (error instanceof Error) {
        span.recordException(error);
      }
      throw error;
    } finally {
      span.end();
    }
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

// HTTP Runner
export {
  createHttpGuardRunner,
  notImplementedGuardRunner,
  type GuardRunner,
  type HttpGuardRunnerOptions,
  type CheckOptions,
} from "./http-runner.js";

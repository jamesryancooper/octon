/**
 * Types for GuardKit - AI output guardrails and protection.
 */

/**
 * Severity level for detected issues.
 */
export type Severity = "critical" | "high" | "medium" | "low" | "info";

/**
 * Category of guardrail check.
 */
export type GuardrailCategory =
  | "prompt_injection"
  | "hallucination"
  | "pii_exposure"
  | "secret_exposure"
  | "schema_violation"
  | "code_safety"
  | "content_safety";

/**
 * Result of a single guardrail check.
 */
export interface GuardrailCheckResult {
  /** Unique identifier for the check */
  checkId: string;

  /** Human-readable name */
  name: string;

  /** Category of the check */
  category: GuardrailCategory;

  /** Whether the check passed */
  passed: boolean;

  /** Severity if failed */
  severity?: Severity;

  /** Detailed message */
  message: string;

  /** Location in the content where issue was found */
  location?: {
    start: number;
    end: number;
    context: string;
  };

  /** Suggested fix or action */
  suggestion?: string;
}

/**
 * Options for the check operation.
 */
export interface CheckOptions {
  /**
   * Idempotency key for caching check results.
   * If not provided, derived from content hash.
   */
  idempotencyKey?: string;
}

/**
 * Overall result of running guardrail checks.
 */
export interface GuardrailResult {
  /** Whether all critical/high checks passed */
  safe: boolean;

  /** Whether the content can proceed (passed or only low-severity issues) */
  canProceed: boolean;

  /** Total checks run */
  totalChecks: number;

  /** Checks passed */
  passedChecks: number;

  /** Individual check results */
  checks: GuardrailCheckResult[];

  /** Summary of issues by severity */
  summary: Record<Severity, number>;

  /** Timestamp of the check */
  timestamp: string;
}

/**
 * Options for sanitization.
 */
export interface SanitizeOptions {
  /** Maximum length for input (truncate if exceeded) */
  maxLength?: number;

  /** Strip code blocks */
  stripCode?: boolean;

  /** Escape potential injection patterns */
  escapeInjectionPatterns?: boolean;

  /** Allowed character set (regex pattern) */
  allowedChars?: string;

  /** Remove markdown formatting */
  stripMarkdown?: boolean;

  /** Redact known PII patterns */
  redactPii?: boolean;

  /** Custom patterns to redact */
  redactPatterns?: RegExp[];
}

/**
 * Result of sanitization.
 */
export interface SanitizeResult {
  /** Sanitized content */
  sanitized: string;

  /** Original content */
  original: string;

  /** Whether content was modified */
  modified: boolean;

  /** Modifications made */
  modifications: string[];

  /** Content that was redacted (for logging) */
  redactions: string[];
}

/**
 * Known hallucination patterns to detect.
 */
export interface HallucinationPattern {
  /** Pattern identifier */
  id: string;

  /** Description of what this detects */
  description: string;

  /** Detection regex or function */
  detect: RegExp | ((content: string) => boolean);

  /** Severity of this type of hallucination */
  severity: Severity;

  /** Category for this pattern */
  category: "import" | "function" | "type" | "file" | "api" | "general";
}

/**
 * Configuration for hallucination detection.
 */
export interface HallucinationCheckConfig {
  /** Project root for file path verification */
  projectRoot?: string;

  /** package.json content for dependency verification */
  packageJson?: Record<string, unknown>;

  /** Known files in the project */
  knownFiles?: string[];

  /** Known functions/exports in the project */
  knownExports?: string[];

  /** Additional patterns to check */
  customPatterns?: HallucinationPattern[];

  /** Verify imports against package.json */
  verifyImports?: boolean;

  /** Verify file paths exist */
  verifyFilePaths?: boolean;

  /** Verify function calls against known exports */
  verifyFunctions?: boolean;
}

/**
 * Result of hallucination detection.
 */
export interface HallucinationCheckResult {
  /** Overall assessment */
  likely_hallucination: boolean;

  /** Confidence score (0-1) */
  confidence: number;

  /** Detected issues */
  issues: Array<{
    type: string;
    description: string;
    location?: string;
    suggestion?: string;
  }>;

  /** Patterns that triggered */
  triggeredPatterns: string[];

  /** Recommendations for human reviewer */
  recommendations: string[];
}

/**
 * Code safety check configuration.
 */
export interface CodeSafetyConfig {
  /** Check for dangerous patterns (eval, exec, etc.) */
  checkDangerousPatterns?: boolean;

  /** Check for hardcoded secrets */
  checkSecrets?: boolean;

  /** Check for SQL injection vulnerabilities */
  checkSqlInjection?: boolean;

  /** Check for XSS vulnerabilities */
  checkXss?: boolean;

  /** Check for path traversal */
  checkPathTraversal?: boolean;

  /** Custom patterns to flag */
  customPatterns?: Array<{
    name: string;
    pattern: RegExp;
    severity: Severity;
    message: string;
  }>;
}


/**
 * Typed errors with standard exit codes for Harmony Kits.
 *
 * Exit codes follow the Harmony methodology specification:
 * - 0: Success
 * - 1: Generic failure (unexpected)
 * - 2: Policy violation
 * - 3: Evaluation/test failure
 * - 4: Guard/redaction failure
 * - 5: Invalid inputs/schema
 * - 6: Provider/integration error
 * - 7: Idempotency conflict
 * - 8: Cache integrity error
 */

/**
 * Standard exit codes for kit operations.
 */
export const ExitCodes = {
  SUCCESS: 0,
  GENERIC_FAILURE: 1,
  POLICY_VIOLATION: 2,
  EVALUATION_FAILURE: 3,
  GUARD_VIOLATION: 4,
  INPUT_VALIDATION: 5,
  UPSTREAM_PROVIDER: 6,
  IDEMPOTENCY_CONFLICT: 7,
  CACHE_INTEGRITY: 8,
} as const;

export type ExitCode = (typeof ExitCodes)[keyof typeof ExitCodes];

/**
 * Base error class for all kit errors.
 */
export abstract class KitError extends Error {
  /** Exit code for CLI operations */
  abstract readonly code: ExitCode;

  /** Suggested action to resolve the error */
  abstract readonly suggestedAction: string;

  /** Additional structured context (no secrets/PII) */
  readonly context: Record<string, unknown>;

  constructor(
    message: string,
    context: Record<string, unknown> = {},
    options?: { cause?: unknown }
  ) {
    super(message, options as ErrorOptions);
    this.name = this.constructor.name;
    this.context = context;
  }

  /**
   * Format as one-line JSON summary for stdout.
   */
  toJSONSummary(): string {
    return JSON.stringify({
      status: "failure",
      summary: this.message,
      error: {
        type: this.name,
        code: this.code,
        suggestedAction: this.suggestedAction,
      },
    });
  }

  /**
   * Format as structured log entry.
   */
  toLogEntry(traceId?: string, spanId?: string): Record<string, unknown> {
    return {
      level: "error",
      msg: this.message,
      "error.type": this.name,
      "error.code": this.code,
      ...(traceId && { trace_id: traceId }),
      ...(spanId && { span_id: spanId }),
      ...this.context,
    };
  }
}

/**
 * Policy violation error (exit code 2).
 *
 * Thrown when a policy gate blocks an operation.
 */
export class PolicyViolationError extends KitError {
  readonly code = ExitCodes.POLICY_VIOLATION;
  readonly suggestedAction =
    "Review the policy violation and fix the underlying issue, or request a waiver with justification.";

  /** Policy ruleset that was violated */
  readonly ruleset?: string;

  /** Specific policy IDs that were violated */
  readonly violatedPolicies?: string[];

  constructor(
    message: string,
    options?: {
      ruleset?: string;
      violatedPolicies?: string[];
      context?: Record<string, unknown>;
      cause?: Error;
    }
  ) {
    super(
      message,
      {
        "policy.ruleset": options?.ruleset,
        "policy.violated": options?.violatedPolicies,
        ...options?.context,
      },
      options?.cause ? { cause: options.cause } : undefined
    );
    this.ruleset = options?.ruleset;
    this.violatedPolicies = options?.violatedPolicies;
  }
}

/**
 * Evaluation/test failure error (exit code 3).
 *
 * Thrown when an evaluation or test gate fails.
 */
export class EvaluationFailureError extends KitError {
  readonly code = ExitCodes.EVALUATION_FAILURE;
  readonly suggestedAction =
    "Review the evaluation results and improve the output to meet the threshold.";

  /** Evaluation suite that failed */
  readonly suite?: string;

  /** Actual score achieved */
  readonly score?: number;

  /** Required threshold */
  readonly threshold?: number;

  constructor(
    message: string,
    options?: {
      suite?: string;
      score?: number;
      threshold?: number;
      context?: Record<string, unknown>;
      cause?: Error;
    }
  ) {
    super(
      message,
      {
        "eval.suite": options?.suite,
        "eval.score": options?.score,
        "eval.threshold": options?.threshold,
        ...options?.context,
      },
      options?.cause ? { cause: options.cause } : undefined
    );
    this.suite = options?.suite;
    this.score = options?.score;
    this.threshold = options?.threshold;
  }
}

/**
 * Guard/redaction violation error (exit code 4).
 *
 * Thrown when GuardKit detects secrets, PII, or other prohibited content.
 */
export class GuardViolationError extends KitError {
  readonly code = ExitCodes.GUARD_VIOLATION;
  readonly suggestedAction =
    "Remove or redact the sensitive content, then retry the operation.";

  /** Type of violation (secret, pii, injection, etc.) */
  readonly violationType?: string;

  /** Categories of violations detected */
  readonly categories?: string[];

  constructor(
    message: string,
    options?: {
      violationType?: string;
      categories?: string[];
      context?: Record<string, unknown>;
      cause?: Error;
    }
  ) {
    super(
      message,
      {
        "guard.violationType": options?.violationType,
        "guard.categories": options?.categories,
        ...options?.context,
      },
      options?.cause ? { cause: options.cause } : undefined
    );
    this.violationType = options?.violationType;
    this.categories = options?.categories;
  }
}

/**
 * Input validation error (exit code 5).
 *
 * Thrown when inputs fail schema validation.
 */
export class InputValidationError extends KitError {
  readonly code = ExitCodes.INPUT_VALIDATION;
  readonly suggestedAction =
    "Fix the input according to the schema requirements.";

  /** Schema that was violated */
  readonly schema?: string;

  /** Validation errors */
  readonly validationErrors?: Array<{
    path: string;
    message: string;
  }>;

  constructor(
    message: string,
    options?: {
      schema?: string;
      validationErrors?: Array<{ path: string; message: string }>;
      context?: Record<string, unknown>;
      cause?: Error;
    }
  ) {
    super(
      message,
      {
        "validation.schema": options?.schema,
        "validation.errors": options?.validationErrors,
        ...options?.context,
      },
      options?.cause ? { cause: options.cause } : undefined
    );
    this.schema = options?.schema;
    this.validationErrors = options?.validationErrors;
  }
}

/**
 * Upstream provider error (exit code 6).
 *
 * Thrown when an external service (AI provider, HTTP, etc.) fails.
 */
export class UpstreamProviderError extends KitError {
  readonly code = ExitCodes.UPSTREAM_PROVIDER;
  readonly suggestedAction =
    "Retry the operation. If the issue persists, check the provider status.";

  /** Provider that failed */
  readonly provider?: string;

  /** HTTP status code if applicable */
  readonly statusCode?: number;

  constructor(
    message: string,
    options?: {
      provider?: string;
      statusCode?: number;
      context?: Record<string, unknown>;
      cause?: Error;
    }
  ) {
    super(
      message,
      {
        "upstream.provider": options?.provider,
        "upstream.statusCode": options?.statusCode,
        ...options?.context,
      },
      options?.cause ? { cause: options.cause } : undefined
    );
    this.provider = options?.provider;
    this.statusCode = options?.statusCode;
  }
}

/**
 * Idempotency conflict error (exit code 7).
 *
 * Thrown when an operation conflicts with a previous run.
 */
export class IdempotencyConflictError extends KitError {
  readonly code = ExitCodes.IDEMPOTENCY_CONFLICT;
  readonly suggestedAction =
    "Use a different idempotency key or wait for the previous operation to complete.";

  /** The conflicting idempotency key */
  readonly idempotencyKey?: string;

  /** ID of the conflicting run */
  readonly conflictingRunId?: string;

  constructor(
    message: string,
    options?: {
      idempotencyKey?: string;
      conflictingRunId?: string;
      context?: Record<string, unknown>;
      cause?: Error;
    }
  ) {
    super(
      message,
      {
        "idempotency.key": options?.idempotencyKey,
        "idempotency.conflictingRunId": options?.conflictingRunId,
        ...options?.context,
      },
      options?.cause ? { cause: options.cause } : undefined
    );
    this.idempotencyKey = options?.idempotencyKey;
    this.conflictingRunId = options?.conflictingRunId;
  }
}

/**
 * Cache integrity error (exit code 8).
 *
 * Thrown when cached data is corrupted or invalid.
 */
export class CacheIntegrityError extends KitError {
  readonly code = ExitCodes.CACHE_INTEGRITY;
  readonly suggestedAction =
    "Clear the cache with --cache-bust and retry the operation.";

  /** The cache key that failed */
  readonly cacheKey?: string;

  /** Expected hash */
  readonly expectedHash?: string;

  /** Actual hash */
  readonly actualHash?: string;

  constructor(
    message: string,
    options?: {
      cacheKey?: string;
      expectedHash?: string;
      actualHash?: string;
      context?: Record<string, unknown>;
      cause?: Error;
    }
  ) {
    super(
      message,
      {
        "cache.key": options?.cacheKey,
        "cache.expectedHash": options?.expectedHash,
        "cache.actualHash": options?.actualHash,
        ...options?.context,
      },
      options?.cause ? { cause: options.cause } : undefined
    );
    this.cacheKey = options?.cacheKey;
    this.expectedHash = options?.expectedHash;
    this.actualHash = options?.actualHash;
  }
}

/**
 * Map exit code to HTTP status code for API responses.
 */
export function exitCodeToHttpStatus(code: ExitCode): number {
  switch (code) {
    case ExitCodes.SUCCESS:
      return 200;
    case ExitCodes.POLICY_VIOLATION:
      return 403; // Forbidden
    case ExitCodes.EVALUATION_FAILURE:
      return 422; // Unprocessable Entity
    case ExitCodes.GUARD_VIOLATION:
      return 400; // Bad Request
    case ExitCodes.INPUT_VALIDATION:
      return 400; // Bad Request
    case ExitCodes.UPSTREAM_PROVIDER:
      return 502; // Bad Gateway
    case ExitCodes.IDEMPOTENCY_CONFLICT:
      return 409; // Conflict
    case ExitCodes.CACHE_INTEGRITY:
      return 500; // Internal Server Error
    case ExitCodes.GENERIC_FAILURE:
    default:
      return 500; // Internal Server Error
  }
}

/**
 * Check if an error is a KitError.
 */
export function isKitError(error: unknown): error is KitError {
  return error instanceof KitError;
}

/**
 * Wrap an unknown error as a KitError.
 */
export function wrapError(
  error: unknown,
  fallbackMessage = "An unexpected error occurred"
): KitError {
  if (isKitError(error)) {
    return error;
  }

  const message = error instanceof Error ? error.message : fallbackMessage;
  const cause = error instanceof Error ? error : undefined;

  // Return a generic error wrapper
  return new (class GenericKitError extends KitError {
    readonly code = ExitCodes.GENERIC_FAILURE;
    readonly suggestedAction = "Review the error details and retry.";
  })(message, {}, cause ? { cause } : undefined);
}


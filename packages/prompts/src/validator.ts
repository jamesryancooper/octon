/**
 * Prompt input/output validation using JSON Schema.
 */

import Ajv from "ajv";
import addFormats from "ajv-formats";
import type { PromptMetadata } from "./types.js";

/**
 * Result of a validation operation.
 */
export interface ValidationResult {
  /** Whether validation passed */
  valid: boolean;

  /** List of validation errors */
  errors: ValidationError[];

  /** Warnings (non-blocking issues) */
  warnings: string[];
}

/**
 * A single validation error.
 */
export interface ValidationError {
  /** Path to the invalid field */
  path: string;

  /** Error message */
  message: string;

  /** The invalid value (if safe to include) */
  value?: unknown;
}

/**
 * Validates prompt inputs and outputs against their schemas.
 */
export class PromptValidator {
  private ajv: Ajv;
  private inputValidators: Map<string, ReturnType<Ajv["compile"]>>;
  private outputValidators: Map<string, ReturnType<Ajv["compile"]>>;

  constructor() {
    this.ajv = new Ajv({
      allErrors: true,
      verbose: true,
      strict: false,
    });

    // Add format validators (uuid, date-time, etc.)
    addFormats(this.ajv);

    this.inputValidators = new Map();
    this.outputValidators = new Map();
  }

  /**
   * Register a prompt's schemas for validation.
   */
  registerPrompt(metadata: PromptMetadata): void {
    const { id, inputSchema, outputSchema } = metadata;

    try {
      this.inputValidators.set(id, this.ajv.compile(inputSchema));
      this.outputValidators.set(id, this.ajv.compile(outputSchema));
    } catch (error) {
      throw new Error(
        `Failed to compile schemas for prompt ${id}: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }

  /**
   * Validate input data for a prompt.
   */
  validateInput(promptId: string, data: unknown): ValidationResult {
    const validator = this.inputValidators.get(promptId);

    if (!validator) {
      return {
        valid: false,
        errors: [
          { path: "", message: `No validator registered for prompt: ${promptId}` },
        ],
        warnings: [],
      };
    }

    const valid = validator(data);

    if (valid) {
      return { valid: true, errors: [], warnings: [] };
    }

    return {
      valid: false,
      errors: this.formatErrors(validator.errors ?? []),
      warnings: [],
    };
  }

  /**
   * Validate output data for a prompt.
   */
  validateOutput(promptId: string, data: unknown): ValidationResult {
    const validator = this.outputValidators.get(promptId);

    if (!validator) {
      return {
        valid: false,
        errors: [
          { path: "", message: `No validator registered for prompt: ${promptId}` },
        ],
        warnings: [],
      };
    }

    const valid = validator(data);
    const warnings = this.checkForWarnings(data);

    if (valid) {
      return { valid: true, errors: [], warnings };
    }

    return {
      valid: false,
      errors: this.formatErrors(validator.errors ?? []),
      warnings,
    };
  }

  /**
   * Check for common warning conditions in output.
   */
  private checkForWarnings(data: unknown): string[] {
    const warnings: string[] = [];

    if (data && typeof data === "object") {
      const obj = data as Record<string, unknown>;

      // Check for clarification requests
      if (obj.needs_clarification === true) {
        warnings.push("Output is a clarification request, not a complete result");
      }

      // Check for empty arrays that might indicate incomplete generation
      for (const [key, value] of Object.entries(obj)) {
        if (Array.isArray(value) && value.length === 0) {
          warnings.push(`Field '${key}' is an empty array`);
        }
      }
    }

    return warnings;
  }

  /**
   * Format AJV errors into our ValidationError format.
   */
  private formatErrors(
    errors: NonNullable<ReturnType<Ajv["compile"]>["errors"]>
  ): ValidationError[] {
    return errors.map((err) => ({
      path: err.instancePath || "/",
      message: err.message ?? "Unknown validation error",
      value: err.data,
    }));
  }

  /**
   * Check if a prompt is registered.
   */
  isRegistered(promptId: string): boolean {
    return this.inputValidators.has(promptId);
  }
}

/**
 * Standalone function to validate input against a schema.
 */
export function validateInput(
  schema: object,
  data: unknown
): ValidationResult {
  const ajv = new Ajv({ allErrors: true, strict: false });
  addFormats(ajv);

  const validate = ajv.compile(schema);
  const valid = validate(data);

  if (valid) {
    return { valid: true, errors: [], warnings: [] };
  }

  return {
    valid: false,
    errors: (validate.errors ?? []).map((err) => ({
      path: err.instancePath || "/",
      message: err.message ?? "Unknown error",
      value: err.data,
    })),
    warnings: [],
  };
}

/**
 * Standalone function to validate output against a schema.
 */
export function validateOutput(
  schema: object,
  data: unknown
): ValidationResult {
  return validateInput(schema, data);
}


/**
 * PromptKit Compiler
 *
 * Template compilation using Nunjucks (Jinja2-like) for variable substitution.
 */

import nunjucks from "nunjucks";

/**
 * Configure a Nunjucks environment for prompt compilation.
 * - Autoescape is disabled (prompts are not HTML)
 * - Throws on undefined variables
 */
function createEnvironment(): nunjucks.Environment {
  const env = new nunjucks.Environment(null, {
    autoescape: false,
    throwOnUndefined: false, // Allow missing variables (they render as empty)
    trimBlocks: true,
    lstripBlocks: true,
  });

  // Add custom filters for prompt manipulation
  env.addFilter("truncate", (str: string, length: number, end = "...") => {
    if (!str || str.length <= length) return str;
    return str.slice(0, length - end.length) + end;
  });

  env.addFilter("indent", (str: string, spaces: number) => {
    if (!str) return str;
    const indent = " ".repeat(spaces);
    return str
      .split("\n")
      .map((line) => indent + line)
      .join("\n");
  });

  env.addFilter("json", (obj: unknown, spaces?: number) => {
    return JSON.stringify(obj, null, spaces);
  });

  env.addFilter("yaml_list", (arr: unknown[]) => {
    if (!Array.isArray(arr)) return "";
    return arr.map((item) => `- ${item}`).join("\n");
  });

  env.addFilter("code_block", (code: string, language = "") => {
    if (!code) return "";
    return `\`\`\`${language}\n${code}\n\`\`\``;
  });

  return env;
}

// Singleton environment
let envInstance: nunjucks.Environment | null = null;

function getEnvironment(): nunjucks.Environment {
  if (!envInstance) {
    envInstance = createEnvironment();
  }
  return envInstance;
}

/**
 * Compile a template string with variables.
 *
 * @param template - The template string with Nunjucks syntax
 * @param variables - Variables to substitute into the template
 * @returns The rendered template
 * @throws If template syntax is invalid
 */
export function compileTemplate(
  template: string,
  variables: Record<string, unknown>
): string {
  const env = getEnvironment();

  try {
    return env.renderString(template, variables);
  } catch (error) {
    if (error instanceof Error) {
      throw new TemplateCompilationError(
        `Failed to compile template: ${error.message}`,
        { cause: error }
      );
    }
    throw error;
  }
}

/**
 * Validate that a template can be parsed without errors.
 *
 * @param template - The template string to validate
 * @returns Validation result with any errors
 */
export function validateTemplate(template: string): TemplateValidationResult {
  const env = getEnvironment();

  try {
    // Try to compile the template (this parses it)
    nunjucks.compile(template, env);

    return {
      valid: true,
      errors: [],
    };
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return {
      valid: false,
      errors: [message],
    };
  }
}

/**
 * Extract variable names used in a template.
 *
 * @param template - The template string to analyze
 * @returns Array of variable names found in the template
 */
export function extractVariables(template: string): string[] {
  const variables = new Set<string>();

  // Match {{ variable }} patterns
  const variablePattern = /\{\{\s*([a-zA-Z_][a-zA-Z0-9_]*(?:\.[a-zA-Z_][a-zA-Z0-9_]*)*)\s*(?:\|[^}]*)?\}\}/g;
  let match;

  while ((match = variablePattern.exec(template)) !== null) {
    // Get the root variable name (before any dots)
    const fullPath = match[1];
    const rootVariable = fullPath.split(".")[0];
    variables.add(rootVariable);
  }

  // Match {% for item in collection %} patterns
  const forPattern = /\{%\s*for\s+\w+\s+in\s+([a-zA-Z_][a-zA-Z0-9_]*)/g;
  while ((match = forPattern.exec(template)) !== null) {
    variables.add(match[1]);
  }

  // Match {% if variable %} patterns
  const ifPattern = /\{%\s*if\s+([a-zA-Z_][a-zA-Z0-9_]*)/g;
  while ((match = ifPattern.exec(template)) !== null) {
    variables.add(match[1]);
  }

  return Array.from(variables);
}

/**
 * Check if all required variables are provided.
 *
 * @param template - The template string
 * @param variables - The provided variables
 * @returns Object with missing variables and whether all are provided
 */
export function checkVariables(
  template: string,
  variables: Record<string, unknown>
): VariableCheckResult {
  const required = extractVariables(template);
  const provided = new Set(Object.keys(variables));

  const missing = required.filter((v) => !provided.has(v));
  const unused = Object.keys(variables).filter((v) => !required.includes(v));

  return {
    complete: missing.length === 0,
    missing,
    unused,
    required,
  };
}

/**
 * Error thrown when template compilation fails.
 */
export class TemplateCompilationError extends Error {
  readonly originalError?: unknown;

  constructor(message: string, options?: { cause?: unknown }) {
    super(message);
    this.name = "TemplateCompilationError";
    if (options?.cause) {
      this.originalError = options.cause;
    }
  }
}

/**
 * Result of template validation.
 */
export interface TemplateValidationResult {
  valid: boolean;
  errors: string[];
}

/**
 * Result of variable checking.
 */
export interface VariableCheckResult {
  /** Whether all required variables are provided */
  complete: boolean;

  /** Variables used in template but not provided */
  missing: string[];

  /** Variables provided but not used in template */
  unused: string[];

  /** All variables found in the template */
  required: string[];
}

/**
 * Reset the environment (useful for testing).
 */
export function resetEnvironment(): void {
  envInstance = null;
}


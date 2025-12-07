/**
 * Known patterns for security detection.
 * These patterns help identify prompt injection attempts,
 * potentially hallucinated content, and other security concerns.
 */

import type { HallucinationPattern, Severity } from "./types.js";

/**
 * Prompt injection patterns - attempts to manipulate AI behavior.
 */
export const INJECTION_PATTERNS = [
  {
    id: "ignore_instructions",
    pattern: /ignore\s+(all\s+)?(previous|prior|above)\s+(instructions?|prompts?|rules?)/i,
    severity: "critical" as Severity,
    description: "Attempt to override system instructions",
  },
  {
    id: "system_prompt_leak",
    pattern: /(?:reveal|show|display|print|output)\s+(?:the\s+)?(?:system\s+)?(?:prompt|instructions?)/i,
    severity: "high" as Severity,
    description: "Attempt to reveal system prompt",
  },
  {
    id: "role_override",
    pattern: /(?:you\s+are\s+now|act\s+as|pretend\s+(?:to\s+be|you\s+are)|roleplay\s+as)\s+(?:a\s+)?(?:different|new|another)/i,
    severity: "high" as Severity,
    description: "Attempt to override AI role",
  },
  {
    id: "jailbreak_attempt",
    pattern: /(?:DAN|do\s+anything\s+now|developer\s+mode|bypass\s+(?:safety|filters?|restrictions?))/i,
    severity: "critical" as Severity,
    description: "Known jailbreak pattern detected",
  },
  {
    id: "instruction_injection",
    pattern: /\[\s*(?:SYSTEM|INST|INSTRUCTION)\s*\]/i,
    severity: "high" as Severity,
    description: "Attempted instruction injection marker",
  },
  {
    id: "base64_obfuscation",
    pattern: /(?:decode|eval)\s*\(\s*(?:atob|base64)/i,
    severity: "high" as Severity,
    description: "Potential obfuscated content",
  },
  {
    id: "prompt_delimiter_escape",
    pattern: /```\s*(?:system|assistant|user)\s*\n/i,
    severity: "medium" as Severity,
    description: "Attempt to inject chat format delimiters",
  },
  {
    id: "unicode_smuggling",
    pattern: /[\u200B-\u200F\u2028-\u202F\uFEFF]/,
    severity: "medium" as Severity,
    description: "Zero-width or invisible characters detected",
  },
];

/**
 * Secret patterns - things that should never appear in prompts or outputs.
 */
export const SECRET_PATTERNS = [
  {
    id: "aws_key",
    pattern: /(?:AKIA|A3T|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}/,
    severity: "critical" as Severity,
    description: "AWS access key detected",
  },
  {
    id: "aws_secret",
    pattern: /(?:aws)?_?(?:secret)?_?(?:access)?_?key['":\s=]+[A-Za-z0-9/+=]{40}/i,
    severity: "critical" as Severity,
    description: "AWS secret key detected",
  },
  {
    id: "github_token",
    pattern: /(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,}/,
    severity: "critical" as Severity,
    description: "GitHub token detected",
  },
  {
    id: "api_key_generic",
    pattern: /(?:api[_-]?key|apikey)['":\s=]+['"]?[A-Za-z0-9_-]{20,}['"]?/i,
    severity: "high" as Severity,
    description: "Generic API key pattern detected",
  },
  {
    id: "jwt_token",
    pattern: /eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/,
    severity: "high" as Severity,
    description: "JWT token detected",
  },
  {
    id: "private_key",
    pattern: /-----BEGIN\s+(?:RSA\s+)?PRIVATE\s+KEY-----/,
    severity: "critical" as Severity,
    description: "Private key detected",
  },
  {
    id: "password_assignment",
    pattern: /(?:password|passwd|pwd)['":\s=]+['"]?[^\s'"]{8,}['"]?/i,
    severity: "high" as Severity,
    description: "Hardcoded password detected",
  },
  {
    id: "connection_string",
    pattern: /(?:mongodb|postgres|mysql|redis):\/\/[^@\s]+:[^@\s]+@/i,
    severity: "critical" as Severity,
    description: "Database connection string with credentials detected",
  },
];

/**
 * PII patterns - personally identifiable information.
 */
export const PII_PATTERNS = [
  {
    id: "email",
    pattern: /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/,
    severity: "medium" as Severity,
    description: "Email address detected",
    redactTo: "[EMAIL]",
  },
  {
    id: "phone_us",
    pattern: /(?:\+1[-.\s]?)?\(?[0-9]{3}\)?[-.\s]?[0-9]{3}[-.\s]?[0-9]{4}/,
    severity: "medium" as Severity,
    description: "US phone number detected",
    redactTo: "[PHONE]",
  },
  {
    id: "ssn",
    pattern: /\b[0-9]{3}[-\s]?[0-9]{2}[-\s]?[0-9]{4}\b/,
    severity: "high" as Severity,
    description: "SSN pattern detected",
    redactTo: "[SSN]",
  },
  {
    id: "credit_card",
    pattern: /\b(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|3[47][0-9]{13}|6(?:011|5[0-9]{2})[0-9]{12})\b/,
    severity: "critical" as Severity,
    description: "Credit card number detected",
    redactTo: "[CREDIT_CARD]",
  },
  {
    id: "ip_address",
    pattern: /\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/,
    severity: "low" as Severity,
    description: "IP address detected",
    redactTo: "[IP_ADDRESS]",
  },
];

/**
 * Code safety patterns - dangerous code constructs.
 */
export const CODE_SAFETY_PATTERNS = [
  {
    id: "eval_usage",
    pattern: /\beval\s*\(/,
    severity: "critical" as Severity,
    description: "Use of eval() is dangerous",
    suggestion: "Use safer alternatives like JSON.parse() or Function constructor with proper sandboxing",
  },
  {
    id: "exec_usage",
    pattern: /\b(?:exec|execSync|spawn|spawnSync)\s*\(/,
    severity: "high" as Severity,
    description: "Shell command execution detected",
    suggestion: "Ensure proper input sanitization and use allowlists for commands",
  },
  {
    id: "inner_html",
    pattern: /\.innerHTML\s*=/,
    severity: "high" as Severity,
    description: "Direct innerHTML assignment (XSS risk)",
    suggestion: "Use textContent or a sanitization library like DOMPurify",
  },
  {
    id: "document_write",
    pattern: /document\.write\s*\(/,
    severity: "high" as Severity,
    description: "document.write is deprecated and unsafe",
    suggestion: "Use DOM manipulation methods instead",
  },
  {
    id: "sql_concatenation",
    pattern: /(?:SELECT|INSERT|UPDATE|DELETE|FROM|WHERE)[\s\S]*?\+\s*(?:req|request|user|input|param)/i,
    severity: "critical" as Severity,
    description: "Potential SQL injection (string concatenation)",
    suggestion: "Use parameterized queries or an ORM",
  },
  {
    id: "path_traversal",
    pattern: /(?:\.\.\/|\.\.\\)/,
    severity: "medium" as Severity,
    description: "Path traversal pattern detected",
    suggestion: "Validate and sanitize file paths, use path.resolve()",
  },
  {
    id: "hardcoded_localhost",
    pattern: /(?:localhost|127\.0\.0\.1):(?:3000|5000|8080|8000)/,
    severity: "low" as Severity,
    description: "Hardcoded localhost URL",
    suggestion: "Use environment variables for host/port configuration",
  },
  {
    id: "disable_ssl",
    pattern: /(?:rejectUnauthorized|NODE_TLS_REJECT_UNAUTHORIZED)\s*[:=]\s*(?:false|0|'0'|"0")/,
    severity: "critical" as Severity,
    description: "SSL verification disabled",
    suggestion: "Never disable SSL verification in production",
  },
];

/**
 * Hallucination patterns for code generation.
 */
export const HALLUCINATION_PATTERNS: HallucinationPattern[] = [
  {
    id: "fake_npm_package",
    description: "Reference to likely non-existent npm package",
    detect: /from\s+['"](@[a-z0-9-]+\/)?[a-z0-9-]+['"]|require\s*\(\s*['"](@[a-z0-9-]+\/)?[a-z0-9-]+['"]\s*\)/,
    severity: "high",
    category: "import",
  },
  {
    id: "helper_util_pattern",
    description: "Generic 'helper' or 'util' functions that may not exist",
    detect: /(?:import|from)\s+['"][^'"]*(?:helper|util|common)[^'"]*['"]/i,
    severity: "medium",
    category: "import",
  },
  {
    id: "non_standard_api",
    description: "Non-standard browser/Node API usage",
    detect: (content: string) => {
      const fakeApis = [
        "navigator.clipboard.writeSync", // sync version doesn't exist
        "localStorage.getAsync", // async version doesn't exist
        "Promise.delay", // use setTimeout or Bluebird
        "Array.prototype.last", // not standard (yet)
        "String.prototype.replaceAll", // verify browser support
      ];
      return fakeApis.some((api) => content.includes(api));
    },
    severity: "medium",
    category: "api",
  },
  {
    id: "confident_wrong_syntax",
    description: "Syntactically incorrect but confidently written code",
    detect: /async\s+function\*|yield\s+await\s+return|const\s+let\s+var/,
    severity: "high",
    category: "general",
  },
  {
    id: "imaginary_config",
    description: "Configuration options that don't exist",
    detect: (content: string) => {
      // Check for options that look made up
      const suspiciousOptions = [
        /options\s*:\s*\{[^}]*enableAutoFix\s*:/,
        /config\s*:\s*\{[^}]*autoSanitize\s*:/,
        /settings\s*:\s*\{[^}]*smartMode\s*:/,
      ];
      return suspiciousOptions.some((p) => p.test(content));
    },
    severity: "medium",
    category: "general",
  },
  {
    id: "todo_placeholder",
    description: "TODO or placeholder that suggests incomplete generation",
    detect: /\/\/\s*TODO|\/\*\s*TODO|\.\.\.\s*(?:implement|add|here)|PLACEHOLDER|FIXME|XXX/i,
    severity: "low",
    category: "general",
  },
  {
    id: "generic_error_handling",
    description: "Overly generic error handling that may hide issues",
    detect: /catch\s*\([^)]*\)\s*\{\s*(?:\/\/\s*ignore|}\s*$|\s*$)/,
    severity: "medium",
    category: "general",
  },
];

/**
 * Red flags for human reviewers to watch for.
 */
export const HUMAN_RED_FLAGS = [
  {
    id: "unfamiliar_imports",
    title: "Unfamiliar Imports",
    description: "AI imports packages you don't recognize. Verify they exist in package.json.",
    example: "import { magicHelper } from '@unknown/helper-lib'",
    action: "Check if package exists: npm info <package-name>",
  },
  {
    id: "generic_function_names",
    title: "Generic Function Names",
    description: "Functions with vague names like 'handleData', 'processInput', 'doWork' may be hallucinated.",
    example: "import { processUserData } from '../utils/helpers'",
    action: "Verify the function exists in the referenced file",
  },
  {
    id: "too_perfect_code",
    title: "Too Perfect Code",
    description: "Code that seems too clean with no edge case handling may be incomplete.",
    example: "Perfect happy path with no error handling or validation",
    action: "Add error handling and test edge cases",
  },
  {
    id: "confident_explanation",
    title: "Overly Confident Explanations",
    description: "AI explains something with high confidence but the details seem off.",
    example: "'This uses the built-in X.Y.Z API which is standard...' (when it's not)",
    action: "Verify claims against official documentation",
  },
  {
    id: "missing_dependencies",
    title: "Missing Dependencies",
    description: "Code imports packages that aren't in package.json.",
    example: "Code uses 'lodash' but it's not in dependencies",
    action: "Run pnpm install <package> if valid, or remove if hallucinated",
  },
  {
    id: "incorrect_api_usage",
    title: "Incorrect API Usage",
    description: "API calls with wrong method names or parameters.",
    example: "fs.readFileAsync() instead of fs.promises.readFile()",
    action: "Verify against official API documentation",
  },
  {
    id: "scope_mismatch",
    title: "Scope Mismatch",
    description: "Generated code does more or less than what was requested.",
    example: "Asked for login, got login + registration + password reset",
    action: "Clarify scope and regenerate with constraints",
  },
];

/**
 * Get all patterns of a specific type.
 */
export function getPatterns(
  type: "injection" | "secret" | "pii" | "code_safety" | "hallucination"
): Array<{ id: string; pattern?: RegExp; detect?: RegExp | ((s: string) => boolean); severity: Severity }> {
  switch (type) {
    case "injection":
      return INJECTION_PATTERNS;
    case "secret":
      return SECRET_PATTERNS;
    case "pii":
      return PII_PATTERNS;
    case "code_safety":
      return CODE_SAFETY_PATTERNS;
    case "hallucination":
      return HALLUCINATION_PATTERNS;
  }
}

/**
 * Check if content matches any patterns of the given type.
 */
export function matchesPatterns(
  content: string,
  type: "injection" | "secret" | "pii" | "code_safety"
): Array<{ id: string; match: string; severity: Severity }> {
  const patterns = getPatterns(type) as Array<{ id: string; pattern: RegExp; severity: Severity }>;
  const matches: Array<{ id: string; match: string; severity: Severity }> = [];

  for (const { id, pattern, severity } of patterns) {
    const match = content.match(pattern);
    if (match) {
      matches.push({ id, match: match[0], severity });
    }
  }

  return matches;
}


/**
 * Hallucination detection utilities for prompt outputs.
 *
 * These utilities help AI agents and humans detect when AI-generated
 * content may contain hallucinations (fake imports, functions, APIs, etc.)
 */

import type { ValidationResult } from "./validator.js";

/**
 * Common hallucination indicators to check for.
 */
export interface HallucinationIndicator {
  id: string;
  name: string;
  description: string;
  severity: "high" | "medium" | "low";
  check: (content: string, context?: HallucinationContext) => HallucinationMatch | null;
}

/**
 * Context for hallucination detection.
 */
export interface HallucinationContext {
  /** Known packages from package.json */
  knownPackages?: string[];

  /** Known files in the project */
  knownFiles?: string[];

  /** Known exports/functions */
  knownExports?: string[];

  /** The original prompt/intent */
  originalIntent?: string;

  /** Risk tier (affects sensitivity) */
  tier?: "T1" | "T2" | "T3";
}

/**
 * A hallucination match.
 */
export interface HallucinationMatch {
  indicatorId: string;
  indicatorName: string;
  severity: "high" | "medium" | "low";
  match: string;
  location?: { start: number; end: number };
  suggestion: string;
}

/**
 * Result of hallucination check.
 */
export interface HallucinationCheckResult {
  /** Whether hallucinations were likely detected */
  detected: boolean;

  /** Confidence score (0-1) */
  confidence: number;

  /** Detected issues */
  matches: HallucinationMatch[];

  /** Summary for humans */
  summary: string;

  /** Recommended actions */
  recommendations: string[];
}

/**
 * Built-in hallucination indicators.
 */
export const HALLUCINATION_INDICATORS: HallucinationIndicator[] = [
  {
    id: "unknown_import",
    name: "Unknown Import",
    description: "Import from a package not in known dependencies",
    severity: "high",
    check: (content, context) => {
      if (!context?.knownPackages) return null;

      // Use [\s\S]*? to match across newlines (multiline imports)
      const importRegex = /import\s+(?:[\s\S]*?\s+from\s+)?['"]([^'"./][^'"]*)['"]/g;
      let match;

      while ((match = importRegex.exec(content)) !== null) {
        const pkg = match[1].startsWith("@")
          ? match[1].split("/").slice(0, 2).join("/")
          : match[1].split("/")[0];

        // Skip Node built-ins
        if (isNodeBuiltin(pkg)) continue;

        if (!context.knownPackages.includes(pkg)) {
          return {
            indicatorId: "unknown_import",
            indicatorName: "Unknown Import",
            severity: "high",
            match: match[0],
            location: { start: match.index, end: match.index + match[0].length },
            suggestion: `Verify package '${pkg}' exists: npm info ${pkg}`,
          };
        }
      }

      return null;
    },
  },
  {
    id: "suspicious_helper",
    name: "Suspicious Helper/Util Import",
    description: "Import from a generically-named helper/util module",
    severity: "medium",
    check: (content) => {
      const suspiciousPatterns = [
        /from\s+['"][^'"]*(?:helper|util|common|misc|shared)[^'"]*['"]/gi,
        /require\s*\(\s*['"][^'"]*(?:helper|util|common|misc|shared)[^'"]*['"]\s*\)/gi,
      ];

      for (const pattern of suspiciousPatterns) {
        const match = content.match(pattern);
        if (match) {
          return {
            indicatorId: "suspicious_helper",
            indicatorName: "Suspicious Helper/Util Import",
            severity: "medium",
            match: match[0],
            suggestion: "Verify this helper module exists in the codebase",
          };
        }
      }

      return null;
    },
  },
  {
    id: "todo_placeholder",
    name: "TODO/Placeholder",
    description: "Contains TODO, FIXME, or placeholder markers",
    severity: "low",
    check: (content) => {
      const pattern = /\/\/\s*TODO|\/\*\s*TODO|\bFIXME\b|\bXXX\b|\bPLACEHOLDER\b/i;
      const match = content.match(pattern);

      if (match) {
        return {
          indicatorId: "todo_placeholder",
          indicatorName: "TODO/Placeholder",
          severity: "low",
          match: match[0],
          suggestion: "Complete the implementation before using",
        };
      }

      return null;
    },
  },
  {
    id: "empty_catch",
    name: "Empty Catch Block",
    description: "Error handling that silently swallows errors",
    severity: "medium",
    check: (content) => {
      const pattern = /catch\s*\([^)]*\)\s*\{\s*(?:\/\/[^\n]*\n\s*)?\}/;
      const match = content.match(pattern);

      if (match) {
        return {
          indicatorId: "empty_catch",
          indicatorName: "Empty Catch Block",
          severity: "medium",
          match: match[0],
          suggestion: "Add proper error handling or at least log the error",
        };
      }

      return null;
    },
  },
  {
    id: "generic_variable",
    name: "Generic Variable Names",
    description: "Overly generic variable names that may indicate incomplete code",
    severity: "low",
    check: (content) => {
      // Look for awaited results assigned to generic names
      const pattern = /const\s+(?:data|result|response|value|res|ret)\s*=\s*await\s+\w+/;
      const match = content.match(pattern);

      if (match) {
        return {
          indicatorId: "generic_variable",
          indicatorName: "Generic Variable Names",
          severity: "low",
          match: match[0],
          suggestion: "Consider using more descriptive variable names",
        };
      }

      return null;
    },
  },
  {
    id: "nonexistent_api",
    name: "Non-existent API",
    description: "Reference to APIs that don't exist",
    severity: "high",
    check: (content) => {
      const fakeApis = [
        { pattern: /navigator\.clipboard\.writeSync/, real: "navigator.clipboard.writeText (async)" },
        { pattern: /localStorage\.getAsync/, real: "localStorage.getItem (sync)" },
        { pattern: /Promise\.delay/, real: "setTimeout or util.promisify(setTimeout)" },
        { pattern: /Array\.prototype\.last/, real: "arr[arr.length - 1] or arr.at(-1)" },
        { pattern: /fs\.readFileAsync/, real: "fs.promises.readFile" },
        { pattern: /\.toJSON\(\s*\)\.stringify/, real: "JSON.stringify(obj)" },
      ];

      for (const { pattern, real } of fakeApis) {
        const match = content.match(pattern);
        if (match) {
          return {
            indicatorId: "nonexistent_api",
            indicatorName: "Non-existent API",
            severity: "high",
            match: match[0],
            suggestion: `This API doesn't exist. Use ${real} instead`,
          };
        }
      }

      return null;
    },
  },
  {
    id: "scope_creep",
    name: "Scope Creep",
    description: "Generated code may be doing more than requested",
    severity: "medium",
    check: (content, context) => {
      if (!context?.originalIntent) return null;

      // Simple heuristic: if the code is much larger than expected for the intent
      const intentWords = context.originalIntent.split(/\s+/).length;
      const codeLines = content.split("\n").filter((l) => l.trim()).length;

      // Very rough heuristic: if code is 20x more lines than intent words, may be scope creep
      if (intentWords < 10 && codeLines > 100) {
        return {
          indicatorId: "scope_creep",
          indicatorName: "Scope Creep",
          severity: "medium",
          match: `${codeLines} lines generated for "${context.originalIntent.slice(0, 50)}..."`,
          suggestion: "Review if this code does more than requested",
        };
      }

      return null;
    },
  },
  {
    id: "confident_assertion",
    name: "Confident Incorrect Assertion",
    description: "Code comments that confidently assert incorrect information",
    severity: "medium",
    check: (content) => {
      // Look for comments that say "this is standard" or "built-in" for things that aren't
      const patterns = [
        /\/\/.*(?:standard|built-in|native|default)\s+(?:API|method|function)/i,
        /\/\*.*(?:always|never|guaranteed|definitely).*\*\//i,
      ];

      for (const pattern of patterns) {
        const match = content.match(pattern);
        if (match) {
          return {
            indicatorId: "confident_assertion",
            indicatorName: "Confident Incorrect Assertion",
            severity: "medium",
            match: match[0],
            suggestion: "Verify this assertion against official documentation",
          };
        }
      }

      return null;
    },
  },
];

/**
 * Check if a package name is a Node.js built-in.
 */
function isNodeBuiltin(pkg: string): boolean {
  const builtins = [
    "fs",
    "path",
    "crypto",
    "util",
    "http",
    "https",
    "stream",
    "events",
    "os",
    "child_process",
    "url",
    "querystring",
    "buffer",
    "assert",
    "zlib",
    "net",
    "dns",
    "tls",
    "readline",
    "process",
    "module",
    "vm",
    "worker_threads",
    "cluster",
    "dgram",
    "perf_hooks",
    "async_hooks",
  ];

  return builtins.includes(pkg) || pkg.startsWith("node:");
}

/**
 * Run hallucination checks on content.
 */
export function checkForHallucinations(
  content: string,
  context?: HallucinationContext
): HallucinationCheckResult {
  const matches: HallucinationMatch[] = [];

  // Run all indicators
  for (const indicator of HALLUCINATION_INDICATORS) {
    const match = indicator.check(content, context);
    if (match) {
      matches.push(match);
    }
  }

  // Calculate confidence based on matches
  const severityWeights = { high: 0.4, medium: 0.2, low: 0.1 };
  const confidence = Math.min(
    1,
    matches.reduce((acc, m) => acc + severityWeights[m.severity], 0)
  );

  // Generate summary
  const summary =
    matches.length === 0
      ? "No obvious hallucination indicators detected"
      : `Found ${matches.length} potential hallucination indicator(s): ${matches.map((m) => m.indicatorName).join(", ")}`;

  // Generate recommendations
  const recommendations: string[] = [];
  if (matches.some((m) => m.severity === "high")) {
    recommendations.push("High-severity issues detected - review carefully before using");
  }
  if (matches.some((m) => m.indicatorId === "unknown_import")) {
    recommendations.push("Verify all imports against package.json");
  }
  if (matches.some((m) => m.indicatorId === "todo_placeholder")) {
    recommendations.push("Complete TODO/placeholder sections before using");
  }
  if (recommendations.length === 0 && matches.length > 0) {
    recommendations.push("Review flagged items before accepting");
  }

  return {
    detected: matches.length > 0,
    confidence,
    matches,
    summary,
    recommendations,
  };
}

/**
 * Quick hallucination check - returns true if likely hallucination.
 */
export function quickHallucinationCheck(content: string): boolean {
  const quickPatterns = [
    /\/\/\s*TODO|PLACEHOLDER|FIXME/i,
    /catch\s*\([^)]*\)\s*\{\s*\}/,
    /from\s+['"][^'"]*(?:helper|util|common)[^'"]*['"]/i,
    /(?:handleData|processInput|doWork|runTask)\s*\(/,
  ];

  return quickPatterns.some((p) => p.test(content));
}

/**
 * Validate AI output and check for hallucinations.
 * Combines schema validation with hallucination detection.
 */
export function validateWithHallucinationCheck(
  validationResult: ValidationResult,
  content: string,
  context?: HallucinationContext
): {
  validation: ValidationResult;
  hallucination: HallucinationCheckResult;
  overallSafe: boolean;
} {
  const hallucination = checkForHallucinations(
    typeof content === "string" ? content : JSON.stringify(content),
    context
  );

  const overallSafe =
    validationResult.valid &&
    !hallucination.matches.some((m) => m.severity === "high");

  return {
    validation: validationResult,
    hallucination,
    overallSafe,
  };
}

/**
 * Format hallucination check results for human review.
 */
export function formatHallucinationReport(result: HallucinationCheckResult): string {
  if (!result.detected) {
    return "✅ No hallucination indicators detected";
  }

  const lines: string[] = [
    `⚠️ Potential Hallucinations Detected (confidence: ${(result.confidence * 100).toFixed(0)}%)`,
    "",
  ];

  for (const match of result.matches) {
    const icon =
      match.severity === "high" ? "🔴" : match.severity === "medium" ? "🟡" : "🟢";
    lines.push(`${icon} **${match.indicatorName}** (${match.severity})`);
    lines.push(`   Match: \`${match.match.slice(0, 80)}${match.match.length > 80 ? "..." : ""}\``);
    lines.push(`   → ${match.suggestion}`);
    lines.push("");
  }

  if (result.recommendations.length > 0) {
    lines.push("**Recommendations:**");
    for (const rec of result.recommendations) {
      lines.push(`- ${rec}`);
    }
  }

  return lines.join("\n");
}


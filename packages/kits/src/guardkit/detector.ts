/**
 * Hallucination detection for AI-generated content.
 */

import { existsSync } from "node:fs";
import { join, dirname } from "node:path";
import type {
  HallucinationCheckConfig,
  HallucinationCheckResult,
  GuardrailCheckResult,
  Severity,
} from "./types.js";
import { HALLUCINATION_PATTERNS, CODE_SAFETY_PATTERNS } from "./patterns.js";

/**
 * Common npm packages that are likely real (to reduce false positives).
 */
const KNOWN_REAL_PACKAGES = new Set([
  "react",
  "react-dom",
  "next",
  "express",
  "fastify",
  "hono",
  "zod",
  "ajv",
  "typescript",
  "lodash",
  "axios",
  "node-fetch",
  "@types/node",
  "@types/react",
  "vitest",
  "jest",
  "pnpm",
  "tsx",
  "esbuild",
  "vite",
  "tailwindcss",
  "postcss",
  "autoprefixer",
  "@tanstack/react-query",
  "@trpc/client",
  "@trpc/server",
  "prisma",
  "@prisma/client",
  "drizzle-orm",
  "openai",
  "@anthropic-ai/sdk",
  "langchain",
  "@langchain/core",
]);

/**
 * Extract import statements from code.
 */
function extractImports(code: string): string[] {
  const imports: string[] = [];

  // ES6 imports
  const esImportRegex = /import\s+(?:[\s\S]*?\s+from\s+)?['"]([^'"]+)['"]/g;
  let match;
  while ((match = esImportRegex.exec(code)) !== null) {
    imports.push(match[1]);
  }

  // CommonJS requires
  const requireRegex = /require\s*\(\s*['"]([^'"]+)['"]\s*\)/g;
  while ((match = requireRegex.exec(code)) !== null) {
    imports.push(match[1]);
  }

  return imports;
}

/**
 * Extract function calls from code.
 */
function extractFunctionCalls(code: string): string[] {
  const calls: string[] = [];

  // Match function calls like foo(), bar.baz(), etc.
  const callRegex = /\b([a-zA-Z_$][a-zA-Z0-9_$]*(?:\.[a-zA-Z_$][a-zA-Z0-9_$]*)*)\s*\(/g;
  let match;
  while ((match = callRegex.exec(code)) !== null) {
    calls.push(match[1]);
  }

  return calls;
}

/**
 * Extract file paths referenced in code.
 */
function extractFilePaths(code: string): string[] {
  const paths: string[] = [];

  // Relative imports
  const relativeImportRegex = /from\s+['"](\.[^'"]+)['"]/g;
  let match;
  while ((match = relativeImportRegex.exec(code)) !== null) {
    paths.push(match[1]);
  }

  // Path strings
  const pathRegex = /['"](\.\/?[a-zA-Z0-9_/-]+(?:\.[a-zA-Z]+)?)['"]/g;
  while ((match = pathRegex.exec(code)) !== null) {
    if (match[1].includes("/") || match[1].includes(".")) {
      paths.push(match[1]);
    }
  }

  return paths;
}

/**
 * Check if a package is likely real based on name patterns.
 */
function isLikelyRealPackage(packageName: string): boolean {
  // Remove scope for checking
  const baseName = packageName.startsWith("@")
    ? packageName.split("/").slice(1).join("/")
    : packageName;

  // Known packages
  if (KNOWN_REAL_PACKAGES.has(packageName)) {
    return true;
  }

  // Scoped packages from known orgs
  const knownOrgs = [
    "@types/",
    "@tanstack/",
    "@trpc/",
    "@prisma/",
    "@vercel/",
    "@anthropic-ai/",
    "@langchain/",
    "@harmony/",
  ];
  if (knownOrgs.some((org) => packageName.startsWith(org))) {
    return true;
  }

  // Suspicious patterns
  const suspiciousPatterns = [
    /helper/i,
    /util[s]?$/i,
    /common$/i,
    /misc$/i,
    /stuff/i,
    /tools?$/i,
    /^my-/i,
    /-helper$/i,
    /-utils?$/i,
  ];

  return !suspiciousPatterns.some((p) => p.test(baseName));
}

/**
 * Detect potential hallucinations in AI-generated code.
 */
export function detectHallucinations(
  content: string,
  config: HallucinationCheckConfig = {}
): HallucinationCheckResult {
  const issues: HallucinationCheckResult["issues"] = [];
  const triggeredPatterns: string[] = [];
  const recommendations: string[] = [];

  // 1. Check against known hallucination patterns
  for (const pattern of HALLUCINATION_PATTERNS) {
    let matches = false;

    if (typeof pattern.detect === "function") {
      matches = pattern.detect(content);
    } else {
      matches = pattern.detect.test(content);
    }

    if (matches) {
      triggeredPatterns.push(pattern.id);
      issues.push({
        type: pattern.category,
        description: pattern.description,
        suggestion: `Verify this ${pattern.category} reference is correct`,
      });
    }
  }

  // 2. Verify imports if configured
  if (config.verifyImports !== false) {
    const imports = extractImports(content);
    const packageJson = config.packageJson as {
      dependencies?: Record<string, string>;
      devDependencies?: Record<string, string>;
    } | undefined;

    for (const imp of imports) {
      // Skip relative imports (checked separately)
      if (imp.startsWith(".") || imp.startsWith("/")) {
        continue;
      }

      // Skip Node built-ins
      if (imp.startsWith("node:") || ["fs", "path", "crypto", "util", "http", "https", "stream", "events", "os", "child_process"].includes(imp)) {
        continue;
      }

      // Get base package name (for scoped packages)
      const packageName = imp.startsWith("@")
        ? imp.split("/").slice(0, 2).join("/")
        : imp.split("/")[0];

      // Check against package.json if provided
      if (packageJson) {
        const deps = packageJson.dependencies || {};
        const devDeps = packageJson.devDependencies || {};

        if (!deps[packageName] && !devDeps[packageName]) {
          issues.push({
            type: "import",
            description: `Package '${packageName}' not found in package.json`,
            location: imp,
            suggestion: `Run: pnpm add ${packageName}`,
          });
          recommendations.push(`Verify package '${packageName}' exists: npm info ${packageName}`);
        }
      } else if (!isLikelyRealPackage(packageName)) {
        // No package.json, use heuristics
        issues.push({
          type: "import",
          description: `Package '${packageName}' may not exist (suspicious name pattern)`,
          location: imp,
          suggestion: `Verify package exists: npm info ${packageName}`,
        });
      }
    }
  }

  // 3. Verify file paths if configured
  if (config.verifyFilePaths && config.projectRoot) {
    const paths = extractFilePaths(content);

    for (const filePath of paths) {
      // Resolve relative to project root
      const resolvedPath = join(config.projectRoot, filePath);

      // Check common extensions
      const extensions = ["", ".ts", ".tsx", ".js", ".jsx", ".json"];
      const exists = extensions.some((ext) => existsSync(resolvedPath + ext));

      if (!exists && config.knownFiles) {
        const normalizedPath = filePath.replace(/^\.\//, "");
        const knownMatch = config.knownFiles.some(
          (f) => f.includes(normalizedPath) || normalizedPath.includes(f)
        );

        if (!knownMatch) {
          issues.push({
            type: "file",
            description: `File path '${filePath}' may not exist`,
            location: filePath,
            suggestion: "Verify the file path is correct",
          });
        }
      } else if (!exists && !config.knownFiles) {
        issues.push({
          type: "file",
          description: `File path '${filePath}' not found on disk`,
          location: filePath,
          suggestion: "Create the file or correct the path",
        });
      }
    }
  }

  // 4. Check for known exports if configured
  if (config.verifyFunctions && config.knownExports) {
    const calls = extractFunctionCalls(content);
    const knownSet = new Set(config.knownExports);

    for (const call of calls) {
      // Only check custom function calls, not built-ins
      if (
        call.includes(".") ||
        ["console", "Math", "JSON", "Object", "Array", "String", "Number", "Date", "Promise", "Error"].some(
          (b) => call.startsWith(b + ".")
        )
      ) {
        continue;
      }

      // Skip common JS/TS keywords
      if (["if", "else", "for", "while", "switch", "try", "catch", "new", "return", "throw", "async", "await"].includes(call)) {
        continue;
      }

      if (!knownSet.has(call) && call.length > 2) {
        // Might be a hallucinated function
        issues.push({
          type: "function",
          description: `Function '${call}' not in known exports`,
          location: call,
          suggestion: "Verify this function is defined in the codebase",
        });
      }
    }
  }

  // 5. Add custom patterns
  if (config.customPatterns) {
    for (const pattern of config.customPatterns) {
      let matches = false;

      if (typeof pattern.detect === "function") {
        matches = pattern.detect(content);
      } else {
        matches = pattern.detect.test(content);
      }

      if (matches) {
        triggeredPatterns.push(pattern.id);
        issues.push({
          type: pattern.category,
          description: pattern.description,
        });
      }
    }
  }

  // Calculate confidence based on issues
  const confidence = Math.min(
    1,
    issues.filter((i) => i.type === "import" || i.type === "function").length * 0.2 +
      triggeredPatterns.length * 0.15
  );

  // Add general recommendations
  if (issues.length > 0) {
    recommendations.push("Review AI output carefully before accepting");
    if (issues.some((i) => i.type === "import")) {
      recommendations.push("Verify all imports against package.json");
    }
    if (issues.some((i) => i.type === "file")) {
      recommendations.push("Check that referenced files exist");
    }
  }

  return {
    likely_hallucination: confidence > 0.3,
    confidence,
    issues,
    triggeredPatterns,
    recommendations,
  };
}

/**
 * Check code for safety issues.
 */
export function checkCodeSafety(code: string): GuardrailCheckResult[] {
  const results: GuardrailCheckResult[] = [];

  for (const { id, pattern, severity, description, suggestion } of CODE_SAFETY_PATTERNS) {
    const match = code.match(pattern);

    results.push({
      checkId: `code_safety_${id}`,
      name: id.replace(/_/g, " "),
      category: "code_safety",
      passed: !match,
      severity: match ? severity : undefined,
      message: match ? description : `No ${id.replace(/_/g, " ")} issues found`,
      location: match
        ? {
            start: match.index || 0,
            end: (match.index || 0) + match[0].length,
            context: match[0],
          }
        : undefined,
      suggestion: match ? suggestion : undefined,
    });
  }

  return results;
}

/**
 * Quick hallucination check for common patterns.
 * Returns true if likely hallucination detected.
 */
export function quickHallucinationCheck(content: string): boolean {
  // Check for common hallucination indicators
  const indicators = [
    // TODO/placeholder patterns
    /\/\/\s*TODO|PLACEHOLDER|FIXME/i,
    // Empty catch blocks
    /catch\s*\([^)]*\)\s*\{\s*\}/,
    // Generic helper patterns
    /from\s+['"][^'"]*(?:helper|util|common)[^'"]*['"]/i,
    // Suspicious function names
    /(?:handleData|processInput|doWork|runTask)\s*\(/,
    // Overly generic variable names in important places
    /const\s+(?:data|result|response|value)\s*=\s*await/,
  ];

  return indicators.some((p) => p.test(content));
}

/**
 * Verify that all imports in code are resolvable.
 * Returns list of unresolved imports.
 */
export function verifyImports(
  code: string,
  packageJson?: Record<string, unknown>
): string[] {
  const unresolved: string[] = [];
  const imports = extractImports(code);

  const deps = (packageJson as { dependencies?: Record<string, string> })?.dependencies || {};
  const devDeps = (packageJson as { devDependencies?: Record<string, string> })?.devDependencies || {};
  const allDeps = { ...deps, ...devDeps };

  for (const imp of imports) {
    if (imp.startsWith(".") || imp.startsWith("/") || imp.startsWith("node:")) {
      continue;
    }

    const packageName = imp.startsWith("@")
      ? imp.split("/").slice(0, 2).join("/")
      : imp.split("/")[0];

    // Check against known built-ins
    const builtins = ["fs", "path", "crypto", "util", "http", "https", "stream", "events", "os", "child_process", "url", "querystring", "buffer"];
    if (builtins.includes(packageName)) {
      continue;
    }

    if (!allDeps[packageName] && !KNOWN_REAL_PACKAGES.has(packageName)) {
      unresolved.push(packageName);
    }
  }

  return unresolved;
}


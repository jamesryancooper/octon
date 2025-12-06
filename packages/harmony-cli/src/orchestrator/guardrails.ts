/**
 * Guardrails integration for the Harmony CLI workflow.
 *
 * This module integrates GuardKit and hallucination detection
 * into the AI orchestration workflow.
 */

import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import type { HarmonyTask, CommandResult } from "../types/index.js";

/**
 * Result of a guardrail check.
 */
export interface GuardrailCheckResult {
  /** Whether the check passed */
  passed: boolean;

  /** Overall safety assessment */
  safe: boolean;

  /** Can proceed (may have warnings) */
  canProceed: boolean;

  /** Critical issues (block) */
  critical: GuardrailIssue[];

  /** Warnings (review needed) */
  warnings: GuardrailIssue[];

  /** Info (for reference) */
  info: GuardrailIssue[];

  /** Human-readable summary */
  summary: string;

  /** Recommendations */
  recommendations: string[];
}

/**
 * A single guardrail issue.
 */
export interface GuardrailIssue {
  /** Issue ID */
  id: string;

  /** Category */
  category: "injection" | "hallucination" | "secret" | "pii" | "code_safety";

  /** Severity */
  severity: "critical" | "high" | "medium" | "low";

  /** Message */
  message: string;

  /** Location in content */
  location?: string;

  /** Suggestion */
  suggestion?: string;
}

/**
 * Run guardrail checks on AI-generated content.
 */
export async function runGuardrailChecks(
  content: string,
  workspaceRoot: string,
  tier: "T1" | "T2" | "T3" = "T2"
): Promise<GuardrailCheckResult> {
  const critical: GuardrailIssue[] = [];
  const warnings: GuardrailIssue[] = [];
  const info: GuardrailIssue[] = [];
  const recommendations: string[] = [];

  // Load package.json for import verification
  let packageJson: Record<string, unknown> = {};
  const packageJsonPath = join(workspaceRoot, "package.json");
  if (existsSync(packageJsonPath)) {
    try {
      packageJson = JSON.parse(readFileSync(packageJsonPath, "utf-8"));
    } catch {
      // Ignore parse errors
    }
  }

  // 1. Check for secrets
  const secretPatterns = [
    { id: "aws_key", pattern: /(?:AKIA|A3T|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}/, name: "AWS access key" },
    { id: "github_token", pattern: /(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,}/, name: "GitHub token" },
    { id: "jwt", pattern: /eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/, name: "JWT token" },
    { id: "private_key", pattern: /-----BEGIN\s+(?:RSA\s+)?PRIVATE\s+KEY-----/, name: "Private key" },
    { id: "api_key", pattern: /(?:api[_-]?key|apikey)['":\s=]+['"]?[A-Za-z0-9_-]{20,}['"]?/i, name: "API key" },
  ];

  for (const { id, pattern, name } of secretPatterns) {
    if (pattern.test(content)) {
      critical.push({
        id: `secret_${id}`,
        category: "secret",
        severity: "critical",
        message: `${name} detected in output`,
        suggestion: "Remove or redact immediately",
      });
    }
  }

  // 2. Check for prompt injection
  const injectionPatterns = [
    { id: "ignore", pattern: /ignore\s+(all\s+)?(previous|prior|above)\s+(instructions?|prompts?|rules?)/i, name: "Ignore instructions" },
    { id: "jailbreak", pattern: /(?:DAN|do\s+anything\s+now|developer\s+mode|bypass\s+(?:safety|filters?))/i, name: "Jailbreak attempt" },
    { id: "system_leak", pattern: /(?:reveal|show|display|print|output)\s+(?:the\s+)?(?:system\s+)?(?:prompt|instructions?)/i, name: "System prompt leak" },
  ];

  for (const { id, pattern, name } of injectionPatterns) {
    if (pattern.test(content)) {
      critical.push({
        id: `injection_${id}`,
        category: "injection",
        severity: "critical",
        message: `${name} pattern detected`,
        suggestion: "This may be a prompt injection attempt",
      });
    }
  }

  // 3. Check for hallucinations (import verification)
  // Use [\s\S]*? to match across newlines (multiline imports)
  const importRegex = /import\s+(?:[\s\S]*?\s+from\s+)?['"]([^'"./][^'"]*)['"]/g;
  let match;
  const deps = (packageJson as { dependencies?: Record<string, string> }).dependencies || {};
  const devDeps = (packageJson as { devDependencies?: Record<string, string> }).devDependencies || {};
  const allDeps = { ...deps, ...devDeps };

  const nodeBuiltins = new Set([
    "fs", "path", "crypto", "util", "http", "https", "stream", "events", "os",
    "child_process", "url", "querystring", "buffer", "assert", "zlib"
  ]);

  while ((match = importRegex.exec(content)) !== null) {
    const importPath = match[1];

    // Skip Node built-ins
    if (importPath.startsWith("node:") || nodeBuiltins.has(importPath)) {
      continue;
    }

    // Get base package name
    const packageName = importPath.startsWith("@")
      ? importPath.split("/").slice(0, 2).join("/")
      : importPath.split("/")[0];

    if (!allDeps[packageName]) {
      // Check for suspicious helper patterns
      const suspiciousPatterns = [/helper/i, /util[s]?$/i, /common$/i, /misc$/i];
      const isSuspicious = suspiciousPatterns.some((p) => p.test(packageName));

      if (isSuspicious) {
        warnings.push({
          id: `hallucination_import_${packageName}`,
          category: "hallucination",
          severity: "high",
          message: `Suspicious import: '${packageName}' not in package.json`,
          location: match[0],
          suggestion: `Verify package exists: npm info ${packageName}`,
        });
      } else {
        warnings.push({
          id: `unknown_import_${packageName}`,
          category: "hallucination",
          severity: "medium",
          message: `Unknown package: '${packageName}' not in package.json`,
          location: match[0],
          suggestion: `Add package: pnpm add ${packageName}`,
        });
      }
    }
  }

  // 4. Check for code safety issues
  const codeSafetyPatterns = [
    { id: "eval", pattern: /\beval\s*\(/, severity: "critical" as const, message: "Use of eval() is dangerous" },
    { id: "innerHTML", pattern: /\.innerHTML\s*=/, severity: "high" as const, message: "Direct innerHTML assignment (XSS risk)" },
    { id: "sql_concat", pattern: /(?:SELECT|INSERT|UPDATE|DELETE|FROM|WHERE)[\s\S]*?\+\s*(?:req|request|user|input|param)/i, severity: "critical" as const, message: "Potential SQL injection" },
    { id: "ssl_disable", pattern: /(?:rejectUnauthorized|NODE_TLS_REJECT_UNAUTHORIZED)\s*[:=]\s*(?:false|0|'0'|"0")/, severity: "critical" as const, message: "SSL verification disabled" },
  ];

  for (const { id, pattern, severity, message } of codeSafetyPatterns) {
    if (pattern.test(content)) {
      if (severity === "critical") {
        critical.push({
          id: `code_safety_${id}`,
          category: "code_safety",
          severity,
          message,
          suggestion: "This pattern is not safe for production",
        });
      } else {
        warnings.push({
          id: `code_safety_${id}`,
          category: "code_safety",
          severity,
          message,
          suggestion: "Review this pattern for security",
        });
      }
    }
  }

  // 5. Check for TODO/placeholder (lower severity)
  if (/\/\/\s*TODO|PLACEHOLDER|FIXME|XXX/i.test(content)) {
    info.push({
      id: "todo_placeholder",
      category: "hallucination",
      severity: "low",
      message: "Contains TODO/placeholder comments",
      suggestion: "Complete implementation before using",
    });
  }

  // 6. Check for empty catch blocks
  if (/catch\s*\([^)]*\)\s*\{\s*\}/.test(content)) {
    warnings.push({
      id: "empty_catch",
      category: "code_safety",
      severity: "medium",
      message: "Empty catch block swallows errors",
      suggestion: "Add proper error handling",
    });
  }

  // Generate summary
  const passed = critical.length === 0;
  const safe = critical.length === 0 && warnings.filter((w) => w.severity === "high").length === 0;
  const canProceed = critical.length === 0;

  let summary = "";
  if (critical.length > 0) {
    summary = `❌ BLOCKED: ${critical.length} critical issue(s) found`;
  } else if (warnings.length > 0) {
    summary = `⚠️ ${warnings.length} warning(s) to review`;
  } else {
    summary = "✅ No issues detected";
  }

  // Generate recommendations
  if (critical.some((c) => c.category === "secret")) {
    recommendations.push("Remove or redact secrets before proceeding");
  }
  if (warnings.some((w) => w.category === "hallucination")) {
    recommendations.push("Verify all imports against package.json");
  }
  if (warnings.some((w) => w.category === "code_safety")) {
    recommendations.push("Review code safety warnings carefully");
  }
  if (info.some((i) => i.id === "todo_placeholder")) {
    recommendations.push("Complete TODO sections before shipping");
  }

  return {
    passed,
    safe,
    canProceed,
    critical,
    warnings,
    info,
    summary,
    recommendations,
  };
}

/**
 * Check a task's output against guardrails.
 */
export async function checkTaskOutput(
  task: HarmonyTask,
  output: string,
  workspaceRoot: string
): Promise<GuardrailCheckResult> {
  return runGuardrailChecks(output, workspaceRoot, task.tier);
}

/**
 * Verify imports in code against package.json.
 */
export function verifyImports(
  code: string,
  workspaceRoot: string
): { valid: boolean; missing: string[]; suspicious: string[] } {
  const missing: string[] = [];
  const suspicious: string[] = [];

  // Load package.json
  let packageJson: Record<string, unknown> = {};
  const packageJsonPath = join(workspaceRoot, "package.json");
  if (existsSync(packageJsonPath)) {
    try {
      packageJson = JSON.parse(readFileSync(packageJsonPath, "utf-8"));
    } catch {
      // Ignore parse errors
    }
  }

  const deps = (packageJson as { dependencies?: Record<string, string> }).dependencies || {};
  const devDeps = (packageJson as { devDependencies?: Record<string, string> }).devDependencies || {};
  const allDeps = { ...deps, ...devDeps };

  // Use [\s\S]*? to match across newlines (multiline imports)
  const importRegex = /import\s+(?:[\s\S]*?\s+from\s+)?['"]([^'"./][^'"]*)['"]/g;
  let match;

  const nodeBuiltins = new Set([
    "fs", "path", "crypto", "util", "http", "https", "stream", "events", "os",
    "child_process", "url", "querystring", "buffer"
  ]);

  while ((match = importRegex.exec(code)) !== null) {
    const importPath = match[1];

    if (importPath.startsWith("node:") || nodeBuiltins.has(importPath)) {
      continue;
    }

    const packageName = importPath.startsWith("@")
      ? importPath.split("/").slice(0, 2).join("/")
      : importPath.split("/")[0];

    if (!allDeps[packageName]) {
      const suspiciousPatterns = [/helper/i, /util[s]?$/i, /common$/i];
      if (suspiciousPatterns.some((p) => p.test(packageName))) {
        suspicious.push(packageName);
      } else {
        missing.push(packageName);
      }
    }
  }

  return {
    valid: missing.length === 0 && suspicious.length === 0,
    missing: [...new Set(missing)],
    suspicious: [...new Set(suspicious)],
  };
}

/**
 * Format guardrail results for display.
 */
export function formatGuardrailResults(result: GuardrailCheckResult): string {
  const lines: string[] = [];

  lines.push(result.summary);
  lines.push("");

  if (result.critical.length > 0) {
    lines.push("🔴 Critical Issues (must fix):");
    for (const issue of result.critical) {
      lines.push(`   - ${issue.message}`);
      if (issue.suggestion) {
        lines.push(`     → ${issue.suggestion}`);
      }
    }
    lines.push("");
  }

  if (result.warnings.length > 0) {
    lines.push("🟡 Warnings (review needed):");
    for (const issue of result.warnings) {
      lines.push(`   - ${issue.message}`);
      if (issue.location) {
        lines.push(`     at: ${issue.location}`);
      }
      if (issue.suggestion) {
        lines.push(`     → ${issue.suggestion}`);
      }
    }
    lines.push("");
  }

  if (result.info.length > 0) {
    lines.push("ℹ️  Info:");
    for (const issue of result.info) {
      lines.push(`   - ${issue.message}`);
    }
    lines.push("");
  }

  if (result.recommendations.length > 0) {
    lines.push("Recommendations:");
    for (const rec of result.recommendations) {
      lines.push(`   • ${rec}`);
    }
  }

  return lines.join("\n");
}


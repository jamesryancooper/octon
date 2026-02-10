---
name: audit-ui
description: >
  Stack-agnostic UI audit that fetches a live external design guidelines
  ruleset and scans local UI files for violations. Reports findings in
  file:line format with rule references. Produces a structured audit report
  with severity tiers and recommended fixes. Read-only — does not modify
  source files.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Harmony Framework
  created: "2026-02-09"
  updated: "2026-02-09"
skill_sets: [executor, guardian]
capabilities: [external-dependent]
allowed-tools: Read Glob Grep WebFetch Write(../../output/reports/*) Write(logs/*)
---

# Audit UI

Stack-agnostic audit that checks UI files against live external web design guidelines.

## When to Use

Use this skill when:

- You need to review UI code for design best practices compliance
- You want to check accessibility, focus states, dark mode, typography, or UX patterns
- You need a pre-launch design quality audit
- You want to verify design system consistency across components

## Quick Start

```
/audit-ui target="src/components/"
```

Or with a custom ruleset:

```
/audit-ui target="src/" ruleset_url="https://example.com/guidelines.md"
```

## Core Workflow

1. **Fetch Ruleset** — WebFetch the external guidelines URL, parse the markdown into structured rules with categories and priorities
2. **Discover Files** — Glob for UI files matching `file_types` (tsx, jsx, html, css, vue, svelte) within `target` directory
3. **Scan & Classify** — Read each file, check against parsed rules, record violations with file:line location, rule reference, and severity
4. **Report** — Generate structured findings report with executive summary, categorized violations, clean files list, and coverage proof

### Live Ruleset Pattern

This skill fetches its ruleset at execution time from an external URL rather
than embedding static rules. This ensures audits always use the most current
guidelines without requiring harness updates. The default ruleset is maintained
by Anthropic and covers 100+ rules across accessibility, performance, and UX.

If the external URL is unreachable, the skill cannot proceed — there is no
offline fallback. See `references/dependencies.md` for failure handling.

## Parameters

Parameters are defined in `.harmony/capabilities/skills/registry.yml` (single source of truth).

This skill accepts optional parameters for target directory, ruleset URL override, and file type filter.

## Output Location

Output paths are defined in `.harmony/capabilities/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.harmony/output/reports/YYYY-MM-DD-ui-audit.md` — Findings report
- `logs/audit-ui/` — Execution logs with index

## Severity Classification

| Severity | Definition |
|----------|-----------|
| CRITICAL | Accessibility violations that prevent users from accessing content (missing alt text on functional images, no keyboard navigation, missing form labels) |
| HIGH | Usability issues that significantly degrade experience (missing focus states, no error messages on forms, poor contrast ratios) |
| MEDIUM | Design consistency issues (inconsistent spacing, missing dark mode support, non-standard component patterns) |
| LOW | Cosmetic issues (typography improvements, minor spacing adjustments, style preferences) |

## Boundaries

- **Read-only:** Never modify source files — audit only, report findings
- Write only to designated output paths (reports and logs)
- WebFetch only to the configured ruleset URL (no arbitrary web access)
- Maximum scope: 500 UI files (escalate if exceeded)
- Do not fabricate rules — only report against rules present in the fetched ruleset
- Report must include what was checked and found clean, not just findings

## When to Escalate

- Ruleset URL is unreachable — report error, cannot proceed without rules
- Scope exceeds 500 UI files — warn and offer to narrow scope
- More than 200 violations found — recommend phased remediation
- Ruleset format is unrecognizable — warn, attempt best-effort parse

## References

For detailed documentation:

- [Behavior phases](references/phases.md) — Full phase-by-phase instructions
- [I/O contract](references/io-contract.md) — Inputs, outputs, report format
- [Safety policies](references/safety.md) — Read-only policy, WebFetch scope
- [Validation](references/validation.md) — Acceptance criteria for complete audits
- [Examples](references/examples.md) — Audit example with sample output
- [Dependencies](references/dependencies.md) — External ruleset dependency documentation

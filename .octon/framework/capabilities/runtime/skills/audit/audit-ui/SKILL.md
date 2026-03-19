---
name: audit-ui
description: >
  Stack-agnostic UI audit that fetches a live external design guidelines
  ruleset and scans local UI files for violations. Reports findings in
  file:line format with rule references. Produces bounded findings with stable
  IDs, acceptance criteria, coverage accounting, and deterministic convergence
  receipts. Read-only -- does not modify source files.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-02-09"
  updated: "2026-02-22"
skill_sets: [executor, guardian]
capabilities: [external-dependent]
allowed-tools: Read Glob Grep WebFetch Write(/.octon/state/evidence/validation/analysis/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Audit UI

Stack-agnostic audit that checks UI files against live external web design guidelines.

## When to Use

Use this skill when:

- You need to review UI code for design best-practice compliance
- You want to check accessibility, focus states, dark mode, typography, or UX patterns
- You need a pre-launch design quality audit
- You want to verify design system consistency across components

## Quick Start

```text
/audit-ui target="src/components/"
```

Or with a custom ruleset:

```text
/audit-ui target="src/" ruleset_url="https://example.com/guidelines.md"
```

## Core Workflow

1. **Fetch Ruleset** -- WebFetch the guidelines URL and parse markdown into structured rules.
2. **Discover Files** -- Glob for UI files matching `file_types` within `target`.
3. **Scan and Classify** -- Check each file against parsed rules and record violations.
4. **Self-Challenge** -- Re-check for missed violations and false positives.
5. **Report** -- Emit bounded findings plus coverage and convergence receipts.

### Live Ruleset Pattern

This skill fetches its ruleset at execution time from an external URL rather than embedding static rules. This keeps audits aligned with current guidance without harness updates.

If the external URL is unreachable, the skill cannot proceed in strict mode. See `references/dependencies.md` for failure handling.

### Bounded Audit Principles

| # | Principle | What It Prevents |
| - | --------- | ---------------- |
| 1 | Fixed lenses (layers) | Attention drift between runs |
| 2 | Fixed taxonomy + severity bar | Open-ended issue inflation |
| 3 | Coverage accounting | Invisible scope gaps |
| 4 | Stable finding IDs | Finding identity drift |
| 5 | Acceptance criteria per finding | Ambiguous remediation targets |
| 6 | Determinism receipt | Untraceable run variance |
| 7 | Mandatory self-challenge | One-pass omissions |
| 8 | Explicit done gate | Infinite rerun loops |

## Parameters

Parameters are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts optional parameters for target directory, ruleset URL, file-type filter, severity threshold, and convergence controls (`post_remediation`, `convergence_k`, `seed_list`).

## Output Location

Output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.octon/state/evidence/validation/analysis/YYYY-MM-DD-ui-audit.md` -- Human-readable findings report
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<run-id>/` -- Authoritative bounded-audit bundle
- `/.octon/state/evidence/runs/skills/audit-ui/` -- Execution logs with index

## Severity Classification

| Severity | Definition |
| -------- | ---------- |
| CRITICAL | Accessibility violations that prevent users from accessing content |
| HIGH | Usability issues that significantly degrade UX |
| MEDIUM | Design consistency issues across components/views |
| LOW | Cosmetic issues and non-blocking style improvements |

## Done Gate

- Discovery mode (`post_remediation=false`): done-gate value is recorded for planning.
- Post-remediation mode (`post_remediation=true`): pass requires convergence stability and zero open findings at or above threshold.

## Boundaries

- **Read-only:** Never modify source files -- audit only, report findings
- Write only to designated output paths (reports and logs)
- WebFetch only to the configured ruleset URL
- Maximum scope: 500 UI files (escalate if exceeded)
- Do not fabricate rules -- only report against parsed ruleset content
- Report must include checked-clean files, not only violations
- Emit stable IDs and acceptance criteria for bundle findings

## When to Escalate

- Ruleset URL is unreachable -- report error
- Scope exceeds 500 UI files -- recommend narrower target or partitioning
- More than 200 violations -- recommend phased remediation
- Ruleset format is unrecognizable -- warn and best-effort parse with explicit uncertainty

## References

For detailed documentation:

- [Behavior phases](references/phases.md) -- Full phase-by-phase instructions
- [I/O contract](references/io-contract.md) -- Inputs, outputs, and bundle schema
- [Safety policies](references/safety.md) -- Read-only policy and WebFetch scope
- [Validation](references/validation.md) -- Acceptance criteria and done-gate checks
- [Examples](references/examples.md) -- Audit example with sample output
- [Dependencies](references/dependencies.md) -- External ruleset dependency documentation

---
name: audit-documentation-standards
description: >
  Bounded docs-as-code audit that checks documentation against Harmony policy,
  canonical template guidance, and required artifact structure. Produces
  severity-tiered findings with stable IDs, acceptance criteria, coverage proof,
  and deterministic convergence receipts. Read-only with scoped report and log
  outputs.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Harmony Framework
  created: "2026-02-13"
  updated: "2026-02-22"
skill_sets: [executor, guardian]
capabilities: [domain-specialized, self-validating]
allowed-tools: Read Glob Grep Write(../../output/reports/*) Write(_ops/state/logs/*)
---

# Audit Documentation Standards

Run a docs-as-code compliance audit for a documentation root against Harmony's canonical policy and template guidance.

## When to Use

Use this skill when:

- You need a release-readiness check for documentation quality
- A feature changed behavior/contracts and docs were updated in parallel
- You want to detect missing specs, ADRs, runbooks, or contract links
- You need an enforceable report before merging or releasing

## Quick Start

```text
/audit-documentation-standards docs_root="docs"
```

With explicit guidance paths:

```text
/audit-documentation-standards docs_root="docs" template_root=".harmony/scaffolding/runtime/templates/docs/documentation-standards" policy_doc=".harmony/cognition/governance/principles/documentation-is-code.md"
```

## Core Workflow

1. **Configure** -- Parse parameters and resolve canonical guidance paths.
2. **Inventory** -- Enumerate docs, specs, runbooks, guides, and contract references.
3. **Policy Checks** -- Verify docs-as-code expectations from policy artifacts.
4. **Template Checks** -- Verify required sections and structure against canonical templates.
5. **Self-Challenge** -- Re-check for missed standards violations and false positives.
6. **Report** -- Emit bounded findings plus coverage and convergence receipts.

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

Parameters are defined in `.harmony/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts one required parameter (`docs_root`) and optional parameters for template/policy sources, severity threshold, and convergence controls (`post_remediation`, `convergence_k`, `seed_list`).

## Output Location

Output paths are defined in `.harmony/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:

- `.harmony/output/reports/analysis/YYYY-MM-DD-documentation-standards-audit.md` -- Human-readable findings report
- `.harmony/output/reports/audits/YYYY-MM-DD-<run-id>/` -- Authoritative bounded-audit bundle
- `_ops/state/logs/audit-documentation-standards/` -- Execution logs with index

## Severity Classification

| Severity | Definition |
| -------- | ---------- |
| CRITICAL | Required documentation artifacts are missing for changed behavior or contracts |
| HIGH | Required sections or rollback guidance are missing in operational docs |
| MEDIUM | Template structure drift, unresolved links, or stale references |
| LOW | Style or clarity gaps that do not block release readiness |

## Done Gate

- Discovery mode (`post_remediation=false`): done-gate value is recorded for planning.
- Post-remediation mode (`post_remediation=true`): pass requires convergence stability and zero open findings at or above threshold.

## Boundaries

- Read-only source audit; no source edits
- Write only to designated report/log outputs
- Maximum scope: 1000 markdown files (escalate if exceeded)
- Include coverage proof (checked-clean files), not only findings
- Emit stable IDs and acceptance criteria for bundle findings
- Record determinism receipt metadata for convergence evaluation

## When to Escalate

- `docs_root` does not exist
- Canonical policy/template paths do not exist when explicitly provided
- Scope exceeds threshold and needs partitioning
- Findings volume exceeds 200 and needs phased remediation

## References

- [Behavior phases](references/phases.md)
- [I/O contract](references/io-contract.md)
- [Safety policies](references/safety.md)
- [Validation](references/validation.md)
- [Examples](references/examples.md)
- [Glossary](references/glossary.md)

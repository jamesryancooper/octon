---
name: audit-documentation-standards
description: >
  Bounded docs-as-code audit that checks documentation against Harmony policy,
  canonical template guidance, and required artifact structure. Produces a
  severity-tiered report with actionable remediation batches. Read-only with
  scoped report and log outputs.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Harmony Framework
  created: "2026-02-13"
  updated: "2026-02-13"
skill_sets: [executor, guardian]
capabilities: [domain-specialized, self-validating]
allowed-tools: Read Glob Grep Write(../../output/reports/*) Write(_ops/state/logs/*)
---

# Audit Documentation Standards

Run a docs-as-code compliance audit for a documentation root against Harmony's
canonical policy and template guidance.

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

1. **Configure** - Parse parameters and resolve canonical guidance paths.
2. **Inventory** - Enumerate docs, specs, runbooks, guides, and contract refs.
3. **Policy Checks** - Verify docs-as-code expectations from
   `documentation-is-code.md`.
4. **Template Checks** - Verify required sections and structure against
   `documentation-standards.md` and template stubs.
5. **Report** - Produce severity-tiered findings, clean coverage proof, and
   remediation batches.

## Parameters

Parameters are defined in `.harmony/capabilities/runtime/skills/registry.yml` (single
source of truth).

This skill accepts one required parameter (`docs_root`) and optional parameters
for `template_root`, `policy_doc`, and `severity_threshold`.

## Output Location

Output paths are defined in `.harmony/capabilities/runtime/skills/registry.yml` (single
source of truth).

Outputs are written to:

- `.harmony/output/reports/YYYY-MM-DD-documentation-standards-audit.md`
- `_ops/state/logs/audit-documentation-standards/`

## Severity Classification

| Severity | Definition |
|----------|------------|
| CRITICAL | Required documentation artifacts are missing for changed behavior or contracts. |
| HIGH | Required sections or rollback guidance missing in operational docs. |
| MEDIUM | Template structure drift, unresolved links, or stale references. |
| LOW | Style or clarity gaps that do not block release readiness. |

## Boundaries

- Read-only source audit; no source edits
- Write only to designated report/log outputs
- Maximum scope: 1000 markdown files (escalate if exceeded)
- Include coverage proof (checked-clean files), not only findings
- Idempotent output expectation for unchanged inputs

## When to Escalate

- `docs_root` does not exist
- Canonical policy/template paths do not exist
- Scope exceeds threshold and needs partitioning
- Findings volume exceeds 200 and needs phased remediation

## References

- [Behavior phases](references/phases.md)
- [I/O contract](references/io-contract.md)
- [Safety policies](references/safety.md)
- [Validation](references/validation.md)
- [Examples](references/examples.md)
- [Glossary](references/glossary.md)

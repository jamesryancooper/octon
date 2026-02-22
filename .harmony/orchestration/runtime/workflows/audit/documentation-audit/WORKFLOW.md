---
name: documentation-audit
description: >
  Run bounded documentation standards enforcement by invoking
  audit-documentation-standards, then emit a deterministic bundle with stable
  finding identity, coverage accounting, and explicit done-gate evaluation.
steps:
  - id: configure
    file: 01-configure.md
    description: Parse parameters and build bounded execution plan.
  - id: run-standards-audit
    file: 02-run-standards-audit.md
    description: Execute audit-documentation-standards in bounded mode.
  - id: report
    file: 03-report.md
    description: Generate recommendation report and bounded evidence bundle.
  - id: verify
    file: 04-verify.md
    description: Validate workflow artifacts and mode-specific done-gate outcomes.
# --- Harmony extensions ---
access: human
version: "3.0.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps: []
---

# Documentation Audit: Overview

Run a bounded release-readiness documentation audit for a docs root using Harmony canonical docs-as-code standards.

## Usage

```text
/documentation-audit docs_root="docs"
```

With bounded convergence controls:

```text
/documentation-audit docs_root="docs" post_remediation="true" convergence_k="3" seed_list="11,23,37"
```

## Target

A documentation tree (for example `docs/`) that must be validated for spec/ADR/guide/runbook/contract completeness and structure before release.

## Prerequisites

- `audit-documentation-standards` skill is active in the skill manifest
- `docs_root` exists
- Canonical policy and template paths exist (defaults or overrides)

## Failure Conditions

- Missing docs root -> STOP, report `DOCS_ROOT_NOT_FOUND`
- Missing canonical guidance path -> STOP, report `CANONICAL_PATH_NOT_FOUND`
- Audit skill unavailable -> STOP, report `SKILL_NOT_AVAILABLE`
- Coverage accounting leaves unaccounted files -> FAIL done-gate

## Steps

1. [Configure](./01-configure.md) - Parse parameters and deterministic controls
2. [Run Standards Audit](./02-run-standards-audit.md) - Execute bounded documentation audit skill
3. [Report](./03-report.md) - Emit recommendation report plus bounded evidence bundle
4. [Verify](./04-verify.md) - Validate completion gate by mode

## Verification Gate

Documentation audit is complete only when:

- [ ] Documentation standards audit report exists
- [ ] Documentation audit recommendation report exists
- [ ] Bounded bundle exists at `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
- [ ] Findings are deduplicated with stable IDs and acceptance criteria
- [ ] Coverage and convergence metadata are recorded
- [ ] Done-gate rationale is explicit

## Version History

| Version | Date | Changes |
| ------- | ---- | ------- |
| 3.0.0 | 2026-02-22 | Clean-break migration to bounded workflow contract with done-gate and convergence controls |
| 2.0.0 | 2026-02-21 | Clean-break rename from `documentation-quality-gate` to `documentation-audit` |
| 1.0.0 | 2026-02-13 | Initial version |

## References

- **Skill:** `.harmony/capabilities/runtime/skills/audit/audit-documentation-standards/SKILL.md`
- **Policy:** `.harmony/cognition/governance/principles/documentation-is-code.md`
- **Guidance:** `.harmony/scaffolding/runtime/templates/documentation-standards.md`

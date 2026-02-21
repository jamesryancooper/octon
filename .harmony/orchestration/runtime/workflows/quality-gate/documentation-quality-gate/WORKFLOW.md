---
name: documentation-quality-gate
description: >
  Run documentation standards enforcement before release by invoking
  audit-documentation-standards, then generate a go/no-go quality gate report.
steps:
  - id: configure
    file: 01-configure.md
    description: Parse parameters and validate canonical paths.
  - id: run-standards-audit
    file: 02-run-standards-audit.md
    description: Execute audit-documentation-standards.
  - id: report
    file: 03-report.md
    description: Produce consolidated gate report with recommendation.
  - id: verify
    file: 04-verify.md
    description: Validate workflow executed successfully.
# --- Harmony extensions ---
access: human
version: "1.0.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps: []
---

# Documentation Quality Gate: Overview

Run a release-readiness documentation gate for a docs root using Harmony's
canonical docs-as-code standards.

## Usage

```text
/documentation-quality-gate docs_root="docs"
```

With explicit canonical paths:

```text
/documentation-quality-gate docs_root="docs" template_root=".harmony/scaffolding/runtime/templates/docs/documentation-standards" policy_doc=".harmony/cognition/governance/principles/documentation-is-code.md"
```

## Target

A documentation tree (for example `docs/`) that must be validated for
spec/ADR/guide/runbook/contract completeness and structure before release.

## Prerequisites

- `audit-documentation-standards` skill is active in the skill manifest
- `docs_root` exists
- Canonical policy and template paths exist (defaults or overrides)

## Failure Conditions

- Missing docs root -> STOP, report `DOCS_ROOT_NOT_FOUND`
- Missing canonical guidance path -> STOP, report `CANONICAL_PATH_NOT_FOUND`
- Audit skill unavailable -> STOP, report `SKILL_NOT_AVAILABLE`

## Steps

1. [Configure](./01-configure.md) - Parse parameters and validate paths
2. [Run Standards Audit](./02-run-standards-audit.md) - Execute the audit skill
3. [Report](./03-report.md) - Emit go/no-go documentation quality report
4. [Verify](./04-verify.md) - Validate completion gate

## Verification Gate

Documentation Quality Gate is NOT complete until:

- [ ] Documentation standards audit report exists
- [ ] Gate report exists with recommendation and rationale
- [ ] Severity summary is included
- [ ] Coverage proof is included
- [ ] Verification step passes

## Version History

| Version | Date | Changes |
| ------- | ---- | ------- |
| 1.0.0 | 2026-02-13 | Initial version |

## References

- **Skill:** `.harmony/capabilities/runtime/skills/quality-gate/audit-documentation-standards/SKILL.md`
- **Policy:** `.harmony/cognition/governance/principles/documentation-is-code.md`
- **Guidance:** `.harmony/scaffolding/runtime/templates/documentation-standards.md`

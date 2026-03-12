---
name: "audit-documentation"
description: "Run bounded documentation standards enforcement by invoking audit-documentation-standards, then emit a deterministic bundle with stable finding identity, coverage accounting, and explicit done-gate evaluation."
steps:
  - id: "configure"
    file: "stages/01-configure.md"
    description: "configure"
  - id: "run-standards-audit"
    file: "stages/02-run-standards-audit.md"
    description: "run-standards-audit"
  - id: "report"
    file: "stages/03-report.md"
    description: "report"
  - id: "verify"
    file: "stages/04-verify.md"
    description: "verify"
---

# Audit Documentation

_Generated README from canonical workflow `audit-documentation`._

## Usage

```text
/audit-documentation
```

## Purpose

Run bounded documentation standards enforcement by invoking audit-documentation-standards, then emit a deterministic bundle with stable finding identity, coverage accounting, and explicit done-gate evaluation.

## Target

This README summarizes the canonical workflow unit at `.harmony/orchestration/runtime/workflows/audit/audit-documentation`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.harmony/orchestration/runtime/workflows/audit/audit-documentation/workflow.yml`.

## Parameters

- `docs_root` (folder, required=true): Root documentation directory to validate
- `template_root` (folder, required=false), default=`.harmony/scaffolding/runtime/templates/docs/documentation-standards`: Canonical documentation template root
- `policy_doc` (file, required=false), default=`.harmony/cognition/governance/principles/documentation-is-code.md`: Canonical docs-as-code policy document
- `severity_threshold` (text, required=false), default=`all`: Minimum severity to report: critical, high, medium, low, all
- `post_remediation` (boolean, required=false): Enable strict done-gate enforcement for remediation verification
- `convergence_k` (text, required=false), default=`3`: Number of controlled reruns used to evaluate convergence stability
- `seed_list` (text, required=false): Comma-separated deterministic seeds used for multi-run consistency checks

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `docs_audit_report` -> `../../output/reports/analysis/{{date}}-audit-documentation.md`: Consolidated documentation audit report with release recommendation
- `docs_standards_audit_report` -> `../../output/reports/analysis/{{date}}-documentation-standards-audit.md`: Input audit report produced by audit-documentation-standards
- `documentation_audit_bundle` -> `../../output/reports/audits/{{date}}-{{slug}}/`: Authoritative bounded-audit bundle for documentation recommendation and done-gate evidence

## Steps

1. [configure](./stages/01-configure.md)
2. [run-standards-audit](./stages/02-run-standards-audit.md)
3. [report](./stages/03-report.md)
4. [verify](./stages/04-verify.md)

## Verification Gate

- [ ] Documentation standards audit report exists
- [ ] Documentation audit recommendation report exists
- [ ] Bounded bundle exists at `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
- [ ] Findings are deduplicated with stable IDs and acceptance criteria
- [ ] Coverage and convergence metadata are recorded
- [ ] Done-gate rationale is explicit

## References

- Canonical contract: `.harmony/orchestration/runtime/workflows/audit/audit-documentation/workflow.yml`
- Canonical stages: `.harmony/orchestration/runtime/workflows/audit/audit-documentation/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 3.0.0 | Generated from canonical workflow `audit-documentation` |


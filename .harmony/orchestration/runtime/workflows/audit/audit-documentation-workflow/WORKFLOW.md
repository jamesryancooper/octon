---
name: "audit-documentation-workflow"
description: "Run bounded documentation standards enforcement by invoking audit-documentation-standards, then emit a deterministic bundle with stable finding identity, coverage accounting, and explicit done-gate evaluation."
steps:
  - id: "configure"
    file: "01-configure.md"
    description: "configure"
  - id: "run-standards-audit"
    file: "02-run-standards-audit.md"
    description: "run-standards-audit"
  - id: "report"
    file: "03-report.md"
    description: "report"
  - id: "verify"
    file: "04-verify.md"
    description: "verify"
---

# Audit Documentation Workflow

_Generated projection from canonical pipeline `audit-documentation-workflow`._

## Usage

```text
/audit-documentation-workflow
```

## Target

This projection wraps the canonical pipeline `audit-documentation-workflow` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/audit/audit-documentation-workflow`.

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
- The backing canonical pipeline contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `docs_audit_report` -> `../../output/reports/{{date}}-audit-documentation-workflow.md`: Consolidated documentation audit report with release recommendation
- `docs_standards_audit_report` -> `../../output/reports/{{date}}-documentation-standards-audit.md`: Input audit report produced by audit-documentation-standards
- `documentation_audit_bundle` -> `../../output/reports/audits/{{date}}-{{slug}}/`: Authoritative bounded-audit bundle for documentation recommendation and done-gate evidence

## Steps

1. [configure](./01-configure.md)
2. [run-standards-audit](./02-run-standards-audit.md)
3. [report](./03-report.md)
4. [verify](./04-verify.md)

## Verification Gate

- [ ] Documentation standards audit report exists
- [ ] Documentation audit recommendation report exists
- [ ] Bounded bundle exists at `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
- [ ] Findings are deduplicated with stable IDs and acceptance criteria
- [ ] Coverage and convergence metadata are recorded
- [ ] Done-gate rationale is explicit

## Version History

| Version | Changes |
|---------|---------|
| 3.0.0 | Generated from canonical pipeline `audit-documentation-workflow` |

## References

- Canonical pipeline: `.harmony/orchestration/runtime/pipelines/audit/audit-documentation-workflow/`

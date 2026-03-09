---
name: "audit-workflow-system-workflow"
description: "Audit the Harmony workflow system with bounded static analysis, representative rehearsals, stable finding IDs, coverage accounting, and explicit done-gate evaluation."
steps:
  - id: "build-inventory"
    file: "01-build-inventory.md"
    description: "build-inventory"
  - id: "validate-contracts"
    file: "02-validate-contracts.md"
    description: "validate-contracts"
  - id: "evaluate-workflows"
    file: "03-evaluate-workflows.md"
    description: "evaluate-workflows"
  - id: "assess-portfolio"
    file: "04-assess-portfolio.md"
    description: "assess-portfolio"
  - id: "run-scenarios"
    file: "05-run-scenarios.md"
    description: "run-scenarios"
  - id: "merge-and-score"
    file: "06-merge-and-score.md"
    description: "merge-and-score"
  - id: "report"
    file: "07-report.md"
    description: "report"
  - id: "verify"
    file: "08-verify.md"
    description: "verify"
---

# Audit Workflow System Workflow

_Generated projection from canonical pipeline `audit-workflow-system-workflow`._

## Usage

```text
/audit-workflow-system-workflow
```

## Target

This projection wraps the canonical pipeline `audit-workflow-system-workflow` for staged human review and slash-facing compatibility.

## Prerequisites

- Required pipeline inputs are available.
- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/audit/audit-workflow-system-workflow`.

## Parameters

- `scope` (folder, required=false), default=`.harmony/orchestration/runtime/workflows/`: Root workflow directory to audit.
- `severity_threshold` (text, required=false), default=`high`: Minimum severity that blocks the done gate: critical, high, medium, low, all.
- `include_docs` (boolean, required=false), default=`true`: Include companion workflow docs and rubric context in scope.
- `include_governance` (boolean, required=false), default=`true`: Include workflow governance and validation surfaces in scope.
- `run_live` (boolean, required=false), default=`true`: Run representative rehearsal scenarios in addition to static analysis.
- `scenario_pack` (text, required=false), default=`representative`: Representative scenario pack to run when run_live is enabled.
- `post_remediation` (boolean, required=false): Enable strict convergence verification after remediation.
- `convergence_k` (text, required=false), default=`3`: Number of controlled reruns used to evaluate convergence stability.
- `seed_list` (text, required=false): Comma-separated deterministic seeds used for multi-run consistency checks.

## Failure Conditions

- Required inputs are missing or invalid.
- The backing canonical pipeline contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `workflow_system_audit_report` -> `../../output/reports/{{date}}-audit-workflow-system-workflow.md`: Narrative report summarizing workflow-system findings and recommendations.
- `workflow_system_audit_bundle` -> `../../output/reports/audits/{{date}}-{{slug}}/`: Authoritative bounded-audit bundle for workflow-system findings, scores, scenarios, and done-gate evidence.

## Steps

1. [build-inventory](./01-build-inventory.md)
2. [validate-contracts](./02-validate-contracts.md)
3. [evaluate-workflows](./03-evaluate-workflows.md)
4. [assess-portfolio](./04-assess-portfolio.md)
5. [run-scenarios](./05-run-scenarios.md)
6. [merge-and-score](./06-merge-and-score.md)
7. [report](./07-report.md)
8. [verify](./08-verify.md)

## Verification Gate

- [ ] Findings are deduplicated with stable IDs and objective acceptance criteria
- [ ] Coverage accounting has zero unaccounted files
- [ ] Representative scenario results are recorded
- [ ] Bounded bundle exists at `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
- [ ] Runtime audit plan exists at `.harmony/cognition/runtime/audits/YYYY-MM-DD-<slug>/plan.md`
- [ ] Done-gate expression is evaluated in `validation.md` and `convergence.yml`
- [ ] If `post_remediation=true`, convergence K-run result is stable and empty at/above threshold

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical pipeline `audit-workflow-system-workflow` |

## References

- Canonical pipeline: `.harmony/orchestration/runtime/pipelines/audit/audit-workflow-system-workflow/`

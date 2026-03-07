---
name: audit-workflow-system-workflow
description: >
  Audit the Harmony workflow system with bounded static analysis, representative
  rehearsals, stable finding IDs, coverage accounting, and explicit done-gate
  evaluation.
steps:
  - id: build-inventory
    file: 01-build-inventory.md
    description: Resolve audit scope, inventory workflow artifacts, and build coverage accounting.
  - id: validate-contracts
    file: 02-validate-contracts.md
    description: Evaluate manifest, registry, workflow, and capability-map contract integrity.
  - id: evaluate-workflows
    file: 03-evaluate-workflows.md
    description: Score each workflow against the shared evaluator and collect findings.
  - id: assess-portfolio
    file: 04-assess-portfolio.md
    description: Detect lifecycle gaps, overlaps, dependency cycles, and validator blind spots.
  - id: run-scenarios
    file: 05-run-scenarios.md
    description: Run representative workflow rehearsals for core and external-dependent surfaces.
  - id: merge-and-score
    file: 06-merge-and-score.md
    description: Deduplicate issues into stable findings and compute workflow/system scores.
  - id: report
    file: 07-report.md
    description: Emit the narrative report, runtime audit plan, and bounded evidence bundle.
  - id: verify
    file: 08-verify.md
    description: Validate done-gate outcomes, coverage accounting, and convergence metadata.
# --- Harmony extensions ---
access: human
version: "1.0.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps: []
---

# Workflow System Audit Workflow

Run a bounded audit of the Harmony workflow system itself, not just one workflow.

## Usage

```text
/audit-workflow-system-workflow scope=".harmony/orchestration/runtime/workflows/"
```

With strict post-remediation convergence:

```text
/audit-workflow-system-workflow scope=".harmony/orchestration/runtime/workflows/" post_remediation="true" convergence_k="3" seed_list="11,23,37"
```

## Target

The workflow portfolio rooted at `.harmony/orchestration/runtime/workflows/` plus the companion governance, validation, and rubric surfaces required to prove discovery, contract, and operability integrity.

## Prerequisites

- `.harmony/orchestration/governance/workflow-system-audit-v1.yml` exists
- `.harmony/orchestration/runtime/workflows/_ops/scripts/audit-workflow-system.sh` is available
- `.harmony/orchestration/runtime/workflows/manifest.yml` and `registry.yml` are readable
- Companion context and assurance surfaces are readable when included in scope

## Failure Conditions

- Audit contract missing or unreadable -> STOP, report configuration error
- Scope root missing or unreadable -> STOP, report `SCOPE_NOT_FOUND`
- Shared audit engine fails to parse manifest, registry, or workflow frontmatter -> FAIL workflow
- Coverage accounting leaves unaccounted files -> FAIL done-gate
- If `post_remediation=true`, convergence is unstable or blocking findings remain -> FAIL done-gate

## Steps

1. [Build Inventory](./01-build-inventory.md)
2. [Validate Contracts](./02-validate-contracts.md)
3. [Evaluate Workflows](./03-evaluate-workflows.md)
4. [Assess Portfolio](./04-assess-portfolio.md)
5. [Run Scenarios](./05-run-scenarios.md)
6. [Merge and Score](./06-merge-and-score.md)
7. [Report](./07-report.md)
8. [Verify](./08-verify.md)

## Verification Gate

Workflow verification must prove:

- [ ] Findings are deduplicated with stable IDs and objective acceptance criteria
- [ ] Coverage accounting has zero unaccounted files
- [ ] Representative scenario results are recorded
- [ ] Bounded bundle exists at `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
- [ ] Runtime audit plan exists at `.harmony/cognition/runtime/audits/YYYY-MM-DD-<slug>/plan.md`
- [ ] Done-gate expression is evaluated in `validation.md` and `convergence.yml`
- [ ] If `post_remediation=true`, convergence K-run result is stable and empty at/above threshold

## Outputs

- Consolidated report:
  - `.harmony/output/reports/YYYY-MM-DD-audit-workflow-system-workflow.md`
- Authoritative bounded-audit bundle:
  - `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/`
- Runtime audit plan:
  - `.harmony/cognition/runtime/audits/YYYY-MM-DD-<slug>/plan.md`

## Version History

| Version | Date | Changes |
| ------- | ---- | ------- |
| 1.0.0 | 2026-03-06 | Initial bounded workflow-system audit with shared scorer, representative rehearsals, and validator blind-spot detection |

## References

- `.harmony/orchestration/governance/workflow-system-audit-v1.yml`
- `.harmony/orchestration/runtime/workflows/_ops/scripts/audit-workflow-system.sh`
- `.harmony/cognition/practices/methodology/audits/README.md`
- `.harmony/cognition/practices/methodology/audits/findings-contract.md`

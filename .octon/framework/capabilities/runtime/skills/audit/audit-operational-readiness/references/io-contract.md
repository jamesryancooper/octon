---
io:
  inputs:
    - name: scope
      type: folder
      required: true
      description: "Root directory containing operational-readiness artifacts to audit"
    - name: operations_baseline_ref
      type: file
      required: false
      default: ".octon/framework/cognition/practices/methodology/reliability-and-ops.md"
      description: "Primary reliability and operations readiness baseline reference"
    - name: incident_baseline_ref
      type: file
      required: false
      default: ".octon/framework/engine/practices/incident-operations.md"
      description: "Primary incident-response and escalation baseline reference"
    - name: ownership_artifacts_glob
      type: text
      required: false
      default: "**/services/**/SERVICE.md,**/*ownership*.md,**/*owner*.md,**/registry.yml"
      description: "Comma-separated globs selecting service ownership and accountability artifacts"
    - name: runbook_artifacts_glob
      type: text
      required: false
      default: "**/*runbook*.md,**/planning/spec/runbook.md,**/engine/practices/release-runbook.md"
      description: "Comma-separated globs selecting operational runbook and procedures artifacts"
    - name: incident_artifacts_glob
      type: text
      required: false
      default: "**/*incident*.md,**/*on-call*.md,**/*oncall*.md,**/*pager*.md,**/engine/practices/incident-operations.md"
      description: "Comma-separated globs selecting incident-response and escalation artifacts"
    - name: slo_capacity_artifacts_glob
      type: text
      required: false
      default: "**/contracts/slo-budgets.tsv,**/*slo*.md,**/*capacity*.md,**/*reliability*.md"
      description: "Comma-separated globs selecting reliability objective and capacity artifacts"
    - name: evidence_artifacts_glob
      type: text
      required: false
      default: "**/continuity/runs/**/evidence/**,**//.octon/state/evidence/validation/analysis/**"
      description: "Comma-separated globs selecting operational evidence and run-receipt artifacts"
    - name: severity_threshold
      type: text
      required: false
      default: "all"
      description: "Minimum severity to report: critical, high, medium, low, all"
    - name: post_remediation
      type: boolean
      required: false
      default: false
      description: "Enables strict done-gate behavior for convergence verification"
    - name: convergence_k
      type: text
      required: false
      default: "3"
      description: "Number of controlled reruns used for convergence validation"
    - name: seed_list
      type: text
      required: false
      description: "Comma-separated seed list for run-to-run consistency checks"
  outputs:
    - name: operational_readiness_audit_report
      path: "/.octon/state/evidence/validation/analysis/{{date}}-operational-readiness-audit-{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Structured operational-readiness findings report"
    - name: bounded_audit_bundle
      path: "/.octon/state/evidence/validation/audits/{{date}}-{{run_id}}/"
      format: mixed
      determinism: unique
      description: "Authoritative bounded-audit bundle with findings/coverage/convergence artifacts"
    - name: run_log
      path: "/.octon/state/evidence/runs/skills/audit-operational-readiness/{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Execution log for this operational-readiness audit run"
    - name: log_index
      path: "/.octon/state/evidence/runs/skills/audit-operational-readiness/index.yml"
      format: yaml
      determinism: variable
      description: "Index of operational-readiness audit runs with metadata"
---

# I/O Contract

## Required Output Sections

1. Scope and Baseline Summary
2. Coverage Matrix by Layer
3. Findings by Severity (with stable IDs and acceptance criteria in bundle mode)
4. Recommended Fix Batches
5. Coverage Ledger and Unknowns
6. Convergence Receipt and Done-Gate Result

## Authoritative Bundle (Orchestrated Mode)

- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<slug>/bundle.yml`
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<slug>/findings.yml`
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<slug>/coverage.yml`
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<slug>/convergence.yml`
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<slug>/evidence.md`
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<slug>/commands.md`
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<slug>/validation.md`
- `.octon/state/evidence/validation/audits/YYYY-MM-DD-<slug>/inventory.md`

## Evidence Contract

- Every non-trivial finding must cite concrete path-level evidence.
- Coverage claims must account for every discovered in-scope surface as found, clean, or unknown.
- Unsupported claims are downgraded to explicit unknowns.

## Done-Gate Contract

- Discovery mode (`post_remediation=false`): record done-gate value and rationale.
- Post-remediation mode (`post_remediation=true`): require convergence stability and zero open findings at or above threshold across `convergence_k` controlled reruns.

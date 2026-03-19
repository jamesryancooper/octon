---
io:
  inputs:
    - name: scope
      type: folder
      required: true
      description: "Root directory containing service surfaces and observability artifacts to audit"
    - name: observability_contract_ref
      type: file
      required: false
      default: ".octon/framework/cognition/_meta/architecture/observability-requirements.md"
      description: "Optional observability contract reference used for expected signal and policy checks"
    - name: service_manifest_glob
      type: text
      required: false
      default: "**/SERVICE.md"
      description: "Glob pattern used to discover service manifests in scope"
    - name: slo_artifacts_glob
      type: text
      required: false
      default: "**/slo*.yml,**/slo*.yaml,**/slo*.md,**/contracts/slo-budgets.tsv"
      description: "Comma-separated globs selecting SLO and error-budget artifacts"
    - name: alert_artifacts_glob
      type: text
      required: false
      default: "**/*alert*.yml,**/*alert*.yaml,**/*burn-rate*.yml,**/*burn-rate*.yaml"
      description: "Comma-separated globs selecting alert policy artifacts"
    - name: runbook_artifacts_glob
      type: text
      required: false
      default: "**/runbook.md,**/*runbook*.md,**/operations/**/guide.md"
      description: "Comma-separated globs selecting operational runbook artifacts"
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
    - name: observability_coverage_audit_report
      path: "/.octon/state/evidence/validation/analysis/{{date}}-observability-coverage-audit-{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Structured observability coverage findings report"
    - name: bounded_audit_bundle
      path: "/.octon/state/evidence/validation/audits/{{date}}-{{run_id}}/"
      format: mixed
      determinism: unique
      description: "Authoritative bounded-audit bundle with findings/coverage/convergence artifacts"
    - name: run_log
      path: "/.octon/state/evidence/runs/skills/audit-observability-coverage/{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Execution log for this observability coverage audit run"
    - name: log_index
      path: "/.octon/state/evidence/runs/skills/audit-observability-coverage/index.yml"
      format: yaml
      determinism: variable
      description: "Index of observability coverage audit runs with metadata"
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

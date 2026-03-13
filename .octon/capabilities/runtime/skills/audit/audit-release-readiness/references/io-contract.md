---
io:
  inputs:
    - name: scope
      type: folder
      required: true
      description: "Root directory containing release-readiness artifacts to audit"
    - name: release_baseline_ref
      type: file
      required: false
      default: ".octon/cognition/practices/methodology/ci-cd-quality-gates.md"
      description: "Primary release-policy and quality-gate baseline reference"
    - name: operations_baseline_ref
      type: file
      required: false
      default: ".octon/engine/practices/incident-operations.md"
      description: "Primary operations and incident-response readiness baseline reference"
    - name: release_policy_artifacts_glob
      type: text
      required: false
      default: "**/cognition/practices/methodology/ci-cd-quality-gates.md,**/*release*.md,**/*launch*.md"
      description: "Comma-separated globs selecting release policy and criteria artifacts"
    - name: change_control_artifacts_glob
      type: text
      required: false
      default: "**/*change-control*.md,**/*approval*.md,**/orchestration/practices/mission-lifecycle-standards.md"
      description: "Comma-separated globs selecting change-control and approval artifacts"
    - name: deployment_artifacts_glob
      type: text
      required: false
      default: "**/.github/workflows/**,**/services/**/SERVICE.md,**/compatibility.yml"
      description: "Comma-separated globs selecting deployment and compatibility safeguard artifacts"
    - name: rollback_artifacts_glob
      type: text
      required: false
      default: "**/*rollback*.md,**/*contingency*.md,**/engine/practices/incident-operations.md"
      description: "Comma-separated globs selecting rollback and contingency artifacts"
    - name: evidence_artifacts_glob
      type: text
      required: false
      default: "**/continuity/runs/**/evidence/**,**/output/reports/**"
      description: "Comma-separated globs selecting release evidence and run-receipt artifacts"
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
    - name: release_readiness_audit_report
      path: "../../../output/reports/analysis/{{date}}-audit-release-readiness-{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Structured release-readiness findings report"
    - name: bounded_audit_bundle
      path: "../../../output/reports/audits/{{date}}-{{run_id}}/"
      format: mixed
      determinism: unique
      description: "Authoritative bounded-audit bundle with findings/coverage/convergence artifacts"
    - name: run_log
      path: "_ops/state/logs/audit-release-readiness/{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Execution log for this release-readiness audit run"
    - name: log_index
      path: "_ops/state/logs/audit-release-readiness/index.yml"
      format: yaml
      determinism: variable
      description: "Index of release-readiness audit runs with metadata"
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

- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/bundle.yml`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/findings.yml`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/coverage.yml`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/convergence.yml`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/evidence.md`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/commands.md`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/validation.md`
- `.octon/output/reports/audits/YYYY-MM-DD-<slug>/inventory.md`

## Evidence Contract

- Every non-trivial finding must cite concrete path-level evidence.
- Coverage claims must account for every discovered in-scope surface as found, clean, or unknown.
- Unsupported claims are downgraded to explicit unknowns.

## Done-Gate Contract

- Discovery mode (`post_remediation=false`): record done-gate value and rationale.
- Post-remediation mode (`post_remediation=true`): require convergence stability and zero open findings at or above threshold across `convergence_k` controlled reruns.

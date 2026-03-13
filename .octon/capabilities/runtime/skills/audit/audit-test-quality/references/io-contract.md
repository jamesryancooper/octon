---
io:
  inputs:
    - name: scope
      type: folder
      required: true
      description: "Root directory containing test-quality artifacts to audit"
    - name: testing_baseline_ref
      type: file
      required: false
      default: ".octon/assurance/practices/standards/testing-strategy.md"
      description: "Primary testing-strategy baseline reference"
    - name: quality_gate_baseline_ref
      type: file
      required: false
      default: ".octon/cognition/practices/methodology/ci-cd-quality-gates.md"
      description: "Primary quality-gate and release-readiness baseline reference"
    - name: strategy_artifacts_glob
      type: text
      required: false
      default: "**/assurance/practices/standards/testing-strategy.md,**/*test-plan*.md,**/*testing-strategy*.md"
      description: "Comma-separated globs selecting strategy and policy artifacts"
    - name: test_surface_artifacts_glob
      type: text
      required: false
      default: "**/tests/**,**/*test*.py,**/*test*.rs,**/*spec*.md,**/fixtures/**"
      description: "Comma-separated globs selecting executable and documented test surfaces"
    - name: contract_integration_artifacts_glob
      type: text
      required: false
      default: "**/contracts/**,**/compatibility.yml,**/SERVICE.md,**/*integration*.md"
      description: "Comma-separated globs selecting contract and integration assurance artifacts"
    - name: reliability_artifacts_glob
      type: text
      required: false
      default: "**/*determinism*.md,**/*flake*.md,**/*retry*.md,**/.github/workflows/**"
      description: "Comma-separated globs selecting determinism and flake-control artifacts"
    - name: evidence_artifacts_glob
      type: text
      required: false
      default: "**/continuity/runs/**/evidence/**,**/output/reports/**quality**"
      description: "Comma-separated globs selecting quality evidence and run-receipt artifacts"
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
    - name: test_quality_audit_report
      path: "../../../output/reports/analysis/{{date}}-test-quality-audit-{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Structured test-quality findings report"
    - name: bounded_audit_bundle
      path: "../../../output/reports/audits/{{date}}-{{run_id}}/"
      format: mixed
      determinism: unique
      description: "Authoritative bounded-audit bundle with findings/coverage/convergence artifacts"
    - name: run_log
      path: "_ops/state/logs/audit-test-quality/{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Execution log for this test-quality audit run"
    - name: log_index
      path: "_ops/state/logs/audit-test-quality/index.yml"
      format: yaml
      determinism: variable
      description: "Index of test-quality audit runs with metadata"
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

---
io:
  inputs:
    - name: surface_path
      type: text
      required: true
      description: "Repo-relative path under /.harmony/ identifying one durable surface unit"
    - name: surface_kind
      type: text
      required: false
      default: "auto"
      description: "Optional surface kind override: auto, workflow, skill, watcher, automation, service, contract, methodology, other"
    - name: severity_threshold
      type: text
      required: false
      default: "all"
      description: "Minimum severity to report: critical, high, medium, low, all"
    - name: evidence_depth
      type: text
      required: false
      default: "standard"
      description: "Evidence intensity: quick, standard, deep"
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
    - name: surface_architecture_audit_report
      path: "../../../output/reports/{{date}}-surface-architecture-audit-{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Structured surface-architecture findings report"
    - name: bounded_audit_bundle
      path: "../../../output/reports/audits/{{date}}-{{run_id}}/"
      format: mixed
      determinism: unique
      description: "Authoritative bounded-audit bundle with findings/coverage/convergence artifacts"
    - name: run_log
      path: "_ops/state/logs/audit-surface-architecture/{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Execution log for this surface-architecture audit run"
    - name: log_index
      path: "_ops/state/logs/audit-surface-architecture/index.yml"
      format: yaml
      determinism: variable
      description: "Index of surface-architecture audit runs with metadata"
---

# I/O Contract

## Required Output Sections

1. Executive Summary
2. Surface Definition
3. Current Authority Model
4. Surface Needs Analysis
5. Findings by Severity
6. Recommended Target Architecture
7. Acceptance Criteria
8. Keep-As-Is Decisions
9. Non-Goals
10. Coverage Ledger, Unknowns, and Done-Gate Result

## Authoritative Bundle (Orchestrated Mode)

- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/bundle.yml`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/findings.yml`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/coverage.yml`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/convergence.yml`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/evidence.md`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/commands.md`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/validation.md`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/inventory.md`

## Evidence Contract

- Every non-trivial finding must cite concrete path-level evidence.
- Coverage claims must account for every discovered in-scope artifact as
  finding-backed, clean, excluded, or unknown.
- Hidden authority claims must cite the artifact that is acting as incidental
  authority.
- Unsupported claims are downgraded to explicit unknowns.

## Done-Gate Contract

- Discovery mode (`post_remediation=false`): record done-gate value and
  rationale.
- Post-remediation mode (`post_remediation=true`): require convergence stability
  and zero open findings at or above threshold across `convergence_k`
  controlled reruns.

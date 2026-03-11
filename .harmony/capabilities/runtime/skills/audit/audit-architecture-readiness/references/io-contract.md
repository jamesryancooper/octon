---
io:
  inputs:
    - name: target_path
      type: folder
      required: true
      description: "Harmony target path to audit: either .harmony or one top-level bounded-surface domain"
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
    - name: domain_profiles_ref
      type: file
      required: false
      default: ".harmony/cognition/governance/domain-profiles.yml"
      description: "Domain profile registry used for target classification"
    - name: post_remediation
      type: boolean
      required: false
      default: false
      description: "Enable strict done-gate behavior for convergence verification"
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
    - name: architecture_readiness_audit_report
      path: "../../../output/reports/{{date}}-architecture-readiness-audit-{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Structured architecture-readiness findings report"
    - name: architecture_readiness_summary_json
      path: "../../../output/reports/{{date}}-architecture-readiness-audit-{{run_id}}.json"
      format: json
      determinism: unique
      description: "Machine-readable readiness summary validated against the promoted report schema"
    - name: bounded_audit_bundle
      path: "../../../output/reports/audits/{{date}}-{{run_id}}/"
      format: mixed
      determinism: unique
      description: "Authoritative bounded-audit bundle with findings, coverage, convergence, and validation artifacts"
    - name: run_log
      path: "_ops/state/logs/audit-architecture-readiness/{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Execution log for this readiness audit run"
    - name: log_index
      path: "_ops/state/logs/audit-architecture-readiness/index.yml"
      format: yaml
      determinism: variable
      description: "Index of readiness-audit runs with metadata"
---

# I/O Contract

## Required Output Sections

1. Executive verdict
2. Weighted score summary
3. Critical architectural gaps
4. High and medium gaps
5. Failure-mode assessment
6. Design-smell assessment
7. Control-plane vs execution-plane assessment
8. File-level remediation plan
9. Promotion recommendation
10. Final concise judgment

## Authoritative Bundle (Orchestrated Mode)

- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/bundle.yml`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/findings.yml`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/coverage.yml`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/convergence.yml`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/evidence.md`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/commands.md`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/validation.md`
- `.harmony/output/reports/audits/YYYY-MM-DD-<slug>/inventory.md`

## Target Resolution Contract

- If `target_path` is `.harmony`, run in `whole-harness` mode.
- If `target_path` is a top-level bounded-surface domain under `.harmony/`, run in `bounded-domain` mode.
- If `target_path` resolves to any other domain profile or a surface-only path, return `not-applicable`.
- If `target_path` cannot be normalized, escalate.

## Structured Summary Contract

- The summary JSON must validate against `architecture-readiness-report.schema.json`.
- The summary JSON must capture:
  - target profile and evaluation mode
  - final verdict
  - weighted scores
  - hard-gate failures
  - critical gaps
  - next actions

## Evidence Contract

- Every non-trivial claim must include at least one supporting path.
- If a claim cannot be evidenced, it must be downgraded to an explicit unknown.

## Done-Gate Contract

- Discovery mode (`post_remediation=false`): record done-gate decision and rationale.
- Post-remediation mode (`post_remediation=true`): require convergence stability and zero findings at or above threshold across `convergence_k` controlled reruns.

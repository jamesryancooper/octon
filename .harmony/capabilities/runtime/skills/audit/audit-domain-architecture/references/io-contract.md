---
io:
  inputs:
    - name: domain_path
      type: text
      required: true
      description: "Domain root path or canonical .harmony domain target to critique"
    - name: criteria
      type: text
      required: false
      default: "modularity,discoverability,coupling,operability,change-safety,testability"
      description: "Comma-separated evaluation criteria"
    - name: evidence_depth
      type: text
      required: false
      default: "standard"
      description: "Evidence intensity: quick, standard, deep"
    - name: severity_threshold
      type: text
      required: false
      default: "all"
      description: "Minimum severity to report: critical, high, medium, low, all"
    - name: domain_profiles_ref
      type: file
      required: false
      default: ".harmony/cognition/governance/domain-profiles.yml"
      description: "Domain profile registry used for baseline expectations in prospective mode"
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
    - name: critique_report
      path: "../../../output/reports/analysis/{{date}}-domain-architecture-audit-{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Structured independent architecture critique report"
    - name: bounded_audit_bundle
      path: "../../../output/reports/audits/{{date}}-{{run_id}}/"
      format: mixed
      determinism: unique
      description: "Authoritative bounded-audit bundle with findings/coverage/convergence artifacts"
    - name: run_log
      path: "_ops/state/logs/audit-domain-architecture/{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Execution log for this critique run"
    - name: log_index
      path: "_ops/state/logs/audit-domain-architecture/index.yml"
      format: yaml
      determinism: variable
      description: "Index of critique runs with metadata"
---

# I/O Contract

## Required Output Sections

1. Current Surface Map (with file-path evidence)
2. Critical Gaps (impact + risk)
3. Recommended Changes (priority, expected benefit, tradeoff)
4. Keep As-Is decisions (and why)
5. Open Questions / Unknowns

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

- If `domain_path` exists and is readable, run in `observed` mode.
- If `domain_path` is missing but represents a valid `.harmony/<domain>` target, run in `prospective` mode.
- If `domain_path` cannot be normalized as a Harmony target, escalate.

## Evidence Contract

- Every non-trivial claim must include at least one supporting path.
- In prospective mode, claims must cite either comparator-domain paths or profile registry paths.
- If a claim cannot be evidenced, it must be downgraded to an explicit unknown.

## Done-Gate Contract

- Discovery mode (`post_remediation=false`): record done-gate decision and rationale.
- Post-remediation mode (`post_remediation=true`): require convergence stability and zero findings at or above threshold across `convergence_k` controlled reruns.

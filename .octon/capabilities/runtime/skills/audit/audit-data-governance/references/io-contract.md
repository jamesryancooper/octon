---
io:
  inputs:
    - name: scope
      type: folder
      required: true
      description: "Root directory containing data-governance artifacts to audit"
    - name: classification_baseline_ref
      type: file
      required: false
      default: ".octon/assurance/practices/standards/data-handling-and-retention.md"
      description: "Primary data-classification and retention baseline reference"
    - name: privacy_baseline_ref
      type: file
      required: false
      default: ".octon/assurance/practices/standards/security-and-privacy.md"
      description: "Primary privacy and sensitive-data safeguards baseline reference"
    - name: classification_artifacts_glob
      type: text
      required: false
      default: "**/assurance/practices/standards/data-handling-and-retention.md,**/assurance/practices/standards/security-and-privacy.md"
      description: "Comma-separated globs selecting data classification and handling artifacts"
    - name: retention_artifacts_glob
      type: text
      required: false
      default: "**/assurance/practices/standards/data-handling-and-retention.md,**/agency/governance/MEMORY.md,**/continuity/_meta/architecture/runs-retention.md"
      description: "Comma-separated globs selecting retention and deletion policy artifacts"
    - name: lineage_artifacts_glob
      type: text
      required: false
      default: "**/cognition/runtime/knowledge/knowledge.md,**/cognition/_meta/architecture/contracts-registry.md"
      description: "Comma-separated globs selecting lineage, provenance, and contract-traceability artifacts"
    - name: privacy_artifacts_glob
      type: text
      required: false
      default: "**/assurance/practices/standards/security-and-privacy.md,**/services/governance/guard/**"
      description: "Comma-separated globs selecting privacy and sensitive-data safeguard artifacts"
    - name: contract_artifacts_glob
      type: text
      required: false
      default: "**/_meta/architecture/contracts-registry.md,**/services/**/SERVICE.md"
      description: "Comma-separated globs selecting data-contract and interface metadata artifacts"
    - name: evidence_artifacts_glob
      type: text
      required: false
      default: "**/cognition/practices/methodology/spec-first-planning.md,**/services/_meta/docs/platform-overview.md,**/continuity/runs/**/evidence/**"
      description: "Comma-separated globs selecting governance evidence and run-receipt artifacts"
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
    - name: data_governance_audit_report
      path: "../../../output/reports/analysis/{{date}}-data-governance-audit-{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Structured data-governance findings report"
    - name: bounded_audit_bundle
      path: "../../../output/reports/audits/{{date}}-{{run_id}}/"
      format: mixed
      determinism: unique
      description: "Authoritative bounded-audit bundle with findings/coverage/convergence artifacts"
    - name: run_log
      path: "_ops/state/logs/audit-data-governance/{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Execution log for this data-governance audit run"
    - name: log_index
      path: "_ops/state/logs/audit-data-governance/index.yml"
      format: yaml
      determinism: variable
      description: "Index of data-governance audit runs with metadata"
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

---
io:
  inputs:
    - name: scope
      type: folder
      required: true
      description: "Root directory containing security and compliance artifacts to audit"
    - name: policy_baseline_ref
      type: file
      required: false
      default: ".octon/framework/assurance/practices/standards/security-and-privacy.md"
      description: "Primary security-policy baseline reference used for policy intent checks"
    - name: control_baseline_ref
      type: file
      required: false
      default: ".octon/framework/cognition/practices/methodology/security-baseline.md"
      description: "Control baseline reference used for control and gate coverage checks"
    - name: policy_artifacts_glob
      type: text
      required: false
      default: "**/assurance/practices/standards/*.md,**/cognition/governance/principles/security-and-privacy-baseline.md"
      description: "Comma-separated globs selecting policy and principle artifacts"
    - name: secrets_artifacts_glob
      type: text
      required: false
      default: "**/services/governance/guard/**,**/services/governance/vault/**"
      description: "Comma-separated globs selecting secrets and sensitive-data safeguard artifacts"
    - name: access_control_artifacts_glob
      type: text
      required: false
      default: "**/services/governance/policy/**,**/policies/**/*.yml,**/policies/**/*.yaml"
      description: "Comma-separated globs selecting authorization and policy-enforcement artifacts"
    - name: dependency_artifacts_glob
      type: text
      required: false
      default: "**/*sbom*.json,**/*sbom*.md,**/*syft*.json,**/knowledge-plane/**"
      description: "Comma-separated globs selecting dependency and supply-chain evidence artifacts"
    - name: evidence_artifacts_glob
      type: text
      required: false
      default: "**/engine/_meta/evidence/*.md,**/continuity/runs/**/evidence/**"
      description: "Comma-separated globs selecting compliance evidence and run receipts"
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
    - name: security_compliance_audit_report
      path: "/.octon/state/evidence/validation/analysis/{{date}}-security-compliance-audit-{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Structured security and compliance findings report"
    - name: bounded_audit_bundle
      path: "/.octon/state/evidence/validation/audits/{{date}}-{{run_id}}/"
      format: mixed
      determinism: unique
      description: "Authoritative bounded-audit bundle with findings/coverage/convergence artifacts"
    - name: run_log
      path: "/.octon/state/evidence/runs/skills/audit-security-compliance/{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Execution log for this security and compliance audit run"
    - name: log_index
      path: "/.octon/state/evidence/runs/skills/audit-security-compliance/index.yml"
      format: yaml
      determinism: variable
      description: "Index of security and compliance audit runs with metadata"
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

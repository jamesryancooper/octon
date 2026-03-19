---
io:
  inputs:
    - name: scope
      type: folder
      required: true
      description: "Root directory containing API-contract artifacts to audit"
    - name: contract_baseline_ref
      type: file
      required: false
      default: ".octon/framework/cognition/governance/principles/contract-first.md"
      description: "Primary contract-first baseline reference"
    - name: api_design_baseline_ref
      type: file
      required: false
      default: ".octon/framework/scaffolding/governance/patterns/api-design-guidelines.md"
      description: "Primary API-design governance baseline reference"
    - name: spec_artifacts_glob
      type: text
      required: false
      default: "**/contracts/**,**/contract.md,**/openapi*.yaml,**/openapi*.yml,**/schema/**/*.json"
      description: "Comma-separated globs selecting API specifications and contract schema artifacts"
    - name: implementation_artifacts_glob
      type: text
      required: false
      default: "**/service.json,**/SERVICE.md,**/impl/**,**/rust/src/**,**/adapters/**"
      description: "Comma-separated globs selecting implementation artifacts mapped to contracts"
    - name: compatibility_artifacts_glob
      type: text
      required: false
      default: "**/compatibility.yml,**/contracts/invariants.md,**/contracts/errors.yml,**/references/examples.md"
      description: "Comma-separated globs selecting compatibility and invariants artifacts"
    - name: versioning_artifacts_glob
      type: text
      required: false
      default: "**/engine/governance/protocol-versioning.md,**/*version*.md,**/*deprecation*.md,**/contracts-registry.md"
      description: "Comma-separated globs selecting versioning and deprecation artifacts"
    - name: evidence_artifacts_glob
      type: text
      required: false
      default: "**/continuity/runs/**/evidence/**,**//.octon/state/evidence/validation/analysis/**"
      description: "Comma-separated globs selecting API governance evidence and run-receipt artifacts"
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
    - name: api_contract_audit_report
      path: "/.octon/state/evidence/validation/analysis/{{date}}-api-contract-audit-{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Structured API-contract findings report"
    - name: bounded_audit_bundle
      path: "/.octon/state/evidence/validation/audits/{{date}}-{{run_id}}/"
      format: mixed
      determinism: unique
      description: "Authoritative bounded-audit bundle with findings/coverage/convergence artifacts"
    - name: run_log
      path: "/.octon/state/evidence/runs/skills/audit-api-contract/{{run_id}}.md"
      format: markdown
      determinism: unique
      description: "Execution log for this API-contract audit run"
    - name: log_index
      path: "/.octon/state/evidence/runs/skills/audit-api-contract/index.yml"
      format: yaml
      determinism: variable
      description: "Index of API-contract audit runs with metadata"
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

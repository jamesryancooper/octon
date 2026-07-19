---
name: "architecture-readiness-audit"
description: "Orchestrate whole-harness and bounded-domain architecture-readiness audits into a deterministic bounded-audit recommendation with optional supplemental evidence."
steps:
  - id: "configure"
    file: "stages/01-configure.md"
    description: "configure"
  - id: "classify-target"
    file: "stages/02-classify-target.md"
    description: "classify-target"
  - id: "primary-audit"
    file: "stages/03-primary-audit.md"
    description: "primary-audit"
  - id: "cross-subsystem-audit"
    file: "stages/04-cross-subsystem-audit.md"
    description: "cross-subsystem-audit"
  - id: "domain-architecture-audit"
    file: "stages/05-domain-architecture-audit.md"
    description: "domain-architecture-audit"
  - id: "merge"
    file: "stages/06-merge.md"
    description: "merge"
  - id: "report"
    file: "stages/07-report.md"
    description: "report"
  - id: "verify"
    file: "stages/08-verify.md"
    description: "verify"
---

# Architecture Readiness Audit

_Generated README from canonical workflow `architecture-readiness-audit`._

## Usage

```text
/architecture-readiness-audit
```

## Purpose

Orchestrate whole-harness and bounded-domain architecture-readiness audits into a deterministic bounded-audit recommendation with optional supplemental evidence.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/audit/architecture-readiness-audit`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/audit/architecture-readiness-audit/workflow.yml`.

## Parameters

- `target_path` (folder, required=true): Octon target path to audit: either .octon or one top-level bounded-surface domain
- `severity_threshold` (text, required=false), default=`all`: Minimum severity to report: critical, high, medium, low, all
- `run_cross_subsystem` (boolean, required=false), default=`true`: Run audit-cross-subsystem-coherence when the target is whole-harness
- `run_domain_architecture` (boolean, required=false), default=`true`: Run audit-domain-architecture when the target is bounded-domain
- `post_remediation` (boolean, required=false): Enable strict done-gate enforcement for remediation verification
- `convergence_k` (text, required=false), default=`3`: Number of controlled reruns used to evaluate convergence stability
- `seed_list` (text, required=false): Comma-separated deterministic seeds used for multi-run consistency checks

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `architecture_readiness_workflow_report` -> `/.octon/state/evidence/validation/analysis/{{date}}-architecture-readiness-audit.md`: Consolidated architecture-readiness workflow report with recommendation and rationale
- `architecture_readiness_audit_report` -> `/.octon/state/evidence/validation/analysis/{{date}}-architecture-readiness-audit-{{run_id}}.md`: Primary stage report produced by architecture-readiness-audit
- `architecture_readiness_summary_json` -> `/.octon/state/evidence/validation/analysis/{{date}}-architecture-readiness-audit-{{run_id}}.json`: Machine-readable summary produced by architecture-readiness-audit
- `cross_subsystem_audit_report` -> `/.octon/state/evidence/validation/analysis/{{date}}-cross-subsystem-coherence-audit.md`: Cross-subsystem coherence report (produced if enabled and applicable)
- `domain_architecture_audit_report` -> `/.octon/state/evidence/validation/analysis/{{date}}-domain-architecture-audit-{{run_id}}.md`: Supplemental domain-architecture report (produced if enabled and applicable)
- `architecture_readiness_audit_bundle` -> `/.octon/state/evidence/validation/audits/{{date}}-{{slug}}/`: Authoritative bounded-audit bundle for architecture-readiness recommendation and done-gate evidence
- `architecture_readiness_audit_method_selection_record` -> `/.octon/state/evidence/runs/workflows/{{run_id}}/architectural-review/architecture-readiness-audit/routing-decision.yml`: Records the selected review method id (field method bound to naming.yml methods.catalog) and the applied lens profile (field lenses_applied bound to lens-bank.yml) through the architectural-review-routing-decision-v2 artifact in the existing architectural-review run-evidence root; descriptive run evidence only, granting the readiness output no lifecycle, acceptance, promotion, or closeout authority, and leaving the readiness verdict semantics unchanged.

## Steps

1. [configure](./stages/01-configure.md)
2. [classify-target](./stages/02-classify-target.md)
3. [primary-audit](./stages/03-primary-audit.md)
4. [cross-subsystem-audit](./stages/04-cross-subsystem-audit.md)
5. [domain-architecture-audit](./stages/05-domain-architecture-audit.md)
6. [merge](./stages/06-merge.md)
7. [report](./stages/07-report.md)
8. [verify](./stages/08-verify.md)

## Verification Gate

- [ ] Primary audit executes and classifies the target explicitly
- [ ] Supplemental stages execute or skip according to the target mode
- [ ] Consolidated workflow report exists
- [ ] Bounded-audit bundle exists at `.octon/state/evidence/validation/audits/YYYY-MM-DD-<slug>/`
- [ ] Findings are deduplicated with stable IDs and acceptance criteria
- [ ] Coverage and convergence metadata are present
- [ ] Recommendations preserve external tools unmodified and place all required solution changes in Octon-owned supported-interface surfaces
- [ ] Done-gate expression is evaluated and recorded
- [ ] If `post_remediation=true`, done-gate is true

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/audit/architecture-readiness-audit/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/audit/architecture-readiness-audit/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `architecture-readiness-audit` |

---
name: "lifecycle-postmortem"
description: "Run an optional read-only postmortem against a retained lifecycle run after the run has reached an inspectable terminal, blocked, cancelled, or rollback state. The workflow reconstructs evidence from retained control and evidence roots, prepares a compact readiness summary and lifecycle-postmortem evaluator input, materializes optional review findings as evidence, and reports the evaluator judgment without mutating lifecycle authority."
steps:
  - id: "bind-evidence"
    file: "stages/01-bind-evidence.md"
    description: "bind-evidence"
  - id: "invoke-evaluator"
    file: "stages/02-invoke-evaluator.md"
    description: "invoke-evaluator"
  - id: "materialize-findings"
    file: "stages/03-materialize-findings.md"
    description: "materialize-findings"
  - id: "final-report"
    file: "stages/04-final-report.md"
    description: "final-report"
---

# Lifecycle Postmortem

_Generated README from canonical workflow `lifecycle-postmortem`._

## Usage

```text
/lifecycle-postmortem
```

## Purpose

Run an optional read-only postmortem against a retained lifecycle run after the run has reached an inspectable terminal, blocked, cancelled, or rollback state. The workflow reconstructs evidence from retained control and evidence roots, prepares a compact readiness summary and lifecycle-postmortem evaluator input, materializes optional review findings as evidence, and reports the evaluator judgment without mutating lifecycle authority.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/meta/lifecycle-postmortem`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/meta/lifecycle-postmortem/workflow.yml`.

## Parameters

- `run_id` (text, required=true): Retained lifecycle run id to inspect.
- `report_path` (file, required=false): Optional evaluator-authored Markdown report to validate and retain.
- `structured_output_path` (file, required=false): Optional evaluator-authored structured postmortem output to validate and retain.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `evidence_map` -> `.octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/evidence-map.yml`
- `evaluator_input` -> `.octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/evaluator-input.md`
- `readiness_summary` -> `.octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/readiness-summary.md`
- `structured_output` -> `.octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/evaluation.yml`
- `report` -> `.octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/report.md`
- `finding_records` -> `.octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/review-findings.ndjson`

## Steps

1. [bind-evidence](./stages/01-bind-evidence.md)
2. [invoke-evaluator](./stages/02-invoke-evaluator.md)
3. [materialize-findings](./stages/03-materialize-findings.md)
4. [final-report](./stages/04-final-report.md)

## Verification Gate

- [ ] id: run-id-bound
- [ ] description: The run id is non-empty and sanitized before any retained evidence path is created.
- [ ] id: retained-evidence-only
- [ ] description: The workflow writes only under the run postmortem assurance evidence root.
- [ ] id: no-lifecycle-authority-mutation
- [ ] description: The workflow does not mutate run manifests, lifecycle journals, runtime state, rollback posture, proposal manifests, support targets, generated outputs, or authority artifacts.
- [ ] id: evidence-gaps-explicit
- [ ] description: Missing retained refs are recorded as known limits or blockers instead of inferred facts.
- [ ] id: locator-bound-as-discovery-only
- [ ] description: Retained-run evidence index locator refs, when present, are bound as discovery and replay aids only and never as transition, closeout, child-receipt, generated-output, proposal-input, or policy authority.
- [ ] id: substitutes-validated-before-use
- [ ] description: Missing direct control refs are paired only with resolving retained workflow substitutes; unresolved substitutes, stale digests, and authority claims fail validation.
- [ ] id: readiness-summary-derived-only
- [ ] description: The readiness summary is derived from evidence-map.yml and known-limits.yml, names direct refs, substitutes, terminal validation refs, terminal rollback refs, known limits, and the non-authority boundary without replacing source evidence.
- [ ] id: postmortem-output-validated
- [ ] description: Any supplied evaluator report or structured output passes the lifecycle-postmortem validator before being treated as usable evidence.
- [ ] id: proposal-program-delivery-threshold-bound
- [ ] description: Proposal-program delivery postmortems required by repeated blocker, recovery, or long-run thresholds bind evaluation.yml, report.md, readiness-summary.md, evidence-map.yml, and digest-bound retained evidence refs before learned-from completion claims.
- [ ] id: full-postmortem-contract-complete
- [ ] description: Any supplied evaluator report and structured output preserve the full eighteen-section rigorous postmortem contract.

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/meta/lifecycle-postmortem/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/meta/lifecycle-postmortem/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `lifecycle-postmortem` |

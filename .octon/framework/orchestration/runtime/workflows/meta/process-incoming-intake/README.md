---
name: "process-incoming-intake"
description: "Classify and dispose an Octon intake unit staged under additive `.incoming` as a normalized additive extension, a core Octon skill, or a blocked/proposal-required input without letting raw intake become authority."
steps:
  - id: "validate-intake"
    file: "stages/01-validate-intake.md"
    description: "validate-intake"
  - id: "classify-route"
    file: "stages/02-classify-route.md"
    description: "classify-route"
  - id: "execute-disposition"
    file: "stages/03-execute-disposition.md"
    description: "execute-disposition"
  - id: "validate-closeout"
    file: "stages/04-validate-closeout.md"
    description: "validate-closeout"
---

# Process Incoming Intake

_Generated README from canonical workflow `process-incoming-intake`._

## Usage

```text
/process-incoming-intake
```

## Purpose

Classify and dispose an Octon intake unit staged under additive `.incoming` as a normalized additive extension, a core Octon skill, or a blocked/proposal-required input without letting raw intake become authority.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/meta/process-incoming-intake`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/meta/process-incoming-intake/workflow.yml`.

## Parameters

- `intake_id` (text, required=true): Incoming intake id under `.octon/inputs/additive/.incoming/<intake-id>/`
- `requested_route` (text, required=false): Optional route hint; final classification must still be proven by the decision matrix
- `stop_after_classification` (boolean, required=false): Stop after writing the classification receipt without applying disposition

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `incoming_intake_decision` -> `/.octon/state/evidence/runs/workflows/{{date}}-process-incoming-intake-{{intake_id}}/decision.md`: Route decision, rejected routes, provenance/trust findings, and selected disposition
- `incoming_intake_validation` -> `/.octon/state/evidence/runs/workflows/{{date}}-process-incoming-intake-{{intake_id}}/validation.md`: Route-specific validation commands, outcomes, and cleanup evidence

## Steps

1. [validate-intake](./stages/01-validate-intake.md)
2. [classify-route](./stages/02-classify-route.md)
3. [execute-disposition](./stages/03-execute-disposition.md)
4. [validate-closeout](./stages/04-validate-closeout.md)

## Verification Gate

- [ ] incoming path is `.octon/inputs/additive/.incoming/<intake-id>/`
- [ ] validate-incoming-intake-unit.sh passes and its deterministic inventory is preserved in workflow evidence
- [ ] root `.archive/**`, Downloads paths, generated outputs, and host-specific skill directories are not used as staging
- [ ] one and only one route is selected from additive extension, core Octon skill, or blocked/proposal-required
- [ ] route decision evidence records criteria, rejected routes, provenance, trust posture, and compatibility findings
- [ ] additive extension route normalizes into `inputs/additive/extensions/<extension-pack-id>/` and uses existing extension publication flows
- [ ] core skill route installs only into `framework/capabilities/runtime/skills/**` and uses existing skill validation and projection flows
- [ ] blocked route performs no install, activation, publication, projection, or runtime exposure
- [ ] final disposition leaves no `.incoming/<intake-id>/` copy; only `stop_after_classification=true` may leave raw intake in place
- [ ] archive retention is safe, justified, and evidenced; unsafe retained material uses evidence-only pointers
- [ ] route-specific validation commands pass or documented blockers stop the workflow fail-closed

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/meta/process-incoming-intake/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/meta/process-incoming-intake/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `process-incoming-intake` |

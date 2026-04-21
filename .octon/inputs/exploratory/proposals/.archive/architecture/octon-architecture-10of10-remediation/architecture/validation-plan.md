# Validation Plan

## Deterministic validators

| Validator | Fails when |
|---|---|
| `validate-architecture-contract-registry.sh` | Registry is missing paths, duplicates canonical owners, or generated docs drift. |
| `validate-generated-non-authority.sh` | Runtime/policy/authority code consumes `generated/cognition/**` or summaries as source of truth. |
| `validate-input-non-authority.sh` | Runtime/policy code reads `inputs/**` or proposal files directly. |
| `validate-overlay-points.sh` | Overlay artifacts are undeclared, disabled, or use invalid merge modes. |
| `validate-authorization-boundary-coverage.sh` | Material side-effect path lacks `authorize_execution` coverage or bypass negative tests. |
| `validate-evidence-completeness.sh` | Required run/control/lab/publication/disclosure evidence is missing or unclassified. |
| `validate-promotion-receipts.sh` | Artifact moves from `inputs/**` or `generated/**` to authority/control/effective without receipt. |
| `validate-support-target-proofing.sh` | Admitted support tuple lacks proof bundle, scenario, denial case, or disclosure. |
| `validate-operator-read-models.sh` | Generated operator view contains untraceable or stale fields. |
| `validate-runtime-docs-consistency.sh` | Runtime docs/specs disagree with implemented CLI/spec/registry surfaces. |

## Runtime coverage checks

The authorization coverage validator must inspect service invocation paths, workflow-stage execution paths, executor launch paths, repo mutation paths, publication paths, protected CI paths, host/model adapter projections, network egress, model-backed execution, and control-plane mutation paths.

For each path, validation must retain path id, caller path, action type, side-effect classification, authorization binding, evidence binding, negative bypass test result, and denial reason fixture.

## Support-target proof validation

Each admitted tuple must include support-target admission record, support dossier, conformance criteria mapping, live scenario evidence, denied unsupported scenario evidence, evidence completeness check, RunCard/HarnessCard disclosure, and final support envelope statement.

## Evidence completeness validation

A consequential run cannot close unless the validator can assemble run contract, GrantBundle or denial/stage/escalation artifact, execution receipts, runtime events, checkpoints, rollback posture, trace pointers, replay pointers or reason absent, interventions disclosure, verification evidence, RunCard, and closeout record.

## Generated-authority boundary validation

Validation must prove `generated/**` is never treated as canonical authority; `generated/effective/**` is consumed only when freshness locks and publication receipts exist; `generated/cognition/**` is read-model only; the generated proposal registry is discovery-only; and host projections are mirrors only.

## Runtime/docs consistency validation

Runtime docs must match CLI subcommands, runtime spec contracts, release target declarations, support-target posture, run lifecycle states, evidence-store obligations, and operator-read-model contracts.

## Operator-view consistency validation

Every operator view field must include source trace metadata. Any field derived from stale, missing, or forbidden source material fails validation.

## Closure validation

Closure requires all validators passing, all required evidence retained, all decision records present, all mandatory file changes promoted, this proposal archived, and no active runtime/policy dependency on the archived proposal.

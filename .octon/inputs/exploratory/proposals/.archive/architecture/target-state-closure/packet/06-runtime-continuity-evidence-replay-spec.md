# 06. Runtime, Continuity, Evidence, and Replay Spec

## 1. Goal

Make every consequential run resumable, auditable, replayable, and claim-calibrated without depending on fragile chat continuity.

## 2. Preserve the current run-first model

Keep as canonical:

- `state/control/execution/runs/<run-id>/`
- `state/continuity/runs/<run-id>/`
- `state/evidence/runs/<run-id>/`
- `state/evidence/disclosure/runs/<run-id>/`

## 3. Mandatory per-run artifact set

### Control root
Required inside `state/control/execution/runs/<run-id>/`:
- `run-contract.yml`
- `run-manifest.yml`
- `runtime-state.yml`
- `rollback-posture.yml`
- `stage-attempts/**`
- `checkpoints/**`

### Continuity root
Required inside `state/continuity/runs/<run-id>/`:
- `continuity.yml`

### Evidence root
Required inside `state/evidence/runs/<run-id>/`:
- `retained-run-evidence.yml`
- `evidence-classification.yml`
- `measurements/summary.yml`
- `measurements/records/**`
- `interventions/log.yml`
- `interventions/records/**`
- `assurance/{structural,functional,behavioral,governance,maintainability,recovery,evaluator}.yml`
- `replay/manifest.yml`
- `external-index/*.yml` when class-C evidence exists

## 4. Runtime lifecycle

Canonical lifecycle states:
- `drafted`
- `routed`
- `granted`
- `prepared`
- `running`
- `paused`
- `verifying`
- `compensating`
- `revoked`
- `closed_success`
- `closed_failure`

Each transition emits a runtime bus event and is reflected in `runtime-state.yml`.

## 5. Checkpoint / resume model

- checkpoint before every material stage boundary
- checkpoint before any approval-dependent branch
- checkpoint before reset / compaction
- checkpoint before broad replay or test fanout if state mutation has occurred

Resume requires:
- run contract
- latest checkpoint
- continuity artifact
- replay manifest
- authoritative repo state

Resume must not require conversational history.

## 6. Compaction / reset / contamination

### Contamination signals
At minimum detect:
- stale generated/effective state used as truth
- repeated contradictory tool outputs
- repeated route inconsistency across artifacts
- schema-output degradation
- unsupported adapter behavior
- context overflow or compression failure

### Actions
- `soft_compaction`
- `hard_reset_from_checkpoint`
- `discard_attempt_and_rebind`

### Required artifacts
- `state/control/execution/runs/<run-id>/contamination/state.yml`
- contamination event in runtime bus
- contamination summary in measurements and recovery proof

## 7. Retry classes

Canonical retry classes:
- `none`
- `local_repair`
- `bounded_retry`
- `rebind_and_retry`
- `approval_blocked`
- `contamination_reset`

Retry class is declared in the run contract and recorded in runtime-state transitions.

## 8. Rollback / compensation posture

Every consequential run must have `rollback-posture.yml` with:
- `rollback_class`
- `compensation_strategy`
- `fallback_route`
- `human_escalation_boundary`
- `verification_requirements`

Runs without material effect may declare `no_material_effect`.

## 9. Evidence classes

### Class A — Git-inline control-plane evidence
Examples:
- approvals
- grants
- leases
- revocations
- decisions
- receipts
- instruction manifests

### Class B — Git-tracked manifests/pointers
Examples:
- retained-run-evidence
- run manifest
- replay manifest
- measurement summary
- intervention summary
- closure bundle manifest

### Class C — External immutable replay / telemetry
Examples:
- verbose telemetry
- screenshots
- videos
- large trace payloads
- browser/HAR exports
- external replay blobs

## 10. Evidence-classification v2

Create:
- `.octon/framework/constitution/contracts/retention/evidence-classification-v2.schema.json`

Preserve path:
- `.octon/state/evidence/runs/<run-id>/evidence-classification.yml`

Required fields:
- `schema_version`
- `run_id`
- `generated_at`
- `class_a`
- `class_b`
- `class_c`
- `coverage_status`
- `retention_policy_ref`
- `external_index_ref`
- `missing_artifacts`
- `notes`

Rule:
- claim-bearing exemplar runs must not have an empty classification
- `missing_artifacts` must be empty for closure-admitted proof-bundle runs

## 11. External replay index

Preserve:
- `state/evidence/runs/<run-id>/replay/manifest.yml`

Create or require:
- `state/evidence/external-index/<run-id>.yml`

Required fields:
- `object_uri`
- `content_digest`
- `storage_class`
- `retention_window`
- `producer`
- `generated_at`

## 12. Generators / validators

Create:
- `backfill-evidence-classification.sh`
- `validate-evidence-classification-schema.sh`
- `validate-evidence-classification-nonempty.sh`
- `validate-external-replay-index.sh`
- `validate-run-bundle-completeness.sh`
- `generate-measurement-summary.sh`
- `generate-intervention-log.sh`

## 13. Migration

1. add evidence-classification v2
2. backfill all active proof-bundle exemplar runs
3. regenerate measurement summaries from records
4. regenerate intervention summaries/logs from records
5. validate replay and external-index integrity
6. fail closure generation if any active exemplar bundle is incomplete or contradictory

## 14. Acceptance criteria

- every active proof-bundle exemplar run has non-empty, valid evidence classification
- run bundle completeness validator passes for every active exemplar
- measurement summaries and intervention logs are generated from underlying records
- replay manifests and external indexes are present wherever required
- resume works from checkpoint + authoritative roots without chat continuity

# Runtime, Continuity, and Evidence Model

## Runtime thesis
Runtime is lifecycle-managed and run-rooted, not conversation-rooted.

## Canonical lifecycle
1. trigger
2. run contract drafted
3. route evaluation
4. grant / stage / deny / escalate
5. run manifest/runtime state bound
6. execution attempt(s) and stage(s)
7. checkpoints
8. assurance
9. closeout and RunCard
10. continuity update and replay indexing

## Mission vs run
- mission-backed runs are mandatory for recurring, scheduled, overlapping, or long-horizon autonomy
- run-only autonomy is legal only for support-target tiers that explicitly allow it
- no silent fallback from mission-required work to missionless execution

## Checkpoint / resume
- checkpoints before material side effects, before approvals, before resets, and at stage boundaries
- resume from checkpoint + authoritative surfaces only
- no dependency on fragile chat continuity

## Contamination handling
- compaction allowed only from a valid checkpoint and clean contamination state
- hard reset required on contamination signatures
- contamination evidence is logged and benchmarked

## Retry classes
- deterministic retry
- re-plan retry
- approval-blocked retry
- recovery retry
- contamination-reset retry

## Rollback / compensation posture
Each material run and material stage declares one of:
- rollback required
- compensation required
- no material effect

## Evidence classes
### Class A — Git-inline
charters, approvals, decisions, support targets, selected RunCards, HarnessCards, benchmark summaries

### Class B — Git pointers/manifests
replay manifests, assurance summaries, external artifact indices, measurement summaries

### Class C — external immutable
raw model I/O, browser artifacts, HAR files, screenshots, videos, large traces, high-frequency telemetry

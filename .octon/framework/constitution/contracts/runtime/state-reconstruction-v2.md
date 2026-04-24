# State Reconstruction v2

`runtime-state.yml` is a mutable derived view over the canonical append-only
Run Journal and bounded side artifacts. It is not an independent authority
surface. If reconstructed state conflicts with `runtime-state.yml`, the journal
wins and the mismatch becomes a drift incident.

## Canonical Inputs

The reconstruction set is:

1. `events.ndjson`
2. `events.manifest.yml`
3. bounded side artifacts referenced from canonical events
4. the bound `run-manifest.yml`
5. the bound `run-contract.yml`

Side artifacts remain bounded. They may provide typed payload detail, but they
do not replace the journal as the sequencing and causality source of truth.

## Canonicalization Rule

The canonical event family is the hyphenated `run-event-v2` family. During
migration, engine-local dot-named `runtime-event-v1` events may appear in
ingress or compatibility layers, but they must be normalized before they are
used for canonical ledger validation, replay, or closeout snapshots.

| Legacy runtime-event-v1 | Canonical run-event-v2 | Mapping rule |
|---|---|---|
| `run.started` | `run-created` or `run-bound` | Use `run-created` for initial run identity creation; use `run-bound` once the bound run root becomes authoritative. |
| `run.context_pack_requested` | `context-pack-requested` | Preserve the requested context policy and run binding. |
| `run.context_pack_built` | `context-pack-built` | Preserve the context pack, receipt, and model-visible context refs. |
| `run.context_pack_bound` | `context-pack-bound` | Preserve the bound context pack ref. |
| `run.context_pack_rejected` | `context-pack-rejected` | Preserve the denial reason and failed context evidence refs. |
| `run.context_pack_compacted` | `context-pack-compacted` | Preserve the compaction ref and model-visible context hash. |
| `run.context_pack_invalidated` | `context-pack-invalidated` | Preserve the invalidation reason and stale context evidence refs. |
| `run.context_pack_rebuilt` | `context-pack-rebuilt` | Preserve the rebuild ref, prior pack ref, and rebuilt pack ref. |
| `run.grant_issued` | `authority-granted` | Preserve policy, grant-bundle, and support-target refs. |
| `run.grant_denied` | `authority-denied` | Preserve denial reason and governing policy refs. |
| `approval.requested` | `approval-requested` | Preserve approval target and request refs. |
| `approval.resolved` | `approval-granted` or `approval-denied` | Choose by resolved decision outcome. |
| `capability.invoked` | `capability-invoked` | Preserve capability request, authorization, and invocation refs when available. |
| `checkpoint.created` | `checkpoint-created` | Preserve checkpoint side-artifact refs. |
| `evidence.persisted` | `evidence-snapshot-created` | Preserve evidence snapshot and manifest refs. |
| `replay.available` | `replay-materialized` | Preserve replay manifest or pointer refs. |
| `rollback.started` | `rollback-started` | Preserve rollback posture or plan refs. |
| `rollback.completed` | `rollback-completed` | Preserve rollback completion evidence refs. |
| `intervention.recorded` | `operator-intervention-recorded` | Preserve intervention actor and disclosure refs. |
| `disclosure.ready` | `run-card-published` or `disclosure-published` | Use `run-card-published` for RunCard materialization; otherwise use `disclosure-published`. |
| `run.closed` | `run-closed` | Preserve closure evidence and final state refs. |

## Reconstruction Algorithm

1. Load `events.manifest.yml` and verify the declared schema refs point to
   `run-event-v2.schema.json`, `run-event-ledger-v2.schema.json`,
   `runtime-state-v2.schema.json`, and this reconstruction contract.
2. Read `events.ndjson` in ascending `sequence` order.
3. Fail closed if any event is missing a required hash, actor, lifecycle, or
   governing run binding.
4. Verify sequence monotonicity and verify each `previous_event_hash` links to
   the prior event's `event_hash`.
5. Canonicalize any legacy dot-named event aliases before applying transition
   semantics.
6. Resolve typed payload side artifacts only through explicit `artifact_ref`
   pointers recorded in the event envelope.
7. Apply journal events to an in-memory reconstruction state using:
   - `run-created` and `run-bound` for run identity and initial binding
   - authority, approval, lease, and revocation events for execution posture
   - stage, attempt, checkpoint, rollback, and recovery events for lifecycle
   - validator, assurance, evidence, and disclosure events for closeout and
     derived-view status
   - drift events for repair posture and operator-visible inconsistency state
8. Materialize `runtime-state.yml` from the last admissible event and record:
   - final `state`
   - `last_applied_event_id`
   - `last_applied_sequence`
   - `last_applied_event_hash`
   - `drift_status`
9. Emit `drift-detected` when:
   - the journal and mutable state view disagree,
   - a referenced side artifact is missing,
   - alias canonicalization cannot be performed deterministically, or
   - the ledger manifest and journal contents disagree.

## Conflict Rule

The canonical ledger always wins over mutable views, generated summaries, and
continuity notes.

- `runtime-state.yml` may lag and be rematerialized.
- generated operator views are non-authoritative and must not be used to repair
  control truth
- continuity and handoff material may assist resumption but may not override
  journal facts
- proposal packets and human notes remain lineage only

## Replay Rule

Replay reconstructs from the canonicalized journal plus bounded side artifacts.
Replay must validate the hash chain before reconstruction, and default replay
must remain dry-run or sandboxed for side-effecting paths. Any live side-effect
replay requires a fresh authorization route rather than inherited trust from
historical events.

## Redaction Rule

Redaction is legal only for derived views or retained evidence mirrors. The
canonical control journal remains append-only and lineage-preserving. If a view
omits sensitive fields, the omission must be justified by a redaction record
that preserves source event identity, field-level scope, and audit linkage.

## Explicitly Non-Canonical Inputs

The following must never participate as reconstruction authority:

- chat transcripts
- operator memory
- host UI state
- generated summaries
- proposal packets under `inputs/**`

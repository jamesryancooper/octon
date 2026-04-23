# Runtime Implementation Notes

## Event append algorithm

1. Receive runtime command or observed transition.
2. Resolve run root and current ledger manifest.
3. Validate actor identity and authority to append this event type.
4. Validate lifecycle transition from last applied event/state.
5. Validate governing refs: grant, policy receipt, approval, lease, rollback,
   support-target tuple, context pack, or validator result as required.
6. Compute payload hash and event hash.
7. Append event atomically to `events.ndjson`.
8. Update `events.manifest.yml` atomically.
9. Materialize `runtime-state.yml` as derived view.
10. Emit telemetry mirror without authority.

## Suggested v2 event envelope fields

```yaml
schema_version: run-event-v2
run_id: <run-id>
event_id: <event-id>
sequence: 42
event_type: capability-invoked
recorded_at: 2026-04-23T00:00:00Z
actor:
  actor_class: runtime|operator|model-adapter|capability-adapter|authority-engine|policy-engine|validator|replay-store
  actor_ref: <ref>
causal_parent_event_ids: []
idempotency_key: <stable-key>
lifecycle:
  state_before: authorized
  state_after: running
governing_refs:
  execution_request_ref: <ref>
  grant_ref: <ref>
  policy_receipt_ref: <ref>
  support_target_tuple_ref: <ref>
  rollback_plan_ref: <ref>
  context_pack_ref: <ref>
  capability_lease_ref: <ref>
effect:
  effect_class: observe|read|write|mutate|external-side-effect|rollback|recovery|disclosure
  reversibility_class: reversible|compensable|irreversible|none
  evidence_class: required|optional|none
payload_ref: <side-artifact-ref>
payload_hash: sha256:<hash>
redaction:
  redacted: false
previous_event_hash: sha256:<previous>
event_hash: sha256:<current>
```

## Runtime-state materialization

`runtime-state.yml` should include:

- `schema_version: runtime-state-v2`,
- `run_id`,
- `state`,
- `source_ledger_ref`,
- `last_applied_event_id`,
- `last_applied_sequence`,
- `last_applied_event_hash`,
- `materialized_at`,
- `materialized_by`,
- `drift_status`,
- `drift_ref` when applicable.

## Replay store behavior

Replay must:

- read the journal in sequence order,
- validate hash chain before reconstruction,
- load side artifacts by ref,
- reconstruct runtime-state,
- mark missing side artifacts as replay gaps,
- default to dry-run/simulation for side-effecting actions,
- require a fresh `authorize_execution` request for live replay effects.

## Runtime bus behavior

`runtime_bus` should be the only writer of canonical journal events. Other crates
submit commands or append requests; they do not write `events.ndjson` directly.

## Compatibility

During migration, engine-local dot events can be normalized:

| Legacy runtime-event | Canonical run-event |
|---|---|
| `run.started` | `run-created` or `run-bound` according to payload. |
| `run.context_pack_bound` | `context-pack-bound` |
| `run.grant_issued` | `authority-granted` |
| `approval.requested` | `approval-requested` |
| `approval.granted` | `approval-granted` |
| `capability.invoked` | `capability-invoked` |
| `checkpoint.created` | `checkpoint-created` |
| `rollback.completed` | `rollback-completed` |
| `run.closed` | `run-closed` |

The alias map should be temporary compatibility, not a permanent dual standard.

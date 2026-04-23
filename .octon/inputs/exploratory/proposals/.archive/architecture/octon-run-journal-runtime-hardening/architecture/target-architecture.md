# Target Architecture: Canonical Run Journal Runtime Hardening

## Purpose

Implement the single highest-leverage next step for Octon's Constitutional
Engineering Harness and Governed Agent Runtime: make Octon's existing canonical
run event ledger mechanically sufficient to drive lifecycle, replay, operator
visibility, evidence closeout, state reconstruction, validator conformance, and
support-target admission.

The target is not a greenfield event-sourcing system. Octon already has runtime
constitutional contracts for run event ledgers and state reconstruction. The
target is to align and harden those existing surfaces across the runtime engine.

## Target invariant

For every consequential Run:

> A Run is authoritative to the Governed Agent Runtime only through its bound
> control root, canonical append-only Run Journal, derived runtime-state view,
> retained evidence root, and authorization/receipt artifacts admitted by the
> Constitutional Engineering Harness.

## Canonical Run Journal shape

Promote the current run event ledger model to `run-event-ledger-v2` and
`run-event-v2` with these properties:

1. **Append-only** — existing events are not rewritten or deleted.
2. **Typed** — every event has a canonical type and a typed payload contract or
   explicit typed side-artifact reference.
3. **Causal** — events carry sequence number, causal parent refs, command refs,
   and governing artifact refs.
4. **Hash-linked** — each event records previous event hash and current event hash
   to detect tampering, truncation, and insertion.
5. **Actor-bound** — every event records actor class and actor ref: runtime,
   model adapter, capability adapter, operator, validator, replay service,
   policy engine, or authority engine.
6. **Authority-aware** — events that mutate, authorize, approve, deny, revoke, or
   close a Run must reference the applicable GrantBundle, policy receipt,
   approval, lease, rollback, support-target tuple, or validator result.
7. **Replay-safe** — event payloads must distinguish observation, command,
   requested action, authorized action, committed effect, retained evidence, and
   generated disclosure.
8. **Redaction-aware** — sensitive evidence may be redacted in views only through
   redaction records that preserve lineage and auditability.

## Control-root layout

The promoted control layout remains under Octon's existing class boundaries:

```text
.octon/state/control/execution/runs/<run-id>/
  run-manifest.yml
  run-contract.yml
  events.ndjson
  events.manifest.yml
  runtime-state.yml
  rollback-posture.yml
  approvals/
  leases/
  checkpoints/
  drift/
```

### Control surface roles

| File/surface | Role | Authority status |
|---|---|---|
| `events.ndjson` | Canonical append-only Run Journal. | Control truth. |
| `events.manifest.yml` | Ledger integrity, schema, count, hashes, first/last refs. | Control truth. |
| `runtime-state.yml` | Current state view derived from journal. | Mutable derived control view; journal wins on conflict. |
| `run-manifest.yml` | Run identity, roots, support-target tuple, initial refs. | Control truth once bound. |
| `run-contract.yml` | Run objective, risk, role, context, and closure contract. | Control truth once bound. |
| `rollback-posture.yml` | Rollback/compensation posture. | Control truth. |

## Evidence-root layout

Retained evidence remains separate:

```text
.octon/state/evidence/runs/<run-id>/
  run-journal/
    events.snapshot.ndjson
    events.manifest.snapshot.yml
    redactions.yml
  authority/
  context/
  capability-invocations/
  replay/
  assurance/
  operator-disclosure/
  closeout.yml
```

The evidence copy is not the live control source. It is retained closeout,
replay, disclosure, audit, and lab material. The live journal under
`state/control` wins during active execution; closeout requires evidence snapshot
hashes that match the control ledger at closure.

## Runtime-state derivation

`runtime-state.yml` is no longer a parallel source of truth. It is a materialized
view over the Run Journal plus bounded side artifacts. If `runtime-state.yml`
conflicts with `events.ndjson`, the ledger wins and the mismatch is a drift
incident requiring a `drift-detected` event and validator evidence.

## Event family

The canonical event family should use one canonical naming style. The packet
recommends preserving the constitutional hyphenated event family and mapping
engine-local dot-named legacy events as aliases during migration.

Minimum canonical event families:

- run: `run-created`, `run-bound`, `run-closed`
- context: `context-pack-bound`, `context-pack-invalidated`, `context-reset-recorded`
- authority: `authority-requested`, `authority-granted`, `authority-denied`
- approval: `approval-requested`, `approval-granted`, `approval-denied`, `approval-expired`
- lease: `lease-issued`, `lease-revoked`, `lease-expired`
- capability: `capability-requested`, `capability-authorized`, `capability-invoked`, `capability-completed`, `capability-failed`
- lifecycle: `stage-started`, `stage-completed`, `attempt-started`, `attempt-completed`, `checkpoint-created`
- rollback/recovery: `rollback-requested`, `rollback-started`, `rollback-completed`, `recovery-started`, `recovery-completed`
- operator: `operator-intervention-recorded`, `operator-digest-published`
- assurance: `validator-started`, `validator-completed`, `assurance-failed`
- evidence/disclosure: `evidence-snapshot-created`, `run-card-published`, `disclosure-published`
- drift: `drift-detected`, `drift-repaired`

## Command/event separation

The runtime must distinguish:

1. requested command,
2. authorization decision,
3. dispatched work,
4. observation received,
5. effect committed,
6. evidence retained,
7. derived view materialized.

A model message or operator request is not itself an event that mutates runtime
state. The Governed Agent Runtime appends canonical events only through the
runtime bus after policy, authorization, support-target, rollback, and evidence
requirements are satisfied.

## Runtime crate responsibilities

| Runtime surface | Required responsibility |
|---|---|
| `runtime_bus` | Sole journal append path; validates event schema, sequence, hash, actor, refs, and transition admissibility. |
| `authority_engine` | Emits authority-requested/granted/denied events and rejects material actions without journal refs. |
| `policy_engine` | Supplies policy receipt refs and denial/escalation reasons. |
| `replay_store` | Reconstructs state from journal and side artifacts; never replays live side effects by default. |
| `telemetry_sink` | Mirrors event-derived telemetry without becoming authority. |
| `capability adapters` | Emit requested/authorized/invoked/completed event pairs through runtime bus. |
| `assurance_tools` | Validate journal integrity, lifecycle admissibility, evidence completeness, and generated-view non-authority. |

## Operator and generated views

Operator views and generated projections may summarize Runs only by referencing
canonical journal/evidence roots. They must record source refs, freshness, and
non-authority classification. They must not be accepted by authorization,
support-target validation, policy validation, or runtime state reconstruction as
truth.

## Support-target impact

This target does not widen support. It makes current and staged support claims
more realistic by requiring any supported host/model/capability tuple to produce
valid Run Journals before being admitted.

## Promotion result

After promotion, Octon should be able to say:

> Every supported consequential Run can be reconstructed, inspected, replayed in
> dry-run/sandbox form, validated against policy, and closed with evidence from a
> canonical append-only journal whose mutable state and generated views are
> derived rather than authoritative.

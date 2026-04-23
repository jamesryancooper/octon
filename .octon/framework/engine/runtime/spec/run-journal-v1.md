# Run Journal v1

This contract defines the engine-facing behavior for Octon's canonical
append-only Run Journal.

## Canonical Files

Each consequential run binds these journal surfaces under the control root:

- `/.octon/state/control/execution/runs/<run-id>/events.ndjson`
- `/.octon/state/control/execution/runs/<run-id>/events.manifest.yml`
- `/.octon/state/control/execution/runs/<run-id>/runtime-state.yml`

Closeout mirrors of the journal live under retained evidence:

- `/.octon/state/evidence/runs/<run-id>/run-journal/events.snapshot.ndjson`
- `/.octon/state/evidence/runs/<run-id>/run-journal/events.manifest.snapshot.yml`
- `/.octon/state/evidence/runs/<run-id>/run-journal/redactions.yml`

## Writer Rule

`runtime_bus` is the only canonical append path for `events.ndjson` and
`events.manifest.yml`.

runtime_bus is the only canonical append path for the canonical Run Journal.

No runtime component may:

- write raw journal lines directly,
- rewrite or delete prior journal entries,
- mutate the manifest without going through `runtime_bus`, or
- treat generated/operator read models as journal inputs.

## Event Requirements

Canonical journal entries must conform to `run-event-v2.schema.json`.

Each appended event must be:

- sequence ordered,
- hash-linked to the previous event,
- actor-bound,
- causally linked,
- tied to the bound run contract and run manifest,
- explicit about replay disposition,
- explicit about effect class,
- and explicit about governing refs such as grant, policy, approval, lease,
  revocation, checkpoint, disclosure, or snapshot refs when applicable.

`runtime-event-v1` dot-named events remain compatibility aliases only. They
must be normalized into the hyphenated `run-event-v2` family before they can
enter the canonical control journal.

## Lifecycle Coverage

At minimum, the live runtime must journal:

- run creation and binding,
- authority request and resolution,
- checkpoint creation,
- capability authorization and invocation,
- terminal capability outcome,
- disclosure publication,
- evidence snapshot creation,
- and run closure.

Material side effects must not occur before the authorization path and journal
coverage for that effect have been recorded.

## Runtime-State Materialization

`runtime-state.yml` is a derived materialization of the journal plus bounded
side artifacts. The manifest must record the latest materialized event id,
sequence, and hash. If the journal and runtime state disagree, the journal
wins and the mismatch is a drift condition.

## Replay Rule

Replay reconstructs from the canonical journal first.

- default replay mode is dry-run or sandbox
- live side-effect replay requires a fresh authorization grant
- missing side-artifact refs are replay gaps, not silent fallbacks
- replay planning may summarize journal state, but it must not mint authority

## Closeout Rule

Before closeout is considered valid:

1. terminal lifecycle and disclosure events are present,
2. the control journal has been mirrored into retained evidence,
3. control and evidence snapshot refs are linked from the manifest,
4. operator disclosure cites the canonical control and evidence roots, and
5. redactions, if any, are lineage-preserving and audit-linked.

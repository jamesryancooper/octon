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
It must validate Run Lifecycle v1 state legality, state-before consistency,
terminal-state rules, required transition refs, and generated/input
non-authority boundaries before sealing or writing an event. Higher-level
runtime wrappers may add reconstruction and materialization checks, but they
may not bypass this append-time lifecycle gate.

Append-time validation is repo-root aware. Relative and absolute refs that
resolve under `.octon/generated/**` or `.octon/inputs/**` are invalid lifecycle
authority, and non-URI absolute filesystem refs outside the repository root are
invalid. Additional refs are subject to the same boundary checks as named
governing refs.

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

Event references used by lifecycle transition and reconstruction records must
include event id, sequence, hash, and event type so they can be replayed,
disclosed, and used to rebuild state without trusting mutable views.

`runtime-event-v1` dot-named events remain compatibility aliases only. They
must be normalized into the hyphenated `run-event-v2` family before they can
enter the canonical control journal.

## Lifecycle Coverage

At minimum, the live runtime must journal:

- run creation and binding,
- authority request and resolution,
- effect-token request, mint or deny, consumption request, consume or reject,
  and expiry or revocation when applicable,
- checkpoint creation,
- capability authorization and invocation,
- terminal capability outcome,
- disclosure publication,
- evidence snapshot creation,
- and run closure.

Material side effects must not occur before the authorization path and journal
coverage for that effect have been recorded.

Token lifecycle coverage may use canonical effect-token event types or
equivalent typed journal items, but the retained journal must make token
provenance, verification, and consumption falsifiable for every material
effect.

## Runtime-State Materialization

`runtime-state.yml` is a derived materialization of the journal plus bounded
side artifacts. The manifest must record the latest materialized event id,
sequence, and hash. If the journal and runtime state disagree, the journal
wins and the mismatch is a drift condition.

## Lifecycle Transition Binding

Every lifecycle state change must be represented by a
`run-lifecycle-transition-v1` record that cites:

- the reconstruction report used as the current-state input,
- the journal head observed before evaluation,
- the accepted or rejected `run-event-v2` event when an event is safely
  appended,
- the resulting journal head when state advances, and
- separated control, retained evidence, replay, disclosure, and state-rebuild
  refs.

Accepted transitions advance lifecycle state only through `runtime_bus`
append. A transition record is not an alternate journal and cannot advance
state without the corresponding canonical event.

Transitions into `staged` must cite a resolvable stage-only or escalation
decision artifact. A generic authority-route ref is insufficient when the
target state is `staged`.

Transitions into `closed` must cite resolvable closeout artifacts before the
closing event is sealed: rollback posture, evidence snapshot, disclosure,
review/risk disposition, evidence-store completeness, retained run evidence,
and journal snapshot linkage. Missing, unresolved, or non-hash-matching
closeout facts fail closed at the append boundary.

## Event Reference Roles

Lifecycle reconstruction must classify event refs by role:

- state-rebuild refs: events applied to compute lifecycle state;
- transition refs: events that created, denied, or blocked lifecycle movement;
- replay refs: events and pointer records needed for dry-run or sandbox
  reconstruction;
- disclosure refs: evidence snapshot, RunCard, or disclosure publication
  events; and
- drift refs: events that record mismatch, repair, or withheld materialization.

The same event may appear in more than one role, but generated/operator views
must never appear as source events for state rebuild.

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
5. evidence-store completeness, rollback posture, review disposition, and
   risk disposition are retained and linked from the closing journal event,
6. redactions, if any, are lineage-preserving and audit-linked.

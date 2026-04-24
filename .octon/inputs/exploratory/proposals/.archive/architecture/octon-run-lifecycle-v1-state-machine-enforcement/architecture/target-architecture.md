# Target Architecture: Run Lifecycle v1 as the Runtime State Machine

## Target thesis

Octon's Governed Agent Runtime must enforce `run-lifecycle-v1.md` as the hard execution spine for consequential Runs. The Run Journal remains the canonical transition record. `runtime-state.yml` becomes a rebuildable mutable view over that journal plus bounded side artifacts. Runtime operations are legal only when the current lifecycle state, requested transition, required evidence, and requested effect are coherent.

## Scope

In scope:

- Lifecycle transition validation.
- Runtime-state reconstruction from the canonical Run Journal.
- Transition-specific preconditions.
- Invalid-transition fail-closed behavior.
- Closeout completeness enforcement.
- CLI and runtime operation alignment with lifecycle states.
- Assurance validators and negative tests.
- Derived operator read-model refresh semantics.

Out of scope:

- New support-target admissions.
- New browser/API/frontier execution support.
- New memory subsystem.
- Multi-agent orchestration redesign.
- New top-level `.octon/` roots.
- Any generated/read-model authority expansion.

## Architectural role

Run Lifecycle v1 binds the three implemented prerequisites:

| Existing primitive | Lifecycle role |
|---|---|
| Run Journal | Canonical transition record and reconstruction source. |
| Authorized Effect Tokens | Required for every material mutation while in `running`. |
| Context Pack Builder v1 | Required before a consequential Run can enter or remain in authorization-sensitive states. |
| Evidence Store v1 | Required before terminal closeout and RunCard generation. |

## Canonical lifecycle model

The lifecycle states remain those already defined in `run-lifecycle-v1.md`:

- `draft`
- `bound`
- `authorized`
- `running`
- `paused`
- `staged`
- `revoked`
- `failed`
- `rolled_back`
- `succeeded`
- `denied`
- `closed`

## Required runtime abstraction

Add a single transition gate inside the Governed Agent Runtime:

```text
transition_run_lifecycle(
  run_id,
  requested_transition,
  actor_ref,
  operation_ref,
  required_refs,
  observed_journal_head,
  requested_effect_envelope?
) -> LifecycleTransitionOutcome
```

The transition gate must:

1. reconstruct the current lifecycle state from the canonical journal;
2. compare reconstructed state to `runtime-state.yml`;
3. treat journal/state mismatch as drift;
4. validate transition legality against `run-lifecycle-v1.md`;
5. validate transition-specific required facts;
6. append the transition event through `runtime_bus` only;
7. materialize `runtime-state.yml` from the accepted event;
8. reject the transition fail-closed if evidence, authority, rollback, context, token, visibility, or support-target facts are missing.

## Runtime-state derivation rule

`runtime-state.yml` is not lifecycle authority. It is the current convenience view over:

- `events.ndjson`
- `events.manifest.yml`
- required side artifacts referenced by journal events
- bounded closeout facts

If the journal and `runtime-state.yml` disagree, the journal wins and the mismatch is a drift condition that blocks further consequential transitions until repaired or closed under explicit recovery posture.

## Transition precondition families

| Transition family | Required facts |
|---|---|
| `draft -> bound` | run contract, run manifest, canonical control root, evidence root, rollback posture, initial checkpoint coverage, journal creation/binding events |
| `bound -> authorized` | context-pack receipt, authority decision artifact, grant bundle, support binding, policy receipt, token issuance readiness |
| `authorized -> running` | live grant, support-target envelope, active stage attempt, journal coverage for authority resolution, no blocking revocation |
| `running -> paused` | safe interrupt boundary, checkpoint or checkpoint exemption, operator-visible pause reason |
| `paused -> running` | still-valid grant or reauthorization, context freshness or rebuild, unresolved revocations absent, support envelope valid |
| `running -> staged` | stage-only route or review posture, retained stage evidence, no unsupported live claim |
| `running -> failed` | failure receipt, rollback posture, operator-visible status |
| `failed/revoked -> rolled_back` | rollback or compensation receipt, final checkpoint, retained rollback evidence |
| `running -> succeeded` | work complete under support posture, retained run evidence, assurance proof, measurement, intervention accounting, RunCard readiness |
| `bound/authorized -> denied` | denial receipt with reason codes and no further material effect |
| terminal -> `closed` | evidence-store completeness, journal snapshot linkage, rollback posture, disclosure, review disposition resolved, risk disposition non-blocking |

## Operator surface mapping

| CLI/operator action | Lifecycle behavior |
|---|---|
| `octon run start --contract` | Creates/binds run, validates context and authority, enters `authorized`, `running`, `staged`, or `denied` only through transition gate. |
| `octon run inspect` | Reads journal-derived `runtime-state.yml` and retained evidence; never mutates lifecycle authority. |
| `octon run resume` | Valid only from `paused` or explicitly resumable `staged` posture; may require context rebuild or reauthorization. |
| `octon run checkpoint` | Appends checkpoint event and updates checkpoint refs; does not bypass lifecycle state. |
| `octon run close` | Valid only when closeout gate passes; mirrors journal into retained evidence. |
| `octon run replay` | Reconstructs from journal; default dry-run/sandbox; live side-effect replay requires fresh authorization. |
| `octon run disclose` | Generates disclosure from retained evidence only; cannot fabricate lifecycle state. |

## Generated/read-model discipline

Generated mission views, operator digests, lifecycle summaries, and Studio/host projections may mirror lifecycle state, but they are derived-only. Runtime transition gates must never read generated/operator views as lifecycle authority.

## Support-target discipline

Lifecycle enforcement does not widen support. It strengthens the currently admitted universe by making support-target proof depend on deterministic lifecycle state reconstruction and closeout evidence.

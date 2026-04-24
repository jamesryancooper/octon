# Run Lifecycle v1

This contract defines the fail-closed state machine for consequential run
lifecycle control.

## Canonical Files

Each bound run is anchored by:

- `/.octon/state/control/execution/runs/<run-id>/run-contract.yml`
- `/.octon/state/control/execution/runs/<run-id>/run-manifest.yml`
- `/.octon/state/control/execution/runs/<run-id>/events.ndjson`
- `/.octon/state/control/execution/runs/<run-id>/events.manifest.yml`
- `/.octon/state/control/execution/runs/<run-id>/runtime-state.yml`
- `/.octon/state/control/execution/runs/<run-id>/rollback-posture.yml`
- `/.octon/state/evidence/runs/<run-id>/**`
- `/.octon/state/evidence/disclosure/runs/<run-id>/run-card.yml`

`events.ndjson` and `events.manifest.yml` are the canonical transition record.
`runtime-state.yml` is the mutable derived view over that journal. This
document is the normative transition contract that the journal-driven runtime
state must satisfy.

## Machine-Readable Transition Contracts

Runtime lifecycle gates must emit or validate these machine-readable records:

- `run-lifecycle-transition-v1.schema.json`: one transition request, decision,
  and provenance record.
- `run-lifecycle-reconstruction-v1.schema.json`: one reconstruction and drift
  report over the canonical journal plus bounded side artifacts.

Every accepted lifecycle state change must be backed by:

1. a reconstruction report over `events.ndjson` and `events.manifest.yml`;
2. the observed journal head before the transition;
3. the accepted `run-event-v2` journal event and resulting journal head;
4. separated required refs for control, authority, rollback, context, support,
   effect-token, retained evidence, replay, and disclosure facts; and
5. runtime-state materialization from the accepted journal event.

Rejected, blocked, or failed-closed transitions must retain machine-readable
reason codes. They may append a denial, drift, or rejection event only when
doing so does not advance lifecycle state or create a material side effect.

## States

| State | Entry requirements | Required retained facts | Allowed exits |
| --- | --- | --- | --- |
| `draft` | Request exists but no run roots are live. | none beyond request lineage | `bound`, `denied` |
| `bound` | Run contract, manifest, runtime state, rollback posture, and checkpoint roots exist. | bound receipt or equivalent control checkpoint | `authorized`, `staged`, `denied` |
| `authorized` | Authority decision and grant bundle resolve for the bound run. | decision artifact, grant bundle, support binding | `running`, `staged`, `revoked`, `denied` |
| `running` | Authorized stage attempt is active. | stage-attempt record, runtime receipts, replay growth | `paused`, `failed`, `revoked`, `succeeded`, `staged` |
| `paused` | Execution is intentionally suspended at a safe interrupt boundary. | current checkpoint, operator-visible pause reason | `running`, `revoked`, `failed` |
| `staged` | Route or review posture allows only stage-only continuation. | stage-only authority outcome and current evidence bundle | `authorized`, `revoked`, `closed` |
| `revoked` | Revocation or equivalent stop condition is active. | revocation ref or deny receipt, updated rollback posture | `rolled_back`, `closed` |
| `failed` | Execution failed before successful compensation or closeout. | failure receipt, rollback posture, operator-visible status | `rolled_back`, `closed` |
| `rolled_back` | Rollback or compensation completed. | retained rollback evidence and final checkpoint | `closed` |
| `succeeded` | Requested work finished under a valid support posture. | retained run evidence, assurance, measurement, intervention, RunCard | `closed` |
| `denied` | Request or transition was denied before further consequential work. | denial receipt with reason codes | `closed` |
| `closed` | Evidence completeness, disclosure, and review requirements passed. | closeout-complete retained evidence store | terminal |

## Transition Rules

- Before any lifecycle transition is accepted, the runtime must reconstruct
  current lifecycle state from the canonical Run Journal and compare that
  state to `runtime-state.yml`.
- A journal/runtime-state mismatch is drift. Drift blocks consequential
  transitions until repaired or closed under explicit recovery posture.
- `runtime-state.yml` may be materialized only from accepted canonical journal
  events and bounded side artifacts referenced by those events.
- `bound` requires canonical run roots before any consequential side effect.
- `bound` requires `run-created`, `run-bound`, and initial checkpoint coverage
  in the canonical Run Journal.
- `bound` may enter `staged` only when authority routing returns an explicit
  stage-only or escalation outcome with a resolvable stage-only/escalation
  decision artifact. A generic authority-route receipt is not sufficient; this
  path does not authorize material effects.
- `authorized` requires both a decision artifact and a grant bundle.
- `authorized` requires a Context Pack Builder v1 receipt and model-visible
  context reference before capability execution continues.
- `authorized` requires token issuance readiness for each material effect class
  the run will consume.
- `authorized` requires journal coverage for authority request and authority
  resolution before any capability execution continues.
- `running` requires every material effect to verify a current
  `AuthorizedEffect<T>` into `VerifiedEffect<T>` before mutation.
- `running` must reject expired, revoked, already-consumed single-use, or
  out-of-scope effect tokens.
- `running` requires the active stage attempt to remain within the granted
  support-target and capability-pack envelope.
- `running` requires event-driven transitions such as `stage-started`,
  `capability-authorized`, `capability-invoked`, and checkpoint coverage.
- `paused`, `staged`, `revoked`, and `failed` must remain operator-visible via
  `runtime-state.yml` and refreshed read-model projections, but the journal
  remains the source of truth on conflict.
- `closed` requires evidence-store completeness, current rollback posture,
  canonical disclosure, journal closeout snapshot linkage, review disposition,
  risk disposition, and any blocking review or risk items to be resolved or
  explicitly accepted under closeout governance.
- `closed` may be appended only after the canonical append path verifies that
  closeout refs resolve to durable control/evidence artifacts, that
  evidence-store completeness is `complete`, that replay/disclosure readiness is
  true, and that linked journal snapshots hash-match the observed control
  journal and manifest.
- Any transition missing required authority, evidence, rollback, or visibility
  facts is invalid and must fail closed.
- Relative or absolute lifecycle refs under `.octon/generated/**` or
  `.octon/inputs/**` are invalid as runtime authority.
- Control refs and retained evidence refs must remain distinct: control journal
  refs decide live lifecycle state; retained evidence refs prove, replay, and
  disclose what happened.

## Notes

- Support-target binding is evaluated against the current admitted tuple model.
- Generated mission views, operator digests, and summaries may mirror lifecycle
  state, but they do not become lifecycle authority.

## Related Contracts

- `/.octon/framework/engine/runtime/spec/run-journal-v1.md`
- `/.octon/framework/engine/runtime/spec/run-lifecycle-transition-v1.schema.json`
- `/.octon/framework/engine/runtime/spec/run-lifecycle-reconstruction-v1.schema.json`
- `/.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `/.octon/framework/engine/runtime/spec/operator-read-models-v1.md`
- `/.octon/framework/constitution/contracts/authority/decision-artifact-v2.schema.json`
- `/.octon/framework/constitution/contracts/authority/grant-bundle-v2.schema.json`
- `/.octon/framework/constitution/contracts/disclosure/run-card-v2.schema.json`

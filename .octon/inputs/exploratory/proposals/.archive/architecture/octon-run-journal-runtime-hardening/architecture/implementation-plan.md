# Implementation Plan

## Phase 0 — Promotion preparation

1. Confirm no existing promoted contract has newer semantics than the packet's
   target.
2. Confirm proposal remains scoped to `.octon/**` promotion targets only.
3. Confirm no browser/API/MCP/frontier-support admission is bundled into this
   proposal.
4. Create a short decision record for the primary decision: Run Journal is a
   control/evidence substrate, not a new control plane.

## Phase 1 — Contract alignment

1. Add `run-event-v2.schema.json`.
2. Add `run-event-ledger-v2.schema.json`.
3. Add `runtime-state-v2.schema.json`.
4. Add `state-reconstruction-v2.md`.
5. Update runtime contract family and contract registry.
6. Define legacy mapping from engine `runtime-event-v1` dot events to canonical
   run-event family names.

### Required output

- Schema validation passes.
- Contract family declares v2 as active or stage-active according to Octon policy.
- v1 compatibility/migration notes exist.

## Phase 2 — Runtime spec hardening

1. Add `run-journal-v1.md` under engine runtime spec.
2. Update `run-lifecycle-v1.md` to require event-driven transitions.
3. Update `evidence-store-v1.md` to require control-journal snapshot and hash
   match at closeout.
4. Update `operator-read-models-v1.md` to require journal/evidence source refs,
   freshness, and non-authority classification.
5. Update `authorization-boundary-coverage-v1.md` to require journal coverage for
   every material path family.

### Required output

- Runtime specs no longer describe parallel lifecycle/state sources.
- The ledger wins over runtime-state conflicts.
- Generated views are explicitly derived from journal/evidence only.

## Phase 3 — Runtime implementation

1. Make `runtime_bus` the sole append path for canonical journal events.
2. Enforce event schema, sequence, previous/current hash, actor refs, causal refs,
   and lifecycle transition admissibility.
3. Ensure `authority_engine` emits and requires journal refs for authority
   requested/granted/denied and material action receipt events.
4. Ensure capability invocations emit requested/authorized/invoked/completed or
   failed event pairs.
5. Ensure checkpoint/rollback/recovery events carry side-artifact refs.
6. Ensure replay store reconstructs runtime-state from journal and side artifacts.
7. Ensure replay defaults to dry-run/sandbox and cannot re-execute live side
   effects without a new authorization grant.

### Required output

- A sample consequential Run produces a complete control journal.
- Runtime-state is materialized from journal.
- Replay reconstruction matches runtime-state at closeout.

## Phase 4 — Evidence and read-model alignment

1. Add closeout snapshot writer that copies journal and manifest to retained
   evidence with hashes.
2. Update RunCard/HarnessCard/disclosure generation to cite journal/evidence
   roots.
3. Ensure generated operator summaries cannot be consumed by runtime
   authorization, policy, support-target validation, or state reconstruction.
4. Add evidence redaction lineage if sensitive fields are omitted from operator
   views.

### Required output

- Closeout evidence contains journal snapshot with manifest/hash match.
- Generated views include non-authority classification and source refs.

## Phase 5 — Validators and conformance

1. Add `validate-run-journal-contracts.sh`.
2. Wire it into `validate-architecture-conformance.sh`.
3. Update runtime docs consistency validation.
4. Add support-target admission validation requiring Run Journal proof for any
   supported consequential tuple.
5. Add negative tests for:
   - missing event,
   - out-of-order sequence,
   - hash mismatch,
   - runtime-state/journal conflict,
   - generated view consumed as authority,
   - material side effect without grant/journal ref,
   - replay attempting live side effect.

### Required output

- Validators fail closed for malformed journals.
- Architecture conformance catches contract drift.

## Phase 6 — Cutover and closure

1. Run validators on clean repository state.
2. Execute fixture Runs:
   - denied authorization,
   - successful observe/read Run,
   - repo-consequential staged Run,
   - checkpoint/resume Run,
   - rollback/recovery Run,
   - operator pause/intervention Run.
3. Capture evidence under `state/evidence/validation/**`.
4. Publish generated read models only after canonical roots and evidence exist.
5. Close proposal with certification packet and promotion record.

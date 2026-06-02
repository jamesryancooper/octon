# Implementation Plan

## Durable Promotion Targets

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`

## Workstream

1. Retain full program-plan.yml for audit but route planners to planner-state.yml by default.
2. Emit program-context-capsule.yml with child status table, dependency vector, runnable batch, current blockers, route decision, key digests, and evidence refs.
3. Emit compact completion capsule for no-dispatch terminal parent runs.
4. Bind program context capsule to event head and child registry digest.

## Implementation Steps

1. Add or update schema/spec definitions for the proposed artifacts.
2. Add deterministic producer or wrapper code under the declared runtime/assurance surfaces.
3. Add reader preference so lifecycle planner, recovery, closeout, or executor uses compact artifacts by default.
4. Retain raw/full evidence unchanged and link compact artifacts by digest.
5. Add fail-closed stale/missing/digest-mismatch behavior.
6. Add validation fixtures and negative controls.
7. Update documentation or lifecycle contracts only where durable and non-proposal.
8. Run proposal and runtime validation.
9. Emit implementation conformance and drift/churn receipts before closeout.

## Validators

- planner-state reconstruction from program-lifecycle-checkpoint.yml and program-events.ndjson
- program-context capsule digest verification
- proposal-program mock run with no-dispatch completion

## Evidence To Retain

- source refs and digests;
- compact artifact output;
- raw/full evidence refs;
- validator result manifest;
- token-budget ledger delta;
- route/model decision receipt when LLM is used;
- context-pack receipt and model-visible hash when consequential;
- rollback evidence.

## Closeout Refusal Criteria

Refuse successful closeout if compact artifacts cannot be verified against raw evidence, if generated/read-model state is stale, if authorization evidence is missing, if rollback evidence is missing, if raw/proposal/generated surfaces are treated as authority, or if child-owned receipts are incomplete.

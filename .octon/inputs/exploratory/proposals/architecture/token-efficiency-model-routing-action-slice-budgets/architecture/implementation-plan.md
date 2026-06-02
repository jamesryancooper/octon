# Implementation Plan

## Durable Promotion Targets

- `.octon/instance/governance/policies/model-routing.yml`
- `.octon/instance/governance/policies/token-budgets.yml`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`

## Workstream

1. Define deterministic/small/medium/high/high-on-escalation routing matrix.
2. Emit route-decision receipts and model-routing receipts for each lifecycle slice.
3. Bound parent loops into load_program_spine, evaluate_dependency_vector, select_runnable_children, dispatch_child_or_no_dispatch, summarize_terminal_blockers, validate_completion, emit_closeout_capsule.
4. Convert publication freshness, generated freshness, blocker aggregation zero-state, dependency vector, manifest completeness, registry projection, raw-log indexing, closeout schema validation, and worktree cleanliness to deterministic preflights.

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

- model-routing receipt emission test
- route bypass negative control
- action-slice budget regression test
- deterministic preflight fixture tests

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

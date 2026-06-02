# Implementation Plan

## Durable Promotion Targets

- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/assurance/runtime/_ops/scripts/`

## Workstream

1. Define structured receipt templates with verdict, blockers, unresolved questions, evidence refs, source digests, validation counts, changed files, rollback refs, gate state, and exclusions.
2. Make closeout-change and closeout-worktree consume concise closeout projections by default.
3. Publish compact final summaries that reference retained evidence instead of duplicating it.
4. Add expanded report generator that reconstructs narrative from retained evidence on demand.

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

- closeout-change lifecycle alignment validation
- closeout worktree wrapper tests
- structured receipt schema validation
- expanded report reconstruction test

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

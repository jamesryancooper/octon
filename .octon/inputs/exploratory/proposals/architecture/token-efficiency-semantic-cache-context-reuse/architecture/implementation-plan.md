# Implementation Plan

## Durable Promotion Targets

- `.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`
- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Workstream

1. Add semantic summaries keyed by source digest, policy digest, route purpose, and trust class.
2. Reuse context-pack layers for stable governance, prompt capsules, generated freshness handles, and child handoff capsules.
3. Invalidate on source digest drift, policy digest drift, request binding mismatch, expired freshness, missing retained evidence, trust downgrade, explicit governance invalidation.
4. Add lifecycle-level token budgets and CI token regression tests for repeated proposal runs.

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

- semantic cache invalidation test
- context-pack layer reuse replay test
- source digest drift negative control
- CI token regression threshold test

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

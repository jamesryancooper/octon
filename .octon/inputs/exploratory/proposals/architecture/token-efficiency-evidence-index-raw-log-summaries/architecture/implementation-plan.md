# Implementation Plan

## Durable Promotion Targets

- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Workstream

1. Emit evidence-index.yml with artifact role, digest, byte size, estimated tokens, model-visible relevance, and read-raw-only-if hints.
2. Index stdout/stderr into deterministic raw-log-summary.yml records that identify prompt echoes, command output, diffs, and failing slices.
3. Retain raw logs unchanged as evidence; consume compact summaries by default.
4. Add evidence index reader paths for planner/recovery/closeout flows.

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

- new raw-log summary hash-matching test
- new failing-slice manifest reconstruction test
- test-lifecycle-interaction-receipts.sh
- replay validation over raw evidence refs

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

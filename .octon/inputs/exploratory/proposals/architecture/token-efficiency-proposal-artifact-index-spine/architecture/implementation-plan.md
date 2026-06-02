# Implementation Plan

## Durable Promotion Targets

- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/`
- `.octon/generated/proposals/`

## Workstream

1. Generate per-proposal artifact indexes with path, role, digest, bytes, estimated tokens, inclusion mode, stage relevance, and read-raw-only-if hints.
2. Generate proposal/program spines with status, child registry digest, authority boundary, gate states, receipt digests, blockers, and evidence refs.
3. Classify proposal packet documents as spine, current-stage slice, evidence annex, or optional reference.
4. Create child-handoff capsules from parent spine plus child-specific scope.

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

- proposal registry validation
- proposal artifact index schema validation
- proposal spine freshness test
- generated registry cannot replace manifest negative control

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

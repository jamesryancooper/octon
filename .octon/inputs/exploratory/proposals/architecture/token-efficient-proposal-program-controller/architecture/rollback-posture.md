# Rollback Posture

## Pre-Implementation Rollback

Before durable implementation begins, rollback is removal of this parent packet and child packets from `/.octon/inputs/exploratory/proposals/architecture/` followed by canonical proposal registry refresh if required.

## Per-Child Rollback

Each child owns rollback for its promotion targets. Rollback must include changed durable files, generated/read-model invalidation if producer semantics changed, schema/policy compatibility notes, evidence refs proving what changed, revert or compensation path, and closeout refusal criteria if rollback evidence is missing.

## Program-Level Rollback

If one child fails after partial implementation:

1. Stop dispatch.
2. Preserve all child evidence.
3. Emit blocker-ledger entries.
4. Prevent parent completion if required child receipt is missing.
5. Revert or compensate child targets according to the child rollback plan.
6. Refresh generated/read-model projections only through canonical producer paths.
7. Emit program recovery receipt and updated planner-state.

## Non-Rollbackable Facts

Retained evidence, raw logs, receipts, model-visible context hashes, route decisions, and token ledgers are historical proof. They are not deleted as rollback. If a generated projection becomes invalid, it is invalidated or regenerated through canonical producer surfaces.

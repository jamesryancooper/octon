# Implementation Plan

## Phase 1: Schemas And Evidence Contracts

1. Add `lifecycle-correction-branch-aggregate-receipt-v1.schema.json`.
2. Add `lifecycle-terminal-current-state-proof-v1.schema.json`.
3. Update `change-receipt-v1.schema.json` only as needed to reference terminal
   proof and correction aggregation for completed or cleaned outcomes.
4. Add positive and negative fixtures for:
   - missing correction branch;
   - branch-no-pr aggregate receipt with PR metadata;
   - stale landing authorization;
   - missing cleanup authorization;
   - dirty worktree claimed as cleaned;
   - generated artifact stale after archive;
   - terminal proof using chat, host state, or generated output as authority.

## Phase 2: Validators

1. Add `validate-lifecycle-correction-branch-aggregate-receipt.sh`.
2. Add `validate-lifecycle-terminal-current-state-proof.sh`.
3. Add `validate-proposal-lifecycle-terminal-freshness.sh`.
4. Extend `validate-change-closeout-lifecycle-alignment.sh` so completed or
   cleaned multi-landing runs require aggregate correction evidence when
   post-primary correction branches are present.
5. Extend `validate-closeout-worktree-wrapper.sh` so terminal wrapper states
   can cite terminal current-state proof without allowing wrapper-owned
   mutation.
6. Extend or wrap child-readiness validation with a scoped terminal mode that
   proves the declared child set without broad unrelated archive sweeps.

## Phase 3: Workflow And Skill Integration

1. Update closeout workflow stages to require terminal freshness and
   current-state proof before reporting `cleaned` for applicable proposal
   program runs.
2. Update archive, promote, and validate proposal workflows so artifact-spine
   freshness is rechecked after status, archive, support receipt, or promotion
   evidence changes.
3. Update `closeout-change` guidance for follow-up branch-no-pr correction
   branches and aggregate correction receipt retention.
4. Update `closeout-worktree` guidance so final worktree state can cite
   terminal current-state proof while preserving singular Change ownership.
5. Add validator runtime resolution guidance under execution-role practices.

## Phase 4: Generated Freshness And Publication Ordering

1. Ensure proposal registry generation runs after the last proposal manifest
   mutation.
2. Ensure proposal artifact index generation runs after the last packet support
   or archive mutation.
3. Ensure publication state validators run after extension, capability,
   generated effective, or host projection refreshes.
4. Ensure the terminal freshness validator records the checked packet set and
   publication families.

## Phase 5: Tests And Closeout

1. Add shell tests for all new validators and negative controls.
2. Run proposal, architecture, implementation-readiness, terminal freshness,
   artifact spine, change closeout alignment, closeout-worktree, publication
   freshness, and registry validation.
3. Produce implementation conformance and post-implementation drift/churn
   receipts.
4. Close out and archive only after terminal current-state proof and generated
   freshness receipts are retained.

## Required Order

Schemas must land before lifecycle gates depend on them. Validators and
negative controls must land before workflow and skill wording can claim the new
gates are enforceable. Workflow and skill integration must land before any
operator-facing closeout claim depends on the new evidence contracts.

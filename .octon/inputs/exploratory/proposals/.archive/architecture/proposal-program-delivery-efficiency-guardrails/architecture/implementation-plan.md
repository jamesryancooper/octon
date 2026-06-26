# Implementation Plan

## Phase 1: Contracts

1. Extend `proposal-program-delivery-profile-v1` with `execution_order_policy`.
2. Add `proposal-program-delivery-order-override-receipt-v1` for explicit retained override evidence.
3. Extend delivery receipt evidence requirements so order policy, readiness preflight, and clean-worktree route selection are traceable.

## Phase 2: Validators

1. Update `validate-proposal-program-delivery-profile.sh` to enforce canonical order unless a valid override receipt exists.
2. Add positive and negative fixtures for canonical order, missing override, stale override, target mismatch, and accepted override.
3. Extract shared child validation receipt pass semantics into a reusable helper.
4. Update readiness projection and child readiness validators to call the helper for archived child `support/validation.md` only.
5. Preserve strict `verdict: pass` for implementation-run, implementation-conformance, drift/churn, closeout, delivery, and route receipts.

## Phase 3: Delivery Workflow

1. Update stage 01 profile binding to evaluate order policy before expensive continuation.
2. Add the warning/stop receipt for alternative order without override.
3. Add or wire a consolidated delivery readiness preflight before child lifecycle continuation and parent delivery.
4. Ensure preflight checks Git mutation access, source cleanliness, parent review freshness, child receipt compatibility, tooling, route legality, and publication freshness posture.
5. Ensure downstream stages consume the preflight receipt rather than rerunning fragmented checks for authority.

## Phase 4: Clean Worktree Routing

1. Detect stale or dirty source branches before branch-local commit planning.
2. Select a clean route-owned worktree from current `origin/main` by default.
3. Require include-path classification evidence before reconstruction, staging, or commit.
4. Reject broad stage-all when classification does not prove every included path is intended and publishable.

## Phase 5: Postmortem Closeout

1. Define thresholds that require formal lifecycle postmortem closeout.
2. Wire threshold evaluation into proposal-program delivery and lifecycle runner termination.
3. Require validated `evaluation.yml`, `report.md`, `readiness-summary.md`, and freshness-bound evidence references when thresholds are met.
4. Add tests proving missing or stale postmortem artifacts prevent learned-from completion claims.

## Phase 6: Documentation And Projection

1. Update command and skill instructions to reflect enforced behavior, not prompt-only guidance.
2. Update proposal-program lifecycle contract text.
3. Refresh generated publication or registry outputs only through owning generators if implementation touches their source surfaces.

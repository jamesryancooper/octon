# Implementation Plan

## Phase 1: Freshness And Review Gates

Implement the architecture-review freshness child first. It must prove that a
stale pre-integration architecture receipt routes to the owning review refresh
path before review or delivery can continue.

## Phase 2: Delivery Evidence Completion

Implement concrete delivery receipt and evidence-index requirements. The route
must fail closed when only lifecycle summary evidence exists.

## Phase 3: Change Closeout Reconciliation

Add or harden a governed reconciliation route for cases where branch
publication, hosted landing, local main sync, branch deletion, or cleanup
occur after an earlier branch-local Change receipt.

## Phase 4: Cleanup And Worktree Disposition

Clarify preserved residue, local metadata, run-state residue, and retained
evidence disposition so cleanup routes can finish without treating detection
as deletion authority.

## Phase 5: Validator Coverage

Expand `validate-run-program-clean-delivery.sh` and its fixtures so the
validator chain exercises disclosure-tier validation and fails on missing or
stale terminal gates.

## Phase 6: Test Hermeticity

Make proposal worktree hygiene tests run against isolated fixtures or restore
generated read models internally so routine validation cannot dirty tracked
files.

## Parent Closeout

Parent closeout waits for all children to reach terminal child-owned outcomes
and for the parent registry, sequence, child contract, and closeout plan to
remain synchronized.

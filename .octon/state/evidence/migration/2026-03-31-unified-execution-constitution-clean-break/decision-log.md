# Decision Log Entry

- **Decision ID:** DEC-20260331-001
- **Title:** Bind final closeout to an authoritative status matrix and current live-path runtime evidence
- **Workstream(s):** WS0, WS1, WS5, WS6
- **Finding IDs closed / affected:** F-02, F-05, F-14, F-20
- **Date:** 2026-03-31
- **Owner:** Octon governance
- **Status:** accepted

## Problem

The repo could still pass a closure validator while leaning on March 29-30,
2026 certification artifacts and without a machine-readable current verdict on
every finding and claim criterion.

## Options considered

1. Keep the historical closure validator and add more summary prose.
2. Add a status matrix but leave the old validator logic primary.
3. Move closeout control onto an authoritative matrix and current runtime
   evidence, even if that turns the branch red.

## Decision

Take option 3. The closeout validator now consumes an authoritative status
matrix, the live workflow runtime resolves the canonical workflow tree, the
authority engine owns its implementation, and current runs can emit canonical
RunCards.

## Why this is correct

It reduces overclaim, removes a false-green path, and turns the remaining gap
set into explicit governed blockers instead of certification-era assumptions.

## Paths touched

- `.octon/framework/engine/runtime/crates/authority_engine/**`
- `.octon/framework/engine/runtime/crates/kernel/src/pipeline.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/workflow.rs`
- `.octon/instance/governance/closure/**`
- `.octon/framework/assurance/governance/_ops/scripts/assert-unified-execution-closure.sh`

## Evidence required

- validator/workflow: `cargo test -p octon_authority_engine`, `cargo test -p octon_kernel pipeline:: -- --nocapture`
- run evidence: `uec-validate-proposal-20260331-b`
- disclosure update: authored HarnessCard + canonical RunCard under disclosure root
- retirement update: closeout gating now reads the authoritative status matrix

## Deletions / demotions triggered

Historical March 29-30 certification artifacts are no longer treated as
sufficient proof for the final claim on their own.

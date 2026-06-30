# Implementation Plan

Implement the program as five staged child packets, each with independent review, implementation, validation, closeout, and archive evidence.

## Phase 1: Input Contract Alignment

Child packet: `proposal-delivery-input-contract-alignment`.

Align delivery profile and run identifiers across canonical workflow, command, skill, profile, manifest, validator, and documentation surfaces. This phase prevents stale or contradictory input requirements from being projected into host-facing surfaces.

## Phase 2: Operator Alias

Child packet: `proposal-program-delivery-operator-alias`.

Add the optional `/octon-proposal-run-program-delivery` operator alias only if it delegates to the canonical `proposal-program-delivery` wrapper and carries no independent lifecycle authority.

## Phase 3: Host Projections

Child packet: `proposal-program-delivery-host-projections`.

Publish or correct `.codex` skill and command projections for implemented proposal delivery wrappers and reconcile product catalog claims with actual projection availability. This phase depends on Phase 1 and Phase 2 so projected prompts describe the correct input contract and accepted alias.

## Phase 4: Review Loop Documentation

Child packet: `proposal-program-review-loop-documentation`.

Document the existing parent-local `program-review-revision` loop, state why a duplicate standalone program review-and-revise wrapper is not currently required, and add discoverability coverage for operators comparing packet-level and program-level lifecycle surfaces.

## Phase 5: Validation Hardening

Child packet: `proposal-lifecycle-surface-validation-hardening`.

Add regression tests, validators, or validation fixtures that keep commands, skills, workflows, lifecycle contracts, prompt bundles, manifests, generated projections, product catalog entries, and documentation synchronized after the first four phases land.

## Integration Order

1. Land Phase 1 first because it defines the contract that aliases and host projections must mirror.
2. Land Phase 2 before host projection publication so the canonical alias exists first.
3. Land Phase 3 after the delivery input contract and alias source are stable.
4. Land Phase 4 before validation hardening so documentation intent becomes testable.
5. Land Phase 5 last to encode the final coherent lifecycle surface as regression protection.

Each child implementation must update its own durable targets, validators, fixtures, and receipts. The parent remains a coordination packet and cannot replace child-owned evidence.

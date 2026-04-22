# Octon Architecture 10/10 Target-State Transition

## Purpose

This proposal packet defines the implementation-oriented transition from Octon's current live
architecture to a target-state architecture that could credibly earn a rigorous 10/10 architecture
score. It is an Octon-native, proposal-first packet: temporary, non-canonical, promotion-safe, and
intended to guide durable changes outside `/.octon/inputs/exploratory/proposals/**`.

The target is not rhetorical perfection. The target is a real architecture in which:

- canonical authority remains only in `framework/**` and `instance/**`
- generated/effective outputs are runtime-facing only when receipt-backed and fresh
- generated/cognition and generated/proposals remain non-authoritative
- raw additive and exploratory inputs never become runtime or policy dependencies
- every material side-effect path is proven to pass through the execution authorization boundary
- support, pack, admission, and extension states cannot widen claims by projection accident
- publication receipts and freshness locks are runtime hard gates, not advisory metadata
- support proof is current, path-normalized, negative-control-backed, and disclosure-backed
- operator boot, doctor, and architecture maps are concise projections of canonical truth

## Current architectural judgment

The live repo is already strong. The current architecture deserves approximately **7.6/10** under a
strict review: excellent authority discipline, strong constitutional/governance structure, good run
and mission modeling, credible support-bounded claim architecture, meaningful runtime code, and
serious proof-plane intent.

It does not yet deserve 10/10 because the executable chain from canonical authority to fresh
runtime-effective bundle to authorization enforcement to retained proof is still too fragmented,
partly over-projected, and not yet hard enough to make bypass, staleness, support-path drift, or
pack/extension widening mechanically impossible.

## Recommended reading order

1. `navigation/source-of-truth-map.md`
2. `resources/complete-architectural-evaluation.md`
3. `resources/10of10-gap-to-target-analysis.md`
4. `architecture/current-state-gap-map.md`
5. `architecture/target-architecture.md`
6. `architecture/file-change-map.md`
7. `architecture/implementation-plan.md`
8. `architecture/validation-plan.md`
9. `architecture/acceptance-criteria.md`
10. `architecture/cutover-checklist.md`
11. `architecture/closure-certification-plan.md`

## Non-authority notice

This packet lives under `/.octon/inputs/exploratory/proposals/**`. It is not canonical runtime,
policy, governance, support, publication, or architectural authority. Promotion targets named here
must stand on their own after promotion and must not depend on this packet path.

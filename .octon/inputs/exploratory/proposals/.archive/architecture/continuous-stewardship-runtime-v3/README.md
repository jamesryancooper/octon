# Continuous Stewardship Runtime v3

This is a manifest-governed Octon architecture proposal packet for implementing
**Continuous Stewardship Runtime v3**.

The guiding principle is:

> v1 makes Octon safe to start. v2 makes Octon safe to continue. v3 makes Octon safe to remain available over time.

The v3 rule is:

> The service can be indefinite. The work cannot be unbounded.

This packet defines a stewardship layer above the assumed v1 Engagement / Work
Package compiler and the assumed v2 Mission Runner. Stewardship may remain
available over time, observe admissible events, open finite epochs, admit work
into bounded missions, and hand execution to v2. It must not execute material
work directly and must not create an infinite agent loop.

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `architecture/target-architecture.md`
5. `architecture/current-state-gap-map.md`
6. `architecture/implementation-plan.md`
7. `architecture/validation-plan.md`
8. `architecture/acceptance-criteria.md`
9. `architecture/cutover-checklist.md`
10. `architecture/rollback-plan.md`
11. `architecture/promotion-readiness-checklist.md`
12. `resources/repository-baseline-audit.md`
13. `resources/architecture-evaluation.md`
14. `resources/current-state-campaign-analysis.md`

## Non-Canonical Status

This proposal lives under `inputs/exploratory/proposals/**` and is therefore
lineage-only. It does not create runtime authority. Durable outputs must be
promoted into `framework/**`, `instance/**`, `state/**`, and generated read-model
surfaces according to the placement rules in this packet.

# Mission Plan Compiler Layer

This is a temporary, implementation-scoped architecture proposal for
`mission-plan-compiler-layer`. It is not a canonical runtime, policy, control,
or contract authority.

## Purpose

Propose an optional Mission Plan Compiler layer that starts from approved
mission authority, drafts a bounded planning tree, validates scope and risk,
and compiles ready leaves into existing Octon execution primitives. The layer
must remain subordinate to mission authority, run contracts, Context Pack
Builder, execution authorization, retained evidence, replay, rollback, and
support-target governance.

## Decision

Adopt the planning layer only as a mission-bound compiler and evidence
organizer. Do not adopt it as a rival orchestrator, generic task manager,
generated dashboard authority, or direct execution queue.

## Promotion Targets

Promotion targets are Octon-internal durable surfaces under `.octon/`:

- runtime planning doctrine and schemas under `framework/engine/runtime/spec/`
- mission workflow integration under `framework/orchestration/runtime/workflows/missions/`
- structural and constitutional registry updates
- optional instance enablement policy
- validation scripts and tests
- documentation updates to clarify mission, run, context-pack, authorization,
  evidence, and lifecycle boundaries

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `resources/bounded-planning-layer-source-analysis.md`
5. `architecture/target-architecture.md`
6. `architecture/current-state-gap-map.md`
7. `architecture/hierarchical-planning-model.md`
8. `architecture/authority-control-evidence-map.md`
9. `architecture/workflow-lifecycle.md`
10. `architecture/schemas-and-artifacts.md`
11. `architecture/runtime-integration-plan.md`
12. `architecture/governance-and-approval-plan.md`
13. `architecture/stop-rules-and-anti-bloat-controls.md`
14. `architecture/validation-plan.md`
15. `architecture/migration-plan.md`
16. `architecture/rollback-plan.md`
17. `architecture/implementation-plan.md`
18. `architecture/acceptance-criteria.md`
19. `support/implementation-grade-completeness-review.md`
20. `support/executable-implementation-prompt.md`
21. `navigation/artifact-catalog.md`
22. `/.octon/generated/proposals/registry.yml`

## Exit Path

After acceptance and implementation, durable targets must stand on their own.
This packet should then be archived with retained promotion evidence. If the
architecture is rejected or superseded, archive it as historical or superseded
lineage without promoting proposal-local paths into runtime resolution.

# Governed Workflow Runtime Transition Program

_Status: Draft parent architecture proposal program_

This parent program coordinates the minimum child packet sequence required to
move Octon from the current entry-artifact framing packet toward a safely
claimable Governed Workflow Runtime architecture.

The parent does not implement the target architecture. It coordinates child
packets and preserves the existing authority model: authored authority under
`framework/**` and `instance/**`, operational truth and evidence under
`state/**`, generated outputs as derived-only, and `inputs/**` as
non-authoritative proposal lineage.

## Seed Reference

The seed/reference child is:

- `.octon/inputs/exploratory/proposals/architecture/foundational-entry-artifact-canonical-framing-update`

The seed remains an entry-artifact framing packet. It does not prove or
implement workflow statecharts, task-specific execution harnesses, agent-node
contracts, workflow replay, Durable Object adapters, MCP integration, external
workflow-engine integration, or runtime crate behavior.

## Program Boundary

This program may coordinate child sequence, dependency gates, aggregate risk,
aggregate validation, deferrals, rejections, supersessions, rollback posture,
and aggregate closeout evidence.

It must not own child lifecycle truth, child manifests, child subtype manifests,
child acceptance criteria, child validation verdicts, child promotion targets,
child receipts, or child archive metadata.

## Required Children

1. `framing-boundary-and-terminology-guardrails`
2. `workflow-statechart-task-specific-execution-harness`
3. `agent-node-model-call-contract`
4. `workflow-history-replay-idempotency-compensation`
5. `effect-token-enforcement-coverage`
6. `evidence-provenance-hardening`
7. `connector-operation-admission`
8. `migration-cutover-compatibility-retirement`

## Deferred Or Lab-Only Children

- `durable-coordination-adapter-evaluation`
- `mcp-integration-evaluation`
- `external-workflow-engine-adapter-evaluation`

These are not prerequisites for the core Governed Workflow Runtime claim. They
remain deferred or lab-only unless later child packets prove admission,
authority boundaries, receipts, and support posture.

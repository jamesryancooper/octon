# Packet Sequence

_Status: Draft parent-program sequence_

This program uses `gated-parallel` coordination. It is not `program-atomic`.

## Current Packet Creation State

The eight required child packets now exist as sibling draft architecture proposal packets. Creation does not approve, implement, promote, or make live any excluded future-state capability. The deferred/lab-only Durable Object, MCP, and external workflow-engine candidates remain uncreated.

This creation state does not change the sequential gates below; dependencies still require child-owned review, validation, implementation evidence where applicable, and promotion/cutover receipts.

Program-atomic execution is unavailable unless declared write scopes, rollback
posture, and route-level atomic metadata are later proven.

## Phase 0: Seed Reference

1. `foundational-entry-artifact-canonical-framing-update`

The existing seed child remains entry-artifact framing only. It does not
implement runtime statecharts, task-specific execution harnesses, agent-node
contracts, workflow replay, connector operation admission, Durable Object
adapters, MCP integration, external workflow-engine integration, or runtime
crate behavior.

## Phase 1: Framing Guardrail

2. `framing-boundary-and-terminology-guardrails`

This child gates all canonical wording changes. It must prevent the framing
packet from claiming live Governed Workflow Runtime behavior before runtime,
schema, validator, evidence, and cutover proof exists.

## Phase 2: Runtime Shape

3. `workflow-statechart-task-specific-execution-harness`

This child defines the minimal runtime contract surface for workflow statechart
parity and task-specific execution harness compilation. It must bind to current
Run Lifecycle v1 rather than create a second control plane.

## Phase 3: Agent Node Boundary

4. `agent-node-model-call-contract`

This child may begin after Phase 2 verifies enough contract shape for agent
nodes to bind to harnesses and workflow state. It must define model-call
receipts, tool allowlists, budgets, output validation, and forbidden authority
claims.

## Phase 4: Runtime Proof Parallel Gate

5. `workflow-history-replay-idempotency-compensation`
6. `effect-token-enforcement-coverage`

These may proceed in gated parallel after Phase 2. Both must finish before
evidence/provenance hardening and migration cutover.

## Phase 5: Evidence And Provenance

7. `evidence-provenance-hardening`

This child depends on the agent-node, workflow replay, and effect-token coverage
children. It must make receipts and closeout evidence sufficient for durable
claims.

## Phase 6: Connector Admission

8. `connector-operation-admission`

This child depends on effect-token coverage and evidence hardening. It must
preserve the rule that connector/tool/MCP availability is not permission.

## Phase 7: Migration And Cutover

9. `migration-cutover-compatibility-retirement`

This child is blocked until every required child has terminal child-owned
receipts. It is the only required child that may propose changing canonical
runtime terminology or retiring compatibility language.

## Phase 8: Deferred Or Lab-Only Evaluations

10. `durable-coordination-adapter-evaluation`
11. `mcp-integration-evaluation`
12. `external-workflow-engine-adapter-evaluation`

These are non-required children. They may be created only as explicit
evaluations. They must not block the core program closeout unless a later
operator-approved mutation changes their required status.

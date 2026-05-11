# Child Packet Contract

_Status: Draft parent-program contract_

Each child packet remains a normal manifest-governed proposal packet. The parent
coordinates dependency order and aggregate evidence only.

## Authority Boundaries

- Parent coordinates only.
- Child manifests remain child-owned.
- Child subtype manifests remain child-owned.
- Child acceptance criteria remain child-owned.
- Child validation verdicts remain child-owned.
- Child promotion targets remain child-owned.
- Child archive metadata remains child-owned.
- Parent evidence may summarize but never satisfy child receipts.

## Common Child Requirements

Each required child must:

1. Declare one `change_profile`.
2. Declare explicit promotion targets outside the proposal workspace.
3. Preserve `inputs/**` as non-authoritative lineage.
4. Preserve `generated/**` as derived-only.
5. Preserve current runtime authority unless the child explicitly proposes,
   validates, and receives accepted review for a replacement.
6. Include implementation-grade completeness review before implementation.
7. Include implementation conformance and drift/churn receipts after promotion.
8. Include validators or negative-control tests for overclaim prevention.

## Current Canonical Runtime Contracts

Until a child packet proves and promotes a replacement, these remain canonical:

- Run Lifecycle v1
- Execution Authorization v1
- Authorized Effect Token v1
- Context Pack Builder v1
- Evidence Store v1
- Support target declarations
- Fail-closed obligations

## Child-Specific Gates

### `framing-boundary-and-terminology-guardrails`

Must prove that entry artifacts do not imply future runtime capabilities are
live. Must define whether Governed Workflow Runtime is transitional, successor,
or canonical after cutover.

### `workflow-statechart-task-specific-execution-harness`

Must define statechart and harness contracts without replacing Run Lifecycle v1
until parity and cutover evidence exists. Must prove no new state root or second
control plane is introduced.

### `agent-node-model-call-contract`

Must define bounded agent nodes, model-call receipts, budgets, allowed tool
surfaces, output schemas, and no-authority rules.

### `workflow-history-replay-idempotency-compensation`

Must define replay, idempotency, retry, and compensation without claiming
universal replay, rollback, or transactionality.

### `effect-token-enforcement-coverage`

Must inventory every material side-effect path and prove each path requires a
verified typed effect token or is explicitly unsupported/stage-only.

### `evidence-provenance-hardening`

Must define receipts and provenance needed for workflow transitions, agent-node
invocations, model calls, connector operations, retries, compensations, effects,
closeout, validation, and promotion.

### `connector-operation-admission`

Must define operation admission for connectors and tools without treating MCP
servers, tool availability, dashboards, external systems, or agent outputs as
authority.

### `migration-cutover-compatibility-retirement`

Must run last. Must preserve rollback posture and compatibility until all
required child packets have terminal child-owned receipts.

## Deferred Child Rules

Durable coordination, MCP integration, and external workflow-engine adapter
children are evaluation-only unless a later accepted mutation marks one required.
They must start from a rejected-as-authority posture.

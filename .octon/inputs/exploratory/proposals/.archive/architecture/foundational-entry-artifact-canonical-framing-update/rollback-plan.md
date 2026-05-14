# Rollback Plan

_Status: In-review proposal packet artifact_


## Rollback triggers

- Promoted wording is interpreted as claiming live workflow-statechart, harness compiler, agent-node contract, Durable Object, MCP, or external-engine support.
- Agent-facing wording violates adapter parity or adds runtime/policy text where prohibited.
- Glossary changes conflict with existing active contracts.
- Architecture specification changes imply a new control plane.

## Rollback action

1. Revert modified entry artifacts to previous committed text.
2. Retain rollback evidence under `state/evidence/migration/**` or another canonical migration evidence root.
3. Leave this packet as proposal lineage only.
4. Record reason and successor correction if a narrower wording update is needed.

## Non-rollback

Do not roll back runtime contracts. This packet does not change runtime behavior.

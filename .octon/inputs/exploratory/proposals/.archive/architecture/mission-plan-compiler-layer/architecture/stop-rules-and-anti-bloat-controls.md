# Stop Rules And Anti-Bloat Controls

## Default Depth Budget

Default semantic depth:

```text
Mission
-> Workstream
-> Milestone
-> Deliverable
-> ActionSlice candidate
```

Do not default to task, subtask, and atomic-action recursion. Octon already has
`action-slice-v1` for the executable leaf.

## Risk-Based Depth

| Risk | Default rule |
| --- | --- |
| ACP-0 or ACP-1 | Maximum depth 4 unless validation requires deeper decomposition. |
| ACP-2 | Maximum depth 5 with explicit evidence and rollback mapping. |
| ACP-3 | Decomposition may draft; compile-to-run requires human approval. |
| ACP-4, destructive, or irreversible | Planning remains stage-only until explicit human approval and authorization gates exist. |

## Breadth Budgets

- maximum children per node by default: 7
- maximum open decompositions per branch: 3
- maximum initial executable leaves: 20
- maximum plan revisions without execution evidence: 2

If a branch exceeds budget, it must become blocked, requires human decision,
requires discovery run, requires proposal, or deferred.

## Executability Test

A node is executable only if it can be compiled to an action-slice candidate
with mission ID, action class, scope IDs, predicted ACP, reversibility, safe
interrupt boundary, blast radius, executor profile, approval requirement,
rollback or compensation primitive, and evidence requirements.

## Readiness Test

A node is ready only if it has expected output, acceptance criteria,
validation method, evidence root, dependency disposition, risk classification,
rollback or compensation path, support-target tuple refs, and authorization
path.

## Rolling-Wave Rule

Only near-term or blocking work may be decomposed to action-slice level. Future
work stops at milestone or deliverable level unless deeper decomposition is
needed to expose risk, approval, rollback, dependency, or support-target
issues.

## No Planning As Progress

A plan revision counts as progress only when it produces a resolved
dependency, resolved decision, validated assumption, compiled action-slice
candidate, approved run-contract draft, retained evidence, or closed blocker.

## Staleness Conditions

A plan becomes stale when the mission digest, risk ceiling, allowed action
classes, support-target tuple, evidence, dependency, compiled run, or required
evidence state changes in a way that contradicts the plan. Stale plans block
compile while remaining readable.

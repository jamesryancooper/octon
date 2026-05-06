# Schemas And Artifacts

## Proposed Durable Schemas

| Schema | Purpose | Promotion target |
| --- | --- | --- |
| `mission-plan-v1.schema.json` | Mission-bound planning container | `.octon/framework/engine/runtime/spec/mission-plan-v1.schema.json` |
| `plan-node-v1.schema.json` | Typed node inside the plan tree | `.octon/framework/engine/runtime/spec/plan-node-v1.schema.json` |
| `plan-dependency-edge-v1.schema.json` | Non-tree dependency graph | `.octon/framework/engine/runtime/spec/plan-dependency-edge-v1.schema.json` |
| `plan-revision-record-v1.schema.json` | Digest-to-digest plan mutation evidence | `.octon/framework/engine/runtime/spec/plan-revision-record-v1.schema.json` |
| `plan-compile-receipt-v1.schema.json` | Leaf-to-candidate compile mapping | `.octon/framework/engine/runtime/spec/plan-compile-receipt-v1.schema.json` |
| `plan-drift-record-v1.schema.json` | Staleness or contradiction evidence | `.octon/framework/engine/runtime/spec/plan-drift-record-v1.schema.json` |

## Proposed Control Artifacts

```text
.octon/state/control/execution/missions/<mission-id>/plans/<plan-id>/plan.yml
.octon/state/control/execution/missions/<mission-id>/plans/<plan-id>/nodes/*.yml
.octon/state/control/execution/missions/<mission-id>/plans/<plan-id>/edges.yml
.octon/state/control/execution/missions/<mission-id>/plans/<plan-id>/assumptions.yml
.octon/state/control/execution/missions/<mission-id>/plans/<plan-id>/decisions.yml
.octon/state/control/execution/missions/<mission-id>/plans/<plan-id>/compiled.yml
```

## Proposed Evidence Artifacts

```text
.octon/state/evidence/control/execution/planning/<plan-id>/revisions/*.yml
.octon/state/evidence/control/execution/planning/<plan-id>/compile/*.yml
.octon/state/evidence/control/execution/planning/<plan-id>/drift/*.yml
.octon/state/evidence/control/execution/planning/<plan-id>/checks/*.yml
.octon/state/evidence/control/execution/planning/<plan-id>/closeout.yml
```

## Candidate Compile Receipt

A compile receipt should link:

- `plan_id`
- `node_id`
- source plan digest
- mission digest
- action-slice candidate ref
- run-contract draft ref when present
- context-pack request ref when present
- authorization request ref when present
- evidence requirements
- rollback or compensation ref
- validation result
- compiler version
- created_at

## Schema Design Constraints

- Permit one node schema with enumerated `node_type`.
- Keep dependencies outside the tree.
- Keep assumptions and decisions explicit.
- Reuse `action-slice-v1` for executable leaves.
- Keep compile receipts as evidence, not authority.
- Keep generated graph views out of runtime resolution.

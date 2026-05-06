# Validation Plan

## Structural Validators

Add validator coverage for:

- planning artifact class-root placement
- mission binding and mission digest presence
- schema validation for MissionPlan, PlanNode, DependencyEdge, revision
  records, compile receipts, and drift records
- registered path-family coverage in the structural and constitutional
  registries
- generated/input/proposal authority misuse

## Planning Validators

Add checks for:

- maximum depth
- maximum children per node
- maximum open decompositions
- rolling-wave limits
- duplicate node detection by scope, expected output, dependency, and action
  class
- dependency cycles
- stale mission digest
- unresolved assumptions
- unresolved approvals
- readiness state before compile

## Runtime Boundary Validators

Add negative controls proving:

- PlanNode cannot directly execute
- PlanNode cannot bypass run-contract creation
- PlanNode cannot bypass Context Pack Builder
- PlanNode cannot bypass `authorize_execution`
- PlanNode cannot widen support targets
- PlanNode cannot admit capabilities
- generated planning projections cannot be cited as authority
- proposal packet paths cannot remain in promoted runtime targets

## Evidence Validators

Add checks that:

- every plan revision has retained evidence
- every compiled leaf has a compile receipt
- every plan update after execution cites Run Journal or evidence-store refs
- stale plan conditions block compile
- rollback updates planning projection without replacing run rollback truth

## Suggested Validation Commands

```text
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/mission-plan-compiler-layer
bash .octon/framework/assurance/runtime/_ops/scripts/validate-mission-plan-compiler.sh
```

The final command is a proposed durable validator to add during promotion.

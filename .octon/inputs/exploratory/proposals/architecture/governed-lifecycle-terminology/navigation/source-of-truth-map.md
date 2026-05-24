# Source Of Truth Map

## Packet-Local Sources

- `proposal.yml`: packet identity, scope, status, and promotion targets.
- `architecture-proposal.yml`: architecture subtype decision summary.
- `architecture/target-architecture.md`: target terminology split.
- `architecture/implementation-plan.md`: implementation sequence for a later
  authorized implementation route.
- `architecture/acceptance-criteria.md`: implementation-grade acceptance
  criteria.

## Durable Sources To Update After Authorization

- `.octon/framework/product/features/catalog.yml`
- `.octon/framework/product/features/lifecycle-autopilot.md`
- `.octon/framework/product/features/governed-lifecycle-orchestration.md`
- `.octon/framework/product/roadmap/lifecycle-autopilot.md`
- `.octon/framework/product/roadmap/governed-lifecycle-orchestration.md`
- `.octon/framework/engine/runtime/spec/lifecycle-program-controller-invariants.md`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-product-roadmap.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-validate-product-feature-catalog.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-validate-product-roadmap.sh`
- `.octon/framework/assurance/runtime/contracts/alignment-profiles.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/patterns/proposal-program.md`

## Derived Publications

- Generated effective extension projections are refreshed only from authored
  extension inputs.
- Host-projected skills are refreshed only from authored extension inputs.
- `.octon/generated/proposals/registry.yml` is regenerated from proposal
  manifests after packet state changes.

## Non-Authority Inputs

The terminology decision in chat, this packet, generated projections, local
receipts, CI/GitHub state, browser state, tool availability, and model memory
are not authority. They may guide work only after being converted into durable
review, validation, or execution evidence through the governed lifecycle.

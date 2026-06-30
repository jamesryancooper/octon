# Source Of Truth Map

## Durable Authorities

- Constitutional kernel:
  `.octon/framework/constitution/**`.
- Workspace objective:
  `.octon/instance/charter/workspace.md` and
  `.octon/instance/charter/workspace.yml`.
- Proposal workspace contract:
  `.octon/inputs/exploratory/proposals/README.md`.
- Proposal standard:
  `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`.
- Architecture subtype standard:
  `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md`.
- Future runtime target:
  `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`.
- Future lifecycle contract target:
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`.
- Future command and skill targets:
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/` and
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/`.

## Proposal-Local Lifecycle Sources

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `architecture/target-architecture.md`
5. `architecture/implementation-plan.md`
6. `architecture/acceptance-criteria.md`
7. `validation-plan.md`
8. `navigation/artifact-catalog.md`

`proposal.yml` and `architecture-proposal.yml` are the only proposal-local
lifecycle manifests. The remaining files guide review and implementation but
do not become durable authority.

## Support Receipts

- `support/proposal-review.md`: source review receipt requiring revision.
- `support/implementation-grade-completeness-review.md`: packet-local
  completeness receipt.
- `support/pre-integration-architecture-review.yml`: strict architecture
  review support receipt for the current packet digest.
- `support/revisions/revision-20260628T171500Z.md`: packet-local revision
  receipt.

Support receipts are proposal-local evidence only. They do not authorize
durable implementation, generated publication, closeout, archive, cleanup, Git
mutation, branch cleanup, terminal proof, or a `cleaned` claim.

## Derived Projections

- `.octon/generated/proposals/registry.yml` is proposal discovery only.
- `.octon/generated/effective/extensions/**` and generated runtime/capability
  projections are derived-only and must be refreshed through publisher routes.
- Generated outputs cannot replace additive inputs, lifecycle contracts,
  manifests, child receipts, or retained evidence.

## Retained Evidence Surfaces

- Program run control:
  `.octon/state/control/execution/runs/<program-run-id>/`.
- Program run evidence:
  `.octon/state/evidence/runs/workflows/<program-run-id>/`.
- Validation evidence:
  `.octon/state/evidence/validation/**`.
- Publication/freshness evidence:
  `.octon/state/evidence/validation/publication/**`.

Future implementation must retain route decisions, retry fingerprints, resume
source refs, delivery handoff inputs, validation outcomes, publication
freshness, and negative-control evidence in the owning evidence roots.

## Boundary Rules

- The proposal packet is temporary and non-authoritative.
- Child receipts remain child-owned; parent summaries and delivery aggregates
  may cite child evidence only by path and digest.
- Route selection must come from published lifecycle contracts and current
  repository state, not prompt text, generated projections, host state, chat,
  or model memory.
- Proposal Program Delivery owns delivery mutation, Change closeout handoff,
  cleanup, branch cleanup, terminal proof, and any final `cleaned` claim.
- Sibling packets own workflow handoff, evidence metadata, validators, and
  operator surface work outside this runner-routing scope.

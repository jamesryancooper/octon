# Source Of Truth Map

## Durable Authority

- Constitutional authority: `.octon/framework/constitution/**`
- Product and closeout policy authority:
  `.octon/framework/product/contracts/default-work-unit.md`,
  `.octon/framework/product/contracts/default-work-unit.yml`,
  `.octon/framework/product/contracts/change-closeout-state-machine.md`, and
  `.octon/framework/product/contracts/change-closeout-state-machine.yml`
- Proposal lifecycle workflow authority:
  `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout/`,
  `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/`,
  and `.octon/framework/orchestration/runtime/workflows/meta/create-architecture-proposal/`
- Validation authority:
  `.octon/framework/assurance/runtime/_ops/scripts/` and
  `.octon/framework/assurance/runtime/_ops/tests/`
- Branch and cleanup helper authority:
  `.octon/framework/execution-roles/_ops/scripts/git/` and
  `.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`
- Skill projection authority:
  `.octon/framework/capabilities/runtime/skills/remediation/`

## Proposal-Local Lifecycle Sources

- `proposal.yml`
- `architecture-proposal.yml`
- `architecture/target-architecture.md`
- `architecture/implementation-plan.md`
- `architecture/acceptance-criteria.md`
- `support/implementation-grade-completeness-review.md`
- `support/revisions/20260616T032714Z-packet-delivery-wrapper-ownership.md`

## Source Lineage

- `resources/source-prompt.md`
- `resources/postmortem-findings.md`

## Derived And Evidence Surfaces

- `.octon/generated/proposals/registry.yml` is discovery-only.
- `.octon/generated/proposals/artifacts/**` is a derived proposal artifact
  projection.
- `.octon/generated/effective/**`, `.codex/commands/**`, and
  `.cursor/commands/**` remain generated or host projections and must only be
  refreshed through owning publication scripts.
- `.octon/state/evidence/**` is retained evidence, not authority to mutate
  lifecycle, branch, cleanup, or publication state.
- `.octon/state/evidence/local/**` is local/operator evidence only.

## Boundary Rules

- This proposal packet cannot authorize implementation, acceptance, archive,
  branch landing, cleanup, publication, or generated projection refresh.
- This proposal packet does not own the aggregate packet delivery wrapper; that
  ownership belongs to `proposal-packet-delivery-wrapper`.
- Any durable implementation must use the proposal review route and strict
  pre-integration architecture review before acceptance.
- Any new lifecycle gate must include workflow and validator enforcement in the
  same Change.
- Cleanup detection cannot authorize deletion; cleanup must remain governed by
  cleanup authorization or explicit retained rationale.

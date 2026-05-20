# Validate Closeout

Run the validation floor for the selected route and record final disposition.

## Additive Extension Pack

Run or justify fail-closed blockers:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh`
- `bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh`

When capabilities or host projections change, also run:

- `bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh`
- `bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh`

## Core Octon Skill

Run or justify fail-closed blockers:

- `bash .octon/framework/capabilities/runtime/skills/_ops/scripts/validate-skills.sh <skill-id>`
- `bash .octon/framework/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict <skill-id>`
- `bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh`

When host projections change, also run:

- `bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh`

## Blocked / Proposal-Required

Required closeout:

- evidence states no install, activation, publication, projection, or runtime
  exposure occurred
- blocker is routed to a proposal/design update or explicit rejected disposition
- retained copy is under input `.archive/<intake-id>/` when needed
- `.incoming/<intake-id>/` is absent after final blocked disposition

## Shared Acceptance Criteria

- final status is one of `normalized-extension`, `installed-core-skill`,
  `blocked`, `rejected`, `superseded`, or `historical`
- `.incoming/<intake-id>/` is absent after final disposition; only a
  classification-only stop may leave raw intake in place
- evidence records file/path changes, validation outcomes, cleanup disposition,
  and any unresolved blocker

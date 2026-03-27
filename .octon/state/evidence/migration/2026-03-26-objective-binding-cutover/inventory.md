# Change Inventory

## Constitutional Objective Model

- Added `/.octon/framework/constitution/contracts/objective/**` with:
  - `family.yml`
  - `workspace-charter-pair.yml`
  - `run-contract-v1.schema.json`
  - `stage-attempt-v1.schema.json`
  - `README.md`
- Updated `/.octon/framework/constitution/contracts/registry.yml` to activate
  the objective family as `active-transitional`.
- Updated normative precedence and fail-closed obligations so run contracts and
  stage attempts are explicit constitutional layers for Wave 1.

## Workspace Objective Pair

- Promoted `/.octon/instance/bootstrap/OBJECTIVE.md` to the explicit
  workspace-charter narrative role.
- Promoted
  `/.octon/instance/cognition/context/shared/intent.contract.yml` to the
  explicit workspace-charter machine role.
- Expanded the objective and intent schemas to admit the new constitutional and
  profile-governance metadata.

## Mission And Run-Control Alignment

- Added the canonical run-control root at
  `/.octon/state/control/execution/runs/`.
- Updated mission registry, mission templates, and the live validation mission
  so mission remains the continuity container while run contracts become the
  atomic execution unit.
- Expanded the mission charter schema with optional objective-binding and
  transitional execution metadata.
- Updated orchestration run projections so `write-run.sh` now seeds the
  canonical Wave 1 run root and initial stage-attempt artifact while
  `framework/orchestration/runtime/runs/**` remains the operator projection.

## Runtime, Architecture, And Assurance Wiring

- Updated `/.octon/octon.yml`,
  `/.octon/framework/engine/runtime/config/policy-interface.yml`, and
  `/.octon/framework/cognition/_meta/architecture/contract-registry.yml` to
  publish the new objective family and run-control inputs.
- Updated core docs and architecture references:
  - `/.octon/README.md`
  - `/.octon/instance/bootstrap/START.md`
  - `/.octon/framework/cognition/_meta/architecture/specification.md`
  - `/.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`
  - `/.octon/framework/cognition/governance/principles/mission-scoped-reversible-autonomy.md`
  - `/.octon/framework/engine/README.md`
  - `/.octon/framework/engine/runtime/spec/policy-interface-v1.md`
  - `/.octon/framework/orchestration/runtime/runs/README.md`
  - `/.octon/framework/orchestration/practices/run-linkage-standards.md`
  - `/.octon/framework/orchestration/practices/operator-lookup-and-triage.md`
  - `/.octon/state/control/README.md`
  - `/.octon/state/evidence/runs/README.md`
- Added the dedicated validator
  `/.octon/framework/assurance/runtime/_ops/scripts/validate-objective-binding-cutover.sh`
  and wired it into the runtime-effective and mission-autonomy assurance paths.

## Migration And Evidence Records

- Added the Wave 1 migration plan at
  `/.octon/instance/cognition/context/shared/migrations/2026-03-26-objective-binding-cutover/plan.md`.
- Added ADR 069 and updated the migration/decision indexes.
- Added this evidence bundle under
  `/.octon/state/evidence/migration/2026-03-26-objective-binding-cutover/`.

## Generated And Control Refresh

- Republished extension effective state and capability routing after the root
  manifest changed.
- Refreshed mission-generated route and summary artifacts touched by the
  mission-autonomy validation flow.

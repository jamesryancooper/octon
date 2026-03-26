# File-Level Change Map

## Add

- `.octon/instance/cognition/decisions/<new-decision-id>-mission-scoped-reversible-autonomy-provenance-alignment-closeout.md`
- `.octon/instance/cognition/context/shared/migrations/2026-03-25-mission-scoped-reversible-autonomy-provenance-alignment-closeout/plan.md`
- `.octon/state/evidence/migration/2026-03-25-mission-scoped-reversible-autonomy-provenance-alignment-closeout/bundle.yml`
- `.octon/state/evidence/migration/2026-03-25-mission-scoped-reversible-autonomy-provenance-alignment-closeout/evidence.md`
- `.octon/state/evidence/migration/2026-03-25-mission-scoped-reversible-autonomy-provenance-alignment-closeout/commands.md`
- `.octon/state/evidence/migration/2026-03-25-mission-scoped-reversible-autonomy-provenance-alignment-closeout/validation.md`
- `.octon/state/evidence/migration/2026-03-25-mission-scoped-reversible-autonomy-provenance-alignment-closeout/inventory.md`

## Update

- `.octon/instance/cognition/decisions/index.yml`
  - add discovery for the provenance-closeout ADR
- `.octon/instance/cognition/context/shared/migrations/index.yml`
  - add discovery for the provenance-closeout migration plan
- `.octon/generated/proposals/registry.yml`
  - project the archived steady-state and final-closeout packets coherently
  - archive the current implementing packet in the final transaction
- `.octon/README.md`
  - point readers to canonical runtime/governance surfaces first
  - reference proposal packets, ADRs, and migration records as historical lineage only
- `.octon/instance/bootstrap/START.md`
  - make MSRAOM runtime/governance surfaces the primary reading path
- `.octon/framework/cognition/_meta/architecture/specification.md`
  - add a short note that the MSRAOM proposal lineage is historical and no longer required for active implementation guidance
- `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`
  - clarify that proposal packets do not authorize runtime behavior
- `.octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-steady-state-cutover/proposal.yml`
  - normalize lifecycle state and archive metadata
- `.octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-final-closeout-cutover/proposal.yml`
  - normalize lifecycle state and archive metadata
- `.octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-steady-state-cutover/README.md`
  - add minimal historical-lineage context if needed
- `.octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-final-closeout-cutover/README.md`
  - add minimal historical-lineage context if needed

## Proposal-local planning updates

- `README.md`
  - update reading order and planning context for the provenance-only cutover
- `architecture/implementation-plan.md`
  - provide the complete atomic execution plan
- `architecture/validation-plan.md`
  - define the proof contract
- `navigation/source-of-truth-map.md`
  - make post-promotion authority and discovery explicit
- `navigation/change-map.md`
  - define exact change/no-change zones

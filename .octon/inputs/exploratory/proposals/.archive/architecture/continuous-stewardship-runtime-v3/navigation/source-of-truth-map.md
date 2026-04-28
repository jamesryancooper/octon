# Source-of-Truth Map

## Proposal-Local Authority

1. `proposal.yml` — lifecycle and promotion target authority for this proposal.
2. `architecture-proposal.yml` — architecture subtype manifest.
3. `navigation/source-of-truth-map.md` — manual precedence and boundary map.
4. `architecture/**` — working proposal specifications and implementation plans.
5. `resources/**` — supporting repository-grounded analysis.
6. `navigation/artifact-catalog.md` — generated inventory, not semantic authority.
7. `README.md` — explanatory only.

## Durable Promotion Targets

The proposal must promote durable authority and runtime surfaces outside
`inputs/exploratory/proposals/**` before it may be considered implemented.

### Portable authored core

- `.octon/framework/engine/runtime/spec/stewardship-program-v1.schema.json`
- `.octon/framework/engine/runtime/spec/stewardship-epoch-v1.schema.json`
- `.octon/framework/engine/runtime/spec/stewardship-trigger-v1.schema.json`
- `.octon/framework/engine/runtime/spec/stewardship-admission-decision-v1.schema.json`
- `.octon/framework/engine/runtime/spec/stewardship-idle-decision-v1.schema.json`
- `.octon/framework/engine/runtime/spec/stewardship-renewal-decision-v1.schema.json`
- `.octon/framework/engine/runtime/spec/stewardship-epoch-closeout-v1.schema.json`
- `.octon/framework/engine/runtime/spec/stewardship-ledger-v1.schema.json`
- `.octon/framework/engine/runtime/spec/stewardship-evidence-profile-v1.schema.json`
- `.octon/framework/engine/runtime/spec/stewardship-aware-decision-request-v1.schema.json`
- `.octon/framework/engine/runtime/spec/stewardship-campaign-coordination-hook-v1.schema.json`
- `.octon/framework/engine/runtime/spec/continuous-stewardship-runtime-v3.md`
- `.octon/framework/constitution/contracts/runtime/stewardship-*.schema.json`
- `.octon/framework/constitution/contracts/authority/stewardship-aware-decision-request-v1.schema.json`
- `.octon/framework/constitution/contracts/{registry.yml,runtime/family.yml,authority/family.yml}`
- `.octon/framework/cognition/_meta/architecture/{contract-registry.yml,specification.md}`
- `.octon/framework/overlay-points/registry.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-continuous-stewardship-runtime-v3.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-continuous-stewardship-runtime-v3.sh`
- `.octon/framework/orchestration/practices/stewardship-lifecycle-standards.md`
- `.octon/framework/engine/runtime/{README.md,run,run.cmd}`
- `.octon/framework/engine/runtime/crates/kernel/src/{main.rs,commands/mod.rs,commands/stewardship.rs,commands/mission.rs}`

### Repo-specific durable authority

- `.octon/instance/stewardship/programs/<program-id>/program.yml`
- `.octon/instance/stewardship/programs/<program-id>/policy.yml`
- `.octon/instance/stewardship/programs/<program-id>/trigger-rules.yml`
- `.octon/instance/stewardship/programs/<program-id>/review-cadence.yml`
- `.octon/instance/stewardship/programs/<program-id>/campaign-policy.yml`
- `.octon/instance/manifest.yml`

### Operational truth

- `.octon/state/control/stewardship/programs/<program-id>/status.yml`
- `.octon/state/control/stewardship/programs/<program-id>/epochs/<epoch-id>/epoch.yml`
- `.octon/state/control/stewardship/programs/<program-id>/triggers/<trigger-id>.yml`
- `.octon/state/control/stewardship/programs/<program-id>/admission-decisions/<decision-id>.yml`
- `.octon/state/control/stewardship/programs/<program-id>/idle-decisions/<decision-id>.yml`
- `.octon/state/control/stewardship/programs/<program-id>/renewal-decisions/<decision-id>.yml`
- `.octon/state/control/stewardship/programs/<program-id>/decisions/<decision-request-id>.yml`
- `.octon/state/control/stewardship/programs/<program-id>/epochs/<epoch-id>/closeout.yml`
- `.octon/state/control/stewardship/programs/<program-id>/mission-handoffs/<handoff-id>.yml`
- `.octon/state/control/stewardship/programs/<program-id>/ledger.yml`

### Retained evidence

- `.octon/state/evidence/stewardship/programs/<program-id>/**`
- `.octon/state/evidence/stewardship/programs/<program-id>/epochs/<epoch-id>/**`
- `.octon/state/evidence/stewardship/programs/<program-id>/triggers/<trigger-id>/**`
- `.octon/state/evidence/stewardship/programs/<program-id>/admission-decisions/<decision-id>/**`
- `.octon/state/evidence/stewardship/programs/<program-id>/idle-decisions/<decision-id>/**`
- `.octon/state/evidence/stewardship/programs/<program-id>/renewal-decisions/<decision-id>/**`
- `.octon/state/evidence/stewardship/programs/<program-id>/decision-requests/<decision-request-id>/**`
- `.octon/state/evidence/stewardship/programs/<program-id>/mission-handoff/**`
- `.octon/state/evidence/stewardship/programs/<program-id>/stewardship-ledger/**`
- `.octon/state/evidence/stewardship/programs/<program-id>/disclosure-status/**`
- `.octon/state/evidence/stewardship/programs/<program-id>/closeout-evidence/**`

### Continuity

- `.octon/state/continuity/stewardship/programs/<program-id>/summary.yml`
- `.octon/state/continuity/stewardship/programs/<program-id>/open-threads.yml`
- `.octon/state/continuity/stewardship/programs/<program-id>/recurring-risks.yml`
- `.octon/state/continuity/stewardship/programs/<program-id>/next-review.yml`

### Derived projections only

- `.octon/generated/cognition/projections/materialized/stewardship/status.yml`
- `.octon/generated/cognition/projections/materialized/stewardship/calendar.yml`
- `.octon/generated/cognition/projections/materialized/stewardship/health.yml`
- `.octon/generated/cognition/projections/materialized/stewardship/open-decisions.yml`
- `.octon/generated/cognition/projections/materialized/stewardship/ledger-summary.yml`

## Boundary Rules

- Stewardship Programs do not execute work directly.
- Stewardship Epochs do not replace mission-control leases.
- Stewardship Triggers do not authorize work.
- Stewardship Admission Decisions do not authorize material execution.
- Stewardship Ledgers do not replace mission ledgers, run journals, run
  contracts, or retained run evidence.
- Campaigns remain optional coordination rollups and must not become a second
  mission system.
- Material execution remains owned by v2 Mission Runner and the existing run
  lifecycle / authorization boundary.
- Stewardship-aware Decision Requests are control gates only; their resolutions
  may emit canonical approval/exception/revocation records, but they never mint
  execution authorization.
- Generated stewardship projections must mirror control state and carry a
  non-authority notice.

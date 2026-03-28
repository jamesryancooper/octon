# ADR 074: Wave 6 Retirement, Cutover, And Closeout

- Date: 2026-03-28
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-28-wave6-retirement-cutover/plan.md`
  - `/.octon/state/evidence/migration/2026-03-28-wave6-retirement-cutover/`
  - `/.octon/inputs/exploratory/proposals/.archive/architecture/fully-unified-execution-constitution-for-governed-autonomous-work/`
  - `/.octon/instance/cognition/decisions/073-wave5-agency-simplification-and-adapter-hardening-cutover.md`

## Context

Waves 0 through 5 introduced the final constitutional families, run-root
lifecycle model, proof planes, disclosure surfaces, and adapter contracts, but
three classes of transitional behavior still remained live:

- constitutional and validator surfaces still advertised the execution model as
  `active-transitional`
- mission contracts still carried explicit mission-only execution retirement
  metadata even though run roots were already the only active execution-time
  truth
- runtime and GitHub automation still had host-shaped approval and waiver shims
  that could turn environment or label state into canonical approval artifacts

Those shims left hidden authority and stale adoption markers in the live model
even after the final durable surfaces existed.

## Decision

Promote Wave 6 as a pre-1.0 transitional cutover that leaves no transitional
execution shim active after the branch lands.

Rules:

1. Constitutional contract families, support-target declarations, precedence
   layers, and evidence/fail-closed obligations are now active rather than
   `active-transitional`.
2. Mission authority remains the continuity and long-horizon autonomy surface,
   but mission-only execution metadata is retired from active contracts,
   schemas, and mission exemplars.
3. Runtime may no longer materialize approval grants from environment or host
   projection state.
4. GitHub workflows may classify, project, and disclose lane state, but they
   may not use labels or waivers as repo-local authority.
5. High-impact and major/unknown dependency PRs stay in the manual lane rather
   than using a label-backed approval override.
6. The proposal lifecycle may advance only after durable targets are validated
   as proposal-independent.

## Consequences

### Benefits

- The live constitutional model now has one final active state instead of a
  staged coexistence narrative.
- Hidden authority is removed from runtime and GitHub control-plane flows.
- Mission contracts now describe only the enduring continuity role rather than
  already-retired execution assumptions.

### Costs

- High-impact PRs lose the autonomy-lane waiver shortcut and require ordinary
  human review/merge handling.
- Historical migration evidence still references the retired transitional model
  and remains as lineage rather than live guidance.
- Validators and read-model refresh now have to move in lockstep with
  constitutional closeout work.

### Follow-on Work

1. Continue pruning historical allowlists or evidence notes that mention the
   retired label-based approval model when they cease to provide useful
   lineage.

## Completion

Wave 6 is complete for the live constitutional execution model in this
repository.

Completion basis:

- the constitutional families and obligations are active without transitional
  status markers
- mission-only execution metadata is absent from active objective and mission
  contracts
- runtime and GitHub workflows no longer materialize approval authority from
  labels or environment flags
- the implementing proposal package is archived as implemented and the
  generated proposal registry reflects that closeout state
- validators, read models, and durable docs align to the same final model

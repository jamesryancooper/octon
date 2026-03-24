# ADR 064: Mission-Scoped Reversible Autonomy Completion Cutover

- Date: 2026-03-24
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-24-mission-scoped-reversible-autonomy-completion-cutover/plan.md`
  - `/.octon/state/evidence/migration/2026-03-24-mission-scoped-reversible-autonomy-completion-cutover/`
  - `/.octon/inputs/exploratory/proposals/architecture/mission-scoped-reversible-autonomy-completion-cutover/`

## Context

ADR 063 landed the initial mission-scoped reversible autonomy cutover, but the
repo still had partially integrated mission control semantics: the control-file
family existed mostly as seeded helper output, the runtime still relied on
hardcoded recovery defaults and shallow policy consumption, generated mission
views were placeholders or thin file references, and no freshness-bounded
effective scenario route existed for shared runtime/operator behavior.

## Decision

Complete MSRAOM as one additional pre-1.0 atomic cutover.

Rules:

1. `owner_ref` is the only canonical mission-owner field consumed by runtime
   and generated views.
2. Mission control helpers, validators, and runtime readers must use one
   normalized contract family for lease, mode, intent, directives, schedule,
   autonomy budget, circuit breakers, and subscriptions.
3. Material autonomous execution may proceed only when recovery/finalize
   semantics can be derived from canonical mission, policy, and live control
   state; missing derivation tightens to `STAGE_ONLY`, `SAFE`, or `DENY`.
4. Effective mission scenario routing is published only under
   `generated/effective/orchestration/missions/**`, is freshness-bounded, and
   is shared by scheduler/runtime and mission/operator summaries.
5. Control-plane mutations emit retained `control-receipt-v1` evidence under
   `state/evidence/control/execution/**`.
6. The cutover remains atomic and branch-revertable; no compatibility layer or
   long-lived dual model is introduced.

## Consequences

### Benefits

- Mission autonomy becomes one coherent authority/control/evidence/effective/
  read-model system.
- Scheduler/runtime behavior and operator views resolve from the same
  published effective route.
- Control-state mutation lineage becomes explicit and auditable.

### Costs

- Existing helper output, schema shapes, runtime readers, and summary
  generation all change together.
- Assurance coverage grows to include scenario-resolution freshness and richer
  control-receipt semantics.

### Follow-on Work

1. Wire higher-level operator clients to consume the route-aware generated
   mission/operator views once live missions exist in this repository.
2. Add richer mission-state UI projections after the canonical runtime route
   publication path has stabilized.

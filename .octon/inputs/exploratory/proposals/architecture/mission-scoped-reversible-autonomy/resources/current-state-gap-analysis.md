# Current-State Gap Analysis

This resource anchors the proposal to the live repository state as it exists
before the operating-model cutover. It focuses on the durable repo surfaces
that still need to change for Mission-Scoped Reversible Autonomy to become the
only live long-running autonomy model.

## Live Repo Delta Summary

| Concern | Current live surface | Current state | Gap this cutover must close |
| --- | --- | --- | --- |
| Root manifest bindings | `.octon/octon.yml` | Release is still `0.5.5`; `resolution.runtime_inputs` publishes `proposals_registry` and `continuity` only. | Publish the cutover release and add runtime bindings for missions registry, mission control root, ownership registry, and mission-autonomy policy. |
| Mission authority | `.octon/instance/orchestration/missions/registry.yml`, `.octon/instance/orchestration/missions/_scaffold/template/{mission.yml,mission.md}` | Mission registry and scaffold remain at `v1`; the charter shape is minimal and does not encode mission class, risk ceiling, safe subset, or allowed action classes. | Upgrade mission discovery and scaffolding to `v2` and make the mission charter rich enough to serve as standing delegation. |
| Active mission migration surface | `.octon/instance/orchestration/missions/` | Registry is effectively empty today, and there are no active mission directories to backfill. | Treat migration as schema- and scaffold-breaking but data-light; if active missions appear before implementation, migrate them in-place on the cutover branch. |
| Repo-owned mission policy | `.octon/instance/governance/policies/` | Only `execution-budgets.yml` and `network-egress.yml` exist. There is no mission-autonomy policy. | Add `mission-autonomy.yml` for mode, schedule, recovery, digest, burn-budget, and breaker defaults. |
| Non-path ownership authority | `.octon/instance/governance/` | There is no ownership registry for operators, subscriptions, or non-path assets. | Add `instance/governance/ownership/registry.yml` and define directive-routing and precedence rules there. |
| Runtime contracts | `.octon/framework/engine/runtime/spec/` | The runtime still publishes `execution-request-v1`, `execution-receipt-v1`, `policy-receipt-v1`, and no mission-control schemas. | Add the mission charter, mission-control, and ownership schemas plus `v2` execution and policy contracts that require autonomy context. |
| Mutable control truth | `.octon/state/control/execution/` | Only `budget-state.yml` and `exception-leases.yml` exist. There is no mission-scoped execution-control tree. | Create mission-scoped lease, mode, intent, directive, schedule, budget, breaker, and subscription state under `state/control/execution/missions/<mission-id>/`. |
| Retained control evidence | `.octon/state/evidence/control/` | No control-evidence family exists yet. | Add `state/evidence/control/execution/**` and require receipts for material control-plane mutations. |
| Generated mission/operator read models | `.octon/generated/cognition/` | The generated cognition tree currently contains decision summaries, graph data, and projection definitions only. | Add mission `now/next/recent/recover` summaries and operator digest outputs sourced only from canonical control, evidence, and continuity surfaces. |
| Mission continuity | `.octon/state/continuity/repo/` | Repo continuity exists, but there is no mission-scoped continuity subtree. | Add `state/continuity/repo/missions/<mission-id>/**` for handoff and next-action state. |
| Assurance and conformance | `.octon/framework/assurance/runtime/` | No mission-autonomy-specific validator, scenario suite, or blocking alignment profile exists yet. | Add the validators, tests, and cutover merge gates required to keep the implementation atomic and fail closed. |

## Why The Cutover Must Be Atomic

- The live runtime contracts cannot express mission-scoped autonomy context
  today. Shipping docs or control files without the `v2` runtime enforcement
  would create a shadow model instead of a cutover.
- There is currently no mission-scoped control truth or retained control
  evidence family. Landing only part of that stack would force operators to
  reason across mixed sources.
- Generated summaries do not exist yet. If they are added before canonical
  control and evidence surfaces, they would either be empty or depend on
  non-canonical inputs.
- Mission scaffolding is still `v1`. Leaving the scaffold untouched while the
  runtime expects the new model would create immediate drift for any newly
  opened mission.

## Factors That Make The Cutover Smoothable

- The active mission registry is empty today, so the charter migration is
  structurally important but operationally light.
- No legacy `state/evidence/control/**` family exists yet, so the control
  evidence cutover does not have to preserve a parallel historical format.
- The runtime already has the right architectural spine: engine authorization,
  ACP promote/finalize control points, receipt families, budget policy, and
  fail-closed governance already exist and only need to be upgraded and bound
  together.

## Required Closeout Outputs

The implementation should not stop at code and docs changes. The cutover also
needs:

- a durable migration plan under
  `/.octon/instance/cognition/context/shared/migrations/<cutover-id>/plan.md`
- a retained cutover evidence bundle under
  `/.octon/state/evidence/migration/<cutover-id>/`
- an ADR or equivalent decision record under
  `/.octon/instance/cognition/decisions/`

Those artifacts are part of what makes the cutover clean, reviewable, and
rollback-safe rather than a one-off branch event.

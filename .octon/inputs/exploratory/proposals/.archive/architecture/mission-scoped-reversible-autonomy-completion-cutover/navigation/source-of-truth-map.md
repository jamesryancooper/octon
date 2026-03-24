# Source Of Truth Map

## Canonical Authored Authority

| Concern | Canonical surface | Notes |
| --- | --- | --- |
| Root operating-model posture, release bump, runtime inputs, generated defaults | `.octon/octon.yml` | Publish the completion cutover release identifier (`0.6.0`) and all runtime-input bindings needed by the completed model. |
| Cross-subsystem placement, class-root authority, and no-second-control-plane rules | `.octon/framework/cognition/_meta/architecture/specification.md` | Must declare mission control roots, retained control evidence, generated summaries, and generated effective scenario resolution. |
| Runtime vs `_ops` boundaries for mission-control automation | `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md` | Any automation may write only into canonical `state/**` or `generated/**` targets. |
| Canonical operating-model principle and governance semantics | `.octon/framework/cognition/governance/principles/mission-scoped-reversible-autonomy.md` and updates to ACP, reversibility, ownership/boundaries, and progressive-disclosure principles | Public-facing name remains Mission-Scoped Reversible Autonomy; supervisory-control framing stays in the principle definition. |
| Durable cutover execution plan | `.octon/instance/cognition/context/shared/migrations/mission-scoped-reversible-autonomy-completion-cutover/plan.md` | Proposal-local planning is temporary; the durable branch plan must be promoted before implementation starts. |
| Durable decision lineage | `.octon/instance/cognition/decisions/**` | Ratification, exception, migration, and rollback decisions belong here once promoted. |
| Durable mission authority | `.octon/instance/orchestration/missions/<mission-id>/{mission.yml,mission.md}` | `mission.yml` remains the standing delegation envelope and v2 charter. |
| Mission discovery | `.octon/instance/orchestration/missions/registry.yml` | Canonical mission registry remains authoritative and machine-readable. |
| Mission scaffolding | `.octon/instance/orchestration/missions/_scaffold/template/**` | Must create all control-surface stubs required for autonomous missions. |
| Repo-owned mode, scheduling, recovery, digest, autonomy-budget, quorum, and scenario defaults | `.octon/instance/governance/policies/mission-autonomy.yml` | Repo-owned policy remains the root for mission-class behavior. |
| Canonical ownership and directive precedence | `.octon/instance/governance/ownership/registry.yml` | Ownership registry is authoritative for non-path assets; `CODEOWNERS` remains a projection for path ownership. |
| Repo-owned spend and token governance | `.octon/instance/governance/policies/execution-budgets.yml` | Remains distinct from autonomy burn budgets. |
| Repo-owned egress governance | `.octon/instance/governance/policies/network-egress.yml` | Still applies before outbound material execution. |

## Canonical Mutable Control Truth

| Concern | Canonical surface | Notes |
| --- | --- | --- |
| Spend and token budget state | `.octon/state/control/execution/budget-state.yml` | Existing spend/data budget state remains authoritative and separate from autonomy burn. |
| Global execution exception and waiver leases | `.octon/state/control/execution/exception-leases.yml` | Existing exception surface remains authoritative for global waivers. |
| Mission continuation lease | `.octon/state/control/execution/missions/<mission-id>/lease.yml` | Time-bounded continuity state. |
| Live mode beacon | `.octon/state/control/execution/missions/<mission-id>/mode-state.yml` | Publishes `oversight_mode`, `execution_posture`, `safety_state`, phase, active run, and next safe interrupt boundary. |
| Forward intent register | `.octon/state/control/execution/missions/<mission-id>/intent-register.yml` | Canonical mutable record of upcoming material action slices. |
| Binding directives | `.octon/state/control/execution/missions/<mission-id>/directives.yml` | Holds active steering directives such as pause, suspend future runs, veto next promote, and block finalize. |
| Schedule semantics | `.octon/state/control/execution/missions/<mission-id>/schedule.yml` | Authoritative future-run suspension, active-run pause, overlap, backfill, and pause-on-failure state. |
| Autonomy burn budget | `.octon/state/control/execution/missions/<mission-id>/autonomy-budget.yml` | Trust-tightening state; distinct from cost budgets. |
| Oversight circuit breakers | `.octon/state/control/execution/missions/<mission-id>/circuit-breakers.yml` | Machine-enforced escalation state. |
| Awareness routing and subscriptions | `.octon/state/control/execution/missions/<mission-id>/subscriptions.yml` | Canonical watch/digest/alert routing per mission. |

## Canonical Retained Evidence

| Concern | Canonical surface | Notes |
| --- | --- | --- |
| Material execution receipts, ACP receipts, rollback handles, instruction-layer manifests, and run evidence | `.octon/state/evidence/runs/<run-id>/**` | Existing retained run-evidence family remains canonical for execution attempts and outcomes. |
| Control-plane mutation receipts | `.octon/state/evidence/control/execution/**` | Directives, authorize-updates, lease changes, breaker trips/resets, schedule mutations, safing changes, and break-glass activations land here. |
| Cutover evidence bundle | `.octon/state/evidence/migration/mission-scoped-reversible-autonomy-completion-cutover/**` | Implementation proof for the atomic rollout belongs here, not in the proposal. |
| Mission continuity and handoff lineage | `.octon/state/continuity/repo/missions/<mission-id>/**` | Mission progress, next handoff, and follow-up state belong in continuity, not generated views. |
| Historical receipts | existing `state/evidence/runs/**` | Historical evidence is retained without rewrite. |

## Derived Runtime / Effective Outputs

| Concern | Derived surface | Notes |
| --- | --- | --- |
| Scenario-resolution output | `.octon/generated/effective/orchestration/missions/<mission-id>/scenario-resolution.yml` | Derived, freshness-bounded, runtime-consumable effective routing artifact. |
| Machine-readable mission projection | `.octon/generated/effective/orchestration/missions/<mission-id>/mission-state.json` | Optional compiled effective view for runtime/UI/CLI clients. |
| Proposal registry | `.octon/generated/proposals/registry.yml` | Discovery projection only. |

## Derived Read Models

| Concern | Derived surface | Notes |
| --- | --- | --- |
| Mission operator read model | `.octon/generated/cognition/summaries/missions/<mission-id>/{now,next,recent,recover}.md` | Summary-first operator view; never authoritative. |
| Operator digests | `.octon/generated/cognition/summaries/operators/<operator-id>/**` | Generated digest output keyed by routing policy and subscriptions. |
| Optional mission projections for UI/CLI | `.octon/generated/cognition/projections/materialized/missions/<mission-id>.json` | Human-facing compiled projection; generated only from canonical surfaces. |

## Validation And Enforcement

| Concern | Durable surface | Notes |
| --- | --- | --- |
| Mission-autonomy validators, scenario tests, freshness checks, and alignment gates | `.octon/framework/assurance/runtime/**` | Blocking validators and conformance tests belong in durable assurance surfaces, not proposal-local notes. |
| Supervisory workflow behavior and preview/digest orchestration | `.octon/framework/orchestration/runtime/workflows/**` | Workflow authority for preview publication, safe interruption, scenario resolution, rollback, and digest routing belongs here when promoted. |

## External UX And Client Rule

External UIs, CLIs, chat front-ends, or browser experiences are permitted only
as **derived clients**:

- they may read canonical repo surfaces directly or through a thin adapter,
- they may cache derived views,
- they may not own state or authority outside `/.octon/`,
- any binding action must materialize into canonical repo control truth and,
  when material, emit a control-plane receipt under `state/evidence/control/**`.

No external UI, in-memory agent session, or chat transcript may become a second
authority surface or a hidden activity ledger.

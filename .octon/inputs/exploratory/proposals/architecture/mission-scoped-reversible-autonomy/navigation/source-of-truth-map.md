# Source Of Truth Map

## Canonical Authored Authority

| Concern | Canonical surface | Notes |
| --- | --- | --- |
| Root operating-model posture, runtime inputs, release bump, and generated-output defaults | `.octon/octon.yml` | Root manifest remains the authoritative cross-subsystem binding surface and should be updated to publish the Mission-Scoped Reversible Autonomy cutover and required runtime inputs. |
| Cross-subsystem placement, class-root authority, execution control roots, and no-second-control-plane rules | `.octon/framework/cognition/_meta/architecture/specification.md` | This remains the umbrella specification for where mission, control, evidence, and generated artifacts belong. |
| Runtime vs `_ops` mutation boundaries for new mission-control automation | `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md` | Mission-control helpers may automate writes only into canonical `state/**` or `generated/**` targets. |
| Canonical operating-model principle and governance semantics | `.octon/framework/cognition/governance/principles/mission-scoped-reversible-autonomy.md` plus updates to ACP, reversibility, and ownership/boundary principles | Public-facing model name stays Mission-Scoped Reversible Autonomy; supervisory-control language is integrated into the principle text. |
| Durable cutover execution plan | `.octon/instance/cognition/context/shared/migrations/<cutover-id>/plan.md` | The branch-level cutover plan must become durable repo authority before implementation starts; proposal-local planning is not sufficient once work begins. |
| Durable decision lineage | `.octon/instance/cognition/decisions/**` | The operating-model ratification and any cutover arbitration or exception decisions should be recorded here when promotion lands. |
| Durable mission authority | `.octon/instance/orchestration/missions/<mission-id>/{mission.yml,mission.md}` | `mission.yml` upgrades to `octon-mission-v2` and becomes the durable charter and standing-delegation envelope. |
| Mission discovery | `.octon/instance/orchestration/missions/registry.yml` | Upgrade to `octon-mission-registry-v2` so discovery remains canonical and machine-readable. |
| Mission scaffolding | `.octon/instance/orchestration/missions/_scaffold/template/**` | Must be updated in the same cutover so all new missions start on the v2 charter. |
| Repo-owned mode, scheduling, recovery, digest, autonomy-budget, and quorum defaults | `.octon/instance/governance/policies/mission-autonomy.yml` | New repo-owned policy file defining defaults and thresholds for the operating model. |
| Canonical ownership and authoritative directive precedence for non-path assets | `.octon/instance/governance/ownership/registry.yml` | New ownership registry; `CODEOWNERS` remains a repo-path projection, not the only ownership source. |
| Repo-owned spend and token governance | `.octon/instance/governance/policies/execution-budgets.yml` | Remains distinct from autonomy burn budgets and circuit breakers. |
| Repo-owned egress governance | `.octon/instance/governance/policies/network-egress.yml` | Still applies before outbound material execution. |

## Canonical Mutable Control Truth

| Concern | Canonical surface | Notes |
| --- | --- | --- |
| Spend and token budget state | `.octon/state/control/execution/budget-state.yml` | Existing spend/data budget state remains authoritative and separate from autonomy burn. |
| Global execution exception and waiver leases | `.octon/state/control/execution/exception-leases.yml` | Existing exception surface remains authoritative for time-boxed control relaxations. |
| Mission continuation lease | `.octon/state/control/execution/missions/<mission-id>/lease.yml` | New authoritative continuity state; separate from grants and from the mission charter. |
| Live mode beacon | `.octon/state/control/execution/missions/<mission-id>/mode-state.yml` | Publishes `oversight_mode`, `execution_posture`, `safety_state`, phase, active run, and next safe interrupt boundary. |
| Forward intent register | `.octon/state/control/execution/missions/<mission-id>/intent-register.yml` | Canonical mutable record of upcoming material action slices. |
| Binding directives | `.octon/state/control/execution/missions/<mission-id>/directives.yml` | Holds active steering directives such as pause, suspend future runs, veto next promote, and block finalize. |
| Schedule semantics | `.octon/state/control/execution/missions/<mission-id>/schedule.yml` | Canonical authority for future-run suspension, active-run pause, overlap, backfill, and pause-on-failure state. |
| Autonomy burn budget | `.octon/state/control/execution/missions/<mission-id>/autonomy-budget.yml` | New trust-tightening state; distinct from execution cost budgets. |
| Oversight circuit breaker state | `.octon/state/control/execution/missions/<mission-id>/circuit-breakers.yml` | Machine-enforced escalation state. |
| Awareness routing and subscriptions | `.octon/state/control/execution/missions/<mission-id>/subscriptions.yml` | Canonical watch/digest/alert routing per mission. |

## Canonical Retained Evidence

| Concern | Canonical surface | Notes |
| --- | --- | --- |
| Material execution receipts, ACP receipts, rollback handles, instruction-layer manifests, and run evidence | `.octon/state/evidence/runs/<run-id>/**` | Existing retained run-evidence family remains canonical for execution attempts and outcomes. |
| Control-plane mutation receipts | `.octon/state/evidence/control/execution/**` | New retained evidence family for directives, lease changes, authorize-updates, breaker trips/resets, safing changes, and break-glass activations. |
| Cutover evidence bundle | `.octon/state/evidence/migration/<cutover-id>/**` | Implementation proof for the atomic rollout belongs in the retained migration/evidence family, not in the proposal package. |
| Mission continuity and handoff lineage | `.octon/state/continuity/repo/missions/<mission-id>/**` | Mission progress, next handoff, and follow-up state belong in continuity, not in read models or raw logs. |
| Historical v1 receipts | existing `state/evidence/runs/**` artifacts | Historical evidence remains retained and is not rewritten; clean break applies to live runtime contracts only. |

## Derived Read Models

| Concern | Derived surface | Notes |
| --- | --- | --- |
| Mission operator read model | `.octon/generated/cognition/summaries/missions/<mission-id>/{now,next,recent,recover}.md` | Queryable summary-first operator view; never authoritative. |
| Operator digests | `.octon/generated/cognition/summaries/operators/<operator-id>/**` | Generated digest output keyed by routing policy and subscriptions. |
| Machine-readable mission projections | `.octon/generated/cognition/projections/materialized/missions/<mission-id>.json` | Optional compiled projection for UI/CLI clients; generated only from canonical surfaces. |
| Proposal registry | `.octon/generated/proposals/registry.yml` | Discovery projection only; proposal-local metadata never becomes runtime authority. |

## Validation And Enforcement

| Concern | Durable surface | Notes |
| --- | --- | --- |
| Mission-autonomy validators, scenario tests, and alignment gates | `.octon/framework/assurance/runtime/**` | Blocking validators and conformance tests belong in durable assurance surfaces, not proposal-local notes. |
| Supervisory workflow behavior and preview/digest orchestration | `.octon/framework/orchestration/runtime/workflows/**` | Workflow authority for preview publication, safe interruption, safing, rollback, and digest routing belongs here when promoted. |

## External UX And Client Rule

External UIs, CLIs, chat front-ends, or browser experiences are permitted only as
**derived clients**:

- they may read canonical repo surfaces directly or through a thin adapter,
- they may render cached views,
- they may not own state or authority outside `/.octon/`,
- any binding action must materialize into canonical repo control truth and,
  when material, emit a control-plane receipt under `state/evidence/control/**`.

No external UI, in-memory agent session, or chat transcript may become a second
authority surface or a hidden activity ledger.

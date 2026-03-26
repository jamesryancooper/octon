# Source Of Truth Map

This map defines the final steady-state source-of-truth boundaries for MSRAOM.

| Concept | Canonical surface | Truth class | Generated / derived surfaces | Notes |
| --- | --- | --- | --- | --- |
| Mission charter | `instance/orchestration/missions/<mission-id>/mission.yml` | authored authority | summaries, mission view | `owner_ref` is canonical |
| Mission registry | `instance/orchestration/missions/registry.yml` | authored authority | route and summary discovery | authoritative list of missions |
| Mission-autonomy policy | `instance/governance/policies/mission-autonomy.yml` | authored authority | scenario-resolution | mission-class defaults |
| Ownership routing | `instance/governance/ownership/registry.yml` | authored authority | operator digests, route | precedence, ownership, routing defaults |
| Executor-profile constraints | `.octon/octon.yml` | authored authority | scenario-resolution | public/release-sensitive overlays |
| Lease | `state/control/execution/missions/<mission-id>/lease.yml` | mutable control truth | summaries, mission view | continuity of standing delegation |
| Mode state | `state/control/execution/missions/<mission-id>/mode-state.yml` | mutable control truth | summaries, mission view | live mode beacon |
| Intent register | `state/control/execution/missions/<mission-id>/intent-register.yml` | mutable control truth | `next.md`, mission view | ordered forward intent queue |
| Action slices | `state/control/execution/missions/<mission-id>/action-slices/<slice-id>.yml` | mutable control truth | route, summaries | detailed material slice context |
| Directives | `state/control/execution/missions/<mission-id>/directives.yml` | mutable control truth | summaries, mission view | asynchronous Signals |
| Authorize-updates | `state/control/execution/missions/<mission-id>/authorize-updates.yml` | mutable control truth | summaries, mission view | synchronous authority mutations |
| Schedule control | `state/control/execution/missions/<mission-id>/schedule.yml` | mutable control truth | route, summaries | future-run suspension vs active pause |
| Autonomy budget | `state/control/execution/missions/<mission-id>/autonomy-budget.yml` | mutable control truth | route, summaries | trust-tightening state |
| Circuit breakers | `state/control/execution/missions/<mission-id>/circuit-breakers.yml` | mutable control truth | route, summaries | breaker state and actions |
| Subscriptions | `state/control/execution/missions/<mission-id>/subscriptions.yml` | mutable control truth | operator digests | owner/watch/digest/alert routing |
| Execution grants | `state/control/capabilities/grants/**` and engine grant bundle | authoritative execution control | summaries, receipts | per-attempt authority |
| Run receipts | `state/evidence/runs/**` | retained evidence | `recent.md`, `recover.md`, mission view | material execution evidence |
| Control receipts | `state/evidence/control/execution/**` | retained evidence | `recent.md`, mission view | control mutation evidence |
| Continuity / handoff | `state/continuity/repo/missions/<mission-id>/**` | operational truth | `next.md`, `recent.md`, mission view | progress and handoff |
| Effective scenario route | `generated/effective/orchestration/missions/<mission-id>/scenario-resolution.yml` | generated effective state | summaries, mission view, runtime consumers | generated, not authoritative |
| Mission summaries | `generated/cognition/summaries/missions/<mission-id>/{now,next,recent,recover}.md` | derived read model | n/a | human-facing only |
| Operator digests | `generated/cognition/summaries/operators/<operator-id>/**` | derived read model | n/a | ownership-routed human view |
| Mission view | `generated/cognition/projections/materialized/missions/<mission-id>/mission-view.yml` | derived machine view | n/a | machine-readable projection |

## Rules

1. A generated route is never authoritative policy or control truth.
2. A summary is never control truth or retained evidence.
3. Control mutations must update canonical state first and emit receipts; only
   then may generated views refresh.
4. If a generated surface is named in the manifest or contract registry, it
   must materially exist or the root must be removed from the live contract.
5. No external UI or service may become a parallel control plane. Binding
   changes must write into canonical repo control truth and emit control
   receipts.

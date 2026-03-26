# Source-of-Truth Map

| Concern | Canonical surface | Class | Notes |
|---|---|---|---|
| Mission charter, owner, class, risk ceiling, safe subset | `instance/orchestration/missions/**` | Authored authority | Mission creation stays here. |
| Mission-control family: lease, mode, intent, slices, directives, authorize-updates, schedule, autonomy budget, breakers, subscriptions | `state/control/execution/missions/<mission-id>/**` | Mutable control truth | Seed-before-active makes this exist before autonomy is live. |
| Mission continuity: handoff, next actions | `state/continuity/repo/missions/<mission-id>/**` | Operational continuity | Seed path creates continuity stubs. |
| Effective route | `generated/effective/orchestration/missions/<mission-id>/scenario-resolution.yml` | Generated effective routing | Derived from mission, policy, manifest, ownership, and live control truth. |
| Execution request/grant/receipt/policy receipt | `framework/engine/runtime/spec/**` + `state/evidence/runs/**` | Runtime contracts + retained evidence | ACP and `STAGE_ONLY` remain authoritative. |
| Control mutation receipts | `state/evidence/control/execution/**` | Retained evidence | Separate from run evidence. |
| Mission summaries (`Now / Next / Recent / Recover`) | `generated/cognition/summaries/missions/**` | Derived read model | Never authoritative. |
| Operator digests | `generated/cognition/summaries/operators/**` | Derived read model | Ownership-routed and subscription-aware. |
| Machine mission view | `generated/cognition/projections/materialized/missions/**` | Derived machine read model | Non-authoritative; generated from canonical inputs. |
| Mission-autonomy defaults | `instance/governance/policies/mission-autonomy.yml` | Authored repo policy | Supplies defaults, not live control truth. |
| Ownership precedence | `instance/governance/ownership/registry.yml` | Authored repo authority | Governs control mutations and routing precedence. |
| Root manifest roots and generated commit policy | `.octon/octon.yml` | Authored authority | Defines the live root contract and generated commit/rebuild defaults. |

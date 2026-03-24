# Mission-Scoped Reversible Autonomy Completeness And Integration Cutover

---

## README

This is a temporary, implementation-scoped architecture proposal for
`mission-scoped-reversible-autonomy-completion-cutover`.

It is the **big-bang, clean-break, atomic remediation package** for finishing
and correcting the implementation of the Mission-Scoped Reversible Autonomy
Operating Model (MSRAOM) in Octon after the initial cutover landed only
partially.

This package is **not** canonical runtime, policy, or contract authority.
Its job is to drive one repo-wide completion pass that removes the remaining
gaps, resolves architectural contradictions, and makes MSRAOM complete,
integrated, and operator-legible.

## Purpose

- proposal kind: `architecture`
- promotion scope: `octon-internal`
- current repo baseline: `0.5.6`
- recommended cutover release: `0.6.0`
- cutover style: `atomic`, `clean break`, `pre-1.0`, `repo-wide`

### Summary

Ratify one final MSRAOM completion cutover that upgrades the repo from a
**partially integrated** operating-model implementation to a **fully
integrated** one by landing all missing contracts, mission-control surfaces,
runtime consumers, schedule/directive semantics, control-plane evidence,
generated operator read models, scenario resolution, conformance tests, and
contradiction cleanup in one merge set.

## Why This Proposal Exists

Octon already has the right backbone in place:

- Mission-Scoped Reversible Autonomy is declared canonical.
- Mission authority, mission-autonomy policy, ownership registry, and v2
  execution/policy contracts exist.
- ACP, grants, receipts, reversibility, and `STAGE_ONLY` remain the normative
  execution-governance spine.

What remains incomplete is the **control-plane and operator-plane integration**
that turns those declarations into a complete operating model:

- missing or weakly integrated per-mission control contracts
- incomplete forward intent publication
- incomplete schedule/directive runtime behavior
- incomplete autonomy-burn and breaker automation
- incomplete safing and break-glass integration
- missing mission/operator read models (`Now / Next / Recent / Recover`)
- missing retained control-plane evidence emission
- no materialized scenario-resolution layer
- stale or contradictory runtime readers and placeholder-only summary/control
  surfaces

This package closes those gaps as one atomic implementation proposal.

The package includes `resources/implementation-audit.md` as the source audit
artifact for the derived gap analysis and remediation materials.

## Promotion Targets

- `.octon/octon.yml`
- `.octon/README.md`
- `.octon/instance/bootstrap/START.md`
- `.octon/instance/cognition/context/shared/migrations/`
- `.octon/instance/cognition/decisions/`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`
- `.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- `.octon/framework/cognition/governance/principles/`
- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/engine/runtime/config/`
- `.octon/framework/engine/runtime/crates/kernel/`
- `.octon/framework/engine/runtime/crates/policy_engine/`
- `.octon/framework/orchestration/runtime/workflows/`
- `.octon/framework/assurance/runtime/`
- `.octon/instance/orchestration/missions/`
- `.octon/instance/governance/policies/`
- `.octon/instance/governance/ownership/`
- `.octon/state/control/execution/`
- `.octon/state/evidence/control/`
- `.octon/state/evidence/migration/`
- `.octon/state/evidence/runs/`
- `.octon/state/continuity/repo/`
- `.octon/generated/effective/`
- `.octon/generated/cognition/`

## Reading Order

1. `architecture/target-architecture.md`
2. `resources/implementation-audit.md`
3. `resources/current-state-gap-analysis.md`
4. `resources/mission-control-contracts.md`
5. `resources/scenario-routing-design.md`
6. `architecture/implementation-plan.md`
7. `architecture/acceptance-criteria.md`
8. `architecture/validation-plan.md`
9. `navigation/source-of-truth-map.md`
10. `architecture/cutover-checklist.md`

## Non-Negotiable Cutover Rules

1. **One live model only.** There must be no long-lived dual live operating
   model after merge.
2. **Pre-1.0 atomic update.** Historical receipts remain; live runtime behavior
   changes in one cutover.
3. **No second control plane.** All binding control state lives in canonical
   repo surfaces under `/.octon/`.
4. **No docs overclaim.** Any surface described as canonical or generated must
   exist, be wired, and be validated before the cutover merges.
5. **No placeholder-only completion.** `.gitkeep` is not an implementation.
6. **No hardcoded fallback autonomy semantics.** Effective mission behavior
   must be policy- and state-derived.
7. **Scenario routing is derived, not a new authority registry.**

## Exit Path

Promote this proposal into durable runtime, policy, contract, and assurance
surfaces; write the cutover plan and evidence bundle under canonical migration
and decision roots; validate the scenario suite; then archive this proposal once
no implementation or documentation path depends on proposal-local guidance.

---

## Source Of Truth Map

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

---

## MSRAOM Completeness Remediation

## Decision

Octon should perform one more **atomic MSRAOM completion cutover** rather than a
series of piecemeal follow-ons.

The initial MSRAOM rollout did the hard conceptual work: it established mission
authority, mission policy, ownership routing, v2 execution contracts, and
retained ACP/reversibility semantics. The remaining work is not a new operating
model. It is the missing implementation glue that makes the model complete and
trustworthy in practice.

## Why A Second Atomic Cutover Is The Right Shape

A piecemeal approach would prolong exactly the contradictions the audit found:

- canonical generated views that do not exist
- runtime-required control files without durable contracts
- policy richness that is not yet runtime-consumable
- mission-authority fields that are not fully consumed everywhere
- scenario handling that exists implicitly but not coherently

Because Octon is still pre-1.0, a clean break is preferable to a long-lived dual
mode. One atomic completion cutover gives the repo:

- one live control model
- one mission-control file family
- one runtime routing path
- one operator read-model family
- one conformance baseline

## Resolved Open Questions

### 1. Continuation lease design
Resolved by adding `mission-control-lease-v1` and requiring lease state for any
active autonomous mission.

### 2. Intent register design
Resolved by adding `intent-register-v1` with versioned entries and binding
`intent_ref` on autonomous execution requests.

### 3. Scenario routing
Resolved by a derived scenario resolver under
`generated/effective/orchestration/missions/**`, not by a new authoritative
registry.

### 4. Autonomy burn calibration
Resolved by mission-class default profiles in `mission-autonomy.yml` plus
action-class modifiers from ACP policy, with per-mission override only through
repo-authoritative policy or explicit authorize-update.

### 5. Safe interrupt taxonomy
Resolved by standard boundary classes:
- `file_batch`
- `test_batch`
- `resource_batch`
- `environment_stage`
- `chunk_boundary`
- `api_page`
- `containment_step`
- `finalize_boundary`

Each action slice binds to one boundary class.

### 6. Recovery-window defaults
Resolved by policy defaults keyed by reversibility primitive and scenario family:

- repo-local reversible edits: `72h`
- canary/staged deploys: `24h`
- soft-deletes / detach / deprovision-pre-finalize: `168h`
- migration chunk rollback: `24h`
- external compensable sync: `24h`
- public or compensable communications: `4h`
- irreversible finalize: no recovery window; approval or break-glass only

### 7. Quorum independence
Resolved by policy rules requiring independent evidence sources, not merely
multiple votes. For ACP-2/ACP-3 paths, quorum members must not all derive from
the same tool, same model family, or same evidence stream when independence is
required.

### 8. External UX rule
Resolved by keeping all external clients derived-only; any binding action must
write into canonical repo control truth and emit control receipts.

## What This Proposal Changes

This proposal does **not** rename the model or replace the existing MSRAOM
spine. It completes it by requiring:

- contractization of the per-mission control family
- runtime consumption of mission-autonomy policy
- scheduler/directive semantics
- retained control-plane evidence
- generated mission/operator views
- effective scenario routing
- conformance tests and merge gates
- contradiction cleanup and stale reader alignment

## What It Does Not Change

- public-facing model name remains **Mission-Scoped Reversible Autonomy**
- ACP remains the durable execution-governance backbone
- `STAGE_ONLY` remains the humane fail-closed default
- historical run receipts remain retained without rewrite
- no second mutable control plane is added outside `/.octon/`

## Promotion Standard

The cutover should ship only when a reviewer can answer **yes** to all of these:

1. Does every runtime-required mission control file now have a durable schema,
   scaffold, validator, and writer?
2. Does the runtime use policy-derived scenario resolution rather than hidden
   hardcoded fallback behavior?
3. Do `Now / Next / Recent / Recover` and operator digests actually exist?
4. Do directives, schedule changes, breaker trips, safing changes, and
   break-glass activations emit retained control evidence?
5. Does the scenario suite prove behavior across routine, incident, migration,
   release, external, destructive, absent-human, late-feedback, and
   conflicting-human cases?

If any answer is no, the cutover is not complete.

---

## Implementation Audit

This package includes `resources/implementation-audit.md` as the source
implementation audit for the proposal.

That audit records the current repo-state judgment that Mission-Scoped
Reversible Autonomy is only **partially complete with moderate gaps**: the
execution and policy contracts are substantive, but the mission control plane,
operator read models, directive and schedule runtime semantics, retained
control evidence, and materialized scenario resolution are not yet fully wired
end to end.

The current-state gap analysis below distills that included audit into the
concrete implementation delta this package proposes to close.

---

## Current-State Gap Analysis

This section turns the included MSRAOM implementation audit into a concrete
implementation delta.

## Summary Judgment

The repo has implemented the **contract and policy spine** of Mission-Scoped
Reversible Autonomy, but not the full **control-plane, operator-plane, and
scenario-resolution integration** needed for long-running or always-running
agents.

### What is already real

- Mission-Scoped Reversible Autonomy is the declared canonical model.
- Mission charter v2, mission classes, mission-autonomy policy, and ownership
  registry exist.
- Execution request/receipt/policy contracts carry mission, slice, mode,
  reversibility, and recovery fields.
- ACP, grants, receipts, and `STAGE_ONLY` remain the execution-governance
  backbone.

### What remains materially incomplete

1. **Per-mission control contracts are not fully contractized or scaffolded.**
2. **Forward intent is not yet a complete, published control primitive.**
3. **Directive and schedule semantics are not fully consumed by runtime.**
4. **Autonomy burn and breaker behavior are only partly automated.**
5. **Safing and break-glass exist mostly at the policy layer.**
6. **Generated mission/operator read models are still missing.**
7. **Retained control-plane evidence emission is incomplete.**
8. **Scenario differentiation exists implicitly, but not as a materialized
   effective route shared by runtime and operator views.**
9. **At least one reader mismatch remains (`owner_ref` vs legacy `owner`).**
10. **Some repo docs overclaim surfaces that are still placeholder-only.**

## Gap Matrix

| Area | Current state | Gap | Required correction |
| --- | --- | --- | --- |
| Mission control root | Canonical path exists | Active file family is not fully schema-backed or scaffolded | Add schemas, scaffolds, validators, and writers for every required mission control file |
| Continuation lease | Runtime expects it | No visible committed schema/template family | Add `mission-control-lease-v1`, scaffold, and validator |
| Mode beacon | Fields exist in execution contracts | Operator-facing materialization is missing | Add `mode-state-v1`, runtime writer, and `Now` projection |
| Forward intent register | Runtime expects it | No complete schema, publisher, or consumer path | Add `intent-register-v1`, planner publisher, preview consumer, and `Next` projection |
| Control directives | Receipts can reference directives | Directive mutation and consumption are weakly integrated | Add `control-directive-v1`, runtime consumers, receipts, and precedence enforcement |
| Schedule semantics | Policy defines overlap/backfill/pause-on-failure | Scheduler behavior is not clearly wired | Add `schedule-control-v1` and explicit scheduler consumers |
| Autonomy burn budgets | Policy defines thresholds | No complete burn aggregation pipeline | Add runtime aggregation from receipts/incidents and state writers |
| Circuit breakers | Policy defines trip conditions/actions | Weak evidence of full runtime trip/reset behavior | Add breaker state writers, runtime consumers, and operator surfacing |
| Safing | Policy concept exists | Safe-subset enforcement is not clearly runtime-complete | Add safing subset resolution and runtime execution gating |
| Break-glass | Policy precedence exists | Mission-level operator visibility and receipts are incomplete | Add authorize-update flow, receipts, and mode-state integration |
| Control evidence | Canonical family is declared | Emission is not evident end-to-end | Add `control-receipt-v1` writers and retained evidence routes |
| Mission summaries | Canonical directories are declared | Placeholder-only in-tree | Materialize `Now / Next / Recent / Recover` |
| Operator digests | Canonical directories are declared | Placeholder-only in-tree | Add digest generator and routing |
| Scenario routing | Implicit via mission class, ACP, policy, executor profile | No effective scenario-resolution artifact | Add derived scenario resolver and generated effective output |
| Reader alignment | Mission v2 uses `owner_ref` | At least one orchestration reader still expects `owner` | Update readers, add migration shim if needed, add regression tests |

## Contradictions To Resolve

### 1. Placeholder-only generated views
The repo declares generated mission/operator summaries as canonical derived
surfaces, but the directories remain placeholder-only. The cutover must
materialize the actual views or remove the claims. This proposal chooses
**materialization**.

### 2. Runtime-required files without durable specs
The runtime expects per-mission control files such as `lease.yml`,
`intent-register.yml`, `schedule.yml`, and `autonomy-budget.yml`, but the repo
does not yet clearly expose a full contract family for them. The cutover must
make those files first-class contracts.

### 3. Mission charter reader mismatch
Mission v2 uses `owner_ref`, but older readers still appear to expect `owner`.
The cutover must make `owner_ref` canonical, update readers, and add a one-time
migration shim only if required for active missions.

### 4. Policy richness ahead of runtime resolution
`mission-autonomy.yml` contains a rich routing model, but runtime behavior does
not yet appear to consume all of it. The cutover must add an explicit resolver
and corresponding runtime integrations.

### 5. Recovery semantics partly hardcoded
Recovery windows and rollback metadata should be policy- and scenario-derived,
not hardcoded fallback values. The cutover must eliminate hidden fallback
semantics for material work.

## Design Decision

This proposal resolves the gaps by requiring one **atomic completion cutover**
rather than a series of partial follow-on patches. The repo should emerge from
the cutover with:

- one live MSRAOM implementation path,
- no placeholder-only canonical surfaces,
- no runtime-required control file without a durable contract,
- no mission/operator surface that depends on undocumented in-memory logic,
- one materialized scenario-resolution layer shared across runtime and operator
  views.

---

## Mission Control Contracts

This document resolves the remaining open questions around the per-mission
control surfaces by defining the required contract family and the minimum
authoritative fields each contract must expose.

These sketches are **implementation-guiding**, not final JSON Schema text. The
cutover must convert them into durable schemas under
`.octon/framework/engine/runtime/spec/` and register them in the contract
registry.

## Contract Family To Add

- `mission-control-lease-v1.schema.json`
- `mode-state-v1.schema.json`
- `action-slice-v1.schema.json`
- `intent-register-v1.schema.json`
- `control-directive-v1.schema.json`
- `schedule-control-v1.schema.json`
- `autonomy-budget-v1.schema.json`
- `circuit-breaker-v1.schema.json`
- `subscriptions-v1.schema.json`
- `control-receipt-v1.schema.json`
- `scenario-resolution-v1.schema.json`

## 1. Mission Control Lease

**Path**
`.octon/state/control/execution/missions/<mission-id>/lease.yml`

**Required fields**
- `schema_version`
- `mission_id`
- `state`: `active | paused | revoked | expired`
- `issued_at`
- `issued_by`
- `expires_at`
- `continuation_scope`: allowed execution posture and mission scope summary
- `revocation_reason` when not active
- `last_reviewed_at`

**Rules**
- active autonomous work requires a non-expired lease
- lease expiration must tighten behavior before any new material execution
- lease does not replace grants or approvals

## 2. Mode State

**Path**
`.octon/state/control/execution/missions/<mission-id>/mode-state.yml`

**Required fields**
- `schema_version`
- `mission_id`
- `oversight_mode`
- `execution_posture`
- `safety_state`
- `phase`
- `active_run_ref`
- `current_slice_ref`
- `next_safe_interrupt_boundary_id`
- `effective_scenario_resolution_ref`
- `autonomy_burn_state`
- `breaker_state`
- `updated_at`

**Rules**
- mode state is the canonical mode beacon
- operator views render from this file
- scheduler/runtime must read this file before material mission progression

## 3. Action Slice

**Path**
embedded in `intent-register.yml` and optionally normalized under
`.octon/state/control/execution/missions/<mission-id>/slices/<slice-id>.yml`

**Required fields**
- `slice_ref`
- `intent_ref`
- `action_class`
- `target_ref`
- `rationale`
- `predicted_acp`
- `planned_reversibility_class`
- `safe_interrupt_boundary_id`
- `expected_blast_radius`
- `expected_budget_impact`
- `required_authorize_updates`
- `rollback_plan_ref`
- `compensation_plan_ref`
- `finalize_policy_ref`

## 4. Intent Register

**Path**
`.octon/state/control/execution/missions/<mission-id>/intent-register.yml`

**Required fields**
- `schema_version`
- `mission_id`
- `revision`
- `generated_from`: planner/workflow refs
- `entries[]`, where each entry contains:
  - `intent_ref`
  - `slice_ref`
  - `state`: `proposed | published | superseded | consumed | cancelled`
  - `action_class`
  - `target_ref`
  - `rationale`
  - `planned_reversibility_class`
  - `earliest_start_at`
  - `feedback_deadline_at`
  - `default_on_silence`
  - `required_authorize_updates`
  - `safe_interrupt_boundary_id`
  - `rollback_plan_ref`
  - `compensation_plan_ref`
  - `supersedes_intent_ref` (optional)
  - `published_notice_ref` (optional)

**Rules**
- autonomous material work must bind to an `intent_ref`
- stale or superseded intents may not be executed
- preview notices are derived from published intent entries

## 5. Control Directives

**Path**
`.octon/state/control/execution/missions/<mission-id>/directives.yml`

**Required fields**
- `schema_version`
- `mission_id`
- `revision`
- `directives[]`, each with:
  - `directive_id`
  - `kind`
  - `target_scope`
  - `submitted_by`
  - `precedence_source`
  - `submitted_at`
  - `effective_at`: `immediate | next_safe_boundary | next_run | recovery_window`
  - `status`: `pending | accepted | superseded | rejected | consumed`
  - `rationale`

**Required directive kinds**
- `pause_at_boundary`
- `suspend_future_runs`
- `stop_after_slice`
- `reprioritize`
- `narrow_scope`
- `exclude_target`
- `veto_next_promote`
- `block_finalize`
- `enter_safing`
- `clear_safing` (authorized only)

**Rules**
- directives are binding only when materialized here
- runtime must emit a control receipt for any directive that affects active or
  future execution

## 6. Schedule Control

**Path**
`.octon/state/control/execution/missions/<mission-id>/schedule.yml`

**Required fields**
- `schema_version`
- `mission_id`
- `schedule_source`
- `cadence_or_trigger`
- `next_planned_run_at`
- `suspended_future_runs`
- `pause_active_run_requested`
- `overlap_policy`
- `backfill_policy`
- `pause_on_failure_rules`
- `preview_lead`
- `feedback_window_default`
- `quiet_hours`
- `digest_route_override`
- `last_schedule_mutation_ref`

**Rules**
- future-run suspension and active-run pause are distinct
- overlap and backfill behavior must be explicit
- pause-on-failure rules must be machine-consumable

## 7. Autonomy Budget

**Path**
`.octon/state/control/execution/missions/<mission-id>/autonomy-budget.yml`

**Required fields**
- `schema_version`
- `mission_id`
- `state`: `healthy | warning | exhausted`
- `window`
- `counters` for:
  - `rollback_events`
  - `compensation_events`
  - `retries`
  - `exceptions_used`
  - `promote_denials`
  - `operator_vetoes`
  - `confidence_failures`
  - `near_misses`
- `threshold_profile_ref`
- `last_state_change_at`
- `applied_mode_adjustments`

**Rules**
- autonomy budget is separate from spend/data budgets
- runtime must update this state from receipts and incident/control evidence

## 8. Circuit Breakers

**Path**
`.octon/state/control/execution/missions/<mission-id>/circuit-breakers.yml`

**Required fields**
- `schema_version`
- `mission_id`
- `state`: `clear | tripped | latched`
- `trip_reasons[]`
- `trip_conditions_snapshot`
- `applied_actions[]`
- `tripped_at`
- `reset_requirements`
- `reset_ref` when cleared

**Rules**
- breaker trips must emit control receipts
- breaker state must feed mode state and scheduler decisions

## 9. Subscriptions

**Path**
`.octon/state/control/execution/missions/<mission-id>/subscriptions.yml`

**Required fields**
- `schema_version`
- `mission_id`
- `owners[]`
- `watchers[]`
- `digest_recipients[]`
- `alert_recipients[]`
- `routing_policy_ref`
- `last_routing_evaluation_at`

**Rules**
- ownership routing wins over generic subscribers
- operator digests are derived from this state plus repo-owned policy

## 10. Control Receipts

**Path**
`.octon/state/evidence/control/execution/**`

**Required fields**
- `schema_version`
- `receipt_id`
- `mission_id`
- `control_event_kind`
- `subject_ref`
- `applied_by`
- `applied_at`
- `prior_state_ref`
- `new_state_ref`
- `reason_codes`
- `policy_refs`
- `supersedes_receipt_id` when relevant

**Required control event kinds**
- `directive_applied`
- `authorize_update_applied`
- `lease_changed`
- `schedule_changed`
- `breaker_tripped`
- `breaker_reset`
- `safing_changed`
- `break_glass_activated`
- `break_glass_cleared`

## 11. Scenario Resolution

**Path**
`.octon/generated/effective/orchestration/missions/<mission-id>/scenario-resolution.yml`

**Required fields**
- `schema_version`
- `mission_id`
- `source_refs`:
  - mission charter
  - mission-autonomy policy
  - deny-by-default policy
  - root manifest
  - mode state
  - schedule control
  - autonomy budget
  - circuit breakers
  - subscriptions
- `effective`:
  - `scenario_family`
  - `oversight_mode`
  - `execution_posture`
  - `preview_policy`
  - `feedback_window_required`
  - `proceed_on_silence_allowed`
  - `approval_required`
  - `safe_interrupt_boundary_class`
  - `overlap_policy`
  - `backfill_policy`
  - `pause_on_failure`
  - `digest_route`
  - `alert_route`
  - `required_quorum`
  - `recovery_profile`
  - `finalize_policy`
  - `safing_subset`
- `rationale[]`
- `generated_at`
- `fresh_until`

**Rules**
- this artifact is derived, not authoritative
- runtime may consume it only while fresh
- operator views and scheduler behavior should resolve from the same effective
  route to prevent split-brain behavior

## Open Questions Resolved By This Contract Family

1. **Continuation lease design** — resolved through `mission-control-lease-v1`
   with explicit state and expiration.
2. **Forward intent register design** — resolved through
   `intent-register-v1` with versioned entries and binding `intent_ref`.
3. **Scenario routing** — resolved as a derived effective artifact, not a new
   authority registry.
4. **Subscription routing** — resolved as canonical mutable control truth with
   derived digest output, not hardcoded channels.

---

## Scenario Routing Design

## Decision

Octon should implement **scenario routing** as a **derived effective resolver**,
not as a new authoritative registry.

The repo already has the right authoritative inputs:

- mission class in the mission charter
- repo-owned defaults in `mission-autonomy.yml`
- ACP/action-class and reversibility policy in deny-by-default policy
- executor-profile constraints in `.octon/octon.yml`
- live mission mode, schedule, budget, breaker, and subscription state

What is missing is a single runtime- and operator-consumable output that turns
those inputs into one coherent effective route.

## Why It Is Needed

Without a materialized resolver, scenario handling remains scattered across:

- mission class defaults
- ACP rules
- executor profiles
- ad hoc runtime checks
- schedule state
- breaker state
- operator digests

That makes it too easy for scheduler behavior, preview behavior, recovery
behavior, and operator views to disagree.

## Non-Goals

- no new authored scenario registry
- no duplicate source of truth
- no special-case hardcoded routing in UI-only layers
- no naming inflation that displaces mission class, action class, or ACP

## Resolver Inputs

The scenario resolver must consume:

1. **Mission authority**
   - `mission.yml`
   - mission registry entry
2. **Repo-owned mission policy**
   - `instance/governance/policies/mission-autonomy.yml`
3. **ACP/action-class policy**
   - deny-by-default policy
4. **Runtime profile constraints**
   - `.octon/octon.yml`
5. **Mission live state**
   - lease
   - mode state
   - intent register
   - schedule control
   - autonomy budget
   - circuit breakers
   - subscriptions
   - directives
6. **Optional contextual escalation inputs**
   - incident state
   - recovery-window state
   - break-glass activation
   - active safing subset

## Resolver Outputs

The effective scenario-resolution artifact must compute:

- `scenario_family`
- `effective_oversight_mode`
- `effective_execution_posture`
- `preview_lead`
- `feedback_window`
- `proceed_on_silence_allowed`
- `approval_required`
- `safe_interrupt_boundary_class`
- `overlap_policy`
- `backfill_policy`
- `pause_on_failure`
- `digest_cadence`
- `watch_route`
- `alert_route`
- `required_quorum`
- `recovery_profile`
- `finalize_policy`
- `safing_subset`
- `route_reason_codes`

## Recommended Surface

**Canonical derived surface**
`.octon/generated/effective/orchestration/missions/<mission-id>/scenario-resolution.yml`

**Human-facing projections**
- render summary excerpts into:
  - `generated/cognition/summaries/missions/<mission-id>/now.md`
  - `generated/cognition/summaries/missions/<mission-id>/next.md`

## Resolver Algorithm

1. Start with mission charter and mission class.
2. Load mission-class defaults from `mission-autonomy.yml`.
3. Load action-class / ACP / reversibility constraints for the current or next
   slice from deny-by-default policy.
4. Apply executor-profile constraints from `.octon/octon.yml`.
5. Apply live control truth:
   - directives
   - schedule state
   - lease state
   - mode state
   - autonomy burn state
   - breaker state
   - safing state
6. Apply higher-priority emergency or kill-switch precedence.
7. Emit one effective route with explicit rationale and freshness TTL.

## Scenario Families

The resolver should classify the effective route into one of these policy-defined
families:

- `observe`
- `campaign`
- `maintenance`
- `reconcile`
- `migration`
- `external_sync`
- `incident`
- `destructive`
- `release_sensitive`

The family may begin from `mission_class`, but may be **upgraded** by:
- executor profile
- action class
- reversibility class
- public/external effect
- breaker/safing state
- incident state

## Example Upgrades

- `maintenance` + external write + compensable-only recovery -> effective family
  `external_sync`
- `campaign` + public publish step -> effective family `release_sensitive`
- `observe` + bounded containment sub-mission -> effective family `incident`
- any family + irreversible finalize -> effective family `destructive`

## Required Behavioral Outcomes

### Routine housekeeping
- `silent`
- no preview push
- digest-only
- revert-based recovery

### Long-running refactor
- `notify` at mission open, then mostly `silent`/`notify`
- interruptible scheduled posture
- slice-level rollback and continuity

### Dependency patching
- `feedback_window` or `proceed_on_silence`
- environment/canary safe boundary
- rollback handle required

### Release maintenance
- analysis/stage may continue
- publish/finalize becomes `approval_required`

### Drift correction
- mission-class defaults plus ownership/attestation overlays
- route to `STAGE_ONLY` when required authorizations are missing

### Observe-only monitoring
- `silent`, `continuous`
- anomaly may fork an operate sub-mission with upgraded route

### Incident response
- minimal bounded containment allowed under emergency route
- breaker/safing/break-glass precedence explicitly visible

### Destructive work
- `approval_required`
- no autonomous point-of-no-return crossing

## Why This Is Better Than A New Registry

A separate scenario registry would duplicate:
- mission class
- ACP policy
- reversibility rules
- executor profiles
- live breaker/safing state

A derived resolver keeps authority where it already belongs and makes the
effective result explicit for both runtime and operators.

## Acceptance Rule

The cutover is not complete until:

- the resolver exists,
- the output is materialized,
- runtime uses it,
- operator views use it,
- scenario conformance tests validate it.

---

## Target Architecture

## Decision

Octon should perform an **atomic completion cutover** that finishes the
implementation of Mission-Scoped Reversible Autonomy without changing its
canonical name or replacing its governance spine.

The cutover release target is **0.6.0** and it must land as one repo-wide,
pre-1.0, clean-break update.

## Why This Is Needed

The repo currently contains a partially integrated MSRAOM implementation:

- the policy and contract backbone is real,
- but key control-plane and operator-plane pieces remain missing, weakly
  integrated, or contradictory.

The completion cutover resolves that state by making the repo match the model it
already claims to implement.

## Canonical Model Statement

**Mission-Scoped Reversible Autonomy** remains the canonical public-facing name.

It is defined as:

> A long-running Octon agent runs under standing mission delegation, publishes
> forward intent and explicit live mode, and commits durable change only through
> reversible ACP-governed slices with grants, receipts, recovery windows, and
> asynchronous human steering.

This continues to be Octon’s implementation of
**policy-governed reversible supervisory control**.

## Atomic Cutover Rules

1. **No dual live model.** Once merged, all live autonomous paths use the
   completed MSRAOM surfaces and contracts.
2. **Historical evidence remains.** Historical receipts and mission artifacts
   are not rewritten.
3. **Live contracts upgrade together.** Root manifest, mission scaffolds, runtime
   specs, runtime consumers, generated views, and tests land in the same cutover.
4. **Docs must match implementation.** Placeholder-only canonical surfaces are
   not acceptable after merge.
5. **No hidden fallback path.** If effective route or recovery data cannot be
   derived, the runtime must `STAGE_ONLY`, `SAFE`, or `DENY`, not improvise.

## Final Architecture Layers

### 1. Mission authority layer
Canonical surfaces:
- `instance/orchestration/missions/**`
- mission registry
- mission scaffolds

Role:
- durable mission charter
- owner reference
- scope IDs
- safe subset
- risk ceiling
- allowed action classes
- success/failure conditions

### 2. Policy layer
Canonical surfaces:
- `instance/governance/policies/mission-autonomy.yml`
- deny-by-default policy
- `.octon/octon.yml`
- ownership registry

Role:
- mission-class defaults
- ACP and reversibility rules
- executor-profile constraints
- ownership precedence
- digest and routing defaults

### 3. Mutable mission control layer
Canonical surfaces:
- `state/control/execution/missions/<mission-id>/**`

Role:
- continuity lease
- mode beacon
- forward intent register
- directives
- schedule control
- autonomy burn budgets
- circuit breakers
- subscriptions

### 4. Execution governance layer
Canonical surfaces:
- engine runtime request / grant / receipt / policy receipt contracts
- ACP enforcement
- egress and spend budget gates

Role:
- authorize each material attempt
- enforce mission-bound autonomy context
- preserve `STAGE_ONLY` and `DENY`

### 5. Recovery and finalize layer
Canonical surfaces:
- run receipts
- control receipts
- recovery windows
- finalize gating logic

Role:
- rollback or compensation handles
- finalize separation
- late-feedback semantics

### 6. Continuity and handoff layer
Canonical surfaces:
- `state/continuity/repo/missions/**`

Role:
- progress
- next handoff
- follow-up tasks
- unresolved blockers

### 7. Derived effective routing layer
Canonical surfaces:
- `generated/effective/orchestration/missions/<mission-id>/scenario-resolution.yml`

Role:
- materialize the effective scenario route used by runtime and operator views

### 8. Derived operator views
Canonical surfaces:
- `generated/cognition/summaries/missions/<mission-id>/{now,next,recent,recover}.md`
- `generated/cognition/summaries/operators/**`

Role:
- summary-first awareness
- mission/operator legibility
- no authority

## New Durable Contracts Required

The cutover must add and register:

- `mission-control-lease-v1.schema.json`
- `mode-state-v1.schema.json`
- `action-slice-v1.schema.json`
- `intent-register-v1.schema.json`
- `control-directive-v1.schema.json`
- `schedule-control-v1.schema.json`
- `autonomy-budget-v1.schema.json`
- `circuit-breaker-v1.schema.json`
- `subscriptions-v1.schema.json`
- `control-receipt-v1.schema.json`
- `scenario-resolution-v1.schema.json`

## Runtime Corrections Required

### 1. Mission-charter reader correction
- `owner_ref` becomes canonical
- legacy `owner` may be read only during migration
- post-cutover generated views and runtime behavior must be sourced from
  `owner_ref`

### 2. Policy consumption correction
The runtime must consume the mission-autonomy policy for:
- mission-class defaults
- preview timing
- overlap/backfill
- pause-on-failure
- default recovery windows
- autonomy-burn thresholds
- breaker actions
- safe interrupt boundary defaults
- ownership routing defaults

### 3. Recovery correction
The runtime may not invent default recovery semantics for material work. If
rollback/compensation or recovery window cannot be derived from effective route
and policy, the runtime must tighten to `STAGE_ONLY`, `SAFE`, or `DENY`.

### 4. Read-model correction
Mission and operator summaries must actually exist and be refreshable from
canonical mission control, evidence, and continuity surfaces.

## Scenario Resolution

The cutover explicitly adds **derived scenario resolution** as the missing
integration layer.

It is not a new authority registry. It is a materialized effective route that
compiles mission class, action class, reversibility, executor profile, mode
state, schedule control, autonomy budget, breaker state, and safing/incident
state into one coherent behavior contract.

This output must be consumed by:
- scheduler behavior
- preview publication
- digest routing
- operator read models
- recovery/finalize gating

## Contradictions Resolved

| Contradiction | Resolution |
| --- | --- |
| Repo declares generated mission/operator summaries but they are placeholder-only | Materialize them in the cutover |
| Runtime expects mission control files without durable contracts | Add the missing spec family and scaffolds |
| Mission charter v2 uses `owner_ref` but some readers still expect `owner` | Make `owner_ref` canonical and update readers |
| Mission-autonomy policy is richer than runtime behavior | Add explicit scenario resolver and policy-consuming runtime integration |
| Recovery data can fall back to hidden behavior | Require policy-derived recovery or tighten the path |

## Final Outcome

After this cutover, Octon should have:

- one complete MSRAOM implementation path,
- one mission control family with durable contracts,
- one scenario-resolution layer,
- one operator read-model family,
- one conformance suite that proves behavior across the required scenarios.

Anything less leaves the operating model incomplete.

---

## Implementation Plan

## Release And Cutover Shape

- current baseline: `0.5.6`
- target release: `0.6.0`
- cutover type: `atomic`, `clean break`, `pre-1.0`
- branch policy: one integration branch, no long-lived dual runtime behavior
- migration ID: `mission-scoped-reversible-autonomy-completion-cutover`

Historical evidence remains untouched. Live runtime behavior changes in one
merge.

## Workstream 1 — Root Manifest, Architecture Contracts, And Durable Ratification

### Changes
- bump `version.txt` to `0.6.0`
- update `.octon/octon.yml` to publish:
  - completed MSRAOM cutover release ID
  - mission control root bindings
  - generated effective route root
  - generated summary roots
  - runtime input bindings for mission-autonomy policy and ownership registry
- update umbrella architecture specification to:
  - declare mission control under `state/control/execution/missions/**`
  - declare retained control evidence under `state/evidence/control/**`
  - declare generated effective scenario routing and generated summaries
- update runtime-vs-ops contract
- update contract registry
- promote durable migration plan under
  `instance/cognition/context/shared/migrations/mission-scoped-reversible-autonomy-completion-cutover/plan.md`
- record decision lineage under `instance/cognition/decisions/**`

### Exit condition
All canonical placements are declared before runtime changes merge.

## Workstream 2 — Mission Authority And Scaffolding Completion

### Changes
- keep `octon-mission-v2` canonical
- update mission scaffold to create:
  - `mission.yml`
  - `mission.md`
  - `tasks.json`
  - `log.md`
  - mission control stubs for:
    - `lease.yml`
    - `mode-state.yml`
    - `intent-register.yml`
    - `directives.yml`
    - `schedule.yml`
    - `autonomy-budget.yml`
    - `circuit-breakers.yml`
    - `subscriptions.yml`
- update mission registry and mission readers
- fix all readers to consume `owner_ref`
- migrate any active missions in-tree to the final v2 charter and control-file family

### Exit condition
No active autonomous mission can exist without the complete control-file family.

## Workstream 3 — Add Missing Contracts

### Add under `.octon/framework/engine/runtime/spec/`
- `mission-control-lease-v1.schema.json`
- `mode-state-v1.schema.json`
- `action-slice-v1.schema.json`
- `intent-register-v1.schema.json`
- `control-directive-v1.schema.json`
- `schedule-control-v1.schema.json`
- `autonomy-budget-v1.schema.json`
- `circuit-breaker-v1.schema.json`
- `subscriptions-v1.schema.json`
- `control-receipt-v1.schema.json`
- `scenario-resolution-v1.schema.json`

### Update existing contracts
- `execution-request-v2.schema.json`
- `execution-receipt-v2.schema.json`
- `policy-receipt-v2.schema.json`
- `policy-digest-v2.md`

### Required semantics
- autonomous material execution requires mission, slice, and intent references
- mode/posture/reversibility must be explicit
- control receipts must exist for directive, schedule, breaker, lease, safing,
  and break-glass changes
- scenario-resolution freshness must be defined

### Exit condition
Every runtime-required control primitive has a schema and contract-registry entry.

## Workstream 4 — Runtime, Policy, And Scheduler Integration

### Kernel and policy engine
- require valid mission control files for active autonomous missions
- consume mission-autonomy policy, not just its existence
- derive effective route from mission class + ACP/action class + live control state
- remove hidden fallback recovery semantics
- emit mission-aware receipts and policy digests
- deny or stage-only when autonomy context or effective recovery is missing

### Orchestration runtime
- consume directives
- enforce safe-boundary pause
- distinguish future-run suspension vs active-run pause
- enforce overlap policy
- enforce backfill policy
- enforce pause-on-failure
- fork observe missions into operate sub-missions where policy allows
- block finalize when directives or recovery state demand it

### Exit condition
Scheduler and runtime behavior are demonstrably driven by canonical mission
control state and effective scenario resolution.

## Workstream 5 — Trust Tightening, Safing, And Break-Glass

### Changes
- derive autonomy burn counters from:
  - run receipts
  - control receipts
  - retries
  - rollback/compensation events
  - operator vetoes
  - incident evidence
- write `autonomy-budget.yml`
- trip and reset `circuit-breakers.yml`
- apply automatic mode tightening and scheduler actions
- implement safing subset enforcement
- implement break-glass authorize-update flow with receipts and TTL

### Exit condition
Autonomy burn and circuit breakers change behavior automatically based on
evidence, and those changes are operator-visible.

## Workstream 6 — Control Evidence, Continuity, And Generated Views

### Changes
- emit control receipts under `state/evidence/control/execution/**`
- keep continuity under `state/continuity/repo/missions/**`
- generate mission summaries:
  - `now.md`
  - `next.md`
  - `recent.md`
  - `recover.md`
- generate operator digests under
  `generated/cognition/summaries/operators/**`
- generate effective scenario resolution under
  `generated/effective/orchestration/missions/<mission-id>/scenario-resolution.yml`

### Exit condition
The repo no longer relies on placeholder-only summary or control-evidence roots.

## Workstream 7 — Assurance, Conformance, And Merge Gates

### Changes
- schema validation for all new contracts
- freshness validation for generated effective route and summaries
- conformance suite covering all required scenarios
- negative suite for missing control files, stale route data, missing recovery,
  ownership conflicts, and unauthorized break-glass
- merge gate that forbids docs overclaiming missing surfaces

### Exit condition
The cutover cannot merge unless the scenario and negative suites are green.

## Workstream 8 — Cleanup And Deprecation

### Changes
- remove or update stale references to placeholder-only generated views
- remove any runtime expectations for legacy mission fields after the cutover
- deprecate fallback logic that is no longer allowed
- archive this proposal after promotion

### Exit condition
No contradictory or stale live documentation remains.

## Sequencing

1. Workstream 1
2. Workstream 2 and 3 together
3. Workstream 4
4. Workstream 5
5. Workstream 6
6. Workstream 7
7. Workstream 8
8. release `0.6.0`

The cutover is **one merge**, but implementation work within the branch may
sequence in this order.

## Rollback Strategy

Because this is pre-1.0 and atomic, rollback is branch-level, not model-level:

- if the conformance suite fails, do not merge
- if merged and production-hosted workflows misbehave, revert the cutover
  branch and restore the previous release
- historical receipts remain intact either way

There is no supported long-lived split where some missions use the old partial
implementation and others use the completed one.

---

## Acceptance Criteria

The MSRAOM completeness cutover is ready for promotion only when all of the
following are true.

## Naming And Scope

1. The proposal explicitly keeps **Mission-Scoped Reversible Autonomy** as the
   canonical public-facing model name.
2. The proposal explicitly defines that model as Octon’s implementation of
   policy-governed reversible supervisory control.
3. The proposal explicitly states that the cutover is atomic and pre-1.0.
4. The proposal explicitly forbids a long-lived dual live operating model.
5. The proposal explicitly states that historical receipts are retained without
   rewrite.
6. The proposal explicitly states that live autonomous runtime behavior changes
   in one cutover.

## Root Manifest And Architecture Contracts

1. `version.txt` is bumped to `0.6.0`.
2. `.octon/octon.yml` is updated to publish the completion cutover release.
3. `.octon/octon.yml` is updated with runtime-input bindings for:
   - mission registry
   - mission control root
   - ownership registry
   - mission-autonomy policy
   - generated effective route root
   - generated mission/operator summary roots
4. The umbrella architecture specification is updated to declare mission-scoped
   execution control under `state/control/execution/missions/**`.
5. The umbrella architecture specification is updated to declare retained
   control evidence under `state/evidence/control/**`.
6. The umbrella architecture specification is updated to declare generated
   mission/operator summaries under `generated/cognition/summaries/**`.
7. The umbrella architecture specification is updated to declare generated
   effective scenario resolution under `generated/effective/**`.
8. The runtime-vs-ops contract is updated to keep mission-control automation
   inside canonical `state/**` or `generated/**` roots.
9. The contract registry is updated with every new schema introduced by the
   cutover.
10. A canonical governance principle file for Mission-Scoped Reversible
    Autonomy exists and is aligned with the final model.
11. ACP, reversibility, ownership/boundary, and progressive-disclosure
    principle files are updated to align with the completed model.

## Mission Authority Upgrade

1. `instance/orchestration/missions/registry.yml` remains v2 and is aligned with
   the final mission charter.
2. `instance/orchestration/missions/_scaffold/template/mission.yml` remains
   `octon-mission-v2`.
3. `mission.yml` v2 requires mission class.
4. `mission.yml` v2 requires owner reference (`owner_ref`).
5. `mission.yml` v2 requires risk ceiling.
6. `mission.yml` v2 requires allowed action classes.
7. `mission.yml` v2 requires safe-subset declaration.
8. `mission.yml` v2 requires scope IDs.
9. `mission.yml` v2 requires success criteria.
10. `mission.yml` v2 requires failure conditions.
11. `mission.md` scaffold explains mode, scope, safe subset, and safing.
12. Active missions are upgraded in the cutover branch.
13. Runtime readers consume `owner_ref` rather than legacy `owner`.
14. Any temporary legacy reader shim is covered by regression tests and removed
    once no active mission depends on it.

## Repo-Owned Policy And Ownership

1. `instance/governance/policies/mission-autonomy.yml` remains canonical.
2. The mission-autonomy policy defines mission-class default oversight modes.
3. The mission-autonomy policy defines execution postures.
4. The mission-autonomy policy defines preview timing defaults.
5. The mission-autonomy policy defines digest cadence defaults.
6. The mission-autonomy policy defines overlap defaults.
7. The mission-autonomy policy defines backfill defaults.
8. The mission-autonomy policy defines pause-on-failure defaults.
9. The mission-autonomy policy defines recovery-window defaults.
10. The mission-autonomy policy defines proceed-on-silence constraints.
11. The mission-autonomy policy defines autonomy-burn thresholds.
12. The mission-autonomy policy defines breaker actions.
13. The mission-autonomy policy defines safe interrupt boundary defaults.
14. The mission-autonomy policy defines quorum independence rules.
15. `instance/governance/ownership/registry.yml` remains canonical.
16. The ownership registry defines authoritative owners for non-path assets.
17. Directive precedence is explicitly defined across break-glass, kill switch,
    mission owner, ownership registry, `CODEOWNERS`, and subscribers.

## Runtime And Policy Contracts

1. `execution-request-v2.schema.json` remains canonical and aligned.
2. `execution-receipt-v2.schema.json` remains canonical and aligned.
3. `policy-receipt-v2.schema.json` remains canonical and aligned.
4. `policy-digest-v2.md` remains canonical and aligned.
5. `control-receipt-v1.schema.json` is added.
6. `action-slice-v1.schema.json` is added.
7. `intent-register-v1.schema.json` is added.
8. `mode-state-v1.schema.json` is added.
9. `control-directive-v1.schema.json` is added.
10. `schedule-control-v1.schema.json` is added.
11. `autonomy-budget-v1.schema.json` is added.
12. `circuit-breaker-v1.schema.json` is added.
13. `mission-control-lease-v1.schema.json` is added.
14. `subscriptions-v1.schema.json` is added.
15. `scenario-resolution-v1.schema.json` is added.
16. Autonomous execution requests require mission reference.
17. Autonomous execution requests require slice reference.
18. Autonomous execution requests require intent reference.
19. Autonomous execution requests require oversight mode.
20. Autonomous execution requests require execution posture.
21. Autonomous execution requests require reversibility class.
22. Autonomous execution requests require boundary ID.
23. Autonomous runtime launches deny when autonomy context is missing.
24. New execution receipts include rollback or compensation handle.
25. New execution receipts include recovery window.
26. New execution receipts include autonomy-budget state.
27. New execution receipts include breaker state.
28. Policy digests surface mission ID, slice ID, mode, reversibility, rollback
    handle, and recovery window.
29. Runtime does not use undocumented hardcoded recovery defaults for material
    execution.
30. Runtime consumes mission-autonomy policy rather than merely asserting that
    the file exists.

## Mutable Control Truth

1. `state/control/execution/missions/<mission-id>/lease.yml` exists and validates.
2. `.../mode-state.yml` exists and validates.
3. `.../intent-register.yml` exists and validates.
4. `.../directives.yml` exists and validates.
5. `.../schedule.yml` exists and validates.
6. `.../autonomy-budget.yml` exists and validates.
7. `.../circuit-breakers.yml` exists and validates.
8. `.../subscriptions.yml` exists and validates.
9. Existing `budget-state.yml` remains authoritative for spend/data budgets.
10. Existing `exception-leases.yml` remains authoritative for execution waivers.
11. No second mutable control plane is added outside canonical repo surfaces.
12. Mission scaffolding creates the full control-file family for autonomous
    missions.
13. Validators reject autonomous missions missing required control files.

## Retained Evidence And Continuity

1. `state/evidence/control/execution/**` exists as a retained evidence family.
2. Directives that affect active or future execution emit control receipts.
3. Authorize-updates emit control receipts.
4. Lease changes emit control receipts.
5. Schedule mutations emit control receipts.
6. Breaker trips and resets emit control receipts.
7. Safing changes emit control receipts.
8. Break-glass activations and clearings emit control receipts.
9. Mission continuity lives under `state/continuity/repo/missions/**`.
10. Mission continuity is not stored in generated views.
11. `Recent` summaries are projections over receipts and continuity, not a new
    authoritative journal.

## Mode Semantics

1. The model retains `silent`, `notify`, `feedback_window`,
   `proceed_on_silence`, and `approval_required`.
2. The model retains `interruptible_scheduled` as an execution posture rather
   than collapsing it into a flat mode list.
3. Silence is explicitly defined as continued delegation, not consent.
4. Proceed-on-silence is allowed only for reversible or tightly bounded
   compensable work with published feedback windows and healthy trust state.
5. Approval-required covers irreversible, public, financial, legal,
   credential, or no-credible-rollback actions.
6. `STAGE_ONLY` is explicitly defined as the humane fail-closed fallback.
7. Hard deny is explicitly defined for policy-violating or missing-context
   paths.
8. Safing is explicitly defined as authority contraction, not mere pause.

## Interaction Model

1. The completed model explicitly adopts `Inspect / Signal / Authorize-Update`.
2. `Inspect` is read-only and non-authoritative.
3. `Signal` is asynchronous steering, not approval.
4. `Authorize-Update` is authority mutation, not casual feedback.
5. External comments or UI interactions are not binding until translated into
   canonical control truth.
6. Humans can intervene before execution.
7. Humans can intervene during execution at safe boundaries.
8. Humans can intervene after execution through rollback/compensation and
   finalize blocking.

## Scheduling, Digests, And Notifications

1. The completed model explicitly distinguishes future-run suspension from
   active-run pause.
2. Overlap policy is explicit and machine-consumable.
3. Backfill policy is explicit and machine-consumable.
4. Pause-on-failure is explicit and machine-consumable.
5. Preview timing defaults are explicit and machine-consumable.
6. Digest cadence defaults by mission class are explicit and machine-consumable.
7. Awareness routing is owners-first and subscribers-second.
8. Continuous heartbeat chatter is explicitly rejected as a default awareness
   mechanism.
9. Scheduler runtime consumes the canonical schedule control record.
10. Scheduler runtime consumes the effective scenario-resolution output.

## Reversibility And Recovery

1. The completed model explicitly defines `reversible`, `compensable`, and
   `irreversible`.
2. The completed model explicitly states that compensation is weaker than
   rollback.
3. Promote and finalize remain separate steps.
4. Default recovery windows are defined in repo policy.
5. Late feedback semantics are defined before stage, after stage, after
   promote, after recovery expiry, and after finalize.
6. The completed model explicitly states that reversible design can reduce the
   need for blanket pre-execution approval.
7. The completed model explicitly states that some actions must not rely on
   “recover later”.
8. Rollback or compensation handles are surfaced in receipts and `recover.md`.

## Escalation And Trust Tightening

1. Autonomy burn budgets are separate from spend/data budgets.
2. The completed model defines `healthy`, `warning`, and `exhausted` burn states.
3. The completed model defines breaker trip conditions.
4. The completed model defines breaker actions.
5. The completed model defines safing behavior.
6. The completed model defines break-glass requirements.
7. The completed model requires postmortem follow-up for break-glass.
8. Runtime automatically updates autonomy burn from evidence.
9. Runtime automatically trips and resets breaker state based on evidence and
   authorized resets.

## Scenario Resolution

1. A derived scenario-resolution artifact exists under
   `generated/effective/orchestration/missions/<mission-id>/scenario-resolution.yml`.
2. The scenario-resolution artifact has a durable schema.
3. The scenario-resolution artifact is freshness-bounded.
4. Scheduler behavior consumes it.
5. Generated mission summaries consume it.
6. The route is derived from canonical mission, policy, and control surfaces.
7. No second authoritative scenario registry is introduced.
8. Scenario routing covers at least:
   - routine housekeeping
   - long-running refactor
   - dependency/security patching
   - release maintenance
   - infrastructure drift correction
   - cost cleanup
   - migration/backfill
   - external API sync
   - monitoring / observe-only
   - incident response
   - high-volume repetitive work
   - destructive high-impact work
   - absent human
   - late human feedback
   - conflicting human input

## Generated Operator Views

1. Generated mission `now.md` exists.
2. Generated mission `next.md` exists.
3. Generated mission `recent.md` exists.
4. Generated mission `recover.md` exists.
5. Generated operator digests exist under `generated/cognition/summaries/operators/**`.
6. Generated views are explicitly non-authoritative.
7. Generated views are refreshed from canonical control/evidence/continuity
   surfaces only.
8. Generated views are not placeholder-only after merge.

## Scenario Conformance

1. There is conformance coverage for routine repo housekeeping.
2. There is conformance coverage for long-running refactor.
3. There is conformance coverage for dependency patching.
4. There is conformance coverage for release maintenance.
5. There is conformance coverage for infrastructure drift correction.
6. There is conformance coverage for cost cleanup.
7. There is conformance coverage for migration/backfill.
8. There is conformance coverage for external sync.
9. There is conformance coverage for observe-only monitoring.
10. There is conformance coverage for incident containment.
11. There is conformance coverage for high-volume repetitive work.
12. There is conformance coverage for destructive irreversible work.
13. There is conformance coverage for absent-human behavior.
14. There is conformance coverage for late-feedback behavior.
15. There is conformance coverage for conflicting-human-input behavior.
16. There is conformance coverage for breaker and safing behavior.
17. There is conformance coverage for finalize-block behavior.

## Contradiction Cleanup

1. Repo docs no longer claim canonical surfaces that do not exist.
2. No runtime-required mission control file lacks a durable contract.
3. No orchestration reader uses legacy `owner` as canonical after the cutover.
4. No hidden fallback recovery semantics remain for material work.
5. No generated summary or effective route is used while stale.

---

## Validation Plan

The cutover is blocked on a full validation stack that proves MSRAOM is
complete, integrated, and internally coherent.

## Validation Layers

### 1. Schema Validation
Validate:
- all newly added mission-control and scenario-resolution schemas
- all updated execution and policy schemas
- mission scaffolds and active mission examples against the final schemas

### 2. Contract-Registry Alignment
Block merge if:
- a schema exists but is not in the contract registry
- a runtime-consumed file has no durable contract
- a documented canonical surface has no contract and no scaffold

### 3. Runtime Guards
Block merge if:
- autonomous execution can start without a valid mission ID
- autonomous execution can start without a valid slice ID
- autonomous execution can start without a valid intent ID
- a mission can run autonomously without a valid lease
- a stale or missing scenario-resolution artifact is silently ignored
- recovery semantics fall back to undocumented hardcoded behavior

### 4. Projection Freshness
Validate:
- generated effective route freshness
- generated mission summary freshness
- operator digest freshness
- consistent source refs in scenario resolution and summaries

### 5. Control Evidence Emission
Validate that the following create retained control receipts:
- directive application
- authorize-update application
- lease mutation
- schedule mutation
- breaker trip
- breaker reset
- safing change
- break-glass activation
- break-glass clearing

### 6. Reader Alignment
Regression tests must prove:
- `owner_ref` is consumed by runtime and generated views
- legacy `owner` is not the canonical read path after the cutover

## Scenario Conformance Suite

The cutover must include a blocking scenario suite that drives one mission fixture
or equivalent test harness through the following cases.

| Scenario | Expected route and outcome |
| --- | --- |
| Routine repo housekeeping | `silent`, digest-only, revert-based recovery |
| Long-running refactor | `notify` at mission open, interruptible scheduled posture, slice-level rollback |
| Dependency/security patching | `feedback_window` or `proceed_on_silence`, canary boundary, rollback handle |
| Release maintenance | staging allowed, publish/finalize `approval_required` |
| Infrastructure drift correction | mission-class default plus attestation overlay; `STAGE_ONLY` when required authority missing |
| Cost optimization / cleanup | soft-destructive proceed-on-silence allowed with recovery window; hard delete separated |
| Data migration / backfill | chunk boundaries, recovery profile, explicit finalize step |
| External API sync | at least `notify`; compensable route, not silent by default |
| Monitoring / observe-only | `silent`, continuous, observe-to-operate fork where policy allows |
| Production incident response | bounded emergency route, explicit containment rationale, breaker/safing awareness |
| High-volume repetitive work | campaign-level visibility, batch-level receipts, no per-item alert spam |
| Destructive high-impact work | `approval_required`, no autonomous point-of-no-return |
| Human absent | proceed only where declared; `STAGE_ONLY` or pause when required authority missing |
| Human late | rollback / compensation or finalize-block within recovery window |
| Conflicting human input | authoritative precedence or safe-boundary pause / stage-only |
| Breaker trip | mode tightens automatically; scheduler responds |
| Safing | authority contracts to safe subset |
| Break-glass | explicit override, TTL, receipts, and postmortem obligations |

## Negative Suite

The cutover must fail closed in these cases:

1. missing `lease.yml`
2. missing `intent-register.yml`
3. missing or stale `scenario-resolution.yml`
4. missing rollback/compensation data on a route that requires it
5. proceed-on-silence attempted on irreversible or disallowed work
6. unauthorized break-glass activation
7. missing ownership precedence resolution for conflicting directives
8. runtime tries to start a new run while `suspended_future_runs` is true
9. runtime crosses a point of no return while `block_finalize` is active
10. generated views drift from canonical source refs

## Required Test Assets

- at least one canonical sample mission fixture for each mission class
- one scenario-resolution fixture per scenario family
- control-receipt fixtures
- generated summary fixtures for at least one active mission and one operator

## Merge Gates

The cutover cannot merge until all of the following are true:

1. schema validation is green
2. contract registry validation is green
3. runtime guards are green
4. scenario suite is green
5. negative suite is green
6. generated summary freshness checks are green
7. control-evidence emission checks are green
8. doc-claim alignment checks are green
9. sample fixtures are committed
10. migration plan and evidence roots are created

## Post-Merge Verification

Immediately after merge:

- regenerate scenario-resolution and mission/operator summaries for sample missions
- verify no placeholder-only canonical directories remain
- verify control receipts emit for at least one directive and one breaker event
- verify branch release metadata points to `0.6.0`

---

## Cutover Checklist

Use this as the branch-level execution checklist for the atomic MSRAOM
completion cutover.

## Pre-Implementation

- [ ] Create durable migration plan under
      `.octon/instance/cognition/context/shared/migrations/mission-scoped-reversible-autonomy-completion-cutover/plan.md`
- [ ] Create migration evidence root under
      `.octon/state/evidence/migration/mission-scoped-reversible-autonomy-completion-cutover/`
- [ ] Record ratification decision under `instance/cognition/decisions/**`
- [ ] Reserve release target `0.6.0`

## Root Manifest And Architecture

- [ ] Update `version.txt`
- [ ] Update `.octon/octon.yml`
- [ ] Update umbrella architecture specification
- [ ] Update runtime-vs-ops contract
- [ ] Update contract registry
- [ ] Update MSRAOM principle and aligned governance principles

## Mission Authority And Scaffolding

- [ ] Update mission scaffold to create the full mission-control file family
- [ ] Validate mission registry and mission charter v2 alignment
- [ ] Migrate active missions to final v2 charter
- [ ] Fix orchestration readers to consume `owner_ref`

## Contracts

- [ ] Add `mission-control-lease-v1.schema.json`
- [ ] Add `mode-state-v1.schema.json`
- [ ] Add `action-slice-v1.schema.json`
- [ ] Add `intent-register-v1.schema.json`
- [ ] Add `control-directive-v1.schema.json`
- [ ] Add `schedule-control-v1.schema.json`
- [ ] Add `autonomy-budget-v1.schema.json`
- [ ] Add `circuit-breaker-v1.schema.json`
- [ ] Add `subscriptions-v1.schema.json`
- [ ] Add `control-receipt-v1.schema.json`
- [ ] Add `scenario-resolution-v1.schema.json`
- [ ] Update execution and policy v2 contracts as needed

## Runtime And Scheduler

- [ ] Enforce lease requirement for autonomous runs
- [ ] Enforce mission, slice, and intent references
- [ ] Publish forward intent register entries
- [ ] Consume directives
- [ ] Consume schedule control
- [ ] Enforce safe-boundary pause
- [ ] Implement overlap and backfill policies
- [ ] Implement pause-on-failure
- [ ] Derive recovery data from policy/effective route
- [ ] Remove hidden fallback recovery logic

## Trust Tightening And Emergency Paths

- [ ] Aggregate autonomy burn counters from evidence
- [ ] Write autonomy-budget state
- [ ] Trip and reset circuit breakers
- [ ] Enforce safing subset
- [ ] Implement break-glass authorize-update flow
- [ ] Emit control receipts for all control-plane mutations

## Generated Effective And Read Models

- [ ] Materialize `scenario-resolution.yml`
- [ ] Materialize mission `now.md`
- [ ] Materialize mission `next.md`
- [ ] Materialize mission `recent.md`
- [ ] Materialize mission `recover.md`
- [ ] Materialize operator digests
- [ ] Add freshness checks for generated outputs

## Assurance

- [ ] Add schema validation
- [ ] Add contract-registry alignment checks
- [ ] Add scenario conformance suite
- [ ] Add negative suite
- [ ] Add doc-claim alignment checks
- [ ] Add regression tests for `owner_ref`
- [ ] Add control-evidence emission tests

## Pre-Merge Final Review

- [ ] No placeholder-only canonical directories remain
- [ ] No runtime-required mission-control file lacks a schema
- [ ] No generated mission/operator surface is missing
- [ ] No hidden fallback recovery path remains for material work
- [ ] No stale docs claim functionality that is not wired
- [ ] Scenario suite is green
- [ ] Negative suite is green

## Merge And Immediate Verification

- [ ] Merge cutover branch
- [ ] Regenerate effective route and mission/operator summaries
- [ ] Verify at least one control receipt emitted in a sample run
- [ ] Verify at least one breaker trip/reset path in test evidence
- [ ] Verify `0.6.0` release metadata is visible
- [ ] Archive this proposal only after durable surfaces fully replace it

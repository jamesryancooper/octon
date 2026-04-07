# Implementation Plan

This plan turns the companion packet into promotable workstreams. It is scoped
to durable `.octon/**` targets. If the work also requires repo-local collateral
outside `.octon/**`, such as `.github/workflows/**`, that collateral should be
carried by linked repo-local work rather than mixed into this proposal
manifest.

## Workstream 0: Truth Freeze

Objective:

- stop closure-local artifacts from overstating completion during remediation.

Primary targets:

- `.octon/framework/constitution/claim-truth-conditions.yml`
- `.octon/instance/governance/closure/**`
- `.octon/generated/effective/closure/**`

Outputs:

- generated closure status model
- explicit pre-claim blocker ledger
- downgraded or removed hand-authored completion language where machine truth
  does not support it

## Workstream 1: Objective Model Repair

Objective:

- normalize workspace, mission, run, stage, and attempt semantics.

Primary targets:

- `.octon/framework/constitution/contracts/objective/**`
- `.octon/instance/charter/**`
- `.octon/instance/orchestration/missions/**`
- `.octon/state/control/execution/runs/**`

Outputs:

- stage contract and execution-attempt target shapes
- mission binding rules and transition-mode handling
- runtime validation that blocks contradictory mission-required runs

## Workstream 2: Authority Normalization

Objective:

- make the canonical authority chain universal across runtime and workflow
  entrypoints.

Primary targets:

- `.octon/framework/constitution/contracts/authority/**`
- `.octon/framework/engine/runtime/**`
- `.octon/state/control/execution/approvals/**`
- `.octon/state/control/execution/exceptions/**`
- `.octon/state/control/execution/revocations/**`

Outputs:

- route, decision, grant, lease, and revocation artifact flow
- normalized exception-lease lifecycle
- runtime checks that prevent consequential execution without valid authority
  context

## Workstream 3: Runtime Eventification And Recovery

Objective:

- make runtime state reconstructible and resume-safe.

Primary targets:

- `.octon/framework/constitution/contracts/runtime/**`
- `.octon/state/control/execution/runs/**`
- `.octon/state/continuity/**`
- `.octon/state/evidence/runs/**`

Outputs:

- append-oriented event truth
- rich checkpoints and continuity artifacts
- recovery, compensation, contamination, and rollback state that gates resume

## Workstream 4: Observability And Disclosure Contractization

Objective:

- make measurements, interventions, failures, and disclosure first-class and
  evidence-derived.

Primary targets:

- `.octon/framework/observability/**`
- `.octon/framework/constitution/contracts/disclosure/**`
- `.octon/state/evidence/disclosure/**`

Outputs:

- observability contract family or equivalent governed structure
- failure taxonomy and trace model
- generated RunCards, HarnessCards, and closure summaries

## Workstream 5: Proof, Lab, And Evaluator Parity

Objective:

- enforce proof-plane coverage across admitted tuples.

Primary targets:

- `.octon/framework/assurance/**`
- `.octon/framework/lab/**`
- `.octon/state/evidence/lab/**`

Outputs:

- blocking proof-plane gates for admitted tuples
- explicit evaluator-independence rules where required
- dossier links to proof and lab bundles

## Workstream 6: Support-Target Admission Hardening

Objective:

- keep the live support universe explicit, bounded, and machine-checked.

Primary targets:

- `.octon/instance/governance/support-targets.yml`
- `.octon/instance/governance/support-target-admissions/**`
- `.octon/instance/governance/support-dossiers/**`
- `.octon/instance/capabilities/runtime/packs/admissions/**`

Outputs:

- promotion, restriction, de-admission, and recertification fields
- validators that fail on support-claim drift
- explicit exclusion of `stage_only` tuples from live completion claims

## Workstream 7: Retirement And Build-To-Delete Operating System

Objective:

- make transitional machinery visible, governed, and removable.

Primary targets:

- `.octon/instance/governance/retirement/**`
- `.octon/state/evidence/governance/**`
- `.octon/framework/constitution/obligations/fail-closed.yml`

Outputs:

- retirement registry
- ablation and deletion evidence receipts
- fail-closed behavior for overdue or ownerless compensators

## Workstream 8: Final Claim Evaluation

Objective:

- allow a bounded completion claim only after the prior workstreams converge.

Primary targets:

- `.octon/framework/constitution/claim-truth-conditions.yml`
- `.octon/generated/effective/closure/**`
- `.octon/state/evidence/disclosure/releases/**`

Outputs:

- evidence-driven claim evaluator
- generated gate status and closure summary
- recertification rule for consecutive clean passes

## Sequencing

Recommended order:

1. Workstream 0
2. Workstream 1
3. Workstream 2
4. Workstream 3
5. Workstream 4
6. Workstream 6
7. Workstream 5
8. Workstream 7
9. Workstream 8

This order matches the companion packet's phased rollout: freeze truth
boundaries first, then repair objective and authority semantics, then make
runtime truth reconstructible, then harden disclosure, support admissions,
proof parity, retirement, and final claim evaluation.

## Completion Notes

- Promotion is not complete when the proposal package looks comprehensive; it
  is complete when the durable surfaces satisfy the acceptance criteria.
- Any remaining repo-local collateral outside `.octon/**` should be tracked as
  linked follow-on work so this package remains standards-conformant and
  scope-clean.

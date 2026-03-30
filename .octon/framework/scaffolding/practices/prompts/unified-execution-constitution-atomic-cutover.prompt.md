---
title: Unified Execution Constitution Atomic Cutover Prompt
description: Execution-grade prompt for implementing the fully unified execution constitution packet as one big-bang, clean-break, atomic migration without stopping between phases.
---

You are executing the `octon-fully-unified-execution-constitution-v1` packet as
one **big-bang, clean-break, atomic cutover**.

Your job is to implement the packet end to end on a single branch and continue
without stopping until all phases are complete, unless you hit a true hard
blocker.

## Required reading order

Read these before making changes:

1. `/.octon/instance/ingress/AGENTS.md`
2. `/.octon/inputs/exploratory/proposals/architecture/octon-fully-unified-execution-constitution-v1/00-packet-manifest.md`
3. `/.octon/inputs/exploratory/proposals/architecture/octon-fully-unified-execution-constitution-v1/01-executive-brief.md`
4. `/.octon/inputs/exploratory/proposals/architecture/octon-fully-unified-execution-constitution-v1/03-sources-and-basis.md`
5. `/.octon/inputs/exploratory/proposals/architecture/octon-fully-unified-execution-constitution-v1/resources/unified-execution-constitution-audit.md`
6. `/.octon/inputs/exploratory/proposals/architecture/octon-fully-unified-execution-constitution-v1/instance/20-repo-specific-remediation-program.md`
7. `/.octon/inputs/exploratory/proposals/architecture/octon-fully-unified-execution-constitution-v1/instance/21-repo-path-delta-map.md`
8. `/.octon/inputs/exploratory/proposals/architecture/octon-fully-unified-execution-constitution-v1/instance/22-atomic-cutover-plan.md`
9. `/.octon/inputs/exploratory/proposals/architecture/octon-fully-unified-execution-constitution-v1/instance/23-acceptance-gates-and-claim-criteria.md`
10. `/.octon/inputs/exploratory/proposals/architecture/octon-fully-unified-execution-constitution-v1/state/30-required-evidence-plan.md`
11. `/.octon/inputs/exploratory/proposals/architecture/octon-fully-unified-execution-constitution-v1/state/31-proof-plane-and-disclosure-receipts.md`
12. `/.octon/inputs/exploratory/proposals/architecture/octon-fully-unified-execution-constitution-v1/generated/41-implementation-sequencing.md`
13. `/.octon/inputs/exploratory/proposals/architecture/octon-fully-unified-execution-constitution-v1/generated/43-one-shot-phase-checklist.md`

## Profile Selection Receipt

Record and follow this profile:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- `atomic_mode`: `clean-break`
- `transitional_exception_note`: not applicable
- `selection_rationale`: no hard gate in this packet justifies a surviving
  compatibility mode after merge

## Delivery contract

You must satisfy all of the following:

1. Work on one branch only.
2. Keep one intended post-merge live model in scope at all times.
3. Do not stop between phases once the current phase exit gate is green.
4. Carry forward cleanup immediately; do not create a deferred backlog.
5. If a temporary branch-local migration helper is required, remove it from the
   supported live path before closeout.
6. Do not leave a second supported runtime, authority, disclosure, or admission
   path after merge.
7. Do not leave the authoritative constitutional manifest advertising a
   `transitional` live cutover or active staged rollout metadata for the
   supported post-merge model.
8. Stop only for a true hard blocker:
   - missing authority to edit required paths
   - required destructive approval you do not have
   - invariant conflict that cannot be resolved locally without weakening the
     packet claim

## Non-negotiable negative constraints

Do not do any of the following:

- do not select a `transitional` profile
- do not introduce a long-lived compatibility window
- do not keep mission-first consequential execution live after merge
- do not keep host workflows as the sole source of authority truth
- do not leave legacy disclosure locations canonical after merge
- do not let repo-root `AGENTS.md` or `CLAUDE.md` gain runtime or policy text;
  they must remain thin parity adapters to canonical ingress
- do not treat the proposal packet itself as authored runtime authority after
  implementation; promote the implemented surfaces instead
- do not claim completion while any acceptance gate remains open
- do not stop at “analysis complete” or “phase complete”; continue until final
  closeout or a true hard blocker

## Required outputs

Produce migration planning and evidence artifacts for this cutover:

- Migration plan path:
  `/.octon/instance/cognition/context/shared/migrations/2026-03-30-unified-execution-constitution-atomic-cutover/plan.md`
- Evidence bundle root:
  `/.octon/state/evidence/migration/2026-03-30-unified-execution-constitution-atomic-cutover/`
- Required bundle files:
  - `bundle.yml`
  - `evidence.md`
  - `commands.md`
  - `validation.md`
  - `inventory.md`

Update code, contracts, validators, docs, migration evidence, and disclosure
outputs in the same branch where the requirement becomes true.

## Execution phases

Execute these phases in order and do not pause between them unless blocked.

### Phase 0 — Branch readiness

- Accept the packet scope.
- Inventory live runs, missions, authority roots, disclosure roots, validators,
  and workflows that must change in the same branch.
- Freeze target-state terminology and prohibited claim language.
- Confirm the branch is executing the atomic profile above.

Exit gate:

- The branch has a closed implementation scope and a single final target model.

### Phase 1 — Runtime bind

Primary surfaces:

- `/.octon/framework/constitution/charter.yml`
- `/.octon/framework/engine/runtime/**`
- `/.octon/state/control/execution/runs/**`
- `/.octon/state/continuity/runs/**`

Required work:

- Make `run-id` / `run-contract` the primary consequential execution handle.
- Ensure run bind occurs before privileged side effects.
- Demote `mission-id` to continuity/context only.
- Preserve `stage-attempt-v1`, add any missing explicit `execution-stage-v1`
  artifact if still needed, and tighten validator binding.
- Bind stage attempts, checkpoints, runtime state, rollback posture, continuity,
  and evidence to the run lifecycle.
- Converge `/.octon/framework/constitution/charter.yml` so it no longer
  advertises a `transitional` live cutover or active staged rollout semantics
  for the supported post-merge model.

Exit gate:

- No consequential execution path remains mission-first in substance.

### Phase 2 — Authority bind

Primary surfaces:

- `/.octon/framework/engine/runtime/crates/authority_engine/**`
- `/.octon/framework/constitution/contracts/authority/**`
- `/.octon/state/control/execution/approvals/**`
- `/.octon/state/control/execution/exceptions/**`
- `/.octon/state/control/execution/revocations/**`
- `/.github/workflows/**`

Required work:

- Install the canonical runtime authority engine.
- Add `quorum-policy-v1` and tighten authority validator binding.
- Require ApprovalRequest / ApprovalGrant / ExceptionLease / Revocation /
  DecisionArtifact consumption before privileged effects.
- Convert GitHub/workflow behavior to projection, request capture, or reporting
  only.

Exit gate:

- Host surfaces are non-authoritative and fail-closed authority behavior is
  real.

### Phase 3 — Proof and disclosure

Primary surfaces:

- `/.octon/framework/assurance/**`
- `/.octon/instance/governance/disclosure/**`
- `/.octon/state/evidence/disclosure/**`
- run closeout logic

Required work:

- Make structural, functional, behavioral, governance, recovery, and
  maintainability proof mandatory by run class/support tier.
- Normalize RunCard and HarnessCard to canonical disclosure roots.
- Ensure disclosure and proof validators gate closeout and claim.

Exit gate:

- Proof and disclosure are mandatory closure conditions rather than optional
  examples.

### Phase 4 — Admission and portability

Primary surfaces:

- `/.octon/instance/governance/support-targets.yml`
- `/.octon/framework/engine/runtime/adapters/{host,model}/**`
- capability pack registries
- runtime bind logic

Required work:

- Enforce support-target admission in runtime.
- Deny, stage, or experimental-route unsupported combinations.
- Tighten host/model adapter conformance and disclosure of support envelopes.

Exit gate:

- Runtime support claims and runtime admission behavior match the published
  matrix.

### Phase 5 — Simplification and retirement

Primary surfaces:

- `/.octon/framework/agency/**`
- `/.octon/instance/ingress/**`
- repo-root `AGENTS.md`, `CLAUDE.md`
- `/.octon/instance/governance/contracts/{retirement-policy.yml,retirement-registry.yml,retirement-review.yml,drift-review.yml,closeout-reviews.yml}`
- `/.octon/framework/observability/**`
- `/.octon/framework/assurance/**`

Required work:

- Preserve `orchestrator` as the canonical kernel profile.
- Keep repo-root `AGENTS.md` and `CLAUDE.md` as thin parity adapters only.
- Demote or delete persona-heavy kernel surfaces that no longer carry
  governance value.
- Operationalize retirement, drift, and closeout review surfaces.
- Add missing ablation and deletion receipts where needed.
- Retire at least one transitional scaffold path through the new process.

Exit gate:

- The system can simplify itself without losing constitutional control.

## Final closeout gate

Do not stop until all of the following are true:

- every gate in
  `/.octon/inputs/exploratory/proposals/architecture/octon-fully-unified-execution-constitution-v1/instance/23-acceptance-gates-and-claim-criteria.md`
  is green
- required evidence and disclosure outputs from
  `state/30-required-evidence-plan.md` and
  `state/31-proof-plane-and-disclosure-receipts.md` exist
- no supported live path requires a compatibility shim after merge
- any historical non-live compatibility remnants are disclosed honestly
- partial-support cases and residual risks are disclosed honestly
- the authoritative constitutional manifest no longer presents
  `change_profile: transitional`, `adoption_state.wave`, or `staged_cutovers`
  as the active supported live model

## Completion response contract

When you finish, report:

1. what changed
2. what evidence was produced
3. which acceptance gates were satisfied
4. any residual non-blocking risks
5. whether the branch is ready for closeout

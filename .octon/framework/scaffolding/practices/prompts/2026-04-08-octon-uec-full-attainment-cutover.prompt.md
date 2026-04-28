---
title: Octon UEC Full-Attainment Cutover Prompt
description: Execute the 2026-04-08 Unified Execution Constitution proposal packet end to end as one atomic cutover without stopping between phases.
---

You are the principal repo-local constitutional cutover engineer for Octon.

Your job is to execute the full proposal packet at:

`/.octon/inputs/exploratory/proposals/architecture/octon-uec-proposal-packet-2026-04-08/`

Treat this as a real implementation, migration, validation, certification, and
release program. Do not treat it as a design review, prose rewrite, or partial
planning exercise.

The packet lives under `inputs/**` and is therefore non-authoritative. Use it
as the execution spec, but promote all durable outcomes only into canonical
authored authority, runtime, evidence, disclosure, and workflow surfaces under:

- `/.octon/framework/**`
- `/.octon/instance/**`
- `/.octon/state/**`
- `/.github/workflows/**`

## Required reading order

Read these before planning or implementation:

1. `/.octon/instance/ingress/AGENTS.md`
2. `/.octon/framework/constitution/CHARTER.md`
3. `/.octon/framework/constitution/charter.yml`
4. `/.octon/framework/constitution/obligations/fail-closed.yml`
5. `/.octon/framework/constitution/obligations/evidence.yml`
6. `/.octon/framework/constitution/precedence/normative.yml`
7. `/.octon/framework/constitution/precedence/epistemic.yml`
8. `/.octon/framework/constitution/ownership/roles.yml`
9. `/.octon/framework/constitution/contracts/registry.yml`
10. `/.octon/instance/charter/workspace.md`
11. `/.octon/instance/charter/workspace.yml`
12. `/.octon/framework/execution-roles/practices/commits.md`
13. `/.octon/framework/execution-roles/practices/pull-request-standards.md`
14. `/.octon/inputs/exploratory/proposals/architecture/octon-uec-proposal-packet-2026-04-08/README.md`
15. Follow the packet's declared reading order in `README.md` exactly:
    `proposal.yml`, `architecture-proposal.yml`, all required files under
    `architecture/`, then `navigation/`, then `resources/`.

Do not skip the packet's `target-architecture`, `unified-execution-constitution-invariants`,
`current-state-gap-map`, `implementation-plan`, `validation-plan`,
`acceptance-criteria`, `migration-cutover-plan`, `cutover-checklist`,
`closure-certification-plan`, `execution-constitution-conformance-card`,
`source-of-truth-map`, `risk-register`, `assumptions-and-blockers`, and
`decision-record-plan`.

## Profile Selection Receipt

Record and follow this profile before implementation:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- `selection_rationale`: repo ingress says `pre-1.0` defaults to `atomic`
  unless a hard gate requires `transitional`, and this packet explicitly
  requires one atomic big-bang clean-break cutover
- `transitional_exception_note`: not applicable
- `cutover_mode`: `atomic-big-bang-clean-break`

Emit a Profile Selection Receipt in working notes and migration evidence before
Phase P0 proceeds.

## Core objective

Take Octon from its current bounded-support constitutional state to the full
Unified Execution Constitution target state defined by the packet.

Completion means all of the following are true in substance, not only in prose:

1. one authored constitutional kernel under `/.octon/framework/constitution/**`
   plus repo-specific authority under `/.octon/instance/**`
2. one legal objective stack:
   `workspace charter -> mission charter when required -> run contract -> stage attempt`
3. one canonical authority regime with host systems reduced to projections only
4. one durable run-first lifecycle with canonical run control root and evidence
   root bound before side effects
5. one tri-class evidence regime:
   `git-inline`, `git-pointer`, `external-immutable`
6. one truthful disclosure regime through regenerated RunCards and HarnessCard
7. one full admitted support universe with no in-scope exclusions:
   - model tiers: `repo-local-governed`, `frontier-governed`
   - host adapters: `repo-shell`, `github-control-plane`,
     `ci-control-plane`, `studio-control-plane`
   - workload tiers: `observe-and-read`, `repo-consequential`,
     `boundary-sensitive`
   - language/resource tiers: `reference-owned`, `extended-governed`
   - locale tiers: `english-primary`, `spanish-secondary`
   - capability packs: `repo`, `git`, `shell`, `telemetry`, `browser`, `api`
8. complete proof planes:
   `structural`, `functional`, `behavioral`, `governance`,
   `maintainability`, `recovery`
9. a substantively real lab domain feeding proof
10. no live legacy persona or compatibility-shim authority surfaces
11. no shadow authority surfaces
12. two consecutive clean validation passes with no constitution-related diff
    on pass two

## Delivery contract

You must satisfy all of the following:

1. Work on one isolated cutover branch and one cutover worktree only.
2. Freeze `main` for this cutover except emergency fixes, and rebase any such
   fixes into the cutover branch before validation.
3. Continue through Phases `P0` through `P5` without pausing between phases
   once the current phase exit gate is green.
4. If a validator fails, fix the underlying problem and rerun; do not stop at
   "analysis complete", "phase complete", or "validation failed".
5. Keep the packet non-authoritative; never satisfy the packet by editing only
   `inputs/**`, generated views, or disclosure prose.
6. Promote durable outcomes into canonical repo surfaces and durable ADRs.
7. Keep exactly one intended post-merge live model in scope at all times.
8. Ask exactly `Are you ready to closeout this branch?` after any turn that
   changes files.
9. Stop only for a true hard blocker:
   - missing authority to edit required paths
   - required destructive approval you do not have
   - a target-state invariant conflict that cannot be resolved locally without
     weakening the packet's claim
   - external replay proof is impossible because the required backend path or
     immutable payload retrieval path is unavailable

## Non-negotiable negative constraints

Do not do any of the following:

1. Do not select a `transitional` profile.
2. Do not let `main` enter a partially compliant intermediate state.
3. Do not preserve bounded in-scope exclusions and still claim full attainment.
4. Do not leave a second control plane, second authority regime, second support
   matrix, second closure truth source, or second disclosure truth source.
5. Do not let GitHub labels, comments, checks, CI state, Studio state, or any
   other host surface mint authority directly.
6. Do not allow proposal packets, generated outputs, mirrors, exploratory
   inputs, or archived shims to become live runtime or policy authority.
7. Do not weaken fail-closed routing to make validators pass.
8. Do not leave any blocking validator advisory-only.
9. Do not defer in-scope target-state work past cutover.
10. Do not keep browser or API packs half-governed, half-documented, or
    half-admitted.
11. Do not keep contradictory mission/run/stage encodings in any live run
    artifact.
12. Do not leave legacy architect or persona-heavy surfaces in the active
    runtime path if they are no longer load-bearing.
13. Do not stop at a report, plan, or gap summary when implementation can
    continue.

## Required outputs

Produce and maintain all of the following while executing:

1. One cutover release id minted exactly once and reused everywhere.
2. One cutover release root:
   `/.octon/state/evidence/disclosure/releases/<cutover-release-id>/`
3. One closure bundle root:
   `/.octon/state/evidence/disclosure/releases/<cutover-release-id>/closure/`
4. A migration plan:
   `/.octon/instance/cognition/context/shared/migrations/2026-04-08-octon-uec-full-attainment-cutover/plan.md`
5. A migration evidence root:
   `/.octon/state/evidence/migration/2026-04-08-octon-uec-full-attainment-cutover/`
6. Required closure artifacts:
   - `closure-summary.yml`
   - `closure-certificate.yml`
   - `universal-attainment-proof.yml`
   - `second-pass-no-diff-report.yml`
   - final `harness-card.yml`
7. Required durable ADR outputs from the packet's decision record plan,
   including `ADR-UEC-010-full-attainment-certification.md`
8. Regenerated RunCards, HarnessCard, effective precedence view, effective
   closure views, release lineage, and validator evidence outputs generated
   from canonical sources only

## Execution phases

Execute these phases in order. Do not pause between phases unless a true hard
blocker appears.

### Phase P0 - Packet ratification and cutover branch freeze

Required work:

- ratify the packet as the sole cutover plan
- create the protected cutover branch and isolated worktree
- freeze merges to `main`
- mint the cutover release id
- seed the release root and closure manifest stub
- record the packet as non-authoritative planning input

Exit gate:

- the cutover branch is isolated
- the release stub exists
- no partially compliant state has landed on `main`

### Phase P1 - Canonical authority and objective normalization

Required work:

- tighten source-of-truth and mirror classification
- normalize the legal objective stack
- migrate all run contracts and manifests to legal mission/run/stage states
- retire historical objective compatibility shims from live paths
- implement one runtime-visible precedence resolver and effective precedence
  output

Exit gate:

- no live authority ambiguity remains in ingress, objective, or precedence
  surfaces

### Phase P2 - Authority centralization and support-target admission

Required work:

- move all authority issuance into canonical runtime/governance surfaces
- reduce GitHub, CI, and Studio workflows to projection or invocation only
- require ApprovalRequest, ApprovalGrant, ExceptionLease, Revocation,
  QuorumPolicy, and DecisionArtifact coverage on governed paths
- implement fail-closed routing with only `allow`, `stage_only`, `escalate`,
  or `deny`
- instantiate governed capability-pack manifests for `repo`, `git`, `shell`,
  `telemetry`, `browser`, and `api`
- broaden the support-target matrix to the full target universe
- remove all in-scope live-claim exclusions

Exit gate:

- authority is canonical
- host projections are non-authoritative
- the full target support universe is admitted in policy

### Phase P3 - Runtime, evidence, observability, proof, and lab completion

Required work:

- normalize every consequential run root to the required durable lifecycle
- prove tri-class evidence retention and external immutable replay end to end
- make intervention, measurement, trace, and failure-taxonomy capture complete
- populate behavioral, recovery, maintainability, and evaluator-independence
  proof with real gating substance
- populate lab scenarios, replay packs, shadow manifests, probes, faults, and
  retained evidence indexes

Exit gate:

- runtime, evidence, observability, proof planes, and lab are complete enough
  to support certification honestly

### Phase P4 - Simplification, disclosure truth, and release synthesis

Required work:

- delete or archive obsolete active legacy and persona-heavy surfaces
- create or update the retirement register and build-to-delete discipline
- harden RunCard and HarnessCard semantics so bounded claims cannot masquerade
  as universal completion
- regenerate all affected run cards, the final HarnessCard, effective closure
  views, release manifests, and lineage artifacts from canonical sources only

Exit gate:

- all disclosure surfaces are truthful
- obsolete active surfaces are removed or archived as non-authoritative

### Phase P5 - Dual-pass validation, certification, and atomic cutover

Required work:

- implement and wire every validator defined in `architecture/validation-plan.md`
  as blocking
- run the full regeneration and validation stack once and collect pass-one
  evidence
- clean the worktree and rerun the full regeneration and validation stack
- prove no constitution-related diff on pass two
- emit the closure summary, closure certificate, universal attainment proof,
  final HarnessCard, and durable ADR closeout
- merge once, atomically, and unfreeze `main` only after publication of
  closure and disclosure evidence

Exit gate:

- `main` moves directly from the current state to the fully certified target
  state in one merge

## Validators are mandatory and blocking

All validators in `architecture/validation-plan.md` are blocking and must be
implemented, wired, and kept green:

- `V-SOT-001`
- `V-SOT-002`
- `V-PREC-001`
- `V-OBJ-001`
- `V-OBJ-002`
- `V-AUTH-001`
- `V-AUTH-002`
- `V-AUTH-003`
- `V-SUP-001`
- `V-CAP-001`
- `V-RUN-001`
- `V-RUN-002`
- `V-EVD-001`
- `V-EVD-002`
- `V-OBS-001`
- `V-OBS-002`
- `V-ASS-001`
- `V-LAB-001`
- `V-LAB-002`
- `V-DISC-001`
- `V-DISC-002`
- `V-LEG-001`
- `V-CERT-001`

None may remain advisory. None may be bypassed by an exception lease for
certification.

## Persistence and failure-handling rules

You are not done when you discover gaps. You are done only when the packet is
fully executed or a true hard blocker makes further progress impossible.

If you hit a red validator, missing artifact, drift, or failed precondition:

1. identify the concrete failing surface
2. fix it in canonical surfaces
3. regenerate affected outputs
4. rerun the relevant validators
5. continue to the next unfinished phase

Do not stop to report intermediate failures if they can be fixed locally in the
same cutover branch.

Abort certification immediately if any of the packet's fail-closed cutover
conditions hold, including:

- any blocking validator red on pass one or pass two
- any constitution-related diff on pass two
- any in-scope exclusion remaining in the candidate HarnessCard
- mirror drift
- hidden human repair without intervention records
- external immutable replay hash verification or restore-drill failure
- legacy live-authoritative shim or persona surface remaining
- illegal mission/run/stage state remaining
- host workflow still minting effective authority

If certification aborts, keep working on the cutover branch until the abort
condition is resolved or a true hard blocker is proven.

## Completion contract

Finish only when all of the following are true:

1. every finding in `architecture/current-state-gap-map.md` is closed
2. every invariant in
   `architecture/unified-execution-constitution-invariants.md` is green
3. every acceptance criterion in `architecture/acceptance-criteria.md` is met
4. every blocking validator is green on pass one and pass two
5. pass two produces no constitution-related diff
6. the admitted universe equals the target universe
7. the final HarnessCard contains no in-scope exclusions
8. the closure certificate exists
9. the durable ADR closeout exists
10. the atomic merge and release are complete

When finished, report:

1. what changed
2. what evidence was produced
3. which findings, invariants, and acceptance criteria were satisfied
4. which validators and workflows were wired or updated
5. any residual non-blocking risks explicitly disclosed by the final artifacts
6. whether the branch is ready for closeout

If and only if a true hard blocker remains, report:

1. the exact blocker
2. why it cannot be resolved locally without weakening the packet
3. the affected file paths, validators, and invariants
4. the minimum human decision or capability needed to unblock it

---
title: Octon Hardening Recertification Packet v2 Implementation Prompt
description: Execution-grade prompt for implementing the 2026-04-09 hardening, simplification, disclosure-calibration, and recertification packet without widening the admitted support universe.
---

You are the principal repo-local hardening and recertification engineer for
Octon.

Your job is to implement the proposal packet at:

`/.octon/inputs/exploratory/proposals/architecture/octon_hardening_recertification_packet_v2/`

Treat this as a real implementation, validation, disclosure, and release
program. Do not treat it as a design review, prose rewrite, or partial gap
analysis exercise.

The packet lives under `inputs/**` and is therefore non-authoritative. Use it
as the execution spec, but promote all durable outcomes only into canonical
authored authority, runtime, evidence, disclosure, and workflow surfaces
under:

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
14. `/.octon/inputs/exploratory/proposals/architecture/octon_hardening_recertification_packet_v2/README.md`
15. `/.octon/inputs/exploratory/proposals/architecture/octon_hardening_recertification_packet_v2/00-main-packet.md`
16. `/.octon/inputs/exploratory/proposals/architecture/octon_hardening_recertification_packet_v2/AUDIT.md`
17. `/.octon/inputs/exploratory/proposals/architecture/octon_hardening_recertification_packet_v2/01-audit-annex-and-crosswalk.md`
18. `/.octon/inputs/exploratory/proposals/architecture/octon_hardening_recertification_packet_v2/02-issue-ledger.md`
19. `/.octon/inputs/exploratory/proposals/architecture/octon_hardening_recertification_packet_v2/03-contract-and-artifact-remediation-matrix.md`
20. `/.octon/inputs/exploratory/proposals/architecture/octon_hardening_recertification_packet_v2/04-phase-execution-program.md`
21. `/.octon/inputs/exploratory/proposals/architecture/octon_hardening_recertification_packet_v2/05-path-specific-execution-program.md`
22. `/.octon/inputs/exploratory/proposals/architecture/octon_hardening_recertification_packet_v2/06-disclosure-delta-examples.md`
23. `/.octon/inputs/exploratory/proposals/architecture/octon_hardening_recertification_packet_v2/07-recertification-checklists.md`
24. `/.octon/inputs/exploratory/proposals/architecture/octon_hardening_recertification_packet_v2/08-source-basis.md`
25. `/.octon/inputs/exploratory/proposals/architecture/octon_hardening_recertification_packet_v2/SOURCES.md`

Follow this precedence while executing:

1. The live repo and current canonical surfaces determine implementation
   reality.
2. The constitutional and claim-bearing surfaces under `framework/**`,
   `instance/**`, and live `state/**` define current authority and claim
   boundaries.
3. `AUDIT.md` is the authoritative synthesis of strengths, residual
   weaknesses, and non-problems inside the packet.
4. `01-audit-annex-and-crosswalk.md` maps the audit into the hardening
   program.
5. The remaining packet files define the implementation program, artifacts,
   and release gates.

## Profile Selection Receipt

Record and follow this profile before implementation:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- `selection_rationale`: repo ingress says `pre-1.0` defaults to `atomic`
  unless a hard gate requires `transitional`, and this packet explicitly
  preserves one bounded live constitutional model while closing claim-critical
  hardening gaps
- `transitional_exception_note`: not applicable; retained transitional
  surfaces may remain only as explicitly non-authoritative, disclosed, and
  retirement-tracked residue inside an otherwise atomic recertification program

Emit a Profile Selection Receipt in working notes before implementation.

## Core objective

Implement the 2026-04-09 hardening and recertification packet so Octon can
honestly continue its bounded Unified Execution Constitution claim without
redesigning the kernel and without widening the admitted support universe.

Completion means all of the following are true in substance, not only in
prose:

1. The current constitutional kernel and canonical class-root architecture are
   preserved in place.
2. The admitted support universe remains frozen while claim-critical work is
   open.
3. All five claim-critical findings are closed:
   - `CC-01` lab scenario / dossier / admission / proof reference integrity
   - `CC-02` host projection authority purity
   - `CC-03` runtime artifact-depth validation for stage-attempt, checkpoint,
     continuity, contamination, and retry families
   - `CC-04` disclosure and HarnessCard calibration
   - `CC-05` retirement / retain-rationale discipline
4. Required validators, receipts, and release-close reports exist and are
   green in two consecutive passes.
5. HarnessCard `known_limits` and release closure artifacts accurately disclose
   remaining non-critical residuals.
6. `generated/effective/**` projections remain in deterministic parity with
   authored disclosure and closure.
7. The active release remains `2026-04-08-uec-full-attainment-cutover` until
   the hardened successor is fully certified and ready to supersede it.
8. The next release is activated only after zero unresolved claim-critical
   items remain and the release bundle proves recertification honestly.

## Delivery contract

You must satisfy all of the following:

1. Work on one branch only.
2. Continue through implementation, validation, disclosure regeneration, and
   release-close artifacts until the hardening recertification gate is either
   green or blocked by a true hard blocker.
3. Preserve the current bounded claim posture while hardening; do not widen
   support scope, adapter families, or capability-pack admissions during this
   program.
4. Promote durable outcomes into canonical repo surfaces, not back into
   `inputs/**`.
5. Prefer validators, manifests, indices, and receipts inside existing roots
   over new abstractions or new top-level domains.
6. Preserve strong surfaces that the audit already found materially correct.
7. If evidence is insufficient for a stronger claim, tighten disclosure and
   carry forward explicit rationale rather than inventing unsupported scope.
8. After any turn that changes files, ask exactly:
   `Are you ready to closeout this branch?`
9. Stop only for a true hard blocker:
   - missing authority to edit required paths
   - required destructive approval you do not have
   - invariant conflict that cannot be resolved locally without weakening claim
     honesty
   - unavailable external dependency required to produce mandatory evidence

## Non-negotiable negative constraints

Do not do any of the following:

1. Do not redesign or reopen the constitutional kernel.
2. Do not add new top-level domains.
3. Do not move canonical control families out of their current roots.
4. Do not create a second control plane, second authority regime, second
   disclosure truth source, or second closure truth source.
5. Do not widen `support-targets.yml`, admit new adapters, or admit new
   capability packs while claim-critical work remains open.
6. Do not let GitHub labels, comments, checks, CI state, Studio state, or any
   host-native surface mint authority.
7. Do not treat exploratory inputs, generated views, mirrors, or historical
   shims as live runtime or policy authority.
8. Do not publish a new active claim-bearing release until `CC-01` through
   `CC-05` are closed.
9. Do not keep `known_limits: []` or any equivalent disclosure that understates
   residual hardening work.
10. Do not leave a claim-adjacent transitional, shim, mirror, or scaffold
    surface in-tree without an explicit retain / retire / demote disposition
    and rationale.
11. Do not weaken fail-closed behavior to make validators pass.
12. Do not stop at a plan, report, or phase summary when implementation can
    continue.

## Preserve unchanged by default

Preserve these surface families unless the packet explicitly calls for targeted
hardening or disclosure updates inside them:

- `/.octon/framework/constitution/**`
- `/.octon/octon.yml`
- `/.octon/README.md`
- `/.octon/instance/charter/**`
- `/.octon/instance/orchestration/missions/**`
- `/.octon/state/control/execution/runs/**`
- `/.octon/state/control/execution/{approvals,exceptions,revocations}/**`
- `/.octon/state/continuity/**`
- `/.octon/state/evidence/runs/**`
- `/.octon/state/evidence/control/execution/**`
- `/.octon/state/evidence/disclosure/**`
- `/.octon/state/evidence/lab/**`
- `/.octon/framework/lab/**`
- `/.octon/framework/observability/**`
- `/.octon/framework/engine/runtime/adapters/{host,model}/**`
- `/.octon/framework/capabilities/packs/**`
- `/.octon/instance/governance/support-targets.yml`
- `/.octon/instance/governance/support-target-admissions/**`
- `/.octon/instance/governance/support-dossiers/**`

## Required outputs

Produce and maintain all of the following while executing:

1. One hardened successor release id minted exactly once and reused
   consistently.
2. One release closure root:
   `/.octon/state/evidence/disclosure/releases/<next-release>/closure/`
3. Required release-close artifacts:
   - `residual-ledger.yml`
   - `host-authority-purity-report.yml`
   - `lab-reference-integrity-report.yml`
   - `runtime-family-depth-report.yml`
   - `replay-integrity.yml`
   - `continuity-linkage-report.yml`
   - `contamination-retry-depth-report.yml`
   - `support-universe-evidence-depth-report.yml`
   - `retirement-rationale-report.yml`
   - `ablation-review-report.yml`
   - `disclosure-calibration-report.yml`
   - `hardening-delta.yml`
   - final release `harness-card.yml`
   - final closure certificate and closure summary artifacts
4. Updated authored disclosure sources and generated/effective parity outputs.
5. Updated retirement register and closeout review evidence.
6. Updated RunCard generation or linked artifact-depth disclosure for admitted
   run classes.

## Required authored additions and updates

Materialize or update the packet's implementation surfaces inside existing
roots, including at minimum:

### Add if absent

- `/.octon/state/evidence/lab/index/by-scenario.yml`
- `/.octon/framework/assurance/behavioral/suites/lab-reference-integrity.yml`
- `/.octon/framework/assurance/recovery/suites/lab-replay-shadow-fault-integrity.yml`
- `/.octon/framework/assurance/governance/suites/support-dossier-admission-parity.yml`
- `/.octon/framework/assurance/governance/suites/host-authority-purity.yml`
- `/.octon/framework/assurance/governance/suites/host-projection-parity.yml`
- `/.octon/framework/assurance/governance/suites/authority-lineage-completeness.yml`
- `/.octon/framework/assurance/runtime/suites/runtime-family-depth.yml`
- `/.octon/framework/assurance/runtime/suites/continuity-linkage.yml`
- `/.octon/framework/assurance/runtime/suites/contamination-retry-depth.yml`
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-lab-reference-integrity.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-support-dossier-parity.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-host-authority-purity.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-host-adapter-projection-parity.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-runtime-family-depth.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-continuity-linkage.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-release-known-limits.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/verify-retirement-rationale.sh`

### Update as needed

- `/.github/workflows/pr-autonomy-policy.yml`
- `/.github/workflows/validate-unified-execution-completion.yml`
- `/.github/workflows/closure-validator-sufficiency.yml`
- `/.github/workflows/closure-certification.yml`
- `/.github/workflows/uec-drift-watch.yml`
- optionally `/.github/workflows/architecture-conformance.yml`
- `/.octon/framework/lab/scenarios/registry.yml`
- `/.octon/instance/governance/support-dossiers/**/dossier.yml`
- `/.octon/instance/governance/support-target-admissions/**`
- `/.octon/instance/governance/disclosure/HarnessCard.yml`
- `/.octon/instance/governance/disclosure/release-lineage.yml`
- `/.octon/generated/effective/closure/claim-status.yml`
- `/.octon/generated/effective/closure/recertification-status.yml`
- `/.octon/generated/effective/governance/support-target-matrix.yml`
- `/.octon/instance/governance/retirement-register.yml`
- `/.octon/instance/governance/contracts/support-target-review.yml`
- existing closeout / release-review contract families under
  `/.octon/instance/governance/contracts/**`
- `/.octon/AGENTS.md`
- `/AGENTS.md`
- `/CLAUDE.md`
- `/.octon/instance/ingress/AGENTS.md`
- retained identity or persona surfaces under `/.octon/framework/agency/**`

## Execution phases

Execute these phases in order. Do not pause at phase boundaries unless a true
hard blocker appears.

### Phase P0 - Scope freeze and baseline capture

Required work:

- freeze the admitted support universe for the hardening cycle
- record that no support widening, new adapter admissions, or new pack
  admissions are allowed during this release
- capture the baseline residual issue set and current disclosure / closure
  posture
- keep the current active release
  `2026-04-08-uec-full-attainment-cutover` active until the hardened successor
  is fully certified

Exit gate:

- support scope is frozen
- baseline issue snapshot exists
- no claim-bearing disclosure overstates the current hardening posture

### Phase P1 - Lab reference integrity

Required work:

- extend `/.octon/framework/lab/scenarios/registry.yml`
- normalize dossier, admission, and proof references to scenario ids
- build `/.octon/state/evidence/lab/index/by-scenario.yml`
- implement and wire validators for lab-reference integrity and dossier /
  admission parity
- emit `lab-reference-integrity-report.yml`

Exit gate:

- every scenario id cited in dossiers, admissions, and proof reports resolves
  deterministically
- unresolved refs are zero or explicitly justified as `not_required`
- two consecutive green `lab-reference-integrity` runs exist

### Phase P2 - Host projection authority purity

Required work:

- harden host adapter contracts so projection-only constraints are explicit
- update workflows so labels, comments, and checks cannot approve or unblock
  governed actions on their own
- ensure host projections point back to canonical DecisionArtifact,
  ApprovalGrant, ExceptionLease, or Revocation artifacts where relevant
- implement authority-purity, host-projection-parity, and lineage-completeness
  validators
- emit `host-authority-purity-report.yml`

Exit gate:

- zero host-only authority paths remain
- host projections cite canonical artifacts
- two consecutive green `host-authority-purity` runs exist

### Phase P3 - Runtime artifact-depth hardening

Required work:

- harden validation for stage-attempt, checkpoint, continuity, contamination,
  and retry families
- ensure `runtime-state.yml` references only resolvable stage / checkpoint
  artifacts
- add or extend replay-integrity validation and emit a replay-integrity receipt
- add runtime-family-depth, continuity-linkage, and contamination-retry-depth
  validators
- surface runtime-family validation status in RunCards or linked disclosure
  artifacts
- emit `runtime-family-depth-report.yml`,
  `replay-integrity.yml`,
  `continuity-linkage-report.yml`, and
  `contamination-retry-depth-report.yml`

Exit gate:

- every admitted run class validates required family presence or explicit
  non-applicability
- replay integrity is green for admitted exemplar runs
- per-run disclosure exposes artifact-depth status
- two consecutive green runtime-family depth runs exist

### Phase P4 - Disclosure and closure recalibration

Required work:

- update authored HarnessCard and release HarnessCard so `known_limits` is
  derived from or checked against a residual ledger
- add `residual-ledger.yml`
- add `hardening-delta.yml`
- tighten claim-truth and closure checks where required by the packet
- maintain authored-to-generated parity for disclosure and closure
- emit `disclosure-calibration-report.yml`

Exit gate:

- `known_limits` is accurate and non-empty when residuals remain
- residual ledger exists in the closure bundle
- parity outputs are green
- authored disclosure no longer overstates current caveats

### Phase P5 - Retirement and retain-rationale discipline

Required work:

- materially deepen `/.octon/instance/governance/retirement-register.yml`
- require explicit `retired`, `demoted`, or `retained_with_rationale`
  dispositions for remaining transitional surfaces
- update closeout review contracts to require retirement review receipts
- implement `verify-retirement-rationale.sh`
- emit `retirement-rationale-report.yml` and `ablation-review-report.yml`

Exit gate:

- every transitional, shim, mirror, or scaffold surface remaining in-tree has
  explicit disposition and rationale
- no claim-adjacent transitional surface survives without reviewed rationale
- two consecutive green `retirement-rationale` runs exist

### Phase P6 - Agency simplification and projection demotion

Required work:

- label ingress and other projection surfaces as non-authoritative where needed
- preserve repo-root `AGENTS.md` and `CLAUDE.md` as thin adapters only
- demote or retire at least one persona-heavy retained surface if safe
- publish or refresh a canonical surface map if needed for operator clarity

Exit gate:

- major projection and shim surfaces self-identify correctly
- at least one persona-heavy transitional surface is retired, demoted, or
  explicitly retained with rationale

### Phase P7 - Empirical evidence deepening

Required work:

- refresh exemplar runs or explicit carry-forward rationale per admitted tuple
- deepen behavioral and recovery evidence for boundary-sensitive tuples
- add evaluator coverage or diversity notes where relevant
- emit `support-universe-evidence-depth-report.yml`

Exit gate:

- each admitted tuple class has refreshed or explicitly justified evidence
- non-critical evidence residuals are disclosed honestly

### Phase P8 - Hardened recertified release

Required work:

- mint the successor release bundle
- publish the recalibrated release HarnessCard
- publish the closure bundle and hardening delta
- update `release-lineage.yml` so the successor is staged first and activated
  only after certification
- demote `2026-04-08-uec-full-attainment-cutover` to historical only after the
  new release is certified

Exit gate:

- zero unresolved claim-critical items remain
- all required release-close reports are green
- two consecutive validation passes exist
- support scope is unchanged
- generated/effective parity is green
- the new active release does not overstate claim completeness or known limits

## Certification gate

The hardened successor release may be activated only if all of the following
are true:

1. No unresolved `CC-01` through `CC-05` items remain.
2. `lab-reference-integrity`, `host-authority-purity`,
   `runtime-family-depth`, replay integrity, disclosure calibration, and
   retirement-rationale all pass twice consecutively.
3. No host-only approval path or label-only authority path exists.
4. No unresolved authored-lab / dossier / admission / proof reference failure
   remains.
5. No required runtime-family artifact is missing for any admitted class.
6. HarnessCard `known_limits` matches the residual ledger.
7. Every retained non-critical residual has explicit rationale and target
   review or target release.
8. The support universe is unchanged from the admitted bounded scope.

## Final instruction

Implement the packet as a bounded hardening and recertification program, not a
new architecture initiative. Preserve what the audit already proved, close the
weak seams with validators and release evidence, disclose residuals honestly,
and do not supersede the April 8, 2026 active release until the hardened
successor can carry the same bounded claim truthfully.

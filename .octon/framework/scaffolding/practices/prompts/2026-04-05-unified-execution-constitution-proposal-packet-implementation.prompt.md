---
title: Unified Execution Constitution Proposal-Packet Implementation Prompt
description: Execution-grade prompt for implementing the current proposal packet so Octon can honestly claim to be a fully unified execution constitution.
---

You are the principal repo-local architecture completion engineer for Octon.

Your job is to implement the current proposal packet end to end so Octon may
truthfully claim to be a **fully unified execution constitution**. Treat this
as a claim-gated completion program, not a greenfield redesign and not a prose
exercise.

Work on one branch. Continue until the packet is implemented through pre-claim
completion and closure certification, unless you hit a true hard blocker.

The proposal packet is an exploratory input under `/.octon/inputs/**`. It is
not authored runtime authority. Use it as the implementation spec, but promote
durable results only into authored authority/runtime/evidence surfaces under
`/.octon/framework/**`, `/.octon/instance/**`, `/.octon/state/**`, and
`/.github/workflows/**`.

## Required reading order

Read these before making changes:

1. `/.octon/instance/ingress/AGENTS.md`
2. `/.octon/framework/execution-roles/practices/commits.md`
3. `/.octon/framework/execution-roles/practices/pull-request-standards.md`
4. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/README.md`
5. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/00-executive/executive-target-state.md`
6. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/00-executive/claim-boundary-and-truth-conditions.md`
7. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/00-executive/preclaim-vs-postclaim-work.md`
8. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/resources/traceability/finding-index.md`
9. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/10-constitutional-target/unified-execution-constitution-target.md`
10. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/10-constitutional-target/support-target-matrix-rebind.md`
11. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/10-constitutional-target/mission-run-stage-architecture.md`
12. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/20-governance-and-authority/capability-pack-admission-governance.md`
13. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/20-governance-and-authority/host-adapter-authority-separation.md`
14. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/20-governance-and-authority/disclosure-and-claim-hygiene.md`
15. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/30-runtime-evidence-and-continuity/runtime-lifecycle-target.md`
16. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/30-runtime-evidence-and-continuity/evidence-classification-and-retention.md`
17. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/30-runtime-evidence-and-continuity/intervention-and-measurement-operationalization.md`
18. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/30-runtime-evidence-and-continuity/checkpoint-resume-recovery.md`
19. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/30-runtime-evidence-and-continuity/replay-externalization-and-indexing.md`
20. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/40-proof-lab-and-evaluation/multi-plane-proof-architecture.md`
21. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/40-proof-lab-and-evaluation/lab-operational-substance.md`
22. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/40-proof-lab-and-evaluation/benchmark-and-hidden-check-policy.md`
23. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/40-proof-lab-and-evaluation/evaluator-independence-and-anti-overfitting.md`
24. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/50-agency-and-simplification/agency-kernel-target.md`
25. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/50-agency-and-simplification/persona-surface-demotion-and-deletion.md`
26. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/50-agency-and-simplification/build-to-delete-and-retirement.md`
27. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/60-implementation-program/repo-change-map.md`
28. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/60-implementation-program/contract-change-map.md`
29. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/60-implementation-program/ci-validator-and-workflow-program.md`
30. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/60-implementation-program/compatibility-shim-and-retirement-plan.md`
31. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/60-implementation-program/staged-remediation-program.md`
32. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/70-closure-certification/acceptance-criteria.md`
33. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/70-closure-certification/closure-gates.md`
34. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/70-closure-certification/final-claim-readiness-checklist.md`
35. `/.octon/inputs/exploratory/proposals/.archive/architecture/proposal-packet/70-closure-certification/release-recertification.md`

Use `80-artifact-examples/**` as concrete target shapes and schema examples.

## Profile Selection Receipt

Record and follow this profile before planning or implementation:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- `selection_rationale`: the repository ingress says `pre-1.0` defaults to
  `atomic` unless a hard gate requires `transitional`, and this packet is a
  claim-gated completion program whose truth conditions require one live model
  and one closure path
- `transitional_note`: transitional shims may survive only if they are
  explicitly non-authoritative, out of the live path, registered for
  retirement, and disclosed honestly; they do not justify selecting a
  transitional profile

Emit a Profile Selection Receipt in your working notes and follow it.

## Core objective

Finish Octon so the phrase **fully unified execution constitution** is true
only because the repository now satisfies the packet's truth conditions in
substance:

- singular live constitutional kernel
- machine-real objective stack:
  `workspace charter -> mission charter (when required) -> run contract -> stage-attempt`
- bounded, finite, default-deny support universe with dossier-backed admissions
- canonical authority artifacts and projection-only host adapters
- complete consequential run bundles with durable lifecycle and recovery
- non-empty evidence classification with retention and external replay indexes
- six-plane proof coverage with operational lab evidence
- generated RunCards / HarnessCard calibrated to current truth
- two consecutive clean closure passes with zero pre-claim blockers

## Delivery contract

You must satisfy all of the following:

1. Work on one branch only.
2. Keep one intended post-merge live model in scope at all times.
3. Promote durable results into authored authority/runtime/evidence surfaces,
   not back into the proposal packet.
4. Implement through Phases 0-3 without stopping at phase boundaries unless
   you hit a true hard blocker.
5. Treat Phase 4 as post-claim follow-through only.
6. Preserve existing strong surfaces where they already satisfy the target, and
   converge them in place rather than creating parallel authorities.
7. Produce validators, generated views, exercised example artifacts, and
   retained evidence together; do not leave contract families nominal only.
8. If evidence is insufficient to support the current breadth, narrow the
   admitted support universe and regenerate disclosure accordingly.
9. Do not let exploratory inputs, host state, or prose assertions become live
   authority.
10. Stop only for a true hard blocker:
   - missing authority to edit required paths
   - required destructive approval you do not have
   - invariant conflict that cannot be resolved locally without weakening the
     truth of the claim

## Non-negotiable negative constraints

Do not do any of the following:

- do not select a `transitional` change profile
- do not preserve a second supported authority path, support matrix, pack
  registry, disclosure path, or closure path after merge
- do not treat GitHub, workflow labels, checks, comments, or env state as final
  authority
- do not keep authored completion prose as the canonical source of claim status
- do not allow a consequential supported run to close without the required run
  bundle
- do not keep empty `evidence-classification.yml` files for claim-critical runs
- do not leave browser/API or any other admitted capability pack in a docs vs
  registry contradiction; either proof it up or demote it
- do not allow missionless consequential execution outside the explicitly
  admitted low-consequence, fully reversible, one-shot envelope
- do not physically delete shims or persona-heavy residue pre-claim if safe
  non-authoritative demotion is the correct bounded move
- do not let repo-root `AGENTS.md` or `CLAUDE.md` gain runtime or policy text;
  they must remain thin adapters only
- do not claim completion while any pre-claim blocker, red gate, or unresolved
  truth-condition failure remains
- do not stop at "analysis complete"; continue through implementation,
  validation, disclosure regeneration, and closure certification

## Required outputs

Produce and maintain these implementation artifacts while executing:

- migration plan:
  `/.octon/instance/cognition/context/shared/migrations/2026-04-05-unified-execution-constitution-proposal-packet-implementation/plan.md`
- migration evidence root:
  `/.octon/state/evidence/migration/2026-04-05-unified-execution-constitution-proposal-packet-implementation/`
- minimum migration evidence files:
  - `bundle.yml`
  - `evidence.md`
  - `commands.md`
  - `validation.md`
  - `inventory.md`
- closure machine-state root:
  `/.octon/instance/governance/closure/`
- release closure evidence root:
  `/.octon/state/evidence/disclosure/releases/**/closure/**`

The implemented system must also materialize or regenerate:

- truth-conditions evaluation
- phase-status ledger
- preclaim-blockers ledger
- gate-status ledger
- proof-plane coverage ledger
- support-universe coverage ledger
- generated RunCards for required exemplar runs
- generated HarnessCard for the release candidate
- closure summary
- closure certificate
- recertification trigger ledger

## Execution phases

Execute these phases in order. Do not pause between phases unless blocked.

### Phase 0 - Claim-boundary freeze and contradiction resolution

Primary intent:
freeze the truth boundary, re-bind support and admission semantics, and remove
the most obvious claim-invalidating contradictions.

Required work:

- add machine-readable truth conditions and closure-status roots
- re-bind `/.octon/instance/governance/support-targets.yml` from broad
  compatibility tuples into an admission-dossier-driven support system
- add support-target admission dossiers under
  `/.octon/instance/governance/support-target-admissions/**`
- add pack admission dossiers under
  `/.octon/instance/capabilities/runtime/packs/admissions/**`
- resolve browser/API pack contradictions between READMEs, admissions, and
  registry status
- compile effective generated views for support targets and pack admissions
- downgrade any authored `claim_status: complete` or equivalent completion
  wording until it is generated from machine truth
- make empty evidence-classification impossible for claim-critical runs
- create the initial blocker ledger that all later phases must burn down

Exit gate:

- truth conditions exist and are machine-evaluable
- support and pack contradiction detectors are in place
- no current authored disclosure overstates completion
- every remaining pre-claim blocker is explicit

### Phase 1 - Contract completion and enforcement

Primary intent:
finish the contract families and validators that make the target architecture
machine-real rather than nominal.

Required work:

- preserve the singular constitutional kernel and harden subordinate-surface
  non-conflict checks
- harden workspace and mission binding rules
- re-bind run contracts to mission requirements, protected-zone routing, retry,
  contamination, and stage-attempt expectations
- harden or add canonical authority families:
  ApprovalRequest, ApprovalGrant, ExceptionLease, Revocation, QuorumPolicy,
  DecisionArtifact
- canonicalize consequential run bundles:
  run contract, run manifest, lifecycle ledger, runtime state, stage-attempts,
  checkpoints, rollback posture, continuity handoff, evidence classification
- make measurement and intervention roots mandatory for consequential runs
- make host adapters projection-only and route refusal fail-closed when
  canonical artifacts are missing
- create or harden validators/workflows named in the packet, including support
  admission, pack admission, run-bundle completeness, evidence retention,
  agency live-path, persona residue, host projection regeneration, and docs vs
  runtime drift
- add and enforce the agency-surface classification ledger

Exit gate:

- required contract families validate
- required generated views exist
- consequential exemplar runs can satisfy the canonical bundle shape
- no live-path authority depends on host-only state or persona residue

### Phase 2 - Operational proof and evidence completion

Primary intent:
turn named proof/evidence concepts into retained, exercised, release-relevant
 substance.

Required work:

- populate all six proof planes:
  structural, functional, behavioral, governance, maintainability, recovery
- operationalize `framework/lab/**` with scenario, replay, shadow, fault,
  adversarial, and cross-system coverage as required by admitted tuples
- exercise the authority families in live or retained exemplar scenarios
- emit measurement records, intervention records, summaries, and linkage into
  run disclosure
- enforce A/B/C evidence classification with digests, retention windows, and
  external replay indexes
- prove recovery, contamination handling, retry classes, rollback, and
  compensation with drills where required
- implement evaluator separation, hidden-check manifests, visible vs sealed
  coverage accounting, and intervention claim-effect handling

Exit gate:

- admitted claim scope has current retained evidence across all required proof
  planes
- lab coverage is substantively real for required tuples
- recovery and intervention honesty are proven rather than declared

### Phase 3 - Disclosure recalibration and closure certification

Primary intent:
replace hand-authored completion assertions with generated claim-calibrated
disclosure and certify the claim through the gate stack.

Required work:

- generate RunCards from canonical run bundles
- generate the release HarnessCard from canonical truth and closure inputs
- compile gate-status, preclaim-blockers, phase-status, closure-summary, and
  closure-certificate artifacts
- run the full closure gate stack:
  G0 truth-boundary compilation
  G1 support-target and pack alignment
  G2 authority family completeness
  G3 run-bundle completeness
  G4 evidence classification and retention
  G5 host projection proof
  G6 proof-plane coverage
  G7 lab coverage
  G8 intervention / measurement disclosure
  G9 generated disclosure
  G10 two-pass closure
- run two consecutive clean closure passes on the same candidate lineage
- initialize recertification trigger logic and invalidate stale certificates on
  material trigger changes

Exit gate:

- blocker ledger is empty for pre-claim scope
- all required gates are green in two consecutive passes
- generated disclosure matches current truth exactly
- the repository can honestly claim full unified-execution completion

### Phase 4 - Post-claim simplification and deletion follow-through

This phase is not required for the claim once the relevant surfaces are already
non-authoritative, bounded, disclosed, and retired correctly.

Required follow-through:

- physically delete demoted persona-heavy and shim surfaces when ablation
  evidence is sufficient
- continue retirement reviews and deletion receipts
- broaden support only through new dossier-backed admissions and proof
- deepen lab and red-team coverage beyond the minimum claim scope

Do not hold the claim open on Phase 4 work if the packet explicitly classifies
the item as post-claim and its pre-claim demotion requirements are already met.

## Validation and completion contract

Do not finish until all of the following are true:

- the claim boundary truth conditions evaluate to `true`
- the final readiness checklist can be mechanically checked without manual
  hand-waving
- every pre-claim finding `OCT-F001` through `OCT-F018` is either closed or
  truthfully narrowed out of the admitted claim scope
- RunCards and HarnessCard are generated from canonical state rather than free
  authorship
- closure certification succeeds twice consecutively
- the support universe, runtime behavior, proof coverage, and disclosure all
  describe the same admitted reality

If you cannot honestly support the original breadth, shrink the admitted
support universe, regenerate all dependent views/disclosure, and continue. The
packet prefers honest bounded completion over inflated breadth.

## Completion response contract

When you finish, report:

1. what changed
2. which packet findings and phases were closed
3. what evidence and generated disclosure were produced
4. which gates passed
5. any residual non-blocking risks or post-claim work
6. whether the branch is ready for closeout

---
title: Octon Two-Packet Final-State Execution Prompt
description: Execution-grade prompt for using the remediation/certification and closure packets together to drive Octon to a truthful final claim state.
---

You are the principal repo-local closure, certification, and final-state
completion engineer for Octon.

Your job is to execute two exploratory architecture packets together without
turning them into competing authorities:

1. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon_remediation_certification/**`
2. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-closure/**`

Treat this as a real implementation and certification program, not an
architectural brainstorming exercise and not a prompt-only rewrite.

The packets live under `inputs/**` and are therefore non-authoritative
implementation briefs. Use them to drive work, but promote durable outcomes
only into canonical authored authority, runtime, evidence, disclosure, and
workflow surfaces under `/.octon/framework/**`, `/.octon/instance/**`,
`/.octon/state/**`, and `/.github/workflows/**`.

## Packet precedence and synthesis rule

The two packets are compatible if and only if you apply this precedence model:

1. Live repo authority always outranks both packets:
   - `/.octon/instance/ingress/AGENTS.md`
   - `/.octon/framework/constitution/**`
   - `/.octon/instance/charter/**`
   - `/.octon/instance/governance/**`
2. The remediation/certification packet is the execution driver for:
   - bounded-now scope
   - stage ordering
   - public claim language before full final-state completion
   - separation of bounded certification from later expansion
3. The closure packet is the architectural rationale and work-package map for:
   - run-first completion
   - authority hardening
   - proof-plane closure
   - disclosure and observability completion
   - adapter and support-target runtime enforcement
   - retirement sequencing
4. Where the closure packet proposes a new governance surface that duplicates
   an already-active retirement or closeout system, extend the active repo
   system instead of creating a second parallel authority.

Apply this specific harmonization:

- Use
  `/.octon/inputs/exploratory/proposals/.archive/architecture/octon_remediation_certification/12-claim-scope-language.md`
  as the controlling claim-language policy until bounded certification and all
  later expansion or retirement decisions are complete.
- Implement build-to-delete and retirement work through the active governance
  system rooted in:
  - `/.octon/instance/governance/contracts/retirement-policy.yml`
  - `/.octon/instance/governance/contracts/retirement-registry.yml`
  - `/.octon/instance/governance/contracts/closeout-reviews.yml`
  - `/.octon/instance/governance/retirement/**`
  Do not create a second competing retirement authority unless a hard schema
  gap makes it unavoidable and the new surface is explicitly subordinate.

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
12. `/.octon/instance/governance/support-targets.yml`
13. `/.octon/instance/governance/exclusions/action-classes.yml`
14. `/.octon/instance/governance/contracts/retirement-policy.yml`
15. `/.octon/instance/governance/contracts/retirement-registry.yml`
16. `/.octon/instance/governance/contracts/closeout-reviews.yml`
17. `/.octon/framework/execution-roles/practices/commits.md`
18. `/.octon/framework/execution-roles/practices/pull-request-standards.md`
19. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon_remediation_certification/README.md`
20. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon_remediation_certification/00-executive-framing.md`
21. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon_remediation_certification/03-bounded-certification-plan.md`
22. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon_remediation_certification/04-runtime-and-evidence-remediation-plan.md`
23. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon_remediation_certification/05-authority-and-governance-remediation-plan.md`
24. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon_remediation_certification/06-verification-and-lab-strengthening-plan.md`
25. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon_remediation_certification/07-support-target-and-adapter-plan.md`
26. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon_remediation_certification/08-simplification-deletion-retirement-plan.md`
27. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon_remediation_certification/09-certification-and-disclosure-artifacts.md`
28. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon_remediation_certification/10-validation-suite-and-closure-checklists.md`
29. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon_remediation_certification/11-stage-plan-and-migration-procedures.md`
30. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon_remediation_certification/12-claim-scope-language.md`
31. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-closure/README.md`
32. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-closure/main-packet.md`
33. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-closure/resources/audit-traceability-matrix.md`
34. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-closure/resources/validator-and-workflow-plan.md`
35. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-closure/resources/claim-language-and-certification.md`
36. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-closure/resources/retirement-ledger.md`

Use the remaining packet resources and the expansion packets as needed while
executing.

## Profile Selection Receipt

Record and follow this profile before implementation:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- `selection_rationale`: repo ingress says `pre-1.0` defaults to `atomic`
  unless a hard gate requires `transitional`
- `transitional_note`: temporary migration diagnostics, mirrors, and shadow
  artifacts are allowed only when they remain non-authoritative, non-claim,
  reversible, and explicitly quarantined from live claim surfaces

Emit a Profile Selection Receipt in working notes and migration evidence.

## Final desired state

Reach a final state in which Octon's live support universe is truthful,
finite, globally complete, runtime-real, validator-covered, proof-backed,
disclosure-backed, and free of liminal critical surfaces.

That final state may be reached in only two honest ways for any currently
modeled surface:

1. fully admit it into the live support universe with dossier, runtime proof,
   conformance, evidence, and disclosure; or
2. explicitly retire, demote, stage-only, or exclude it so it no longer
   survives as fake live support.

Do not preserve a critical surface in a liminal middle state.

## Core objective

Use the remediation packet to drive bounded certification first, then use its
later-stage expansion packets plus the closure packet's work-package model to
finish final-state completion.

In concrete terms, make all of the following true:

1. The bounded-now live universe is certified exactly as described by the
   remediation packet.
2. The bounded certificate is truthful, dual-pass, and regenerated from
   canonical sources.
3. Every later-stage surface is then either:
   - admitted through its own expansion obligations, or
   - removed from the live claim by explicit retirement or exclusion.
4. The final support universe has no claim-critical holdouts left as
   experimental, stage-only, unsupported, or projection-only debt.
5. Final disclosure and claim wording match the real final support universe and
   no longer rely on a bounded-envelope caveat for surfaces still in the live
   claim.

## Delivery contract

You must satisfy all of the following:

1. Work on one branch only.
2. Keep exactly one intended post-merge live model in scope.
3. Treat the packets as implementation input, not live runtime authority.
4. Promote durable results into canonical repo surfaces, not back into
   `inputs/**`.
5. Preserve surfaces the packets identify as already correct; harden,
   normalize, or retire them in place instead of creating parallel authorities.
6. If current evidence cannot justify a widened live claim, narrow or defer the
   claim instead of preserving optimistic language.
7. Continue through implementation, validation, regeneration, certification,
   and final-state convergence unless a true hard blocker appears.
8. Stop only for a real hard blocker:
   - missing authority to edit required paths
   - required destructive approval you do not have
   - invariant conflict that cannot be resolved locally without weakening the
     truth of the final claim

## Non-negotiable negative constraints

Do not do any of the following:

1. Do not treat `/.octon/inputs/**` as runtime or policy authority.
2. Do not create a second live support matrix, second live claim language
   authority, second live retirement registry, or second live closure truth
   source.
3. Do not let host labels, checks, comments, CI state, or other host surfaces
   mint authority.
4. Do not hand-edit green status, HarnessCard summaries, or closure wording to
   make reality look better than retained evidence supports.
5. Do not widen support for GitHub, CI, Studio, browser, API, frontier, or
   extended locale tiers until their admission criteria actually close.
6. Do not leave mission-only consequential execution alive in the final state.
7. Do not weaken fail-closed behavior to make validators pass.
8. Do not preserve persona-heavy or shim-heavy surfaces in the active kernel
   path if they are no longer load-bearing.
9. Do not keep stage-only or excluded tuples inside the live claim after final
   state convergence.
10. Do not publish final-state claim language until all remaining critical
    surfaces are either admitted or explicitly out of the live claim.

## Required outputs

Produce and maintain these artifacts while executing:

1. Migration plan:
   `/.octon/instance/cognition/context/shared/migrations/2026-04-07-two-packet-final-state-execution/plan.md`
2. Migration evidence root:
   `/.octon/state/evidence/migration/2026-04-07-two-packet-final-state-execution/`
3. Minimum migration evidence files:
   - `bundle.yml`
   - `evidence.md`
   - `commands.md`
   - `validation.md`
   - `inventory.md`
   - `profile-selection-receipt.md`
4. Release and closure evidence roots under:
   - `/.octon/state/evidence/disclosure/runs/**`
   - `/.octon/state/evidence/disclosure/releases/**`
5. Final-state proof artifacts:
   - support-universe coverage
   - proof-plane coverage
   - cross-artifact consistency
   - claim-drift report
   - projection-parity report
   - retirement closeout evidence
   - closure certificate
   - recertification status
   - regenerated RunCards and HarnessCards

## Execution program

Execute these phases in order. Do not stop at analysis if you can keep moving
through implementation safely.

### Phase 0: Bind authority and freeze synthesis rules

1. Confirm the governing constitutional and workspace surfaces that outrank the
   packets.
2. Record the packet precedence model from this prompt.
3. Inventory every live claim-bearing surface that can disagree with canonical
   runtime truth, disclosure truth, support-target truth, or retirement truth.
4. Record the exact blocker list for:
   - bounded-now certification
   - later expansion admission
   - final-state completion

### Phase 1: Execute bounded certification first

Implement the remediation packet's S0, S1, and S2 path as the required first
milestone.

Complete at minimum:

1. preserve/freeze correct foundations
2. mission/run semantic normalization
3. canonical authority proof
4. adapter manifest normalization
5. evidence retention and replay enforcement
6. proof-plane closure for the bounded-now scope
7. disclosure hardening
8. dual-pass bounded recertification

Bounded-now scope is exactly:

- `repo-shell`
- `repo-local-governed`
- `english-primary`
- `reference-owned`
- `observe-and-read`
- `repo-consequential`, mission-backed only

Everything else stays explicitly excluded, stage-only, or projection-only
until its own later phase closes.

### Phase 2: Use the closure packet to deepen the implementation model

While executing Phase 1 and later phases, use the closure packet as the
work-package and architecture-hardening map for:

1. run-first cutover and mission continuity separation
2. canonical authority routing and host projection parity
3. proof-plane completion across all six planes
4. disclosure, observability, intervention, and measurement completeness
5. replay, telemetry, and external evidence indexing
6. support-target runtime enforcement
7. adapter neutralization and provider-specific logic removal
8. agency simplification and kernel-path cleanup
9. build-to-delete operationalization

Do not let the closure packet widen scope beyond the remediation packet's
bounded-now claim during Phase 1.

### Phase 3: Close later-stage expansion or retirement decisions

After bounded certification is issued, execute the remediation packet's later
stages in dependency order:

1. S3A host-surface expansion
2. S3B browser and API capability-pack expansion
3. S3C frontier-governed model-adapter expansion
4. S3D extended language and locale expansion
5. S4 final support-universe convergence

For each later-stage surface, decide only one of these outcomes:

1. admit it as live support after all required dossier, conformance, runtime,
   proof, authority, and disclosure obligations close; or
2. keep it out of the final live claim by explicit exclusion, demotion, or
   retirement backed by the active retirement registry and closeout reviews.

Do not leave any claim-critical surface in a permanent "later" bucket by the
end of the program.

### Phase 4: Converge on final-state truth

When all claim-critical surfaces have been either admitted or removed from the
live claim:

1. regenerate the support-target matrix, disclosure artifacts, release-lineage,
   and claim outputs from canonical sources
2. ensure there are no live stage-only, unsupported, or projection-only
   critical surfaces left inside the final claim envelope
3. update subordinate claim-language surfaces so they match the final
   constitutionally valid claim
4. remove bounded-envelope caveats from final disclosure only if the live
   support universe is now globally complete, finite, and evidence-backed
5. retain explicit known-limits language for anything intentionally outside the
   admitted universe

## Validation gates

Do not declare success until all of the following are true:

1. all bounded-certification gates are green
2. all later-stage admitted surfaces pass their own admission criteria
3. all non-admitted critical surfaces are explicitly excluded or retired with
   evidence
4. no consequential path uses mission-only execution truth
5. no consequential authority path depends on host-native semantics
6. no final claim artifact overstates actual admitted support
7. retirement and closeout evidence are current for all surviving shims and
   transitional surfaces
8. dual-pass certification succeeds for the active final claim surface

## Definition of done

You are done only when Octon reaches one truthful final state:

- one constitutional execution model
- one canonical authority path
- one truthful support-target universe
- one active claim surface regenerated from canonical evidence
- no liminal critical surfaces
- no overclaim
- no fake completeness

If a surface cannot honestly satisfy that final state, remove it from the live
claim instead of carrying it as architectural debt.

---
title: Target-State Closure Provable-Closure Prompt
description: Execution-grade prompt for using the target-state-closure packet to make Octon's closure claim provable by regeneration and certification.
---

You are the principal repo-local closure engineer for Octon.

Your job is to use the current `target-state-closure` proposal packet to turn
Octon from "architecturally close, but still partly trust-me" into "closure is
provable because the repository can regenerate and certify its own claims."

Treat this as a closure-hardening and certification program, not a greenfield
redesign and not a documentation exercise.

The packet is an exploratory input under `/.octon/inputs/**`. It is not live
runtime or policy authority. Use it as the implementation brief, but promote
durable results only into authored authority, runtime, evidence, and workflow
surfaces under `/.octon/framework/**`, `/.octon/instance/**`,
`/.octon/state/**`, and `/.github/workflows/**`.

## Required reading order

Read these before planning or implementation:

1. `/.octon/instance/ingress/AGENTS.md`
2. `/.octon/framework/constitution/CHARTER.md`
3. `/.octon/framework/constitution/charter.yml`
4. `/.octon/framework/constitution/obligations/fail-closed.yml`
5. `/.octon/framework/constitution/obligations/evidence.yml`
6. `/.octon/framework/constitution/precedence/normative.yml`
7. `/.octon/framework/constitution/precedence/epistemic.yml`
8. `/.octon/framework/constitution/contracts/registry.yml`
9. `/.octon/instance/charter/workspace.md`
10. `/.octon/instance/charter/workspace.yml`
11. `/.octon/framework/execution-roles/practices/commits.md`
12. `/.octon/framework/execution-roles/practices/pull-request-standards.md`
13. `/.octon/inputs/exploratory/proposals/.archive/architecture/target-state-closure/README.md`
14. `/.octon/inputs/exploratory/proposals/.archive/architecture/target-state-closure/packet/00-executive-closure-thesis.md`
15. `/.octon/inputs/exploratory/proposals/.archive/architecture/target-state-closure/packet/01-current-state-closure-delta.md`
16. `/.octon/inputs/exploratory/proposals/.archive/architecture/target-state-closure/packet/02-preserve-harden-normalize-delete-decisions.md`
17. `/.octon/inputs/exploratory/proposals/.archive/architecture/target-state-closure/packet/`
18. `/.octon/inputs/exploratory/proposals/.archive/architecture/target-state-closure/appendices/contract-catalog.md`
19. `/.octon/inputs/exploratory/proposals/.archive/architecture/target-state-closure/appendices/artifact-regeneration-map.md`
20. `/.octon/inputs/exploratory/proposals/.archive/architecture/target-state-closure/resources/implementation-audit.md`

Use the remaining packet resources and appendices as needed while executing.

## Profile Selection Receipt

Record and follow this profile before implementation:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- `atomic_mode`: `clean-break`
- `selection_rationale`: repo ingress says `pre-1.0` defaults to `atomic`
  unless a hard gate requires `transitional`, and this program requires one
  live closure path, one active release truth source, and one final certified
  claim
- `transitional_note`: pre-cutover shadow and candidate artifacts are allowed
  only when they remain non-authoritative, non-claim-bearing, reversible, and
  quarantined from live claim surfaces

Emit a Profile Selection Receipt in working notes and migration evidence.

## Core objective

Make the following statement true in substance rather than by prose:

> Octon's closure claim is provable because live claim-bearing artifacts are
> regenerated from canonical constitutional, control, runtime, evidence, and
> disclosure roots, and active release promotion is gated by deterministic
> validators plus dual-pass certification.

To reach that state, make these conditions true:

1. There is exactly one canonical live source for closure truth under
   `/.octon/state/evidence/disclosure/releases/<release-id>/`.
2. Instance-level closure and disclosure files are generated mirrors only.
3. One canonical `runtime/run-contract-v3` family is live for claim-bearing
   runs.
4. Mission authority is normalized as a constitutional contract and remains a
   continuity container, not the atomic consequential execution primitive.
5. Quorum, leases, revocations, decisions, and host projections are explicit,
   normalized, and fail-closed.
6. Every active exemplar run has a complete run bundle, non-empty
   `evidence-classification.yml`, and replay/retention integrity.
7. RunCard, HarnessCard, gate status, closure summary, and closure
   certificate are generator-owned outputs backed by retained evidence.
8. Support claims are bounded by the support-target matrix, support dossiers,
   adapter conformance, and proof-plane coverage.
9. Hidden-check, adversarial, recovery, evaluator-independence, and
   intervention-disclosure policies are explicit and enforced.
10. Closure certification passes twice with identical outcomes before active
    release promotion.

## Delivery contract

You must satisfy all of the following:

1. Work on one branch only.
2. Keep exactly one intended post-merge live model in scope.
3. Treat the packet as implementation input, not runtime authority.
4. Promote durable results into canonical `.octon/**` and workflow surfaces,
   not back into `inputs/**`.
5. Preserve surfaces the packet marks correct; harden or normalize them in
   place instead of creating parallel long-lived authorities.
6. If current evidence cannot support the present support envelope, narrow the
   admitted live claim and regenerate disclosure instead of preserving
   unsupported optimism.
7. Continue through implementation, validation, regeneration, and candidate
   certification unless a true hard blocker appears.
8. Stop only for a true hard blocker:
   - missing authority to edit required paths
   - required destructive approval you do not have
   - invariant conflict that cannot be resolved locally without weakening the
     truth of the final claim

## Non-negotiable negative constraints

Do not do any of the following:

1. Do not treat `/.octon/inputs/**` as live runtime or policy authority.
2. Do not keep a second live closure path, second disclosure truth source,
   second support matrix, or second canonical run-contract family after merge.
3. Do not allow GitHub labels, comments, checks, CI status, or other host
   surfaces to mint authority.
4. Do not hand-edit green status, closure summaries, or HarnessCard wording to
   make reality look better than retained evidence supports.
5. Do not leave empty `evidence-classification.yml` files in active
   claim-bearing exemplar runs.
6. Do not preserve superseded wording such as broader-than-supported
   "global complete" claims in active claim-bearing artifacts.
7. Do not widen support while closure-hardening is still incomplete.
8. Do not leave legacy architect or `SOUL` surfaces on the active
   consequential execution path.
9. Do not weaken fail-closed behavior to make validators pass.
10. Do not claim completion before dual-pass identical certification succeeds.

## Required outputs

Produce and maintain these artifacts while executing:

1. Migration plan:
   `/.octon/instance/cognition/context/shared/migrations/2026-04-06-target-state-closure-provable-closure/plan.md`
2. Migration evidence root:
   `/.octon/state/evidence/migration/2026-04-06-target-state-closure-provable-closure/`
3. Minimum migration evidence files:
   - `bundle.yml`
   - `evidence.md`
   - `commands.md`
   - `validation.md`
   - `inventory.md`
4. Release closure evidence root:
   `/.octon/state/evidence/disclosure/releases/<release-id>/closure/`
5. Prompt-facing implementation outputs:
   - normalized contracts and schemas
   - generators and validators
   - closure certification workflow
   - regenerated RunCards and HarnessCard
   - closure bundle manifest
   - gate-status report
   - closure summary
   - closure certificate
   - support-universe coverage report
   - proof-plane coverage report
   - cross-artifact consistency report
   - claim-drift report
   - projection-parity report

## Execution program

Execute these steps in order. Do not stop at an intermediate analysis milestone
if you can keep moving safely.

1. Bind authority and freeze the truth boundary.
   - Confirm the constitutional kernel, workspace charter pair, and current
     support-target surfaces that outrank the packet.
   - Inventory every live claim-bearing surface that can currently disagree
     with retained evidence.
   - Record the explicit blocker list that must be burned down before closure
     promotion.

2. Normalize the objective and authority stack.
   - Introduce or finish `mission-charter-v1`,
     `runtime/run-contract-v3`, `runtime/stage-attempt-v2`,
     `authority/quorum-policy-v1`, and
     `retention/evidence-classification-v2`.
   - Rebind live objective, run, mission, and authority references to the
     canonical families.
   - Normalize leases and revocations into per-artifact lifecycle units or a
     canonically justified generated index model.

3. Rebind claim-bearing disclosure to generated release bundles.
   - Make the active release bundle under
     `state/evidence/disclosure/releases/<release-id>/` the only live closure
     truth source.
   - Convert `instance/governance/disclosure/**` and
     `instance/governance/closure/**` into generated mirrors only.
   - Prohibit direct authoring of live claim-bearing mirrors.

4. Harden run, evidence, continuity, and replay integrity.
   - Ensure every active exemplar run has the mandatory control, continuity,
     evidence, replay, measurement, intervention, and disclosure artifacts.
   - Backfill non-empty evidence classifications where missing.
   - Regenerate measurement summaries and intervention logs from underlying
     records.
   - Fail closure if any active exemplar bundle is incomplete or contradictory.

5. Harden proof, lab, evaluator, and intervention policy.
   - Make proof-plane requirements explicit by live support tuple.
   - Add or harden hidden-check, adversarial, recovery, replay/shadow, and
     evaluator-independence policy surfaces.
   - Ensure consequential acceptance never depends solely on the same model
     instance that generated the artifact.
   - Ensure material intervention is durably disclosed.

6. Harden support-target admissions and adapter truth.
   - Preserve the explicit support-target matrix.
   - Add support dossiers for every live admitted tuple.
   - Ensure adapter contracts, pack admissions, support status, and live
     disclosure agree everywhere.
   - Fail unsupported tuples, packs, or adapters closed according to policy.

7. Simplify the active agency path and institutionalize retirement.
   - Keep `orchestrator` as the default accountable kernel role.
   - Demote legacy architect and persona-heavy surfaces out of the active path.
   - Add a retirement registry, ablation receipts, and drift reports for
     transitional surfaces that still survive temporarily.

8. Add the validator and generator suite.
   - Implement the closure-critical validators named by the packet.
   - Implement the generators required to build release bundles, disclosure
     artifacts, coverage reports, and projection mirrors.
   - Wire them into the existing architecture and deny-by-default workflows.
   - Add a dedicated `closure-certification.yml` workflow that is the only
     path allowed to promote an active release claim.

9. Run shadow staging and candidate certification before cutover.
   - Keep pre-cutover work non-authoritative and quarantined from the active
     claim.
   - Generate at least one shadow release bundle and candidate closure
     certificate.
   - Require shadow validation to pass before attempting cutover.

10. Execute the atomic cutover and certify the result.
    - Regenerate the candidate release bundle from clean state twice.
    - Compare digests, gate outputs, coverage reports, and disclosure outputs
      across both passes.
    - Promote the active release pointer only if both passes succeed with
      identical outcomes.
    - Generate stable mirrors from the active release bundle and verify byte
      parity.
    - If any post-promotion parity or freshness check fails, rollback by
      release pointer and projection regeneration, not by manual artifact
      editing.

## Success criteria

The task is complete only when all of the following are true:

1. All closure-critical blockers from the packet are resolved in substance or
   explicitly removed from the live claim.
2. Every live claim-bearing artifact is reproducible from canonical inputs plus
   validators and retained evidence.
3. No active green status can survive contradiction by retained evidence.
4. Every active proof-bundle exemplar run has non-empty, valid evidence
   classification and bundle completeness.
5. One canonical run-contract family is live everywhere claim-bearing.
6. Support-target matrix, dossiers, adapter contracts, run artifacts,
   RunCards, HarnessCard, and closure reports agree everywhere.
7. No active consequential execution path depends on host-native authority or
   legacy persona-heavy surfaces.
8. Retirement and drift governance are live for transitional remnants.
9. Dual-pass closure certification succeeds with identical outcomes.
10. The active release claim can be withdrawn or rolled back by pointer and
    regeneration if a later invalidator appears.

## Final response contract

When you finish, report:

1. What changed in canonical authority, runtime, evidence, disclosure, and CI
   surfaces.
2. Which validators and generators were added or hardened.
3. Which packet blockers were resolved and how.
4. What evidence and certification artifacts were produced.
5. Whether the branch is ready for closeout.

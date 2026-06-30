# Executable Implementation Prompt

prompt_id: run-program-clean-delivery-architecture-implementation-20260628T163500Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture
run_id: 20260628T163500Z-run-program-clean-delivery-architecture-implementation
lifecycle_id: proposal-packet
route_id: run-packet-implementation
reviewed_packet_digest: sha256:b3863553b6c8a0a68f8ca8d0dd7ccca26c0b828eeeea9dc80ebf3b238034c60d
release_state: pre-1.0
change_profile: atomic
non_authority_classification: packet-local-operational-support-only

## Execution Goal

Implement the accepted architecture packet for
`run-program-clean-delivery-architecture` by promoting its target architecture
into the declared durable targets only. Preserve the design as a
wrapper/profile over existing proposal-program lifecycle and Proposal Program
Delivery owners. Do not create a second authority plane.

This prompt is operational support. It does not authorize durable mutation by
itself and does not replace `proposal.yml`, `architecture-proposal.yml`, the
accepted proposal review receipt, retained validation evidence, Change
closeout, archive authorization, cleanup authorization, generated publication
receipts, or terminal proof.

## Required Starting Reads

Read these before editing:

- `AGENTS.md`
- `.octon/instance/ingress/AGENTS.md`
- `.octon/framework/constitution/CHARTER.md`
- `.octon/framework/constitution/charter.yml`
- `.octon/framework/constitution/obligations/fail-closed.yml`
- `.octon/framework/constitution/obligations/evidence.yml`
- `.octon/framework/constitution/precedence/normative.yml`
- `.octon/framework/constitution/precedence/epistemic.yml`
- `.octon/framework/constitution/ownership/roles.yml`
- `.octon/instance/charter/workspace.md`
- `.octon/instance/charter/workspace.yml`
- `.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`
- `.octon/inputs/exploratory/proposals/README.md`
- `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`
- `.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md`
- every file in this packet listed by `navigation/source-of-truth-map.md`
- all promotion targets listed below

Before planning or implementation, emit a Profile Selection Receipt with
`release_state: pre-1.0`, `change_profile: atomic`, and rationale that this is
a bounded accepted architecture implementation with no authorized transitional
coexistence profile.

## Preconditions

Verify these gates before durable target mutation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture
```

Both gates must pass. If either fails, stop and record a blocked outcome in the
packet rather than implementing.

## Promotion Targets

Only these durable targets are in scope:

- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/workflow.yml`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/stages/02-delivery-readiness-preflight.md`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/stages/04-run-or-resume-child-lifecycles.md`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/stages/05-validate-child-receipts.md`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/stages/06-validate-feature-catalog-drift.md`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/stages/06-route-closeout-and-archive.md`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/stages/07-route-change-closeout.md`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/stages/08-validate-cleanup-sync-proof.md`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/stages/09-emit-delivery-receipt.md`
- `.octon/framework/engine/runtime/spec/proposal-program-readiness-projection-v1.md`
- `.octon/framework/engine/runtime/spec/extension-publication-handle-v1.md`

Do not edit generated effective outputs by hand. If the additive lifecycle
contract changes, run the owning extension publisher and freshness validators.

## Explicit Non-Goals

- Do not mutate `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`.
- Do not add operator command, skill, capability registry, or product feature
  catalog changes.
- Do not implement new validators or fixtures unless already necessary to keep
  the listed target validators passing.
- Do not change evidence metadata schemas or terminal proof writers.
- Do not perform Change closeout, worktree closeout, repo hygiene deletion,
  archive relocation, branch deletion, generated publication, hosted landing,
  final sync, or a `cleaned` claim from this implementation route.
- Do not widen accepted promotion targets.

## Workstreams

1. Preserve wrapper/profile composition.
   Reuse the proposal-program lifecycle runner and Proposal Program Delivery
   workflow. The wrapper may sequence, preflight, stop, and report blockers.
   Existing owners keep child receipts, packet closeout, archive, Change
   closeout, repo hygiene cleanup, generated publication, and terminal proof.

2. Tighten route state and stop-condition expression where current targets are
   under-specified.
   Ensure durable targets expose machine-checkable stop classes equivalent to:
   `authority-gap`, `ownership-conflict`, `unsafe-mutation`,
   `approval-required`, `stale-evidence`, `generated-freshness-drift`,
   `publishable-evidence-gap`, `validation-failure`,
   `parent-summary-substitution`, and `cleaned-proof-gap`.

3. Preserve target-owned evidence.
   Parent program summaries, delivery receipts, readiness projections, and
   delivery evidence indexes may cite child-owned evidence by path and digest
   only. They must not satisfy child implementation, conformance, drift/churn,
   closeout, archive, generated publication, Change, cleanup, branch, landing,
   sync, or terminal proof requirements.

4. Bind generated publication safely.
   Treat additive extension source assets as publication inputs only. Runtime
   consumers may rely only on published generated effective extension state
   through freshness-checked handles. Direct edits under
   `.octon/generated/effective/**` are invalid.

5. Keep terminal outcomes evidence-based.
   Requested outcome may be `cleaned`, but actual outcome must downgrade to the
   highest evidence-backed state: `blocked`, `implemented`, `archive-ready`,
   `landed`, `synced`, or `cleaned`.

## Validation Plan

Run at least these validators after implementation, plus any tighter validator
required by the changed target files:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture
```

When changed surfaces affect generated extension publication, also run:

```sh
bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-route-bundle.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-no-raw-generated-effective-runtime-reads.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh
```

When delivery profile, receipt, evidence-index, or readiness projection
semantics are touched, run the applicable subset:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh --profile <profile>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh --receipt <receipt>
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-program-delivery-evidence-index.sh --receipt <receipt> --out <index>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh --index <index>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh --projection <projection>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh --targeted <target>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh --receipt <receipt>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh --receipt <receipt>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh --receipt <receipt>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh --report <report>
bash .octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh --target <proposal-program>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-terminal-closeout-local-evidence.sh --proof <proof> --require-cleaned
bash .octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh
```

Record compact validation logs with command, cwd, start time, end time, exit
code, evidence ref, and bounded excerpts. Retain full logs or digests when
available under `.octon/state/evidence/validation/**` or the relevant
run/workflow evidence root.

## Required Negative Controls

Prove these fail closed through validators, fixtures, or explicit blocked
receipt evidence:

- Parent summary, readiness projection, delivery receipt, or delivery evidence
  index used as child-owned receipt evidence.
- Aggregate delivery receipt used as archive, Change, cleanup, generated
  publication, branch, landing, sync, or terminal proof authorization.
- Raw additive extension input used as runtime route authority without
  generated effective publication and freshness evidence.
- Hand-edited generated effective output used as fresh publication state.
- Local/private terminal evidence used as hosted or shared closeout proof.

## Evidence Requirements

Retain or cite:

- Profile Selection Receipt with `release_state: pre-1.0` and
  `change_profile: atomic`.
- Repository Reconnaissance Receipt covering searches for existing contracts,
  workflows, validators, specs, commands, skills, generated publication
  surfaces, and proposal lineage.
- Minimal Implementation Plan and Impact Map covering code, docs, contracts,
  generated outputs, evidence, and validators.
- Dependency Receipt stating `none` unless dependencies changed. Do not add
  dependencies without a separate receipt.
- Cleanup Pass Receipt covering added surfaces, simplifications, deletion
  candidates, retained residue, and remaining cleanup risk.
- Compact validator logs or receipts for every validator run or blocker.
- Publication receipts and generation locks when generated extension state is
  refreshed by the owning publisher.
- Rollback notes for each durable target family touched.

## Rollback Posture

Before durable implementation, rollback is packet rejection, supersession, or
archive. After implementation, rollback belongs to the implementing Change and
must revert only the scoped durable targets through the selected Change
closeout route. Generated outputs must be regenerated through owning publisher
scripts, not hand-reverted.

## Post-Implementation Packet Receipts

After implementation, write:

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture
```

The conformance review must cover promotion target existence, affected artifact
coverage, validator coverage, generated output coverage, rollback coverage,
downstream reference coverage, exclusions, and final closeout recommendation.

The drift/churn review must cover active proposal-path backreferences, naming
drift, generated projection freshness, manifest and schema validity,
repo-local projection boundaries, target-family boundaries, churn, validators
run, exclusions, and final closeout recommendation.

Refuse closeout, implemented status, archive-ready claims, implemented archive,
and `cleaned` claims until both post-implementation receipts exist, pass, and
their validators pass.

## Terminal Criteria

Implementation may report complete only when:

- every changed durable target stays inside the promotion target list;
- no active durable target depends on this proposal path as authority;
- target-owned authority boundaries remain explicit;
- generated and raw input non-authority checks pass;
- required validation passes or records an explicit blocker;
- `support/implementation-conformance-review.md` passes;
- `support/post-implementation-drift-churn-review.md` passes;
- rollback and cleanup posture are recorded;
- no unresolved authority, ownership, publication, evidence, or worktree
  blocker remains.

If any criterion is missing, report the route as blocked or deferred with the
next owning route and do not claim implementation success.

## Delegation Boundaries

Delegation is optional. If used, delegate only bounded, disjoint write scopes
inside the promotion targets. Do not delegate authorization, final acceptance,
Change closeout, archive, cleanup deletion, Git mutation, branch cleanup,
generated publication approval, or terminal proof claims. The orchestrator
remains accountable for integration, validation, receipts, and final boundary
checks.

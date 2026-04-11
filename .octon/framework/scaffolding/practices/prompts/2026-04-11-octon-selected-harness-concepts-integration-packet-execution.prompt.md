---
title: Octon Selected Harness Concepts Integration Packet Execution Prompt
description: Execution-grade prompt for fully implementing the selected harness concepts integration packet against the live Octon repository.
---

You are the principal Octon constitutional governance, assurance, and runtime
refinement engineer for this repository.

Your job is to fully implement the proposal packet at:

`/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/`

Treat this as a real implementation, promotion, validation, and closure
program. Do not treat it as a design review, prose rewrite, packet summary,
or partial planning exercise.

The packet lives under `inputs/**` and is non-authoritative. Use it as the
execution specification only. Promote durable meaning only into canonical
surfaces under:

- `/.octon/framework/**`
- `/.octon/instance/**`
- `/.octon/state/**`

Use `/.octon/generated/**` only for optional derived summaries or projections
that the packet explicitly calls for. Never satisfy the work by editing only
the proposal packet.

## Governing doctrine

1. Extend existing canonical surfaces; do not create parallel subsystems.
2. Preserve one live control plane and one retained proof plane.
3. Keep proposal packets, generated summaries, comments, and chat history
   non-authoritative.
4. Confirm already-covered concepts rather than reimplementing or replacing
   them.
5. Leave deferred and rejected concepts explicit and untouched.
6. When proposal text conflicts with live canonical repo truth, the live repo
   wins.

## Required reading order

Read these before planning or implementation:

1. `AGENTS.md`
2. `/.octon/instance/ingress/AGENTS.md`
3. `/.octon/framework/constitution/CHARTER.md`
4. `/.octon/framework/constitution/charter.yml`
5. `/.octon/framework/constitution/obligations/fail-closed.yml`
6. `/.octon/framework/constitution/obligations/evidence.yml`
7. `/.octon/framework/constitution/precedence/normative.yml`
8. `/.octon/framework/constitution/precedence/epistemic.yml`
9. `/.octon/framework/constitution/ownership/roles.yml`
10. `/.octon/framework/constitution/contracts/registry.yml`
11. `/.octon/instance/charter/workspace.md`
12. `/.octon/instance/charter/workspace.yml`
13. `/.octon/framework/agency/runtime/agents/orchestrator/AGENT.md`
14. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/README.md`
15. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/proposal.yml`
16. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/architecture-proposal.yml`
17. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/navigation/source-of-truth-map.md`
18. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/resources/repository-baseline-audit.md`
19. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/architecture/concept-coverage-matrix.md`
20. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/architecture/current-state-gap-map.md`
21. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/architecture/target-architecture.md`
22. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/architecture/file-change-map.md`
23. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/architecture/implementation-plan.md`
24. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/architecture/migration-cutover-plan.md`
25. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/architecture/validation-plan.md`
26. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/architecture/acceptance-criteria.md`
27. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/architecture/cutover-checklist.md`
28. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/architecture/closure-certification-plan.md`
29. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/architecture/execution-constitution-conformance-card.md`
30. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/resources/evidence-plan.md`
31. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/resources/decision-record-plan.md`
32. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/resources/assumptions-and-blockers.md`
33. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/resources/rejection-ledger.md`
34. `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/resources/risk-register.md`

Use `navigation/artifact-catalog.md` and
`resources/full-concept-integration-assessment.md` as supporting context when
the core packet files above are not enough.

## Profile Selection Receipt

Record and follow this profile before implementation:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- `selection_rationale`: repo ingress defaults `pre-1.0` work to `atomic`,
  and this packet refines live canonical surfaces without justifying a
  transitional dual-truth model
- `cutover posture within atomic profile`:
  - additive contracts first
  - retained evidence second
  - validators third
  - fail-closed gates last
- `transitional_exception_note`: not applicable unless a true hard blocker
  forces temporary dual-read behavior

Emit a Profile Selection Receipt into:

- `/.octon/instance/cognition/context/shared/migrations/2026-04-11-octon-selected-harness-concepts-integration/plan.md`
- `/.octon/state/evidence/migration/2026-04-11-octon-selected-harness-concepts-integration/**`

## Known packet sensitivities

1. The packet is manifest-governed, but the live repo's current active
   architecture packet convention differs. Do not claim that this packet shape
   is already the repo-native convention unless the repo is explicitly updated
   to make that true.
2. `/.octon/octon.yml` references a `migrate-harness` workflow path that this
   packet did not inspect. If you rely on that workflow, inspect it first and
   treat its live contents, not the packet's assumption, as authoritative.
3. Some proposal target paths may be stale relative to the live canonical repo
   families. If the live repo has already promoted a newer canonical family,
   update the live family and record the deviation in decision/evidence
   artifacts instead of reintroducing stale paths.

## Core objective

Fully implement every concept with final disposition `adapt`, confirm every
concept with final disposition `already_covered`, and leave `defer` and
`reject` concepts explicit without accidental implementation.

Completion means all of the following are true in substance, not only in
documentation:

1. Structured review findings and canonical review dispositions exist as a
   real capability with retained evidence and control gating.
2. Proposal-first mission classification exists as real mission control truth
   and fails closed when required proposal references are missing.
3. Failure-driven hardening exists as an evidence-to-proposal refinement loop
   with no automatic promotion into authority.
4. Tool or adapter output envelopes are compact, budgeted, machine-usable, and
   recoverable through retained raw evidence.
5. Evidence distillation exists as a governed evidence bundle and proposal
   generation path, not as a shadow-memory runtime feed.
6. Progressive-disclosure context, reversible work-item control, and evidence
   bundles remain confirmed canonical anchors and are not duplicated or
   replaced.
7. Deferred dependency-internalization work remains deferred until separate
   evidence exists.
8. Approval bypass or unbounded domain access remains rejected and
   constitutionally prohibited.

## Architectural facts you must preserve

Assume and verify all of the following:

1. `framework/**` and `instance/**` are the only authored authority roots.
2. `state/control/**` is the only live mutable control truth.
3. `state/evidence/**` is the retained proof plane.
4. `generated/**` is derived-only.
5. `inputs/**` is exploratory and may never become runtime or policy truth.
6. Mission and run control remain the only live execution control surfaces.
7. Distillation output may propose authority changes, but it may never auto-
   apply them.

## Already-covered concepts - confirm, do not duplicate

Treat the following as confirmation targets, not implementation scopes:

- Progressive-disclosure context map:
  `/.octon/instance/cognition/context/index.yml`,
  `/.octon/framework/governance/decisions/adr/ADR-036-cognition-sidecar-section-index-architecture.md`,
  and existing ingress or cognition roots remain the canonical anchors.
- Reversible work-item state machine:
  existing mission, run, stage-attempt, control, and continuity roots remain
  canonical.
- Evidence bundles and observability:
  existing run evidence, disclosure, RunCard, and HarnessCard surfaces remain
  canonical.

If the packet appears to suggest replacement work for those surfaces, prefer
the current repo anchors and record the confirmation rather than adding
duplicate architecture.

## Required implementation surfaces

Implement or update the current canonical equivalents of the following packet
targets. If the live repo has already moved a concept into a newer canonical
family, update the current family and record the path deviation rather than
reviving stale targets.

### 1. Structured review findings + disposition

- Create `review-finding` and `review-disposition` contracts in the canonical
  assurance family.
- Create a repo-specific review disposition policy.
- Materialize run-local review disposition state under
  `/.octon/state/control/execution/runs/<run-id>/authority/**`.
- Retain raw findings and provenance under
  `/.octon/state/evidence/runs/<run-id>/assurance/**`.
- Make progression validators read canonical dispositions rather than comments
  or prose-only reviews.

### 2. Proposal-first mission classification

- Extend `/.octon/instance/governance/policies/mission-autonomy.yml`.
- Extend the live canonical run-contract schema family with mission
  classification and proposal-requirement fields.
- Create or wire mission-local classification control records under
  `/.octon/state/control/execution/missions/<mission-id>/**`.
- Add fail-closed validation that proposal-required mission classes cannot
  execute without proposal references.

### 3. Failure-driven harness hardening

- Add canonical failure-classification and hardening-recommendation contracts.
- Add a repo-specific failure-distillation workflow contract.
- Retain failure-distillation bundles under
  `/.octon/state/evidence/validation/failure-distillation/<job-id>/**`.
- Ensure accepted hardenings promote only through ordinary authority routes
  such as policies, contracts, skills, or context surfaces.

### 4. Thin adapters + token-efficient outputs

- Add a canonical tool-output envelope contract in the current live
  constitutional contract system.
- Add a repo-specific output budget profile.
- Retain output-envelope validation receipts under
  `/.octon/state/evidence/validation/tool-output-envelope/<run-id>/**`.
- Offload full raw payloads to retained evidence while exposing only compact
  machine-usable envelopes to live agent or runtime flows.

### 5. Evidence distillation

- Add a canonical distillation-bundle contract.
- Add a repo-specific evidence-distillation workflow contract.
- Retain distillation bundles under
  `/.octon/state/evidence/validation/distillation/<job-id>/**`.
- Optionally publish derived summaries under
  `/.octon/generated/cognition/distillation/<job-id>/**`, but keep them
  explicitly non-authoritative.
- Ensure distillation remains evidence -> proposal -> human-approved
  promotion, never evidence -> runtime memory.

### 6. Contract registry and placement hygiene

- Update `/.octon/framework/constitution/contracts/registry.yml` whenever new
  schemas, families, or canonical placements are added.
- Do not create a stray contract family or path that conflicts with the live
  registry, workspace charter execution binding, or current run-contract
  lineage.

## Required evidence and decision capture

Every adapted concept must ship with retained evidence proving the capability
is real, usable, and constitutionally aligned.

At minimum retain:

- review findings NDJSON, disposition control snapshots, and blocking validator
  receipts
- mission classification control records, proposal references, and fail-closed
  validation receipts
- failure-distillation bundles, recurrence reports, and promoted-hardening
  regression proof
- output-envelope validation receipts, budget compliance proof, and raw-payload
  recovery pointers
- distillation bundles, source-index manifests, provenance proof, and
  anti-shadow-memory validation receipts

Where feasible, follow the repo's existing evidence-bundle pattern:

- `bundle.yml`
- `evidence.md`
- `commands.md`
- `validation.md`
- `inventory.md`

If promotion materially changes governance or contract meaning, record the
corresponding decisions under the appropriate repo decision surface. At
minimum, capture decisions for:

- review finding or disposition formalization
- proposal-gated failure or evidence distillation
- compact output envelopes as part of native-first runtime discipline
- proposal-first mission classification for high-ambiguity work

## Execution sequence

Execute the work in this order. Do not stop at intermediate analysis or the
first validator failure if the underlying repo state can still be fixed.

### Phase 0 - Scope confirmation and anchor verification

- Confirm final packet dispositions and packet-convention drift note.
- Confirm no overlap or supersession issue with the active UEC remediation
  packet that requires explicit merge or replacement.
- Confirm already-covered anchors remain the right anchors.
- Record the packet as non-authoritative implementation input.

### Phase 1 - Structured review findings + disposition

- Add contracts, policy, control-state materialization, retained finding
  records, and validators.
- Keep enforcement non-blocking until representative samples validate cleanly.

### Phase 2 - Proposal-first mission classification

- Extend policy and canonical run-contract schemas.
- Materialize mission-local classification state.
- Add proposal-reference enforcement validators.
- Keep gating report-only until representative samples validate cleanly.

### Phase 3 - Failure-driven hardening

- Add schemas and workflow contracts.
- Produce retained failure-distillation bundles.
- Prove recurring failure clustering and proposal generation.
- Do not auto-promote hardening outputs.

### Phase 4 - Thin adapter output envelopes

- Add the output-envelope contract and budget profile.
- Wire compact live envelopes plus retained raw payloads.
- Produce validation receipts and recoverability proof.

### Phase 5 - Evidence distillation

- Add the distillation contract and workflow.
- Produce retained distillation bundles and optional derived summaries.
- Keep the whole loop evidence-first and proposal-gated.

### Phase 6 - Fail-closed enablement and closure

- Turn on blocking review-disposition enforcement.
- Turn on proposal-required mission-class fail-closed behavior.
- Turn on output-envelope validation where runtime profiles apply.
- Run the full validation suite twice consecutively with no new blocking
  issues.
- Produce closure notes, evidence pointers, and explicit deferred or rejected
  concept statements.

## Validation contract

Validation must cover all of the following:

1. Structural validation:
   correct files, correct class roots, correct schema placement, and registry
   alignment.
2. Runtime or control validation:
   blocking review dispositions actually gate progression and proposal-first
   mission classes fail closed without packet references.
3. Assurance validation:
   findings map to dispositions, failure and distillation bundles preserve
   provenance, and no workflow auto-promotes authority.
4. Evidence retention validation:
   every new capability has inspectable retained proof and recoverable raw
   payloads.
5. Generated-output validation:
   generated summaries remain non-authoritative and trace back to control,
   evidence, or authority roots.
6. Operator and runtime usability validation:
   reviewers, mission intake, governance operators, and runtime adapters can
   actually use the new capability without side-channel conventions.

Minimum required validation artifacts by concept:

- Structured review findings + disposition:
  schema tests, run-control blocking tests, evidence provenance checks
- Proposal-first mission classification:
  schema tests, fail-closed mission intake tests, proposal-reference presence
  checks
- Failure-driven harness hardening:
  bundle validation, recurrence clustering checks, promoted-hardening
  regression proof
- Thin adapters + token-efficient outputs:
  output-envelope schema tests, token-budget checks, raw-payload recovery
  proof
- Distillation pipeline:
  distillation bundle schema tests, provenance checks, anti-shadow-memory
  checks

## Closure requirements

Do not certify closure until all of the following are true:

1. Every adapted concept still has the correct final disposition after
   implementation review.
2. Every required authoritative surface exists in the correct root.
3. Every required control-state artifact exists where mutable truth is needed.
4. Every required evidence artifact exists and is inspectable.
5. Every required validator or check exists and passes.
6. Every required operator or runtime touchpoint is demonstrably usable.
7. Two consecutive validation passes introduce no new blocking issues.

Certification output must include at minimum:

- one packet-level closure note
- one evidence-pointer set for each adapted concept
- one statement of remaining deferred and rejected concepts
- one zero-blocker assertion for the adapted concept set

## Hard blockers that justify stopping

Stop only for a true hard blocker such as:

- unresolved constitutional conflict
- unresolved ownership or authority routing ambiguity
- required destructive approval you do not have
- required validation impossible without unavailable external capability
- live canonical path ambiguity that cannot be resolved from current repo truth
  without human governance input

## Non-negotiable negative constraints

Do not do any of the following:

1. Do not create a second mission control plane, second review control plane,
   second proof plane, or shadow-memory subsystem.
2. Do not treat `inputs/**`, `generated/**`, comments, chat history, or host UI
   state as runtime or policy authority.
3. Do not auto-promote distillation or hardening outputs into authority.
4. Do not let review comments, free-form evaluator prose, or packet-local
   notes stand in for canonical review disposition state.
5. Do not add docs-only or proposal-only pseudo-capabilities and call them
   implemented.
6. Do not replace already-covered canonical anchors with duplicate new
   subsystems.
7. Do not widen mission autonomy, support targets, or approval boundaries.
8. Do not implement selective dependency internalization in this workstream.
9. Do not add unbounded domain access or any approval-bypass capability.
10. Do not backfill control truth from proposal-local packet files.
11. Do not let generated distillation summaries override retained evidence or
    promoted authority.
12. Do not leave validators advisory-only once the paired evidence and control
    materialization are proven clean.
13. Do not stop at analysis, blocker ledgers, or first-pass validation if the
    underlying implementation can still be completed in the current branch.

## Delivery contract

You must satisfy all of the following:

1. Work on one branch only.
2. Continue from implementation through validation and closure unless a true
   hard blocker appears.
3. Promote durable outcomes into canonical repo surfaces, never back into the
   proposal tree.
4. Keep current live repo truth above stale proposal path suggestions.
5. After any turn that changes files, ask exactly:
   `Are you ready to closeout this branch?`

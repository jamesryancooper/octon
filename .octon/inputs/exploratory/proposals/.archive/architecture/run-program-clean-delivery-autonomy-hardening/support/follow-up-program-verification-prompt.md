prompt_id: run-program-clean-delivery-autonomy-hardening-program-verification-20260704T0306Z
generated_at: "2026-07-04T03:06:08Z"
generated_by: octon-proposal-lifecycle-generate-program-verification-prompt
generator_route_id: generate-program-verification-prompt
generation_run_id: lifecycle-proposal-program-1783112176123-f118c03e
target_program: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening
artifact_class: operational-aid
authority: non-authoritative
parent_status_at_generation: implemented
child_authority_preserved: yes
program_verification_execution_authorized: gated-rerun-required
verdict: ready-for-verification

# Follow-Up Program Verification Prompt

## Purpose

Run parent aggregate verification for
`run-program-clean-delivery-autonomy-hardening` after program implementation
orchestration. This prompt is an operational aid only. It does not authorize
parent closeout, archive, Proposal Program Delivery, Change closeout, hosted
landing, branch cleanup, worktree cleanup, publication, deletion, generated
output refresh, Git mutation, or a `cleaned` claim.

The later verification route may write or refresh only these parent-local
aggregate receipts:

- `support/program-implementation-orchestration-conformance-review.md`
- `support/program-post-implementation-orchestration-drift-churn-review.md`

Those receipts may summarize child state by path and digest, but they must not
satisfy or replace child manifests, child receipts, child validation verdicts,
child promotion targets, child archive metadata, child closeout evidence,
Proposal Program Delivery receipts, Change receipts, cleanup authorization,
branch state, rollback handles, terminal proof, or child lifecycle outcomes.

## Verification Target

Verify the implemented proposal program at:

```text
.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening
```

Packet identity:

- `proposal_id`: `run-program-clean-delivery-autonomy-hardening`
- `proposal_kind`: `architecture`
- `status`: `implemented`
- `program_execution_mode`: `sequential`
- `required_child_count`: `7`
- `profile`: `release_state=pre-1.0`, `change_profile=atomic`

Act as an independent verifier. Re-ground against current repository state
before judging the packet. Generation-time observations in this prompt are
context only; current files, validators, and retained evidence win.

## Required Source Reading

Read these parent files before checking child evidence or durable targets:

- `proposal.yml`
- `architecture-proposal.yml`
- `README.md`
- `resources/child-packet-index.yml`
- `resources/child-packet-index.md`
- `architecture/packet-sequence.md`
- `architecture/child-packet-contract.md`
- `architecture/program-closeout-plan.md`
- `architecture/implementation-plan.md`
- `architecture/target-architecture.md`
- `architecture/acceptance-criteria.md`
- `validation-plan.md`
- `navigation/source-of-truth-map.md`
- `navigation/artifact-catalog.md`
- `support/proposal-review.md`
- `support/implementation-grade-completeness-review.md`
- `support/pre-integration-architecture-review.yml`
- `support/program-implementation-orchestration-prompt.md`
- `support/program-implementation-orchestration-run.md`

Then inspect each required child packet as child-owned evidence. Resolve each
child from the parent registry path to its current active or archived packet
path. At generation time all seven required children were archived under
`.octon/inputs/exploratory/proposals/.archive/architecture/`; the later route
must re-resolve this rather than trusting the generation-time state.

For each required child, inspect these child-owned files:

- `proposal.yml`
- `support/proposal-review.md`
- `support/implementation-grade-completeness-review.md`
- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`
- `support/pre-integration-architecture-review.yml`
- `support/proposal-closeout.md`
- `support/proposal-terminal-closeout.yml`

If a required child is missing, no longer terminal, no longer archived when the
parent expects archived evidence, or lacks child-owned implementation,
conformance, drift, validation, closeout, terminal closeout, or archive
evidence, write blocked parent aggregate receipts and return control to the
owning child lifecycle route.

## Child Sequence And Dependencies

Verify the children in the registered sequential order. Do not parallelize
child acceptance judgment and do not reorder dependencies.

| Order | Child id | Generation-time evidence path | Dependency gate |
| --- | --- | --- | --- |
| 1 | `run-program-clean-delivery-compact-blocker-remediation` | `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-compact-blocker-remediation` | terminal |
| 2 | `run-program-clean-delivery-autonomous-hygiene-continuation` | `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-autonomous-hygiene-continuation` | terminal after child 1 |
| 3 | `run-program-clean-delivery-stale-branch-retirement` | `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-stale-branch-retirement` | terminal after child 2 |
| 4 | `run-program-clean-delivery-run-health-localization` | `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-run-health-localization` | terminal after child 3 |
| 5 | `run-program-clean-delivery-no-dispatch-deduplication` | `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-no-dispatch-deduplication` | terminal after child 4 |
| 6 | `run-program-clean-delivery-retained-state-reporting` | `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-retained-state-reporting` | terminal after child 5 |
| 7 | `run-program-clean-delivery-authorized-hosted-landing` | `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-authorized-hosted-landing` | terminal after child 6 |

The parent may only cite child evidence by current path and digest. Parent
summary text is not child evidence.

## Verification Questions

Answer these questions with evidence:

- Does `proposal.yml` remain `status: implemented`, and does packet-local
  lifecycle authority remain in `proposal.yml` rather than subtype metadata?
- Does `support/program-implementation-orchestration-run.md` report
  `verdict: pass`, `required_child_count: 7`, `terminal_child_count: 7`,
  `parent_summary_not_child_evidence: true`,
  `child_receipts_remain_child_owned: true`, and
  `child_authority_preserved: yes`?
- Do all seven child packets remain terminal and archived with child-owned
  review, architecture, implementation, conformance, drift, validation,
  closeout, terminal closeout, and archive evidence?
- Does child sequencing preserve every dependency gate in
  `resources/child-packet-index.yml`?
- Do child-owned implementation and validation receipts cover PM-001 through
  PM-007 without leaving a parent-only proof gap?
- Do the aggregate acceptance criteria remain satisfied for compact blocker
  remediation, artifact budgets, hygiene continuation, stale branch retirement,
  run-health localization, no-dispatch deduplication, retained-state reporting,
  and authorized hosted landing?
- Are generated read models, proposal paths, generated prompts, host
  projections, chat, dashboards, local-only diagnostics, and tool state kept
  non-authoritative?
- Are cleanup, branch deletion, hosted mutation, publication, archive, final
  sync, terminal cleanliness, and `cleaned` claims absent unless a separate
  owning route has current retained evidence?

## Required Commands

Run these checks from the repository root. Record exact command, exit code,
relevant output summary, affected paths, and retained evidence location when
the command writes evidence.

```text
yq -e . .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/proposal.yml
yq -e . .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/architecture-proposal.yml
rg -n "T[O]DO|T[B]D|F[I]XME|\\{\\{|\\[[D]escribe" .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening --require-terminal-evidence
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening --projection .octon/generated/proposals/artifacts/architecture/run-program-clean-delivery-autonomy-hardening/proposal-program-spine.yml --require-terminal-evidence
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-hosted-no-pr-landing.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-lifecycle-alignment.sh
git diff --check
```

For each current child path, also run:

```text
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <child> --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt <child>/support/pre-integration-architecture-review.yml --package <child> --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <child>
```

If a delivery receipt or delivery evidence index does not yet exist for this
parent, record an accepted-external delivery finding and do not claim
`cleaned`, final sync, branch cleanup, worktree cleanliness, hosted landing, or
terminal delivery. Missing delivery evidence is not a parent aggregate
verification failure unless the verifier tries to make a delivery or terminal
cleanliness claim.

## Stable Finding Identity

Use stable finding ids in the `RCDHA-PVFY` namespace:

- `RCDHA-PVFY-001`, `RCDHA-PVFY-002`, and so on.
- Reuse the same id across reruns for the same root cause.
- Do not renumber findings after one is resolved.
- Group issues only when they share one correction and one acceptance test.

Each finding must include:

- id
- severity: `P0`, `P1`, `P2`, or `P3`
- status: `open`, `resolved`, `blocked`, or `accepted-external`
- owner: parent, child id, delivery, Change, cleanup, generated-output, or
  external-route
- affected paths
- evidence
- expected behavior
- correction scope
- acceptance criteria
- deferral eligibility: `eligible` or `not-eligible`

No finding is deferrable if it concerns child authority preservation,
implementation conformance, post-implementation drift, generated/runtime
publication freshness, proposal path authority leakage, required validator
failure, or a required child terminal evidence gap.

## Required Receipt Shape

If all parent aggregate gates pass, write or refresh
`support/program-implementation-orchestration-conformance-review.md` with at
least:

```markdown
verdict: pass
unresolved_items_count: 0
child_receipt_summary_count: <current count from child-owned receipts inspected>
child_authority_preserved: yes
verified_at: <UTC timestamp>
run_id: <current verification run id>
target_program: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening

# Program Implementation Orchestration Conformance Review
```

The conformance receipt must include:

- scope and authority boundary;
- stable findings table;
- checked parent evidence;
- child receipt summary for all seven children;
- sequence and dependency-gate verification;
- PM-001 through PM-007 coverage;
- aggregate acceptance-criteria coverage;
- validator coverage with command summaries and evidence refs;
- generated-output and proposal-path non-authority review;
- delivery, Change, cleanup, branch, hosted-landing, archive, and terminal
  proof boundaries;
- explicit exclusions;
- final route recommendation.

If parent aggregate drift/churn gates pass, write or refresh
`support/program-post-implementation-orchestration-drift-churn-review.md` with
at least:

```markdown
verdict: pass
unresolved_items_count: 0
child_receipt_summary_count: <current count from child-owned receipts inspected>
child_authority_preserved: yes
verified_at: <UTC timestamp>
run_id: <current verification run id>
target_program: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening

# Program Post-Implementation Orchestration Drift/Churn Review
```

The drift/churn receipt must include:

- scope and authority boundary;
- stable findings table;
- current parent and child state;
- active proposal-path backreference scan across durable surfaces;
- generated projection freshness review;
- manifest and schema validity;
- host projection and generated read-model boundary review;
- target-family boundary review across lifecycle, workflow, closeout, product
  contracts, skills, commands, validators, and tests;
- cleanup and worktree-hygiene posture under the explicit dirty-start lease;
- churn review limited to changes caused by this verification route;
- validators run;
- delivery, Change, cleanup, branch, hosted-landing, archive, and terminal
  proof boundaries;
- explicit exclusions;
- final route recommendation.

If any required parent or child gate fails, write both receipts with
`verdict: blocked` or `verdict: fail`, `child_authority_preserved: no` when the
failure would require parent substitution for child authority, and stable
findings that name the next owning route. Do not fill child evidence gaps with
parent text.

## Return Status

Return exactly one final route status:

- `clean`
- `corrections-needed`
- `needs-packet-revision`
- `blocked`
- `superseded`
- `explicitly-deferred`

Use `clean` only when both required parent aggregate receipts exist, both
declare `verdict: pass`, both declare `unresolved_items_count: 0`, both declare
`child_authority_preserved: yes`, all required validators and deterministic
checks pass or are recorded as accepted-external without a parent claim, and no
open `RCDHA-PVFY` finding remains.

Use `corrections-needed` for bounded parent receipt or durable implementation
corrections that stay within accepted child scope. Use
`needs-packet-revision` when the accepted parent or child proposal semantics
are insufficient. Use `blocked` when authority, evidence, or validator state is
missing and cannot be corrected within the route.

## Hard Stops

Stop without writing passing receipts if any of these are true:

- parent `proposal.yml#status` is not `implemented`;
- parent review is missing, stale, not accepted, or lacks implementation
  authorization;
- parent strict pre-integration architecture review is missing, stale, or not
  passing;
- `support/program-implementation-orchestration-run.md` is missing, incomplete,
  not passing, or reports `child_authority_preserved: no`;
- child readiness, program structure, parent standard, or architecture
  validation fails;
- any required child cannot be resolved to a current active or archived packet;
- any child-owned implementation, conformance, drift/churn, validation,
  closeout, terminal closeout, or archive evidence is missing or failing;
- parent summaries would be the only proof of child state;
- verification would require destructive cleanup, branch deletion, hosted
  provider mutation, generated publication, archive relocation, Change
  closeout, or terminal proof outside the owning route;
- generated outputs, proposal paths, generated prompts, host projections, chat,
  dashboards, or model memory would need to become authority.

## Delivery Boundary

This prompt does not authorize Proposal Program Delivery and does not claim
clean delivery. Proposal Program Delivery may claim `cleaned` only through its
own governed route and only when aggregate delivery receipt,
evidence-index validation, terminal proof, Change closeout alignment, branch
cleanup authorization, final sync proof, worktree hygiene, cleanup
authorization, and no-open-blocker evidence all pass.

If aggregate delivery evidence is absent, the verification receipts must report
the highest evidence-backed parent orchestration outcome and name Proposal
Program Delivery or the owning closeout route as the next step.

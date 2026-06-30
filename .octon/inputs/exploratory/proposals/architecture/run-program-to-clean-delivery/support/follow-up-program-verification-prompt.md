prompt_id: run-program-to-clean-delivery-follow-up-program-verification-20260630T014200Z
generated_by: octon-proposal-lifecycle-generate-program-verification-prompt
target_program: .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery
route: run-program-verification-and-correction-loop
artifact_class: operational-aid
authority: non-authoritative
run_id: 20260630T014200Z-run-program-to-clean-delivery-parent-verification-prompt
prompt_set_id: octon-proposal-lifecycle-generate-program-verification-prompt
prompt_bundle_sha256: sha256:581741a858b04d2f85183470a0f83a6915cb0729a4fd91661da241835f53281c
generated_at: 2026-06-30T01:42:00Z

# Follow-Up Program Verification Prompt

## Purpose

Run aggregate parent program verification for:

`.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery`

Use this only after `support/program-implementation-orchestration-run.md`
exists and reports `verdict: pass` with `child_authority_preserved: yes`.
This prompt is parent-local coordination guidance only. It does not approve
execution, widen scope, replace proposal manifests, replace child-owned
receipts, replace child validation verdicts, authorize closeout, authorize
archive, stage changes, commit changes, deliver a Change, clean a branch, or
claim `git_clean_terminal`.

The verification loop must produce parent-local aggregate receipts:

- `support/program-implementation-orchestration-conformance-review.md`
- `support/program-post-implementation-orchestration-drift-churn-review.md`

These receipts may summarize child state, but they must not satisfy child
receipts, child validation verdicts, child promotion targets, child archive
metadata, child terminal outcomes, Change delivery receipts, branch cleanup
authorization, terminal proof, or cleaned-state claims.

## Required Reads

Read the repository ingress and proposal lifecycle context before verification:

- `AGENTS.md`
- `.octon/instance/ingress/AGENTS.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery/proposal.yml`
- `.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery/architecture-proposal.yml`
- `.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery/resources/child-packet-index.yml`
- `.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery/architecture/child-packet-contract.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery/architecture/packet-sequence.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery/architecture/program-closeout-plan.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery/architecture/acceptance-criteria.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery/validation-plan.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery/support/proposal-review.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery/support/program-implementation-orchestration-prompt.md`
- `.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery/support/program-implementation-orchestration-run.md`
- `.octon/state/evidence/runs/workflows/20260630T010000Z-run-program-to-clean-delivery-parent-next-route/aggregate-terminal-blockers.yml`

Read each required child through its child-owned archived packet and terminal
closeout receipt. The parent child registry still records the original sibling
paths; the archived packets and terminal receipts are the evidence to inspect
for the current child lifecycle outcome.

Required children, in sequence:

1. `run-program-clean-delivery-architecture`
   - archived packet:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-architecture`
   - terminal receipt:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-architecture/support/proposal-terminal-closeout.yml`
2. `run-program-clean-delivery-runner-routing`
   - archived packet:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-runner-routing`
   - terminal receipt:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-runner-routing/support/proposal-terminal-closeout.yml`
3. `run-program-clean-delivery-workflow-handoff`
   - archived packet:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-workflow-handoff`
   - terminal receipt:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-workflow-handoff/support/proposal-terminal-closeout.yml`
4. `run-program-clean-delivery-evidence-metadata`
   - archived packet:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-evidence-metadata`
   - terminal receipt:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-evidence-metadata/support/proposal-terminal-closeout.yml`
5. `run-program-clean-delivery-validators`
   - archived packet:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-validators`
   - terminal receipt:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-validators/support/proposal-terminal-closeout.yml`
6. `run-program-clean-delivery-operator-surface`
   - archived packet:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-operator-surface`
   - terminal receipt:
     `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-operator-surface/support/proposal-terminal-closeout.yml`

For each child, inspect:

- `proposal.yml`
- `architecture-proposal.yml`
- `architecture/acceptance-criteria.md`
- `architecture/implementation-plan.md`
- `validation-plan.md`
- `support/proposal-review.md`
- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/proposal-closeout.md`
- `support/proposal-terminal-closeout.yml`

## Authority Boundaries

- Preserve the parent manifest status as current repo state unless a later
  authorized lifecycle route explicitly changes it.
- Treat `inputs/**` proposal packets as non-authoritative planning lineage.
- Parent evidence cannot satisfy child receipts, child promotion targets,
  child validation verdicts, child closeout evidence, child archive metadata,
  child terminal closeout, Change delivery receipts, branch cleanup
  authorization, terminal proof, or cleaned-state claims.
- Each child keeps authority over its own manifest, scope, acceptance criteria,
  promotion targets, validators, support reviews, closeout, archive, and
  corrections.
- Do not mutate an archived child packet from the parent route. If child
  evidence is missing, stale, malformed, or failing, stop with the child owner
  and next owning child route.
- Do not run program closeout, archive relocation, Change delivery, branch
  cleanup, destructive cleanup, staging, commit, push, or terminal clean-state
  routes from this verification/correction loop.
- Generated outputs, raw inputs, host UI state, chat/model memory, and tool
  availability remain non-authority unless backed by authored runtime, spec,
  validator, or retained evidence surfaces.
- The archived child packet locations do not make the parent registry paths
  evidence authority; verify registry intent and archive outcome separately.

## Interpreter Preflight

Some validators use Bash associative arrays. Before running validators,
confirm that the `bash` used for command execution is Bash 4 or newer:

```sh
bash --version
```

If `bash` resolves to `/bin/bash` 3.2 and a validator fails with
`declare: -A: invalid option`, treat that as an interpreter issue, not a
proposal-content failure. Rerun the affected validator with a Bash 4+ or Bash 5
interpreter, for example:

```sh
/Users/jamesryancooper/.homebrew/bin/bash <validator> <args>
```

## Verification Sequence

Verify in this order:

1. Confirm the parent implementation orchestration run reports:
   - `verdict: pass`
   - `child_authority_preserved: yes`
   - `promotion_evidence_count: 6`
   - every required child outcome is `archived`
   - no parent evidence claims child receipt satisfaction, Change delivery,
     branch cleanup authorization, terminal proof, or `git_clean_terminal`.
2. Confirm the aggregate terminal blocker evidence reports
   `blocked_required_child_count: 0`.
3. Confirm the child registry is sequential, required, and dependency ordered:
   - `run-program-clean-delivery-architecture`
   - `run-program-clean-delivery-runner-routing`, after architecture
   - `run-program-clean-delivery-workflow-handoff`, after architecture and
     runner routing
   - `run-program-clean-delivery-evidence-metadata`, after workflow handoff
   - `run-program-clean-delivery-validators`, after runner routing, workflow
     handoff, and evidence metadata
   - `run-program-clean-delivery-operator-surface`, after validators
4. Confirm every required child archived packet has:
   - `proposal.yml#status: archived`
   - a terminal closeout receipt with `terminal_verdict: archive-ready`
   - `archive_ready: yes`
   - passing child-owned implementation conformance evidence
   - passing child-owned post-implementation drift/churn evidence
   - terminal closeout evidence that cites child-owned validation and does not
     use parent aggregate evidence as the child verdict.
5. Rerun required parent, archived child, terminal closeout, publication,
   proposal-program delivery, Change closeout, evidence-tier, feature-catalog,
   and non-authority validators.
6. Inspect durable targets for proposal-path backreferences, generated-output
   authority leaks, raw-input authority leaks, stale refs, incomplete feature
   catalog notes, missing delivery receipt refs, branch cleanup authority
   leaks, and under-scoped validation coverage.
7. Inspect current worktree churn and classify it as declared durable target
   changes, generated projections, retained evidence, parent-local support
   evidence, archived child evidence, or unrelated residue.
8. If findings exist, classify each finding by owner and apply only the
   smallest authorized correction. Use exactly one owner class:
   - `parent`
   - `child:run-program-clean-delivery-architecture`
   - `child:run-program-clean-delivery-runner-routing`
   - `child:run-program-clean-delivery-workflow-handoff`
   - `child:run-program-clean-delivery-evidence-metadata`
   - `child:run-program-clean-delivery-validators`
   - `child:run-program-clean-delivery-operator-surface`
   - `cross-child`
   - `out-of-scope`
9. Repeat verification after each correction until both parent-local aggregate
   receipts can pass, or stop with failing receipts and concrete blockers.

## Required Validators

Run parent gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery
```

For each archived child, run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <archived-child> --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package <archived-child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <archived-child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <archived-child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-receipt.sh --receipt <archived-child>/support/proposal-terminal-closeout.yml
```

Run program delivery and Change closeout validators:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh --receipt <program-delivery-receipt-if-present>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh --receipt <change-receipt-if-present>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh --receipt <change-receipt-if-present>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh --receipt <change-receipt-if-present> --verify-live-refs
bash .octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh --change-receipt <change-receipt-if-present>
```

If a receipt is not present because this route has not reached delivery,
record `not-applicable: receipt absent before delivery route` instead of
creating or inventing a receipt.

Run publication, generated/non-authority, terminal, and feature validators:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check
```

Run clean-delivery regression coverage when the corresponding tests exist:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-branch-no-pr-delivery-receipt-builder.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-lifecycle-alignment.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-evidence-disclosure-tiers.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-packet-terminal-closeout.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-proposal-artifact-index-spine.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-generate-proposal-registry.sh
```

If a named test is absent in the current checkout, record it as
`not-applicable: test absent` and continue with the closest current validator.

## Correction Loop

If a validator, evidence inspection, terminal closeout check, delivery receipt
check, or authority boundary check fails, create stable findings and classify
each finding by owner.

Correction rules:

- Apply a correction only when it is inside parent-local support evidence
  required by this verification route, or inside a durable target that the
  owning child already implemented and the current route is explicitly allowed
  to correct.
- Keep corrections minimal and evidence-driven.
- After any durable correction, rerun the smallest affected validator set
  first, then rerun the full required validator set before declaring aggregate
  pass.
- After any child-owned correction need is identified, stop and route to the
  owning child lifecycle route. Do not hand-edit archived child receipts from
  the parent route.
- After any parent-local support correction, rerun parent gates and aggregate
  receipt checks.
- Do not repair unrelated repository residue.
- Do not perform closeout, archive relocation, delivery, branch cleanup,
  destructive cleanup, staging, commit, push, or terminal clean-state proof.

Stop and write failing aggregate receipts instead of mutating when:

- the correction would exceed a child promotion target;
- the correction would require archived child receipt edits from the parent;
- the correction would require sibling mutation not authorized by the owning
  child;
- the correction would require product behavior outside this program's scope;
- the correction would treat parent evidence as child authority;
- the correction would require human approval;
- the correction would require destructive cleanup, branch deletion, or Git ref
  mutation;
- the correction would require generated outputs, raw inputs, host UI state,
  chat/model memory, or tool availability to act as authority.

## Conformance Receipt Requirements

Write:

`.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery/support/program-implementation-orchestration-conformance-review.md`

Include at least these top-level fields:

```text
verdict: pass|fail
unresolved_items_count: <integer>
child_receipt_summary_count: <integer>
child_authority_preserved: yes|no
verified_at: <UTC timestamp>
```

Use `verdict: pass` and `child_authority_preserved: yes` only when:

- the parent implementation orchestration run reports `verdict: pass`;
- aggregate terminal blocker evidence reports `blocked_required_child_count:
  0`;
- the child registry sequence and dependencies match the implemented and
  archived child order;
- every required child has passing child-owned implementation conformance and
  post-implementation drift/churn reviews;
- every required child has a terminal closeout receipt with
  `terminal_verdict: archive-ready` and `archive_ready: yes`;
- parent, archived child, terminal closeout, delivery boundary, publication,
  generated/non-authority, feature-catalog, and regression validators pass or
  have clearly recorded non-blocking warnings;
- promotion target coverage matches child-owned scopes;
- no parent evidence is used to satisfy child receipts, child validation
  verdicts, child promotion targets, child closeout evidence, child archive
  metadata, Change delivery receipts, branch cleanup authorization, terminal
  proof, or cleaned-state claims;
- generated outputs and evidence paths remain derived or retained evidence,
  not runtime authorization or catalog authority.

Include sections for blockers, checked evidence, child receipt summary,
archived child terminal receipt summary, promotion target coverage, validator
coverage, correction summary, generated output coverage, delivery and Change
boundary coverage, rollback coverage, downstream reference coverage,
exclusions, and final route recommendation.

## Drift And Churn Receipt Requirements

Write:

`.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery/support/program-post-implementation-orchestration-drift-churn-review.md`

Include at least these top-level fields:

```text
verdict: pass|fail
unresolved_items_count: <integer>
child_receipt_summary_count: <integer>
child_authority_preserved: yes|no
verified_at: <UTC timestamp>
```

Use `verdict: pass` and `child_authority_preserved: yes` only when:

- the aggregate conformance receipt exists and reports `verdict: pass`;
- current parent metadata drift is explicitly checked, including
  `proposal.yml#status`, `architecture-proposal.yml#status`, archive outcome,
  parent navigation, and support artifact inventory;
- archived child packet state has no unresolved mismatch between terminal
  receipt paths, archived packet locations, original child registry entries,
  and current proposal manifests;
- durable clean-delivery targets contain no active proposal-path dependencies
  except retained evidence or historical provenance references;
- delivery, Change closeout, hosted landing, cleanup, and terminal proof
  surfaces preserve their owning-route boundaries;
- proposal-program delivery and terminal closeout workflows do not bypass
  existing governed mechanism integration, proposal review, archive readiness,
  delivery receipt, branch cleanup authorization, or terminal proof
  boundaries;
- receipt schemas and validators consistently represent the implemented
  clean-delivery lifecycle capability;
- generated outputs, raw inputs, proposal packets, generated prompts, host UI
  state, chat/model memory, and tool availability remain non-authority;
- churn is limited to declared child promotion targets, generated projections,
  retained evidence, archived child evidence, parent-local aggregate
  verification receipts, and validator output summaries.

Include sections for blockers, checked evidence, durable target backreference
scan, parent lifecycle metadata drift, archived child drift review, delivery
and Change boundary review, branch cleanup and terminal proof boundary review,
generated/non-authority review, target-family boundary review, churn review,
validators run, warnings, exclusions, and final closeout recommendation.

## Pass And Failure Semantics

If any required command fails, any required child review is missing or failing,
any archived child terminal receipt is missing or failing, any delivery or
cleanup evidence boundary is incoherent, any parent/child dependency is
incoherent, or the parent would need to own child truth to pass, write failing
aggregate receipts with concrete blockers. Do not omit the receipts because
verification failed.

If both aggregate receipts pass, the final route recommendation is:

`generate-program-closeout-prompt`

If either aggregate receipt fails, the final route recommendation must identify
the smallest correction route, child owner, parent-local fix, or human
escalation needed before program closeout can continue.

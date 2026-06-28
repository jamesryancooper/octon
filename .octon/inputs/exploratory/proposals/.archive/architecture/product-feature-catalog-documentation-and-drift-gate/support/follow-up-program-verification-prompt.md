prompt_id: product-feature-catalog-documentation-and-drift-gate-follow-up-program-verification-20260627T185959Z
generated_by: octon-proposal-lifecycle-generate-program-verification-prompt
target_program: .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate
route: run-program-verification-and-correction-loop
artifact_class: operational-aid
authority: non-authoritative
generated_at: 2026-06-27T18:59:59Z

# Follow-Up Program Verification Prompt

## Purpose

Run the aggregate verification/correction loop for:

`.octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate`

Use this only after `support/program-implementation-orchestration-run.md`
exists and reports a passing implementation orchestration run. This prompt is
parent-local coordination guidance only. It does not approve execution, widen
scope, replace proposal manifests, replace child-owned receipts, replace child
validation verdicts, authorize closeout, authorize archive, stage changes, or
commit changes.

The verification loop must produce parent-local aggregate receipts:

- `support/program-implementation-orchestration-conformance-review.md`
- `support/program-post-implementation-orchestration-drift-churn-review.md`

These receipts may summarize child state, but they must not satisfy child
receipts, child validation verdicts, child promotion targets, child archive
metadata, rollback handles, or child terminal outcomes.

## Required Reads

Read the repository ingress and proposal lifecycle context before verification:

- `AGENTS.md`
- `.octon/instance/ingress/AGENTS.md`
- `.octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate/proposal.yml`
- `.octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate/architecture-proposal.yml`
- `.octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate/resources/child-packet-index.yml`
- `.octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate/architecture/child-packet-contract.md`
- `.octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate/architecture/packet-sequence.md`
- `.octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate/architecture/program-closeout-plan.md`
- `.octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate/architecture/acceptance-criteria.md`
- `.octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate/validation-plan.md`
- `.octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate/support/proposal-review.md`
- `.octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate/support/program-implementation-orchestration-prompt.md`
- `.octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate/support/program-implementation-orchestration-run.md`

Read each required child packet and its child-owned implementation evidence:

- `.octon/inputs/exploratory/proposals/architecture/document-current-product-feature-gaps`
- `.octon/inputs/exploratory/proposals/architecture/feature-catalog-drift-closeout-gate`
- `.octon/inputs/exploratory/proposals/architecture/feature-catalog-drift-validator`
- `.octon/inputs/exploratory/proposals/architecture/closeout-integration-and-receipts`

For each child, inspect:

- `proposal.yml`
- `architecture-proposal.yml`
- `architecture/acceptance-criteria.md`
- `architecture/implementation-plan.md`
- `validation-plan.md`
- `support/proposal-review.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

## Authority Boundaries

- Preserve parent `proposal.yml#status: accepted` unless a later authorized
  lifecycle route explicitly changes it.
- The parent program is coordination lineage only.
- Parent evidence cannot satisfy child receipts, child promotion targets,
  child validation verdicts, child closeout evidence, or child archive
  metadata.
- Each child keeps authority over its own manifest, scope, acceptance criteria,
  promotion targets, validators, support reviews, and corrections.
- Do not mutate a sibling packet unless the active child packet explicitly
  requires a sibling-local consistency change.
- Do not run program promotion, closeout, archive, delivery, staging, commit,
  or Change closeout routes from this verification/correction loop.
- Generated outputs, raw inputs, host UI state, chat/model memory, and tool
  availability remain non-authority unless backed by authored runtime, spec,
  validator, or retained evidence surfaces.
- Product feature catalog entries remain navigation-only. They do not mint
  runtime routes, generated-effective state, support claims, or execution
  evidence.
- Drift receipts and validation outputs are evidence for closeout gating. They
  are not runtime authorization and do not silently rewrite product docs.

## Interpreter Preflight

Some program validators use Bash associative arrays. Before running validators,
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

1. Confirm the parent implementation orchestration run exists and reports:
   - `verdict: pass`
   - `child_authority_preserved: yes`
   - `promotion_evidence_count: 0`
   - no program promotion, closeout, archive, delivery, staging, commit, or
     Change closeout route was run.
2. Confirm the child registry is sequential and the child paths are siblings,
   not nested under the parent program.
3. Verify the child sequence and dependency gates:
   - `document-current-product-feature-gaps`
   - `feature-catalog-drift-closeout-gate`, after child 1
   - `feature-catalog-drift-validator`, after child 2
   - `closeout-integration-and-receipts`, after children 2 and 3
4. Confirm every required child has passing child-owned
   `support/implementation-conformance-review.md`.
5. Confirm every required child has passing child-owned
   `support/post-implementation-drift-churn-review.md`.
6. Rerun required parent, child, product catalog, drift, workflow, and receipt
   validators.
7. Inspect durable targets for proposal-path backreferences, generated-output
   authority leaks, raw-input authority leaks, stale refs, incomplete feature
   notes, missing receipt refs, and under-scoped validation coverage.
8. If findings exist, classify them by owner and apply only the smallest
   authorized correction.
9. Repeat verification after each correction until both parent-local aggregate
   receipts can pass, or stop with failing receipts and concrete blockers.

## Required Validators

Run parent gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate
```

For each child, run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <child> --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <child>
```

Run product feature catalog validation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
```

Run feature catalog drift validation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh --fixture missing-catalog-entry
bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh --fixture stale-ref
bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh --fixture status-mismatch
bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh --fixture probably-not-product-feature
bash .octon/framework/assurance/runtime/_ops/tests/test-feature-catalog-drift-closeout.sh
```

Run workflow validators:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-workflow.sh
```

Run receipt validator regression tests:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-packet-delivery.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-packet-terminal-closeout.sh
```

## Correction Loop

If a validator, evidence inspection, or receipt check fails, create stable
findings and classify each finding as exactly one owner class:

- `parent`
- `child:document-current-product-feature-gaps`
- `child:feature-catalog-drift-closeout-gate`
- `child:feature-catalog-drift-validator`
- `child:closeout-integration-and-receipts`
- `cross-child`
- `out-of-scope`

Correction rules:

- Apply a correction only when it is inside the owning child packet's declared
  promotion targets and acceptance criteria, or inside parent-local support
  evidence required by this verification route.
- Keep corrections minimal and evidence-driven.
- After any child-owned correction, update or regenerate that child's own
  implementation conformance and post-implementation drift/churn evidence
  before aggregate parent receipts may pass.
- After any parent-local support correction, rerun parent gates and aggregate
  receipt checks.
- Rerun the smallest affected validator set first, then rerun the full required
  validator set before declaring aggregate pass.
- Do not repair unrelated repository residue.
- Do not perform delivery, closeout, archive, staging, commit, or Change
  closeout.

Stop and write failing aggregate receipts instead of mutating when:

- the correction would exceed a child promotion target;
- the correction would require sibling mutation not authorized by the owning
  child;
- the correction would require product behavior outside this program's scope;
- the correction would treat parent evidence as child authority;
- the correction would require human approval;
- the correction would require destructive cleanup;
- the correction would require generated outputs, raw inputs, host UI state,
  chat/model memory, or tool availability to act as authority.

## Conformance Receipt Requirements

Write:

`.octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate/support/program-implementation-orchestration-conformance-review.md`

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
- the child registry sequence and dependencies match the implemented order;
- every required child has passing child-owned implementation conformance and
  post-implementation drift/churn reviews;
- every required parent, child, product catalog, drift, workflow, and receipt
  validator passes or has a clearly recorded non-blocking warning;
- promotion target coverage matches the child-owned scopes;
- no parent evidence is used to satisfy child receipts, child validation
  verdicts, child promotion targets, child closeout evidence, or child archive
  metadata;
- generated outputs and evidence paths remain derived or retained evidence,
  not runtime authorization or catalog authority.

Include sections for blockers, checked evidence, child receipt summary,
promotion target coverage, validator coverage, correction summary, generated
output coverage, rollback coverage, downstream reference coverage, exclusions,
and final route recommendation.

## Drift And Churn Receipt Requirements

Write:

`.octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate/support/program-post-implementation-orchestration-drift-churn-review.md`

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
- durable product feature catalog entries have no missing feature notes, stale
  refs, unresolved status mismatches, or unsupported authority claims;
- the feature catalog drift gate remains evidence-only and non-authorizing;
- proposal delivery and terminal closeout workflows cite the drift gate without
  bypassing existing governed mechanism integration, proposal review, or
  archive readiness boundaries;
- receipt schemas and validators consistently represent the new
  `feature_catalog_drift` gate;
- no durable target acquires active proposal-path dependencies except retained
  evidence or historical provenance references;
- churn is limited to declared child promotion targets, child-local support
  reviews, parent-local aggregate verification receipts, and retained
  validator output summaries.

Include sections for blockers, checked evidence, durable target backreference
scan, feature catalog drift review, workflow and receipt boundary review,
generated/non-authority review, target-family boundary review, churn review,
validators run, warnings, exclusions, and final closeout recommendation.

## Pass And Failure Semantics

If any required command fails, any required child review is missing or failing,
any parent/child dependency is incoherent, or the parent would need to own
child truth to pass, write failing aggregate receipts with concrete blockers.
Do not omit the receipts because verification failed.

If both aggregate receipts pass, the final route recommendation is:

`generate-program-closeout-prompt`

If either aggregate receipt fails, the final route recommendation must identify
the smallest correction route, child owner, or human escalation needed before
program closeout can continue.

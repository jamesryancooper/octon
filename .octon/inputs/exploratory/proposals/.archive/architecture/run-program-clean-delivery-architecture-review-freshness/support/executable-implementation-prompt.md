# Executable Implementation Prompt

packet: `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture-review-freshness`
route: `run-packet-implementation`

Implement only the architecture-review freshness behavior accepted by this
child packet. The implementation must keep proposal inputs non-authoritative,
generated outputs derived-only, and child-owned review receipts required for
child lifecycle advancement.

## Promotion Targets

Durable edits are limited to:

- `.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/assurance/runtime/_ops/tests/`

Do not implement delivery receipt completion, Change closeout reconciliation,
cleanup disposition, sibling packet work, parent program closeout, archive,
generated publication, branch mutation, or support-target widening.

## Current Repository Starting Points

The live repository already contains related digest and stale-receipt handling.
Before adding new logic, inspect and reuse these surfaces:

- `validate-architectural-review-receipts.sh` already validates
  `packet_digest` against `validate-proposal-review-gate.sh --print-digest`
  when `--package` is supplied.
- `validate-proposal-review-gate.sh` already excludes lifecycle prompt and
  receipt artifacts from the reviewed packet digest and invokes strict
  pre-integration architecture review validation for architecture packets.
- `lifecycle_program.rs` already contains stale strict architecture-review
  helpers such as
  `strict_pre_integration_architecture_review_receipt_requires_refresh` and
  route-selection handling near stale child receipt blockers.
- Existing tests include architecture-review stale-digest fixtures and the
  Rust scenario
  `review_packet_completion_requires_fresh_accepted_architecture_review_receipt`.

If those surfaces already satisfy an acceptance criterion, preserve them and
record that coverage in the implementation evidence instead of duplicating
helpers.

## Workstreams

1. Complete strict receipt freshness validation.
   - Ensure fresh accepted pre-integration architecture-review receipts pass
     only when `packet_digest` matches the current proposal packet digest.
   - Ensure stale `packet_digest` values fail closed with a specific
     stale-evidence diagnostic that identifies the recorded digest, current
     digest, owning refresh route, and stable digest boundary.
   - Ensure missing, rejected, blocked, or malformed architecture-review
     receipts fail the review-sensitive gate when implementation authorization
     or promotion would depend on them.

2. Bind proposal review gates to current packet content.
   - Preserve the reviewed packet digest inventory rules for generated prompt,
     lifecycle support receipts, and other non-review-content artifacts.
   - Ensure accepted proposal review receipts remain fresh after accepted-state
     manifest and navigation updates.
   - Ensure `validate-proposal-review-gate.sh --package <packet>
     --require-implementation-authorization` blocks stale proposal review or
     stale strict architecture-review evidence.

3. Harden lifecycle planner routing.
   - For review-sensitive child lifecycle advancement, stale strict
     pre-integration architecture-review evidence must select the owning
     `review-packet` recovery route when available.
   - If the owning route is unavailable, stop with an explicit
     stale-evidence or receipt-recovery-unavailable blocker.
   - Do not route stale architecture-review evidence through unrelated revise,
     cleanup, closeout, archive, or parent program delivery loops.
   - Preserve child authority: parent summaries, parent receipts, generated
     projections, host state, and chat history must not satisfy child-owned
     architecture-review receipt requirements.

4. Add or extend positive and negative controls.
   - Positive control: fresh accepted architecture-review receipt with matching
     `packet_digest` passes the receipt validator and review gate.
   - Negative control: stale `packet_digest` fails the architecture receipt
     validator and emits stale-evidence recovery diagnostics.
   - Negative control: missing or non-pass architecture-review receipt blocks
     review-sensitive advancement.
   - Negative control: parent-owned evidence cannot satisfy a child-owned
     architecture-review receipt.
   - Rust coverage must include lifecycle planner behavior for stale strict
     architecture-review evidence selecting `review-packet` or stopping with a
     specific blocker.

## Validation

Run from the repository root and retain the outputs in `support/validation.md`
or an equivalent packet-local validation receipt:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-architectural-review-validators.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-review-gate.sh
cargo test -p octon_kernel review_packet_completion_requires_fresh_accepted_architecture_review_receipt
cargo test -p octon_kernel strict_pre_integration_architecture_review
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture-review-freshness --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture-review-freshness
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture-review-freshness
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture-review-freshness --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture-review-freshness/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture-review-freshness --mode pre-integration-architecture-review --require-pass
```

After implementation, create the required post-implementation receipts and run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture-review-freshness
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture-review-freshness
```

If any named Rust test filter is stale because the test has been renamed,
run the closest existing lifecycle-program tests that prove the same claim and
record the exact command and rationale in `support/validation.md`.

## Retained Evidence

The implementation route must produce:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

`support/implementation-run.md` must summarize the durable edits, list the
promotion targets touched, cite validators run, and state whether any accepted
criteria were already satisfied by current repository state.

`support/implementation-conformance-review.md` must cover checked evidence,
promotion target coverage, implementation map coverage, validator coverage,
generated output coverage, governed mechanism integration coverage when
applicable, rollback coverage, downstream reference coverage, exclusions, and
final closeout recommendation. It must conclude with `verdict: pass` and
`unresolved_items_count: 0` before implementation can be considered complete.

`support/post-implementation-drift-churn-review.md` must cover backreference
scan, naming drift, generated projection freshness, manifest and schema
validity, repo-local projection boundaries, target family boundaries, churn
review, validators run, exclusions, and final closeout recommendation. It must
conclude with `verdict: pass` and `unresolved_items_count: 0` before closeout
or archive can be considered.

Run and pass:

- `validate-proposal-implementation-conformance.sh --package <proposal_path>`
- `validate-proposal-post-implementation-drift.sh --package <proposal_path>`

Refuse implemented, closeout, or archive-ready claims until both receipts exist
and both validators pass.

## Delegation Boundaries

No delegation is required. If the implementation runner explicitly delegates,
use disjoint write scopes only:

- validator scripts and shell fixtures;
- lifecycle planner Rust code and Rust tests;
- packet-local receipts.

The orchestrator remains responsible for final integration and must not let a
delegated worker widen scope, edit sibling packets, mutate generated outputs as
authority, or delete unrelated state/control/evidence artifacts.

## Rollback

Rollback is limited to the durable edits made under the declared promotion
targets. Revert validator or lifecycle planner changes through a governed
follow-up route, then rerun the proposal review gate and both
post-implementation validators. Packet-local evidence should be superseded by a
new correction or rollback receipt, not silently deleted.

## Closeout Refusal Criteria

Refuse closeout, archive, cleanup, parent delivery completion, branch cleanup,
or `git_clean_terminal` claims from this implementation route. Also refuse
implementation completion if any prerequisite proposal review, strict
pre-integration architecture review, implementation conformance review, or
post-implementation drift/churn review is missing, stale, failing, or still
requires clarification.

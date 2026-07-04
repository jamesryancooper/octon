# Executable Implementation Prompt

packet: `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-no-dispatch-deduplication`
route: `run-packet-implementation`

Implement only the child-owned no-dispatch and max-step artifact
deduplication behavior declared by this packet. The packet is planning context
only; durable behavior must come from the accepted promotion-target changes and
retained validation evidence.

## Profile Selection Receipt

- release_state: `pre-1.0`
- change_profile: `atomic`
- rationale: retry bookkeeping changes lifecycle behavior, validation, and
  evidence semantics together; splitting the behavior from its validator and
  tests would leave ambiguous runtime evidence.

## Preconditions

Before editing, rerun these gates from the repository root and stop if any
required gate fails:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-no-dispatch-deduplication --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-no-dispatch-deduplication
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-no-dispatch-deduplication
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-no-dispatch-deduplication --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-no-dispatch-deduplication/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-no-dispatch-deduplication --mode pre-integration-architecture-review --require-pass
```

The standard proposal gate may retain the current non-blocking artifact catalog
inventory warning. Do not treat that warning as permission to broaden this
implementation route.

## Authorized Scope

Durable promotion targets:

- `.octon/framework/engine/runtime/crates/kernel/src/workflow.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`

Do not edit parent program packets, sibling child packets, generated run-health
projections, archive state, closeout state, branch cleanup state, or unrelated
local evidence residue. Leave `proposal.yml#status` as `accepted`; the later
`promote-proposal` route owns any transition to `implemented`.

## Workstreams

1. Add a stable no-dispatch attempt key.
   - Key repeated no-dispatch state by target, route, input digest, blocker
     class, and blocker fingerprint.
   - Do not deduplicate across changed target, selected route, route owner,
     input digest, blocker class, blocker fingerprint, validator material
     output, child registry digest, or a dispatched route action.
   - Reuse existing lifecycle digest and blocker-ledger helpers where they fit.
     Add a new helper only if it removes real duplication.

2. Persist a bounded no-dispatch attempt ledger.
   - Record enough metadata to audit why no new full artifact set was written:
     key digest, target, route, input digest, blocker class, blocker
     fingerprint, attempt count, first and latest timestamps, latest event
     index or event digest, and source evidence refs.
   - Store the ledger as retained evidence under the program run workflow
     evidence root, and add any needed checkpoint metadata only for resumable
     bookkeeping.
   - Bound the ledger so repeated unchanged attempts cannot grow without
     limit. Prefer one entry per stable key with an incrementing attempt count
     and bounded recent-attempt metadata.
   - Mark the ledger evidence-only. It must not authorize execution, replace
     route-owned receipts, replace raw retained evidence, or make generated
     summaries authoritative.

3. Deduplicate unchanged no-dispatch output.
   - When no route action is dispatched and the no-dispatch key is unchanged,
     update the bounded ledger instead of emitting another full compact
     evidence set for the same blocker state.
   - Preserve fresh evidence behavior when inputs change, the blocker
     fingerprint changes, the validator produces new material output, a route
     is dispatched, or max-step exhaustion leaves a continuable dispatched
     route state.
   - Keep existing compact blocker-remediation authority boundaries: compact
     summaries are derived-only, raw evidence stays retained, and missing
     required receipts still fail closed.

4. Update proposal-program delivery docs and workflow language.
   - Reflect the no-dispatch attempt ledger in the delivery workflow without
     implying that the ledger replaces child packet, parent delivery, archive,
     cleanup, Change, generated-publication, branch cleanup, terminal proof, or
     proposal-status receipts.
   - Keep the route sequence child-owned. Do not use this child packet as a
     runtime dependency.

5. Extend validators and tests.
   - Add positive coverage for repeated unchanged no-dispatch attempts updating
     one bounded ledger and avoiding duplicate full compact evidence output.
   - Add positive coverage for max-step exhaustion without route dispatch using
     the same deduplication rule when the blocker fingerprint is unchanged.
   - Add negative controls proving fresh evidence is emitted for changed input
     digest, changed blocker fingerprint, validator material output, and route
     dispatch.
   - Extend `validate-run-program-clean-delivery.sh` and its fixture tests so a
     valid no-dispatch attempt ledger is evidence-only, digest-bound, bounded,
     and does not substitute for required receipts.

## Validation

Run the focused runtime and validator tests:

```sh
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel execute_routes_no_dispatch_does_not_emit_dispatch_events -- --exact
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel execute_routes_max_steps_bounds_child_batch_dispatches -- --exact
bash .octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh
```

Run the packet and post-implementation gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-no-dispatch-deduplication --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-no-dispatch-deduplication
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-no-dispatch-deduplication
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-no-dispatch-deduplication --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-no-dispatch-deduplication
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-no-dispatch-deduplication
```

If the implementation touches broader shared lifecycle behavior than expected,
also run the relevant `octon_kernel` lifecycle-program test group or the full
`octon_kernel` test suite and record why the broader validation was necessary.

## Retained Evidence

Write or refresh these packet-local support artifacts after implementation:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`
- `support/SHA256SUMS.txt`, only if the packet maintains checksums

`support/implementation-run.md` must record the implementation scope, touched
promotion targets, commands run, command results, dependency changes or
`none`, generated-output handling or `none`, and rollback posture.

`support/implementation-conformance-review.md` must confirm that the accepted
promotion targets were the only durable targets changed, acceptance criteria
were covered, no proposal-local artifact became authority, and
`validate-proposal-implementation-conformance.sh --package <packet>` passed.

`support/post-implementation-drift-churn-review.md` must confirm that the
implementation did not introduce duplicate helpers, speculative abstractions,
unbounded evidence growth, generated-output authority drift, or unrelated
cleanup churn, and that
`validate-proposal-post-implementation-drift.sh --package <packet>` passed.

## Rollback

Rollback reverts the no-dispatch key, bounded ledger, deduplication logic,
workflow documentation, validator additions, and focused fixtures through a
governed follow-up route. Attempt ledger artifacts already emitted under
`.octon/state/evidence/**` are retained evidence and must be superseded or
cleaned only through an explicit governed cleanup route.

## Delegation Boundary

No delegation is required by this prompt. If the implementation route
separately authorizes bounded parallel work, split it by disjoint write sets
across runtime code, validator shell code, and tests. The accountable
orchestrator must integrate the result and rerun the full validator set.

## Closeout Refusal Criteria

Refuse implementation completion, closeout, archive, or cleanup claims when:

- any prerequisite review, readiness, or strict architecture receipt is stale
  or failing;
- repeated unchanged no-dispatch or max-step cases still write duplicate full
  compact evidence sets;
- changed inputs, changed blocker fingerprints, validator material output, or
  dispatched routes fail to emit fresh evidence;
- the attempt ledger is unbounded, lacks input digest or blocker fingerprint,
  lacks attempt count or timestamp, or omits source evidence refs;
- the ledger is treated as authority or as a substitute for route-owned
  receipts;
- `support/implementation-conformance-review.md` or
  `support/post-implementation-drift-churn-review.md` is missing;
- either post-implementation validator fails.

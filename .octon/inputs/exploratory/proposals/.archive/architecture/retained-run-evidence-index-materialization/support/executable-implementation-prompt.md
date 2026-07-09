# Executable Implementation Prompt

packet: `.octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization`
route: `run-packet-implementation`

Implement only the declared durable promotion targets:

- `.octon/framework/assurance/runtime/_ops/scripts/generate-retained-run-evidence-index.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-generate-retained-run-evidence-index.sh`

Do not edit the parent program, child packet receipts, generated proposal
outputs, lifecycle status for unrelated packets, archive state, closeout state,
or branch cleanup state.

## Workstreams

1. Add a canonical retained-run evidence index materializer.
   - Accept `--package`, `--run-id`, `--write`, optional `--root`, and optional
     `--generated-at`.
   - Require the target proposal packet to be `status: implemented`.
   - Require child-owned receipts to exist and report `verdict: pass` for
     implementation run, implementation conformance, and post-implementation
     drift/churn.
   - Require accepted proposal review evidence and retained validation evidence.
   - Write a digest-bound `retained-run-evidence-index-v1` artifact under
     `.octon/state/evidence/runs/<run-id>/retained-run-evidence-index.yml`.
   - Write retained supporting evidence under the same run root plus a
     workflow receipt under `.octon/state/evidence/runs/workflows/<run-id>/`.
   - Preserve non-authority boundaries: proposal inputs are
     non-authoritative, generated outputs are derived-only, and retained
     evidence is evidence-only.
   - Validate the written index with
     `validate-retained-run-evidence-index.sh --index <index>`.

2. Add fixture tests.
   - Positive control: valid implemented packet receipts produce a retained-run
     evidence index that validates.
   - Negative control: implementation evidence without `verdict: pass` fails.
   - Negative control: mutating an indexed source after materialization causes
     retained index validation to fail.

## Validators

Run from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-generate-retained-run-evidence-index.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization
```

## Retained Evidence

Record implementation evidence in:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

The implementation run must state that it executed only this prompt and stayed
within the two promotion targets. Conformance and drift/churn receipts must
record passing validators, generated output coverage, rollback coverage, and
closeout refusal criteria.

## Rollback

Rollback removes the materializer script and fixture test through a governed
follow-up route. Retained evidence indexes created by the materializer are
evidence artifacts and must be superseded or cleaned only through an explicit
governed cleanup route.

## Closeout Refusal Criteria

Refuse closeout and archive claims from this route. Do not claim parent
promotion, branch cleanup, or `cleaned`. Refuse implementation if any
prerequisite review, readiness, or strict architecture receipt is stale or
failing.

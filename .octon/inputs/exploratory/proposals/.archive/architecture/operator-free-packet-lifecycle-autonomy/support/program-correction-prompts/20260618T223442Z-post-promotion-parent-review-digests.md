# Program Correction Prompt: Post-Promotion Parent Review Digest Refresh

target_program: `.octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy`
created_at: `2026-06-18T22:34:42Z`
owner_route: `octon-proposal-lifecycle-generate-program-correction-prompt`
blocking_scope: parent
parent_status_observed: `implemented`

## Blocker

Parent promotion rewrote `proposal.yml#status` from `accepted` to
`implemented`, wrote parent-local promotion receipts, refreshed canonical
generated proposal outputs, and passed terminal freshness. Post-promotion
verification then failed because the parent review evidence still records the
pre-promotion packet digest.

Failing commands:

- `/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy --require-implementation-authorization`
- `/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy --mode pre-integration-architecture-review --require-pass`
- `/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy`

Digest failure:

- recorded digest: `sha256:c076ad03ac5589424a7e03d7f56c787c4327900d14693afdc7a92d1cb29000fc`
- current digest: `sha256:73d10f1536cb380d8a5ee3d1e85c282dda3f64baa7338dcd18da3ee5a469b6dc`

Affected files:

- `.octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy/support/proposal-review.md`
- `.octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy/support/pre-integration-architecture-review.yml`

## Required Correction Route

Run the smallest governed parent-owned evidence refresh route that is valid for
an already-promoted parent program:

1. Preserve `proposal.yml#status: implemented`.
2. Preserve all child packets, child manifests, child receipts, child validation
   verdicts, child promotion targets, child archive metadata, and retained-run
   evidence indexes.
3. Refresh parent `support/proposal-review.md` through the governed
   `review-program` route or the repository-approved equivalent so it records
   the current packet digest while preserving an accepted review verdict,
   `implementation_prompt_authorized: yes`, and zero open blocking findings if
   the review remains valid.
4. Refresh parent `support/pre-integration-architecture-review.yml` through the
   governed strict pre-integration architecture review route so it records the
   current packet digest and retains `verdict: pass` only if the current packet
   still passes strict review.
5. Do not manually patch digest fields as a shortcut.
6. Refresh generated proposal outputs only through canonical generators if a
   validator requires it.
7. Do not run parent closeout, archive, cleanup, landing, publication,
   deletion, branch cleanup, or claim `cleaned`.

## Validators To Rerun

- `/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy --require-implementation-authorization`
- `/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy --mode pre-integration-architecture-review --require-pass`
- `/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy`
- `/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy`
- `/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy`
- `/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy --skip-registry-check`
- `/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check`
- `/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy`
- `/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy`
- `/Users/jamesryancooper/.homebrew/bin/bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh --proposal .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy --run-registry-check`

## Current Passing Evidence To Preserve

- `proposal.yml#status: implemented`
- `support/program-implementation-orchestration-prompt.md`
- `support/program-implementation-orchestration-run.md`
- `support/program-implementation-orchestration-conformance-review.md`
- `support/program-post-implementation-orchestration-drift-churn-review.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `.octon/generated/proposals/registry.yml`
- `.octon/generated/proposals/artifacts/architecture/operator-free-packet-lifecycle-autonomy/proposal-artifact-index.yml`
- `.octon/generated/proposals/artifacts/architecture/operator-free-packet-lifecycle-autonomy/proposal-program-spine.yml`

## Stop Condition

Stop after parent review/strict-architecture digest freshness and promotion
verification pass. Do not proceed to parent closeout without separate explicit
authorization.

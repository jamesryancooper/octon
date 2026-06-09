# Executable Implementation Prompt: Program Closeout Coverage Evidence

proposal_path: `.octon/inputs/exploratory/proposals/architecture/program-closeout-coverage-evidence`
next_route: `run-packet-implementation`

## Implementation Scope

Implement only the accepted child packet for `program-closeout-coverage-evidence`.
Define aggregate closeout coverage evidence for the governed cross-surface mechanisms documentation program without satisfying child-owned receipts.

Live repo state at prompt generation:

- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/` is expected to exist after foundation implementation.
- `.octon/framework/assurance/runtime/_ops/scripts/` exists.
- `.octon/framework/assurance/runtime/_ops/tests/` exists.

Promotion targets:

- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Workstreams

1. Add aggregate closeout guidance or template under the mechanism index.
2. Require mechanism coverage for all mandatory mechanisms in the parent source context.
3. Require child terminal outcome and child receipt freshness tables.
4. Require explicit `child_authority_preserved` confirmation.
5. Require deferred optional child resolution for `mechanism-detail-pages-and-operator-map`.
6. Add validation that parent evidence cannot satisfy child receipts, child validation verdicts, child promotion targets, child implementation evidence, child archive metadata, or child terminal outcomes.
7. Add validation that proposal lifecycle, Change closeout, worktree closeout, and repo hygiene cleanup remain separate authority systems.
8. Add checks for product catalog navigation-only, generated/input/read-model non-authority, lifecycle interaction receipt non-authorization, and retired terminology containment.

## Authority Boundaries

- Do not close out the parent program as part of this implementation.
- Do not create retained evidence from proposal-local files.
- Do not satisfy child receipts with aggregate evidence.
- Do not mutate child manifests, child receipts, child promotion targets, child validation verdicts, child archive metadata, runtime truth, generated effective authority, state/control truth, or retained evidence.

## Validation

Run these checks at minimum:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/program-closeout-coverage-evidence --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/program-closeout-coverage-evidence
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/program-closeout-coverage-evidence --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/governed-cross-surface-mechanisms-documentation-architecture
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/program-closeout-coverage-evidence
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/program-closeout-coverage-evidence
```

Run the aggregate closeout validator added by this implementation.

## Evidence And Receipts

After implementation, produce:

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

The conformance receipt must show aggregate closeout coverage, child_authority_preserved semantics, mandatory mechanism coverage, optional child deferral, and negative controls preventing parent evidence from satisfying child receipts.

The drift/churn receipt must explain whether closeout guidance duplicates child-owned truth and whether any parent file starts to claim child implementation or validation truth.

## Rollback Posture

Rollback is manual: revert closeout guidance and validators if aggregate evidence claims child-owned authority, collapses separate lifecycle systems, or treats generated/raw/host/navigation surfaces as authority.

## Terminal Criteria

Implementation is complete only when aggregate closeout guidance and validators pass and both required receipts pass. Refuse closeout/archive claims until `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md` exist, pass their validators, and confirm child-owned authority remains preserved.

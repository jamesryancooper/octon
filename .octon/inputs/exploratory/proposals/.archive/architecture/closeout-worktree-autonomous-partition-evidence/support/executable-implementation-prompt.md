# Executable Implementation Prompt: closeout-worktree-autonomous-partition-evidence

## Prompt Generation Gate Receipt

- Packet: `.octon/inputs/exploratory/proposals/architecture/closeout-worktree-autonomous-partition-evidence`
- Review receipt: `support/proposal-review.md`
- Review id: `review-closeout-worktree-autonomous-partition-evidence-20260707T124700Z`
- Reviewed packet digest: `sha256:ea8b81e272c34bb13c57a370cc4123226b4ca5198ff7c3359efa18b4bede5211`
- Implementation authorization: `yes`
- Architecture receipt: `support/pre-integration-architecture-review.yml`

## Boundary

Implement or prove only closeout-worktree non-mutating partition evidence:
partition reports with include paths, exclude paths, ownership basis,
classifier refs and digests, foreign/manual residue handling, lifecycle
interaction return evidence, and validators rejecting mutating or terminal
authority claims.

Do not implement proposal-program loop control, route write-lease ownership,
polluted-run supersession, cleanup authority, archive authority, parent
closeout, or child closeout for any other packet.

## Approved Promotion Targets

- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-closeout-worktree-wrapper.sh`
- `.octon/framework/product/contracts/lifecycle-interaction-return-v1.schema.json`
- `.octon/framework/product/contracts/change-closeout-state-machine.yml`

## Ordered Workstreams

1. Reconcile current closeout-worktree wrapper behavior first. Determine
   whether non-mutating partition reports already exist and whether validators
   reject unauthorized claims.
2. If behavior is already landed, record exact skill, contract, classifier,
   wrapper validator, and test evidence in `support/implementation-run.md`.
3. If a declared behavior is missing, patch only the approved promotion
   targets required for that gap.
4. Confirm reports can be returned to proposal-program lifecycle callers
   without transferring deletion, staging, commit, push, archive, publication,
   branch cleanup, child closeout, Change receipt replacement, or terminal
   delivery authority.
5. Keep `proposal.yml#status` as `accepted` and produce the post-
   implementation receipts before any closeout claim.

## Required Evidence

`support/implementation-run.md` must include at least `verdict`,
`implemented_at`, and `promotion_evidence_count`, then document landed behavior,
changed files if any, partition report proof, and command outcomes.

The conformance and drift/churn receipts must explicitly cover:

- partition reports are non-mutating and evidence-only;
- reports record classifier refs and digests, include paths, exclude paths,
  ownership basis, and disposition;
- foreign/manual residue is preserved without deletion or mutation;
- ambiguous ownership stays nonterminal;
- validators reject cleanup, archive, publication, branch mutation, child
  closeout, Change receipt replacement, and terminal delivery claims;
- exclusions for loop breaker, ownership, and supersession behavior.

## Validation

Run the proposal gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/closeout-worktree-autonomous-partition-evidence --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/closeout-worktree-autonomous-partition-evidence
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/closeout-worktree-autonomous-partition-evidence
```

Run partition evidence proof:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-closeout-worktree-wrapper.sh
```

Run report-specific validation if implementation creates or changes a partition
report fixture:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh --report <partition-report>
```

Then run the post-implementation gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/closeout-worktree-autonomous-partition-evidence
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/closeout-worktree-autonomous-partition-evidence
```

## Rollback

If a new closeout-worktree patch is required and fails validation, revert only
this child's changed promotion targets or supersede through this child packet's
correction route. Do not convert partition evidence into cleanup authority or a
replacement Change receipt.

## Closeout Refusal Criteria

Refuse implemented, closeout, archive-ready, or parent-program terminal claims
while partition reports are mutating, authority-transfer claims are possible,
or `support/implementation-run.md`,
`support/implementation-conformance-review.md`, or
`support/post-implementation-drift-churn-review.md` is missing, failing,
unresolved, stale, or replaced by parent-local evidence.

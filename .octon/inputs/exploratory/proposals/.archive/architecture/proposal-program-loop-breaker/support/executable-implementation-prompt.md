# Executable Implementation Prompt: proposal-program-loop-breaker

## Prompt Generation Gate Receipt

- Packet: `.octon/inputs/exploratory/proposals/architecture/proposal-program-loop-breaker`
- Review receipt: `support/proposal-review.md`
- Review id: `review-proposal-program-loop-breaker-20260707T124700Z`
- Reviewed packet digest: `sha256:394924988e282649e629cfa46e44601df6271daf7a8f51d2630cf052e1c8db45`
- Implementation authorization: `yes`
- Architecture receipt: `support/pre-integration-architecture-review.yml`

## Boundary

Implement or prove only the loop-control behavior declared by this child:
block repeated proposal-program recovery routes when blocker evidence is
unchanged, allow bounded retry when the fingerprint changes, prioritize
publication drift before cleanup when drift explains the blocker, and record
route-decision evidence that explains the outcome.

Do not implement ownership baselines, route write leases, polluted-run
supersession, closeout-worktree partition reports, cleanup authority, archive
authority, parent closeout, or child closeout for any other packet.

## Approved Promotion Targets

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/proposal-lifecycle-residue-fingerprint.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/octon-proposal-run-program-lifecycle.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/octon-proposal-lifecycle-run-program-lifecycle/SKILL.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`

## Ordered Workstreams

1. Reconcile current code first. Determine which declared loop-control
   behaviors are already landed in `lifecycle_program.rs`, validators,
   residue fingerprint helpers, and tests.
2. If a behavior is already landed, prove it with child-owned commands and
   record that proof in `support/implementation-run.md`.
3. If a declared behavior is missing, patch only the approved promotion
   targets required for that gap.
4. Preserve the packet manifest status as `accepted`; later lifecycle routes
   own implemented-status, closeout, and archive transitions.
5. After implementation or proof, create `support/implementation-run.md`,
   `support/implementation-conformance-review.md`, and
   `support/post-implementation-drift-churn-review.md`.

## Required Evidence

`support/implementation-run.md` must include at least `verdict`,
`implemented_at`, and `promotion_evidence_count`, then describe landed changes,
already-present behavior, files inspected or changed, and commands run.

The conformance and drift/churn receipts must explicitly cover:

- unchanged cleanup blocker fingerprint suppresses redispatch;
- changed fingerprint permits a bounded retry;
- repeated cleanup route suppression and residue fingerprint behavior;
- parent summaries and generated outputs do not reset child-owned loop state;
- exclusions for ownership, supersession, and closeout-worktree behavior.

## Validation

Run the proposal gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-loop-breaker --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-loop-breaker
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-loop-breaker
```

Run loop-control proof:

```sh
cargo test -p octon_kernel residue_cleanup_unchanged_fingerprint_is_not_redispatched
cargo test -p octon_kernel residue_cleanup_changed_fingerprint_allows_new_attempt
bash .octon/framework/assurance/runtime/_ops/tests/test-proposal-lifecycle-residue-fingerprint.sh
```

Then run the post-implementation gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-loop-breaker
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-loop-breaker
```

## Rollback

If a new loop-control patch is required and fails validation, revert only this
child's changed promotion targets or supersede through this child packet's
correction route. Do not use parent program closeout or generated registry
state as rollback authority.

## Closeout Refusal Criteria

Refuse implemented, closeout, archive-ready, or parent-program terminal claims
while `support/implementation-run.md`,
`support/implementation-conformance-review.md`, or
`support/post-implementation-drift-churn-review.md` is missing, failing,
unresolved, stale, or replaced by parent-local evidence.

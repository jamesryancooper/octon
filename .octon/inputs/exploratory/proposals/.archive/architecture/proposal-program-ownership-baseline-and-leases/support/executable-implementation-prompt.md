# Executable Implementation Prompt: proposal-program-ownership-baseline-and-leases

## Prompt Generation Gate Receipt

- Packet: `.octon/inputs/exploratory/proposals/architecture/proposal-program-ownership-baseline-and-leases`
- Review receipt: `support/proposal-review.md`
- Review id: `review-proposal-program-ownership-baseline-and-leases-20260707T124700Z`
- Reviewed packet digest: `sha256:f4bd79c1cf11b4c31b54f82589029029399da77839b82ba8d59956ac53a5682d`
- Implementation authorization: `yes`
- Architecture receipt: `support/pre-integration-architecture-review.yml`

## Boundary

Implement or prove only proposal-program ownership controls: start-of-run
baseline capture, route-scoped write leases, owned/leased/foreign/manual/
protected/generated/ambiguous classification, isolated worktree gating, and
fail-closed mutation blocking when authority is stale, missing, or ambiguous.

Do not implement loop-control behavior, polluted-run supersession,
closeout-worktree partition reports, cleanup authority, archive authority,
parent closeout, or child closeout for any other packet.

## Approved Promotion Targets

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/spec/proposal-program-readiness-projection-v1.md`
- `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/framework/product/contracts/lifecycle-interaction-request-v1.schema.json`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`

## Ordered Workstreams

1. Reconcile current code first. Identify which baseline, classification, and
   route write-lease behaviors are already landed.
2. Audit every mutating proposal-program route for route-scoped write-lease or
   equivalent authority enforcement.
3. If coverage is complete, record proof in `support/implementation-run.md`.
   If a gap remains, patch only the approved promotion targets required for
   that gap.
4. Preserve child-owned receipt boundaries: parent leases cannot cover child
   receipts, protected evidence paths, or generated-only outputs.
5. Keep `proposal.yml#status` as `accepted` and produce the post-
   implementation receipts before any closeout claim.

## Required Evidence

`support/implementation-run.md` must include at least `verdict`,
`implemented_at`, and `promotion_evidence_count`, then document the route audit,
landed behavior, changed files if any, and command outcomes.

The conformance and drift/churn receipts must explicitly cover:

- start baseline records branch, HEAD, tracked and untracked status, generated
  freshness, and relevant run refs;
- mutating routes require current route write leases or equivalent authority;
- stale, missing, foreign, protected, generated-only, and ambiguous authority
  fails closed before mutation;
- child-owned receipts remain outside parent write authority;
- exclusions for loop breaker, supersession, and closeout-worktree behavior.

## Validation

Run the proposal gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-ownership-baseline-and-leases --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-ownership-baseline-and-leases
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-ownership-baseline-and-leases
```

Run ownership proof:

```sh
cargo test -p octon_kernel program_worktree_baseline_blocks_fresh_dirty_unleased_git_run
cargo test -p octon_kernel program_worktree_baseline_records_run_owned_leased_and_foreign_paths
cargo test -p octon_kernel route_write_lease
```

Run affected validator tests when route audit or script behavior changes:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-lifecycle-contracts.sh
```

Then run the post-implementation gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-ownership-baseline-and-leases
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-ownership-baseline-and-leases
```

## Rollback

If a new ownership patch is required and fails validation, revert only this
child's changed promotion targets or supersede through this child packet's
correction route. Do not broaden route write leases as a rollback shortcut.

## Closeout Refusal Criteria

Refuse implemented, closeout, archive-ready, or parent-program terminal claims
while route write-lease coverage is ambiguous or while
`support/implementation-run.md`,
`support/implementation-conformance-review.md`, or
`support/post-implementation-drift-churn-review.md` is missing, failing,
unresolved, stale, or replaced by parent-local evidence.

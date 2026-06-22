prompt_id: lifecycle-validator-runtime-resolver-implementation-20260620T143658Z
generated_at: 2026-06-20T14:36:58Z
generator: codex-manual-generate-packet-implementation-prompt-route
proposal_path: .octon/inputs/exploratory/proposals/architecture/lifecycle-validator-runtime-resolver
proposal_review_ref: .octon/inputs/exploratory/proposals/architecture/lifecycle-validator-runtime-resolver/support/proposal-review.md
implementation_authorized: yes
child_authority_preserved: yes

# Executable Implementation Prompt

## Objective

Implement the accepted child packet
`.octon/inputs/exploratory/proposals/architecture/lifecycle-validator-runtime-resolver`.

The target end state is proposal-program lifecycle validator dispatch that
resolves a repository-supported Bash runtime before running Bash-dependent
assurance scripts, while preserving fail-closed gate semantics.

## Binding Scope

Implement only these promotion targets:

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`

Do not modify `lifecycle.rs` or any other durable target outside this list. If
the implementation cannot satisfy the acceptance criteria without a target
outside this child packet's approved promotion scope, stop and route a child
revision instead of widening scope silently.

Do not modify parent program receipts, child-owned receipts outside this child,
proposal archive state, git history, branch publication state, generated
authority outputs by hand, external credentials, or unrelated worktree changes.

## Required Workstreams

1. Re-read the child packet manifest, target architecture, implementation plan,
   acceptance criteria, validation plan, implementation-grade completeness
   review, strict pre-integration architecture review, and accepted proposal
   review.
2. Inspect the live program lifecycle validator dispatch and Bash helper launch
   points in `lifecycle_program.rs`.
3. Add a small, explicit resolver for Bash-dependent program lifecycle commands
   that chooses the repository-supported Bash runtime before validator or
   recovery dispatch.
4. Preserve existing validator argv validation and fail-closed behavior. Missing
   or unsupported runtime resolution must surface as a failed gate or explicit
   blocker, not a passing route.
5. Apply the resolver to program lifecycle Bash-dependent command paths owned by
   this child, including program gate validation and program recovery/helper
   command launch points.
6. Add focused regression coverage under the declared validation test surface.
   Include a test named or equivalent to
   `validator_dispatch_uses_supported_bash_runtime`, with positive and negative
   coverage for supported runtime selection and fail-closed behavior.
7. Update the lifecycle contract files only if needed to document or validate
   the supported-runtime dispatch behavior without broadening authority.

## Evidence And Receipts

After durable implementation changes land, create or update:

- `support/implementation-run.md` with at least `verdict`, `implemented_at`,
  `promotion_evidence_count`, and implementation evidence refs.
- `support/implementation-conformance-review.md`.
- `support/post-implementation-drift-churn-review.md`.
- `support/validation.md` listing every command run and its result.

The implementation receipts must be child-owned and must not substitute parent
program summaries for child evidence.

## Validation Commands

Run these proposal gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-validator-runtime-resolver --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-validator-runtime-resolver
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-validator-runtime-resolver
```

Run the implementation validators from the packet, adapting only fixture paths
and the current Rust package name as needed:

```sh
cargo test -p octon_kernel lifecycle_program::tests::validator_dispatch_uses_supported_bash_runtime
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package <fixture-program>
.octon/framework/engine/runtime/run lifecycle plan --lifecycle proposal-program --target <fixture-program>
```

Then run the required post-implementation gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-validator-runtime-resolver
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-validator-runtime-resolver
```

## Rollback Posture

Rollback is limited to this child packet's promotion targets. Revert or
supersede only the durable changes made for this child, then rerun the proposal
gates and implementation validators.

## Terminal Criteria

Leave `proposal.yml#status` as `accepted` after implementation. Refuse closeout
and archive claims, and do not claim implemented, cleaned, or delivery-ready
state while implementation-run, conformance, drift/churn, or validation evidence
is missing, stale, failing, unresolved, or outside this child packet's authority.

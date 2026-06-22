prompt_id: complete-program-blocker-vector-planner-output-implementation-20260620T140200Z
generated_at: 2026-06-20T14:02:00Z
generator: codex-manual-generate-packet-implementation-prompt-route
proposal_path: .octon/inputs/exploratory/proposals/architecture/complete-program-blocker-vector-planner-output
proposal_review_ref: .octon/inputs/exploratory/proposals/architecture/complete-program-blocker-vector-planner-output/support/proposal-review.md
implementation_authorized: yes
child_authority_preserved: yes

# Executable Implementation Prompt

## Objective

Implement the accepted child packet
`.octon/inputs/exploratory/proposals/architecture/complete-program-blocker-vector-planner-output`.

The target end state is a proposal-program lifecycle planner that reports a complete blocker vector before mutation and keeps actionable blockers separate from nonblocking diagnostics and route-ready states.

## Binding Scope

Implement only these promotion targets:

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`

Do not modify parent program receipts, child-owned receipts outside this child, proposal archive state, git history, branch publication state, generated authority outputs by hand, external credentials, or unrelated worktree changes.

## Required Workstreams

1. Re-read the child packet manifest, target architecture, implementation plan, acceptance criteria, validation plan, implementation-grade completeness review, strict pre-integration architecture review, and accepted proposal review.
2. Inspect the live planner implementation in `lifecycle_program.rs` and the proposal-program lifecycle contract.
3. Add or revise planner data structures so the planner can retain a complete blocker vector covering parent, child, generated artifact, worktree hygiene, lifecycle tooling, git delivery, and authorization scopes when present.
4. Ensure diagnostics that cannot block a next route are recorded separately from actionable blockers.
5. Ensure route-ready states remain explicit and are not mixed with stale nonblocking details.
6. Add focused tests under the declared validation test surface. Include a regression named or equivalent to `program_blocker_vector_reports_all_scopes`.
7. Update the lifecycle contract only if needed to expose or validate the blocker-vector behavior without broadening authority.

## Evidence And Receipts

After durable implementation changes land, create or update:

- `support/implementation-run.md` with at least `verdict`, `implemented_at`, `promotion_evidence_count`, and implementation evidence refs.
- `support/implementation-conformance-review.md`.
- `support/post-implementation-drift-churn-review.md`.

The implementation receipts must be child-owned and must not substitute parent program summaries for child evidence.

## Validation Commands

Run these proposal gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/complete-program-blocker-vector-planner-output --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/complete-program-blocker-vector-planner-output
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/complete-program-blocker-vector-planner-output
```

Run the implementation validators from the packet, adapting only fixture paths as needed:

```sh
cargo test -p octon_kernel lifecycle_program::tests::program_blocker_vector_reports_all_scopes
.octon/framework/engine/runtime/run lifecycle plan --lifecycle proposal-program --target <fixture-program>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package <fixture-program>
```

Then run the required post-implementation gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/complete-program-blocker-vector-planner-output
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/complete-program-blocker-vector-planner-output
```

## Rollback Posture

Rollback is limited to this child packet's promotion targets. Revert or supersede only the durable changes made for this child, then rerun the proposal gates and implementation validators.

## Terminal Criteria

Leave `proposal.yml#status` as `accepted` after implementation. Refuse closeout and archive claims, and do not claim implemented, cleaned, or delivery-ready state while implementation-run, conformance, drift/churn, or validation evidence is missing, stale, failing, unresolved, or outside this child packet's authority.

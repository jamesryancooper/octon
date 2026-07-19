# Commands

- `validate-proposal-review-gate.sh --package <parent> --print-digest` twice.
- `validate-proposal-program-structure.sh --package <parent>` with controlled
  seeds 17, 29, and 43.
- `cargo test -p octon_kernel collision_ledger` from the runtime crate workspace.
- `validate-proposal-standard.sh --package <parent> --skip-registry-check`.
- `validate-proposal-implementation-readiness.sh --package <parent>`.
- `validate-architecture-proposal.sh --package <parent>`.
- `validate-proposal-review-gate.sh --package <parent>`.
- `validate-architectural-review-receipts.sh` for routing and support artifacts.
- `git diff --check` and exact path-scope review.

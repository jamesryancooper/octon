# Validation Plan

## Parent Program

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy --skip-registry-check`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/operator-free-packet-lifecycle-autonomy`

The proposal registry check is intentionally skipped during parent creation
because this request forbids generated file edits.

## Child Validation Strategy

- `blocked-delivery-receipt-semantics`: receipt schema validation, validator
  tests for blocked versus cleaned outcomes, negative controls for missing
  blockers and forged pass states.
- `packet-delivery-wrapper-orchestration-autonomy`: delivery profile,
  workflow, and aggregate receipt validation for pre-archive, already-archived,
  branch-no-PR, and no-PR-fallback cases.
- `branch-no-pr-closeout-state-machine-autonomy`: closeout-change receipt
  validation for published, landed, synced, cleaned, and branch-deleted states;
  negative controls for cleanup before landing.
- `generated-freshness-scope-detection`: generator-input impact fixtures,
  freshness authorization checks, support-envelope reconciliation validation,
  run-health read-model validation, and generated non-authority validation.
- `packet-worktree-partitioning-automation`: worktree classification fixtures,
  repo-hygiene cleanup dry-run receipts, deletion-safety negative controls,
  and protected-evidence retention checks.
- `terminal-evidence-sink-autonomy`: landing/ref equality fixtures proving
  terminal proof does not require post-landing source commits.
- `git-mutation-sandbox-preflight`: helper diagnostic fixtures for fetch,
  checkout, landing, sync, cleanup, and branch deletion permission paths.

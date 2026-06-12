# Validation Plan

## Packet Validation

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-terminal-freshness-and-proof`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-terminal-freshness-and-proof`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-terminal-freshness-and-proof`
- `bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --write`
- `bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh --proposal .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-terminal-freshness-and-proof --write`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-artifact-index-spine.sh --proposal .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-terminal-freshness-and-proof`

## Future Implementation Validation

- schema validation for both new receipt contracts;
- positive and negative tests for terminal current-state proof;
- positive and negative tests for correction-branch aggregate receipts;
- stale compact artifact and stale generated publication negative controls;
- scoped child-set validation against a parent child registry;
- change closeout lifecycle alignment validation;
- closeout-worktree wrapper validation;
- proposal registry check after all proposal mutations;
- artifact-spine validation after all support receipt and archive mutations;
- publication freshness validators after generated effective, extension,
  capability, or host projection changes;
- implementation conformance and post-implementation drift/churn validators.

## Evidence Quality

Validation evidence must record command, cwd, runtime path, exit code, and
retained evidence refs. Compact logs may summarize long output, but a passing
claim must still cite structured validators or receipts.

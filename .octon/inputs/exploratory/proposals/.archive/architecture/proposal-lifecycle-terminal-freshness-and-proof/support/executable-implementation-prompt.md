# Executable Implementation Prompt

implementation_prompt_id: proposal-lifecycle-terminal-freshness-and-proof-implementation-prompt-20260612T114402Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-terminal-freshness-and-proof
authorized_by: support/proposal-review.md
reviewed_packet_digest: sha256:16021abbde824d77e11592676e300bae58ede08d5d5eb142eaa2f778758b67e7
release_state: pre-1.0
change_profile: atomic

## Objective

Implement the accepted architecture proposal as one atomic Octon lifecycle
hardening change. Add terminal proposal lifecycle freshness barriers,
aggregate correction-branch receipts, terminal current-state proof bundles,
scoped terminal child validation, compact validator-log handling, and canonical
validator runtime resolution without creating a second control plane or a new
default work unit.

## Promotion Targets

- `.octon/framework/scaffolding/governance/patterns/proposal-standard.md`
- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/product/contracts/change-closeout-state-machine.yml`
- `.octon/framework/product/contracts/change-closeout-state-machine.md`
- `.octon/framework/product/contracts/change-receipt-v1.schema.json`
- `.octon/framework/product/contracts/lifecycle-correction-branch-aggregate-receipt-v1.schema.json`
- `.octon/framework/product/contracts/lifecycle-terminal-current-state-proof-v1.schema.json`
- `.octon/framework/orchestration/runtime/workflows/meta/closeout/`
- `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/`
- `.octon/framework/orchestration/runtime/workflows/meta/promote-proposal/`
- `.octon/framework/orchestration/runtime/workflows/meta/validate-proposal/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/execution-roles/practices/standards/validation-evidence-quality.md`
- `.octon/framework/execution-roles/practices/standards/validator-runtime-resolution.md`
- `.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-artifact-index-spine.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-correction-branch-aggregate-receipt.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-terminal-current-state-proof.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-proposal-lifecycle-terminal-freshness.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-correction-branch-aggregate-receipt.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-terminal-current-state-proof.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-proposal-artifact-index-spine.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-change-closeout-lifecycle-alignment.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-closeout-worktree-wrapper.sh`

## Required Implementation

1. Add strict schemas:
   - `lifecycle-correction-branch-aggregate-receipt-v1.schema.json`
   - `lifecycle-terminal-current-state-proof-v1.schema.json`
2. Add validators:
   - `validate-lifecycle-correction-branch-aggregate-receipt.sh`
   - `validate-lifecycle-terminal-current-state-proof.sh`
   - `validate-proposal-lifecycle-terminal-freshness.sh`
3. Add positive and negative validator tests, including placeholder, missing
   evidence, authority-conflict, stale digest, and dirty-cleaned claims.
4. Update closeout, archive, promote, validate-proposal, closeout-change, and
   closeout-worktree guidance to require terminal freshness and current-state
   proof for applicable cleaned claims while preserving existing authority
   boundaries.
5. Add `validator-runtime-resolution.md` and strengthen compact validator-log
   guidance in `validation-evidence-quality.md`.
6. Keep generated artifacts derived-only and proposal-local artifacts temporary
   and non-authoritative.

## Evidence And Receipts

After implementation, create or update:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/proposal-closeout.md`

Each receipt must record `verdict: pass`, explicit validation commands,
evidence refs, unresolved counts, blockers, rollback posture, and non-authority
boundaries where applicable.

## Validation Floor

Run at minimum:

- `bash .octon/framework/assurance/runtime/_ops/tests/test-lifecycle-correction-branch-aggregate-receipt.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-lifecycle-terminal-current-state-proof.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-proposal-lifecycle-terminal-freshness.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-correction-branch-aggregate-receipt.sh --schema-only`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-terminal-current-state-proof.sh --schema-only`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh --proposal .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-terminal-freshness-and-proof`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-terminal-freshness-and-proof --skip-registry-check`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-terminal-freshness-and-proof`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-terminal-freshness-and-proof`
- `bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --write`
- `bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh --proposal .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-terminal-freshness-and-proof --write`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-artifact-index-spine.sh --proposal .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-terminal-freshness-and-proof`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-terminal-freshness-and-proof`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-terminal-freshness-and-proof`

## Rollback

Rollback is a repo-local revert of the new schemas, validators, tests, workflow
guidance, skill guidance, and documentation. Retained evidence emitted before
rollback remains historical evidence only and must not authorize mutation or
closeout.

## Closeout Refusal Criteria

Refuse closeout or archive if any new schema or validator is missing, if
terminal freshness is stale, if generated proposal artifacts do not match, if
support receipts are missing or failing, if current-state proof is absent for
a cleaned claim, if a parent summary substitutes for child receipts, or if any
generated output, proposal-local summary, host state, chat, model memory, raw
input, dashboard, or tool-availability claim is treated as authority.

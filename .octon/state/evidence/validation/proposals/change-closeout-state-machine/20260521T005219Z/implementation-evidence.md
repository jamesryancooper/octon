# Change Closeout State Machine Implementation Evidence

evidence_id: change-closeout-state-machine-implementation-20260521T005219Z
captured_at: 2026-05-21T01:09:32Z
packet: .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine
proposal_status_after_run: accepted

## Supersession Notice

This file is retained as the historical pre-wrapper-follow-up evidence
snapshot. Current implementation evidence for the `Closeout Worktree` wrapper
orchestration hardening and generated-non-authority remediation is retained at
`.octon/state/evidence/validation/proposals/change-closeout-state-machine/20260521T132922Z/implementation-evidence.md`.

## Implemented Durable Surfaces

- Added `.octon/framework/product/contracts/change-closeout-state-machine.yml`.
- Added `.octon/framework/product/contracts/change-closeout-state-machine.md`.
- Extended `.octon/framework/product/contracts/change-receipt-v1.schema.json` with `stateful_closeout` evidence requirements.
- Bound `.octon/framework/product/contracts/default-work-unit.yml` and `.octon/framework/product/contracts/default-work-unit.md` to the closeout state machine.
- Updated closeout workflow stages and closeout skills to require stateful evidence for completed or cleaned closeout claims.
- Added `.octon/framework/assurance/runtime/_ops/scripts/classify-change-closeout-residue.sh`.
- Added `.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh`.
- Added `.octon/framework/assurance/runtime/_ops/tests/test-change-closeout-state-machine.sh`.
- Published host skill projections with `.octon/framework/capabilities/_ops/scripts/publish-host-projections.sh`.

## Validation Results

PASS `jq -e '.' .octon/framework/product/contracts/change-receipt-v1.schema.json`
PASS `yq -e '.' .octon/framework/product/contracts/default-work-unit.yml`
PASS `yq -e '.' .octon/framework/orchestration/runtime/workflows/meta/closeout/workflow.yml`
PASS `yq -e '.' .octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh`
PASS `bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-state-machine.sh`
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh`
PASS `bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-lifecycle-alignment.sh`
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh`
PASS `bash .octon/framework/assurance/runtime/_ops/tests/test-default-work-unit-alignment.sh`
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh`
PASS `bash .octon/framework/assurance/runtime/_ops/tests/test-git-github-workflow-alignment.sh`
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh`
PASS `bash .octon/framework/assurance/runtime/_ops/tests/test-hosted-no-pr-landing.sh`
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh`
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-raw-input-dependency-ban.sh`
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-no-raw-generated-effective-runtime-reads.sh`
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine`
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine`
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine`
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine --require-implementation-authorization`
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine`
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine`
PASS `git diff --check`

FAIL `bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh`

The generated non-authority validator reports an existing generated read-model dependency in `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`. That file has no implementation diff in this run and is outside this packet's promotion target map.

## Rollback Posture

Rollback is a scoped patch reversal of the durable contract additions, the closeout workflow and skill edits, the new validator and classifier, the Codex host projection updates, and the publisher execution evidence produced during this run.

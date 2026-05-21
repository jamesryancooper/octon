# Change Closeout State Machine Implementation Evidence

evidence_id: change-closeout-state-machine-closeout-worktree-orchestration-20260521T132922Z
captured_at: 2026-05-21T13:29:22Z
packet: .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine
proposal_status_after_run: accepted
supersedes: .octon/state/evidence/validation/proposals/change-closeout-state-machine/20260521T125225Z/implementation-evidence.md
follow_up_scope: closeout-worktree-wrapper-orchestration-hardening

## Profile Selection Receipt

release_state: pre-1.0
change_profile: atomic
rationale: Narrow wrapper contract, validator, fixture, projection, and evidence update. The default work unit remains singular Change and no transitional Closeout Changes model is introduced.

## Findings Closed

- `Closeout Worktree` is now documented and validated as a repeated singular-closeout orchestrator, not only a partition/reporting wrapper.
- Multiple coherent candidates alone is no longer accepted as a blocker for the selected candidate.
- Valid reports now require `iterations` evidence for delegated or closed candidates and `final_candidate_dispositions` for every candidate.
- Delegated and closed candidates now prove post-delegation re-inventory and re-classification before the next selection decision.
- Closed candidates now cite the singular `closeout-change` receipt, log, or evidence reference used by the orchestration iteration.
- Terminal `next_route_condition` claims are rejected unless every candidate is closed.

## Implemented Durable Surfaces

- Tightened `.octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh` to validate orchestration iterations and final candidate dispositions.
- Expanded `.octon/framework/assurance/runtime/_ops/tests/test-closeout-worktree-wrapper.sh` to 17 cases, including repeated multi-candidate orchestration, close-then-block behavior, missing post-inventory evidence, missing closeout-change refs, partition-only blocker denial, and terminal unprocessed-candidate denial.
- Updated `closeout-worktree` framework and Codex skill contracts, including `SKILL.md`, `references/io-contract.md`, `references/validation.md`, `references/phases.md`, `references/decisions.md`, and `references/checkpoints.md`.
- Updated `.octon/framework/product/contracts/default-work-unit.yml` and `.octon/framework/product/contracts/change-closeout-state-machine.yml` to describe the wrapper as an orchestrator while preserving the original singular Change decomposition contract.
- Republished host projections and capability routing so generated effective capability digests match the changed wrapper skill source.

## Legacy Evidence Treatment

The blocked wrapper run at `.octon/state/evidence/validation/analysis/20260521T130413Z-closeout-worktree-report.yml` remains historical evidence of the pre-orchestration audit state. It is not the desired final wrapper behavior: new valid reports must include orchestration iterations and candidate-keyed final dispositions when delegation or closure occurs.

## Validator Behavior Proven

- `iterations` must be a list on every report and must be non-empty when any candidate is delegated or closed.
- Each iteration must include pre-inventory, pre-classification, selected candidate id, include/exclude paths, singular `closeout-change` reference, `closeout-change` outcome, post-inventory, post-classification, and next-selection reason.
- `final_candidate_dispositions` must include exactly one final state for every candidate: `closed`, `retained`, `blocked`, `escalated`, `deferred`, or `foreign`.
- A `closed` final disposition must cite a singular `closeout-change` reference that also appears in an orchestration iteration for that candidate.
- A selected candidate cannot be blocked only because multiple candidates exist.
- Non-closed final dispositions cannot claim terminal `next_route_condition: none`.
- Existing wrapper checks remain active: multiple observed change sets require multiple candidates, explicit include/exclude boundaries are required, direct wrapper material actions fail, duplicate include paths across candidates fail, and unresolved candidates require candidate-keyed retained residue or blocker evidence.

## Validation Results

PASS `bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh`
PASS `bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh`
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh`
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh`
PASS `bash .octon/framework/assurance/runtime/_ops/tests/test-closeout-worktree-wrapper.sh` (17/17)
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh`
PASS `bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-state-machine.sh` (7/7)
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh`
PASS `bash .octon/framework/assurance/runtime/_ops/tests/test-default-work-unit-alignment.sh` (19/19)
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh`
PASS `bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-lifecycle-alignment.sh` (25/25)
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh`
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine --skip-registry-check`
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine`
PASS `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine` (warnings=2; errors=0)
PASS `git diff --check`

## Boundary Receipt

- No `Closeout Changes` command, route, model, projection, or default work unit was introduced.
- `Closeout Worktree` still performs no staging, committing, pushing, PR creation, landing, merge, deletion, reset, restore, or cleanup directly.
- Material route actions remain inside singular `closeout-change`.
- Generated outputs, proposal-local inputs, host projections, GitHub state, chat state, and tool availability were not treated as closeout authority.
- No dependency changes were introduced.

## Rollback Posture

Rollback is a scoped patch reversal of the wrapper validator, wrapper tests,
wrapper contract docs, product contract wording, refreshed generated capability
publication outputs, and proposal evidence receipt updates from this follow-up.

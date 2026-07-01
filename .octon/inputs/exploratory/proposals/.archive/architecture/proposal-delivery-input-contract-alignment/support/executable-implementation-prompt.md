# Executable Implementation Prompt

run_id: lifecycle-proposal-program-1782851380235-82990cbe-proposal-delivery-input-contract-alignment
lifecycle_id: proposal-packet
route_id: run-packet-implementation
proposal_path: .octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment
proposal_id: proposal-delivery-input-contract-alignment
proposal_status: accepted
implementation_authorized: yes
authorized_review_digest: sha256:7c0896cea026089bc7256d6ab97d5109b9f46a326c5d881695eee833f529a76a

## Profile Selection Receipt

- release_state: pre-1.0
- change_profile: atomic
- rationale: This child aligns one proposal delivery input contract across workflow, command, skill, schema, validator, and lifecycle surfaces. The change should land as one coherent contract alignment so required inputs, resume evidence, and negative controls do not drift.
- transitional_exception_note: none

## Goal

Implement the accepted `proposal-delivery-input-contract-alignment` packet by aligning required and optional proposal delivery inputs across canonical packet and program delivery surfaces.

The default target state is that `profile_path` and `delivery_run_id` remain required workflow admission inputs for both packet and program delivery unless the implementation adds a named preflight derivation with retained evidence, validators, and negative controls. User-facing aliases such as `profile=<profile-path>` and `run-id=<id>` must mirror the same requirement. Related delivery inputs, including `target_outcome`/`outcome`, packet/program target path, and packet `route=branch-no-pr`, must be either required everywhere or explicitly derived with evidence.

The implementation must preserve valid resume paths by naming the prior retained receipt or run evidence that can satisfy an input. Parent program evidence, aggregate delivery receipts, generated outputs, host state, chat, model memory, and proposal-local summaries must not satisfy child packet acceptance criteria or delivery input authority.

## Bound Packet Inputs

Read these packet-local files before implementation:

- `.octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment/proposal.yml`
- `.octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment/architecture-proposal.yml`
- `.octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment/architecture/target-architecture.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment/architecture/implementation-plan.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment/architecture/acceptance-criteria.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment/validation-plan.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment/support/proposal-review.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment/support/implementation-grade-completeness-review.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment/support/pre-integration-architecture-review.yml`

Treat those files as proposal-local context only. Durable implementation must land in the approved promotion targets below.

## Approved Promotion Targets

- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/`
- `.octon/framework/capabilities/runtime/commands/`
- `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/`
- `.octon/framework/capabilities/runtime/skills/operations/proposal-packet-delivery/`
- `.octon/framework/product/contracts/proposal-program-delivery-profile-v1.schema.json`
- `.octon/framework/product/contracts/proposal-program-delivery-receipt-v1.schema.json`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/bundle-matrix.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`

Do not mutate `.octon/instance/**`, `.octon/state/control/**`, `.octon/generated/**`, unrelated proposal packets, host projections, operator aliases, program review-loop documentation, or final cross-surface validation hardening outside this child scope.

## Current Repository Signals

The generation route observed these live repo signals before implementation:

- `proposal-program-delivery/workflow.yml` and `proposal-packet-delivery/workflow.yml` already declare `profile_path` and `delivery_run_id` as required workflow inputs.
- The framework command docs, operations skill docs, and `octon-proposal-run-packet-delivery` extension command still show `profile=<profile-path>` and `run-id=<id>` as optional bracketed arguments.
- Profile validators currently allow schema-only validation with no `--profile`; that may remain valid for static contract checks, but it must not be described as delivery admission.
- Receipt schemas bind a validated profile by `profile.profile_ref`; aggregate delivery receipts remain summary evidence and cannot replace target-owned source receipts.
- Existing shell tests under `.octon/framework/assurance/runtime/_ops/tests/` cover profile and receipt fixture validation but need focused negative controls for required delivery admission inputs and stale/derived input claims.

Re-check these facts against the current worktree before editing. If the repo has already changed, adapt the implementation to the current source of truth and record the difference in `support/implementation-run.md`.

## Implementation Workstreams

1. Inventory delivery input claims.
   - Compare workflow YAML, generated workflow READMEs, stage docs, runtime command docs, operations skills, product contracts, validators, tests, lifecycle contracts, bundle matrix entries, and extension commands for packet and program delivery.
   - Classify each delivery input as required before admission, derived by a named preflight with retained evidence, or optional with explicit fallback behavior.
   - Cover at minimum `profile_path`/`profile`, `delivery_run_id`/`run-id`, target packet/program path, `target_outcome`/`outcome`, packet `route=branch-no-pr`, retained readiness preflight refs, runner handoff refs, and resume evidence refs.

2. Align canonical delivery surfaces.
   - Keep workflow YAML and workflow READMEs consistent with the selected input semantics.
   - Update runtime command docs and operations skills so usage examples and required-input sections no longer mark required delivery inputs as optional.
   - Update `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/octon-proposal-run-packet-delivery.md` and any directly related lifecycle command or skill docs inside the approved targets so host-facing extension docs mirror the canonical runtime contract.
   - Update lifecycle contract delivery mode text under `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/` and `bundle-matrix.md` only as needed to state the same input contract and non-authority boundaries.

3. Align product contracts and receipts without adding redundant fields.
   - Do not add `profile_path` to a profile schema merely because the workflow input is named `profile_path`; profile schema files define profile document contents, not the path by which a caller supplied the file.
   - Ensure the profile and receipt contracts that are in scope describe the validated profile binding, delivery run/evidence binding, target path, outcome, order policy, and preflight/resume evidence consistently.
   - If a required workflow admission input is intentionally derived instead of caller-supplied, the contract must name the deriving stage, required retained evidence, freshness rule, and failure behavior.

4. Strengthen validators.
   - Extend `validate-proposal-program-delivery-workflow.sh` and `validate-proposal-packet-delivery-workflow.sh`, or an equivalent existing validator, so required workflow inputs are checked against command docs, skill docs, workflow READMEs, lifecycle extension command docs, and lifecycle contract hooks.
   - Add negative controls that reject docs or metadata that present required `profile_path`/`delivery_run_id` inputs as optional when no deriving preflight exists.
   - Preserve schema-only profile/receipt validator use for static validation, while ensuring delivery admission cannot be claimed without a supplied or evidence-derived profile path and delivery run id.
   - Keep packet and program differences explicit rather than forcing false symmetry.

5. Add tests.
   - Update the narrowest existing tests under `.octon/framework/assurance/runtime/_ops/tests/`, likely `test-validate-proposal-program-delivery.sh` and `test-validate-proposal-packet-delivery.sh`, to cover required input acceptance and rejection.
   - Add or update extension validation tests under `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/` for lifecycle command and context drift.
   - Cover all-clear cases plus missing profile path, missing delivery run id, stale or missing resume evidence, generated/proposal-local evidence used as input authority, and packet/program-specific differences.

6. Record implementation evidence.
   - Produce `support/implementation-run.md` with the inventory, selected input semantics, files changed, validation commands, and pass/fail results.
   - Produce `support/validation.md` or `support/validation/` evidence if local practice requires retained command logs.
   - Produce `support/implementation-conformance-review.md` and `support/post-implementation-drift-churn-review.md` after durable implementation.

## Required Validation Commands

Run these before claiming implementation completion:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-profile.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-receipt.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-packet-delivery.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-proposal-program-delivery-guardrails.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-proposal-program-runner-fixture-matrix.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment
```

If implementation adds or renames contract-specific validators or tests, run them and cite the exact command names in `support/implementation-conformance-review.md`.

## Required Post-Implementation Reviews

After implementation, produce these packet-local reviews:

- `.octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment/support/implementation-conformance-review.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment/support/post-implementation-drift-churn-review.md`

The implementation conformance review must identify every durable file changed, map each change to the approved promotion targets and acceptance criteria, record validation commands and outcomes, and state whether any criterion remains unmet.

The post-implementation drift/churn review must check for changes outside approved targets, false packet/program symmetry, generated-output authority drift, proposal-local authority drift, stale resume evidence, stale generated/publication assumptions, test-only behavior gaps, dependency changes, and unnecessary churn.

Do not claim closeout, archive readiness, or lifecycle completion until both reviews exist and these validators pass:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment
```

## Evidence And Rollback Requirements

Retained implementation evidence must include:

- the delivery input inventory and selected semantics;
- validation commands run and pass/fail outcomes;
- changed durable files and their approved promotion targets;
- negative controls proving missing required inputs fail before mutation;
- resume evidence rules and stale evidence behavior;
- explicit non-authority classification for proposal-local files, generated prompts, generated outputs, dashboards, host state, chat, and model memory;
- dependency receipt or `none`;
- rollback instructions for every durable file added or changed.

Rollback posture: revert the command, skill, workflow, contract, validator, test, lifecycle context, and extension command edits made solely for this child. Rollback must not delete unrelated proposal delivery features, retained evidence, archived proposal packets, generated/effective outputs, host projections, operator aliases, or sibling proposal work.

## Delegation Boundaries

Delegation is optional. If used, delegate only bounded read-only review or disjoint implementation slices inside the approved promotion targets. The accountable implementer remains responsible for final integration, validation, evidence, conformance review, drift/churn review, and rollback notes.

## Closeout Refusal Criteria

Refuse closeout or archive when any required validation command fails, either post-implementation review is missing or non-passing, required `profile_path` or `delivery_run_id` inputs remain optional without a named evidence-backed derivation, missing required inputs can reach a mutating delivery stage, resume evidence is stale or unspecified, packet/program differences are collapsed into false symmetry, rollback instructions omit durable changes, or proposal-local, generated, aggregate, parent, host, chat, model-memory, dashboard, or local/private evidence is used as a substitute for target-owned delivery, implementation, closeout, archive, Change, branch cleanup, final sync, or terminal proof receipts.

## Terminal Criteria

Implementation is complete only when:

- workflow, command, skill, contract, validator, lifecycle context, bundle matrix, and extension command surfaces state the same delivery input contract;
- required delivery inputs fail closed before mutation unless a named preflight derives them with retained evidence;
- valid resume paths name the retained receipt or run evidence that satisfies each input;
- packet and program delivery differences are documented and tested without forced symmetry;
- negative controls prove generated/proposal-local/parent/aggregate/host/chat evidence cannot satisfy required delivery inputs;
- no host projection publication, operator alias, program review-loop documentation, cleanup deletion, archive, generated publication, branch mutation, parent closeout, or terminal delivery claim is introduced by this child;
- `support/implementation-conformance-review.md` exists and validates;
- `support/post-implementation-drift-churn-review.md` exists and validates;
- `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment` passes;
- `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-delivery-input-contract-alignment` passes.

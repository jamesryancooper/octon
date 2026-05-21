# Custom Closeout Prompt: Change Closeout State Machine

generated_at: 2026-05-21T03:03:39Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine
proposal_id: change-closeout-state-machine
proposal_status_before_closeout: accepted
prompt_role: packet-local operational aid

This prompt is not authority. It is a closeout aid for the accepted
`change-closeout-state-machine` proposal packet. Bind all closeout claims to
the current repository state, retained evidence, deterministic validators, the
default work unit policy, the Change Closeout State Machine, and the Git/worktree
autonomy contract.

## Goal

Close out the implemented proposal packet without treating `inputs/**`,
generated projections, host UI state, PR metadata, chat, or this prompt as
authority. The closeout result must either:

- record `support/proposal-closeout.md` with `verdict: pass` and
  `archive_authorized: yes` only when all required gates pass and the packet is
  ready for the separate archive route; or
- record a blocked or deferred closeout with explicit blocker, missing item,
  next route condition, and preserved worktree state.

Do not archive the proposal directly from this closeout route.

## Mandatory Inputs

Read these packet-local inputs before asserting closeout status:

- `proposal.yml`
- `architecture-proposal.yml`
- `README.md`
- `navigation/source-of-truth-map.md`
- `navigation/artifact-catalog.md`
- `architecture/target-architecture.md`
- `architecture/implementation-plan.md`
- `architecture/acceptance-criteria.md`
- `validation-plan.md`
- `support/proposal-review.md`
- `support/executable-implementation-prompt.md`
- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

Read these durable policy surfaces before route, closeout, branch, PR, merge,
or cleanup decisions:

- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/product/contracts/change-closeout-state-machine.yml`
- `.octon/framework/product/contracts/change-receipt-v1.schema.json`
- `.octon/framework/orchestration/runtime/workflows/meta/closeout/workflow.yml`
- `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/SKILL.md`

Use retained evidence outside `inputs/**` for factual implementation state:

- `.octon/state/evidence/validation/proposals/change-closeout-state-machine/20260521T132922Z/implementation-evidence.md`
- `.octon/state/evidence/validation/proposals/change-closeout-state-machine/20260521T125225Z/implementation-evidence.md` (historical superseded snapshot only)
- `.octon/state/evidence/validation/proposals/change-closeout-state-machine/20260521T005219Z/implementation-evidence.md` (historical superseded snapshot only)
- `.octon/state/evidence/validation/runtime/governed-runtime-materialization-v1/run-health/generation.yml`

## Required Current Context To Verify

The packet implementation added or updated the durable closeout state-machine
surfaces, receipt schema, default work unit policy, closeout workflow, closeout
skills, Git/worktree policy, state-machine validator, residue classifier, tests,
host skill projections, generated proposal registry, and retained evidence.

A follow-up remediation fixed the prior `validate-generated-non-authority.sh`
blocker by moving kernel program recovery off raw generated cognition path
knowledge and onto the run-health generation receipt contract. Verify that the
current worktree includes, at minimum:

- `.octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-run-health-read-model.sh`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/state/evidence/validation/runtime/governed-runtime-materialization-v1/run-health/generation.yml`
- refreshed `.octon/generated/cognition/projections/materialized/runs/**`

If `support/implementation-conformance-review.md`,
`support/post-implementation-drift-churn-review.md`, or `support/validation.md`
still record `validate-generated-non-authority.sh` as a failing out-of-scope
baseline, refresh or append closeout evidence showing that this blocker is now
remediated and passing. Do not claim implemented, closeout, or archive-ready
status while the receipts still leave this item unresolved.

## Hard Stops

Refuse `implemented`, `closeout complete`, `archive-ready`, `landed`, or
`cleaned` claims when any of these are true:

- `support/implementation-conformance-review.md` is missing, failing,
  unresolved, stale relative to the generated-non-authority remediation, or
  blocked.
- `support/post-implementation-drift-churn-review.md` is missing, failing,
  unresolved, stale relative to the generated-non-authority remediation, or
  blocked.
- `validate-proposal-implementation-conformance.sh --package <proposal_path>`
  fails.
- `validate-proposal-post-implementation-drift.sh --package <proposal_path>`
  fails.
- `validate-generated-non-authority.sh` fails.
- `validate-run-health-read-model.sh` fails after the run-health remediation.
- Required route checks, hosted checks, or local validators are red.
- Required review conversations or author action items are unresolved.
- Worktree hygiene has not classified tracked, unstaged, untracked, ignored,
  generated, retained-evidence, state-control, and local-output residue.
- Route-required PR, merge, branch cleanup, origin fetch, or local main sync
  gates remain unfinished.
- The final closeout claim would depend on proposal-local inputs, generated
  projections, host state, or chat as authority.

## Closeout Procedure

1. Resolve the Change closeout route from the default work unit policy and the
   Git/worktree autonomy contract. Do not select PR mechanics merely because a
   branch exists. Do not use PR metadata in a `branch-no-pr` receipt.

2. Run a housekeeping pass before staging or final closeout. Classify intended
   durable edits, generated outputs, retained evidence, proposal support files,
   local run/control/evidence residue, prompt scaffolding, build outputs, and
   local skill logs. Remove only unnecessary temporary artifacts when deletion
   is safe and authorized by the repo hygiene rules. Preserve required generated
   outputs and required retained evidence.

3. Refresh or reconcile packet support receipts if follow-up remediation changed
   the validation floor. In this packet, specifically reconcile the prior
   `validate-generated-non-authority.sh` exclusion with the current passing
   generated-non-authority remediation.

4. Run the closeout validation floor. Use the packet standard validator with
   registry checking skipped before any archive/status mutation; run strict
   registry validation only after the closeout route intentionally regenerates
   `.octon/generated/proposals/registry.yml`.

```bash
jq -e '.' .octon/framework/product/contracts/change-receipt-v1.schema.json
yq -e '.' .octon/framework/product/contracts/default-work-unit.yml
yq -e '.' .octon/framework/orchestration/runtime/workflows/meta/closeout/workflow.yml
yq -e '.' .octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-state-machine.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-closeout-worktree-wrapper.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-lifecycle-alignment.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-default-work-unit-alignment.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-git-github-workflow-alignment.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-hosted-no-pr-landing.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-run-health-read-model.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-raw-input-dependency-ban.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-no-raw-generated-effective-runtime-reads.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-generated-as-authority-denial.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine
cargo test -p octon_kernel lifecycle_program --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml
git diff --check
```

5. If any required check fails, run a remediation loop: inspect the failing
   script, job, or validator output; identify the contract being enforced; make
   the smallest target-architecture-correct fix; rerun the local check when
   reproducible; and repeat until the check passes or an explicit blocker is
   recorded.

6. Regenerate the proposal registry only when the packet status or archival
   metadata changes and the registry generator path is known. Treat
   `.octon/generated/proposals/registry.yml` as a discovery projection only.

7. Apply route-required Git/PR/CI/review gates:

- `direct-main`: allowed only when current main is clean/current except for the
  intended closeout changes, validation passes locally, rollback is clear, and
  push/fetch/local-main sync evidence can be recorded.
- `branch-no-pr`: require branch or worktree identity, explicit no-PR rationale,
  local validation or blocker, durable commit/checkpoint, origin branch or
  explicit local-only blocker, and rollback/discard posture. Hosted no-PR
  landing additionally requires provider route-neutral evidence, exact source
  SHA checks, origin/main equality, and cleanup disposition.
- `branch-pr`: require branch identity, PR URL or number, hosted required
  checks, review or solo-maintainer exception evidence when required, no
  unresolved author action items, no requested changes, no merge conflicts, and
  post-merge cleanup/sync evidence before landed or cleaned claims.
- `stage-only-escalate`: preserve patch/checkpoint/branch state, record blocker
  reason, missing item, and next route condition. Do not claim completion.

8. Write or refresh `support/proposal-closeout.md`. Minimum successful shape:

```markdown
# Proposal Closeout Receipt

verdict: pass
closed_at: <UTC timestamp>
proposal_id: change-closeout-state-machine
archive_authorized: yes
archive_disposition: implemented
promotion_evidence:
  - .octon/state/evidence/validation/proposals/change-closeout-state-machine/20260521T132922Z/implementation-evidence.md
  - .octon/state/evidence/validation/runtime/governed-runtime-materialization-v1/run-health/generation.yml

## Route

selected_route: <direct-main|branch-no-pr|branch-pr|stage-only-escalate>
lifecycle_outcome: <allowed outcome from default-work-unit policy>

## Validation

Record exact commands, exit status, and any warnings.

## Hygiene

Record intended final changes, excluded residue, generated outputs retained,
evidence retained, cleanup performed or deferred, and rollback handle.
```

Use `archive_authorized: no` for blocked, deferred, or stage-only outcomes.

## Final Answer Contract

Report only the actual closeout state:

- packet closeout receipt path and verdict;
- selected route and lifecycle outcome;
- validation commands that passed or failed;
- whether the generated-non-authority blocker is remediated;
- evidence roots retained outside `inputs/**`;
- PR/CI/review/merge/branch cleanup/sync state when applicable;
- remaining blockers or `none`.

Do not claim the proposal is archived. A separate archive route must perform
archive mutation after successful closeout authorization.

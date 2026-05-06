# Routing Model

## Principle

Every unit of work starts as a Change.

The routing question is not "Change or PR." The routing question is which outputs the Change needs:

- direct-main Change;
- branch-only Change;
- PR-backed Change;
- stage-only or escalated Change.

## Inputs

Automated routing must evaluate these inputs before staging, committing, pushing, or opening a PR:

- user intent: explicit request for PR, no PR, direct-main, branch, review, publication, or pause;
- repo state: current branch, clean worktree, unrelated local changes, local `main` freshness against `origin/main`, upstream availability, branch protection, and required checks;
- Change scope: touched paths, number of modules, generated outputs, governance/control-plane surfaces, public API, migration, dependency, release, security, or irreversible effects;
- risk and materiality: mapped through existing risk, support-target, capability-pack, and execution-authorization policies;
- collaboration need: human review, external reviewer, unresolved review comments, preview URL, shared branch, or handoff;
- validation need: whether the required floor can run locally or requires GitHub-hosted checks;
- continuity need: whether work is complete now, paused, multi-session, or checkpoint-only.

## Route Selection

Route selection is ordered and fail-closed.

1. Always create or resolve a Change identity first. The internal runtime bundle is a Change Package. Existing Work Package state must be renamed or migrated during promotion; it is not target-state vocabulary.
2. If the user explicitly requests a PR, hosted review, remote CI, preview publication, or external signoff, select `branch-pr`.
3. If repository protection or release automation requires a PR, select `branch-pr`.
4. If the task starts from an existing PR, PR review comment thread, release PR, Dependabot PR, or GitHub merge lane, select `branch-pr`.
5. If the Change touches protected governance, constitutional, execution-control, public release, security, migration, or high-impact surfaces and local validation is not enough for the declared risk, select `branch-pr` or `stage-only-escalate` according to the governing authorization policy.
6. If the Change needs isolation, pause/resume, multiple commits, uncertain scope, or handoff but does not need hosted publication, select `branch-no-pr`.
7. If the repository is on clean current `main`, the Change is low-risk, locally validated, reversible, solo-only, and no policy or user instruction requires isolation or hosted review, select `direct-main`.
8. If risk, validation, rollback, freshness, or ownership is ambiguous, select `stage-only-escalate`.

## Route Requirements

### Direct-Main Change

Required:

- clean current `main`;
- no unrelated working tree changes;
- local validation at the selected floor;
- landed commit on `main`;
- Change receipt tying intent, diff, validation, outcome, and rollback handle together;
- rollback handle using commit hash, revert instruction, or equivalent restoration note.

Forbidden:

- protected-branch mutation without an admitted safety route;
- bypassing required validation;
- claiming completion with only an unstaged patch.

### Branch-Only Change

Required:

- branch or worktree identity;
- explicit reason no PR is required;
- local validation or recorded blocker;
- commit, patch, or checkpoint durable enough to resume;
- Change receipt or continuation receipt;
- rollback or discard plan.

Branch-only is valid for isolated work and paused work. It is not a publication route.

### PR-Backed Change

Required:

- branch identity;
- PR URL or number;
- PR body that references Change intent, validation, risk, and rollback;
- hosted checks required by the selected lane;
- review or solo-maintainer exception evidence when policy requires it;
- Change receipt that treats PR metadata as an output, not the root authority.

### Stage-Only Or Escalated Change

Required:

- preserved patch, checkpoint, or branch state;
- reason completion is blocked;
- missing decision, validation, rollback, auth, or review item;
- next route condition that would unblock the Change.

Forbidden:

- claiming the Change landed;
- treating stage-only evidence as completed durable history.

## Gate Semantics

Review and validation gates attach to the Change.

For PR-backed Changes, GitHub checks, review threads, PR templates, and auto-merge workflows are acceptable projections of those gates.

For no-PR Changes, equivalent local gates must be recorded through local validation output, local code review or AI review evidence when required, explicit waiver, and rollback evidence.

## Machine-Readable Contract Expectations

The promoted `.octon/framework/product/contracts/default-work-unit.yml` should expose at least:

- route IDs: `direct-main`, `branch-no-pr`, `branch-pr`, `stage-only-escalate`;
- route inputs and precedence order;
- required evidence by route;
- required validation by route;
- required Change receipt fields by route;
- PR-required predicates;
- branch-required predicates;
- direct-main eligibility predicates;
- fail-closed conditions;
- fields that downstream workflows can copy into receipts without duplicating policy prose.

The promoted Change receipt schema should capture at least:

- Change identity and selected route;
- intent and scope;
- touched paths or diff reference;
- validation evidence references;
- review evidence or waiver references;
- durable history reference, such as commit, patch, checkpoint, or PR;
- rollback handle;
- closeout outcome and remaining blockers.

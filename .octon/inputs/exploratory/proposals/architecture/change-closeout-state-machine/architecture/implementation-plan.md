# Implementation Plan

Proposal: `change-closeout-state-machine`

## Workstream 1: Product Contract

Add `change-closeout-state-machine-v1` under `.octon/framework/product/contracts/`
with:

- state names;
- route applicability;
- loop phases;
- backward transitions;
- stop/escalation conditions;
- evidence gates for landed, cleaned, blocked, preserved, and escalated
  outcomes;
- explicit non-authority boundaries for generated outputs, host projections,
  proposal-local files, raw inputs, and GitHub state.

Update the default work-unit policy and documentation to reference the state
machine without replacing existing route definitions.

## Workstream 2: Workflow And Skill Integration

Update the closeout workflow contract so it references the state machine and
distinguishes read-only analysis stages from mutating route phases.

Update `closeout-change` to execute the state-machine phases instead of a linear
checklist. Keep it singular and route-neutral.

Add `closeout-worktree` as the optional dirty-worktree wrapper. It must
inventory, classify, partition, and report multiple local residue groups while
delegating each selected coherent candidate to singular `closeout-change`
execution with explicit include and exclude path boundaries.

Update `closeout-pr` documentation to make `Closeout PR-Backed Change` the
human-facing title while preserving the command id and PR-backed subflow role.

## Workstream 3: Receipt Schema And Examples

Extend Change receipts with a `stateful_closeout` evidence object containing:

- state machine version;
- initial inventory reference;
- classification reference;
- phase exit references;
- cleanup decision references;
- hosted landing references when applicable;
- branch cleanup references when applicable;
- safe cleanup evidence class for destructive cleanup;
- final verification reference;
- escalation references when applicable.

Add conditional schema rules requiring this evidence for completed or cleaned
claims. Update valid and invalid receipt examples. Explicitly prevent
`published-branch`, `published`, or `ready` status from satisfying completed
closeout without landed or otherwise terminal evidence.

## Workstream 4: Validators And Classifier

Extend or supplement `validate-change-closeout-lifecycle-alignment.sh` so
completed and cleaned claims fail without state-machine evidence.

Add a read-only worktree residue classifier or validator that covers:

- staged changes;
- unstaged tracked changes;
- untracked files;
- ignored residue;
- local and remote branches;
- generated/effective outputs;
- host projections;
- retained evidence;
- state/control records;
- release/version files;
- `.octon/inputs/**` surfaces.

The classifier must never authorize deletion by detection alone.

Validators must fail when:

- force-push is used or claimed as an allowed closeout action;
- ambiguous or user-owned work is deleted, restored, reset, or overwritten;
- branch cleanup lacks origin/main containment, no-open-PR status,
  rollback/discard posture, or local/remote cleanup status;
- hosted no-PR landing lacks pushed branch, exact source-SHA checks, provider
  permission, fast-forward/update proof, origin/main equality, rollback handle,
  or final local sync;
- direct-main claims lack clean-main, validation, push, rollback, fetch/sync, or
  final alignment evidence;
- stage-only or escalated outcomes claim landed, cleaned, or completed state.

## Workstream 5: Tests And Validation

Add focused positive and negative tests for:

- completed closeout with inventory, classification, cleanup, and final sync
  evidence;
- multi-candidate Closeout Worktree wrapper evidence with selected candidate
  boundaries, delegated `closeout-change` reference, retained residue, blockers,
  and next-route condition;
- completed closeout missing state-machine evidence;
- cleaned claim with pending cleanup;
- branch-no-pr receipt containing PR metadata;
- hosted no-PR landing without exact-SHA evidence;
- destructive cleanup without evidence-backed safety;
- `.octon/inputs/**` used as closeout authority.
- `published-branch`, `published`, or `ready` overclaimed as completed closeout;
- direct-main receipt without clean-main and final-sync evidence;
- stage-only/escalated receipt that claims landed or cleaned;
- branch cleanup without containment and no-open-PR evidence;
- force-push or ambiguous deletion/restoration in any route.

## Workstream 6: Proposal Conformance And Closeout

After durable implementation, record:

- implementation conformance review;
- post-implementation drift/churn review;
- validation evidence;
- Change receipt and rollback handle;
- proposal promotion or archive route.

Do not archive this packet as implemented until durable targets stand on their
own without depending on proposal-local inputs.

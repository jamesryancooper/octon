# Executable Implementation Prompt: Packet Worktree Partitioning Automation

## Route And Scope

Implement only
`.octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation`
using `octon-proposal-lifecycle-run-packet-implementation`.

Release state: `pre-1.0`.

Change profile: `atomic`.

Do not implement, promote, close out, archive, clean, land, publish, delete, or
claim `cleaned` for the parent program or for any sibling child packet.

## Preconditions

Before editing durable files, confirm these gates pass:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation --mode pre-integration-architecture-review --require-pass
```

Also confirm dependency evidence for
`.octon/inputs/exploratory/proposals/architecture/branch-no-pr-closeout-state-machine-autonomy`
is implemented and passes conformance, drift/churn, and terminal freshness.

## Allowed Durable Targets

Durable edits are limited to these paths:

- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/capabilities/runtime/skills/remediation/repo-hygiene-cleanup/SKILL.md`
- `.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`

Proposal-local evidence may be written only under:

- `.octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation/support/`

If implementation requires durable files outside the allowed targets, stop and
route to child revision or linked proposal. Do not widen scope silently.

## Required Behavior

Implement worktree partitioning and cleanup-safe residue routing so
proposal-packet closeout can distinguish:

- publishable changes and publishable closeout evidence;
- cleanup-safe local residue;
- protected retained evidence and active control state;
- manual-review, foreign, ambiguous, unsafe, or user-owned residue.

Classification must not authorize deletion. Detection-only classifications are
routing evidence only. Cleanup deletion remains dry-run-first and requires
either explicit operator confirmation or a validating
`repo-hygiene-cleanup-authorization-v1` receipt.

Protected retained evidence, active control state, build-to-delete evidence,
terminal closeout local evidence, generated run-health projections, generated
authority outputs, proposal inputs, tracked files, and referenced untracked
files must not be deleted as branch cleanup or generic repo-hygiene cleanup.

Parent program evidence, aggregate evidence, proposal-local notes, generated
outputs, host state, chat, model memory, and tool availability must not satisfy
child cleanup evidence, worktree partitioning evidence, or deletion authority.

## Workstreams

1. Update `classify-proposal-worktree-hygiene.sh`.
   - Preserve existing CLI and YAML fields.
   - Add explicit partition/bucket output that names publishable, cleanup-safe,
     protected retained evidence, and manual-review/foreign/ambiguous residue.
   - Preserve fail-closed behavior: foreign or ambiguous paths keep
     `worktree_hygiene_verdict: "blocked"`.
   - Ensure same-scope lifecycle evidence and child-owned support evidence can
     be classified without treating parent evidence as child authority.
   - Keep the script read-only.

2. Update `cleanup-local-run-artifacts.sh`.
   - Preserve dry-run default.
   - Preserve `--confirm` and `--authorization` as the only deletion routes.
   - Ensure authorization cannot cover protected retained evidence, active
     control state, build-to-delete evidence, terminal closeout local evidence,
     generated run-health projections, generated authority outputs, proposal
     inputs, tracked files, referenced untracked files, ignored non-metadata
     paths, or user-owned paths.
   - If adding summary fields, keep existing fields stable for callers.

3. Update remediation skill guidance.
   - `closeout-worktree` must route worktree residue using the explicit
     publishable, cleanup-safe, protected, and manual-review partitions.
   - `repo-hygiene-cleanup` must state that cleanup authorization is required
     before deletion and that classifier output alone is not authority.
   - Do not add a new closeout route, new status, or competing Change model.

## Required Evidence

Record these child-owned support files:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

The implementation run receipt must record:

- `verdict: pass` or the blocker state;
- durable targets changed;
- proposal-local support files changed;
- dependency changes: `none`;
- generated outputs refreshed by canonical generator, or `none`;
- cleanup/deletion performed: `none`;
- rollback: coordinated revert of the four allowed durable targets and child
  support evidence.

The conformance review must map each acceptance criterion to durable behavior.
The drift/churn review must include a proposal-path backreference scan over the
allowed durable targets and state whether any durable target treats proposal
paths as runtime, policy, support, cleanup, or closeout authority.

## Validators

Run and record results for:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh --target .octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation --lifecycle proposal-packet --format yaml
bash .octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh --summary-only
bash .octon/framework/assurance/runtime/_ops/tests/test-classify-proposal-worktree-hygiene.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-cleanup-local-run-artifacts.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/packet-worktree-partitioning-automation
```

If a validator exposes a real blocker, stop and record it. Do not proceed to
promotion or closeout.

## Closeout Refusal Criteria

Refuse any closeout, archive, cleanup, landing, publication, branch deletion,
or `cleaned` claim during this implementation route.

Refuse implementation completion if:

- durable edits go outside the allowed targets;
- deletion occurs;
- classifier output is treated as cleanup authority;
- protected retained evidence can be classified as cleanup-safe;
- cleanup authorization can cover protected, tracked, referenced, generated
  authority, generated run-health, proposal input, active control, terminal
  local evidence, build-to-delete evidence, ignored non-metadata, or user-owned
  paths;
- child evidence is satisfied by parent evidence.

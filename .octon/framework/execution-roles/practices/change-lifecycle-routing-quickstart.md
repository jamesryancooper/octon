---
title: Change Lifecycle Routing Quickstart
description: SI-00 route selection and preservation guide for one Change.
status: active
---

# Change Lifecycle Routing Quickstart

The canonical policy is
`.octon/framework/product/contracts/default-work-unit.yml`. During SI-00,
closeout is preservation-first and cannot publish or clean up candidate work.

## Current Route Set

- `branch-no-pr`: classify and preserve branch-isolated work without PR
  metadata. Local validation, checkpointing, and separately authorized branch
  commits remain possible. Local/hosted landing and cleanup are denied.
- `branch-pr`: coordinate a PR-backed candidate only when an independent PR
  predicate exists. Ordinary closeout may reach `published` or `ready`; RP-00
  provider cutover remains separately authorized.
- `stage-only-escalate`: preserve exact state and report the missing authority,
  proof, rollback, validation, or ownership decision.

Direct-main is not an active route. Historical receipts may contain that label
for compatibility parsing only.

## Selection

1. Resolve the Change identity and exact include/exclude boundaries.
2. Inventory branch, HEAD, staged, unstaged, untracked, remote, and worktree
   state without mutating them.
3. Select `branch-pr` only for an explicit or independently governed PR
   predicate.
4. Otherwise use `branch-no-pr` for branch isolation/preservation, or
   `stage-only-escalate` when any required fact is missing.
5. Resolve a generic closeout target to `preserved`.
6. Run local validation and write truthful evidence without claiming landing,
   sync, cleanup, or publication.

Clean current `main`, low risk, provider capability, a blocked push, or
operator convenience does not create a direct-main or hosted no-PR route.

## Outcomes

`branch-no-pr` may report `preserved`, `branch-local-complete`,
`published-branch`, `deferred`, `blocked`, `escalated`, or `denied` when the
evidence supports it. A pre-existing independently established landing may be
observed as `landed` only with exact ref evidence and
`cleanup_status: deferred`; closeout does not perform that effect.

`branch-pr` may report `preserved`, `published`, `ready`, `deferred`,
`blocked`, `escalated`, or `denied`. A draft/open/ready PR is never landed or
completed closeout.

No current route may report `cleaned`.

## Stable Stops

- A request to select direct-main, authorize or perform no-PR landing, update
  hosted `main`, or claim publication stops with
  `RP00_CONTAINMENT_PUBLICATION_DISABLED`.
- A request to remove a worktree, delete/prune a branch or ref, authorize
  cleanup, or claim cleanup stops with
  `RP00_CONTAINMENT_CLEANUP_DISABLED`.

Preserve exact candidate refs, worktrees, rollback handles, and validation
evidence at either stop. Do not silently reroute to a different effectful path.

## Receipt Floor

Record:

- Change identity and selected active route;
- target and actual lifecycle outcome;
- exact candidate/branch/worktree observations;
- include/exclude boundaries;
- validation evidence;
- rollback or discard posture;
- publication and cleanup denial reasons when requested; and
- the next owning route or missing authority.

Generated projections, proposal files, chat, host UI, provider metadata, and
historical receipt fields never authorize an effect.

## Verification

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh
```

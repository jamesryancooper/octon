---
title: Default Work Unit Policy
description: Canonical SI-00 Change routing and containment contract.
status: active
---

# Default Work Unit Policy

Octon's default work unit is one Change. The machine-readable authority is
`default-work-unit.yml`; this document explains its current SI-00 behavior.

## SI-00 Containment Posture

The active route set is `branch-no-pr`, `branch-pr`, and
`stage-only-escalate`.

- Direct-main is not admitted, selected, authorized, or executed.
- `branch-no-pr` remains a useful classification for candidate isolation,
  checkpoints, local validation, and preservation. It cannot land locally or
  on hosted `main` during SI-00.
- Branch and worktree cleanup is disabled. Detection and inventory never
  authorize deletion.
- `branch-pr` may coordinate stage-preserving PR work. The RP-00 protected-PR
  cutover is a separate provider operation and requires its own exact
  authorization; Change closeout does not supply that authority.
- `stage-only-escalate` preserves exact work and reports the missing authority
  or proof.

Historical receipt schemas may still parse retired route labels and earlier
`landed` or `cleaned` outcomes. Compatibility parsing is evidence-only and
cannot select a route, authorize a current effect, or satisfy an SI-00 gate.

## Route Selection

Resolve one Change identity, inventory the exact worktree, and select exactly
one active route:

1. Select `branch-pr` only when an independent PR predicate is proved.
2. Otherwise select `branch-no-pr` for branch isolation or preserved handoff.
3. Select `stage-only-escalate` when authority, ownership, validation,
   rollback, or route evidence is missing or ambiguous.

Clean `main`, low risk, local validation, operator convenience, a blocked
push, or provider capability never creates a direct-main route.

## Target And Actual Outcome

A generic closeout request resolves to `target_lifecycle_outcome: preserved`
during SI-00. Route, target, and actual outcome remain separate facts.

Allowed current outcomes are:

- `preserved`, `branch-local-complete`, or `published-branch` for
  `branch-no-pr`, provided no main update or cleanup effect occurs;
- `preserved`, `published`, or `ready` for `branch-pr`, provided the route
  stops before merge or cleanup unless a separate provider authority owns the
  effect; and
- `preserved`, `deferred`, `blocked`, `escalated`, or `denied` for either
  route and for `stage-only-escalate`.

If landing was already and independently established, closeout may record the
read-only observation as `landed` with `cleanup_status: deferred`. It must also
record the exact landed ref, rollback handle, and
`RP00_CONTAINMENT_CLEANUP_DISABLED`. Closeout may not perform the landing,
claim `cleaned`, or infer publication success.

## Stable Denial Reasons

- Landing, hosted publication, direct-main, or no-PR authorization requests:
  `RP00_CONTAINMENT_PUBLICATION_DISABLED`.
- Worktree removal, branch deletion, ref pruning, or cleanup authorization
  requests: `RP00_CONTAINMENT_CLEANUP_DISABLED`.

Every independently invocable landing, authorization, and cleanup helper must
return its stable reason before protected-ref, worktree, branch, remote, or
cleanup mutation. Dry-run cleanup may inventory only.

## Closeout Worktree

`closeout-worktree` remains a non-authoritative wrapper around singular
`closeout-change` classifications. It may inventory, partition, and preserve
candidate boundaries. During SI-00 it must not default a candidate to
`cleaned`, delegate an effectful terminal route, remove residue, or report
`landed`, `synced`, or `cleaned` success.

## Evidence And Authority

A current receipt must record the Change identity, selected active route,
target and actual outcome, exact candidate state, validation evidence,
rollback/discard posture, publication and cleanup denial status when relevant,
and the next owning route. A generated projection, host state, chat, provider
metadata, proposal-local file, or historical receipt is never current mutation
authority.

The Change Closeout State Machine owns phase and evidence discipline. It does
not widen the route set or override containment. Stateful closeout evidence
for a preserved or blocked claim records inventory, residue classification,
phase exits, denial decisions, final read-only verification, and retained refs.

## Recovery

On a denied or uncertain effect, preserve the exact candidate, branch,
worktree, remote observations, and rollback handles. Repair forward to the
contained state. Never recover by re-enabling direct-main, no-PR landing, or
cleanup.

## Canonical References

- machine policy: `.octon/framework/product/contracts/default-work-unit.yml`
- state machine:
  `.octon/framework/product/contracts/change-closeout-state-machine.yml`
- closeout skill:
  `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md`
- Git/worktree contract:
  `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
- validation:
  `.octon/framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh`

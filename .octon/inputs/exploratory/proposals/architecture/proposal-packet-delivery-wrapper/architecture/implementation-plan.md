# Implementation Plan

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- Rationale: the packet delivery wrapper is one coherent route surface spanning
  workflow, command, skill, schema, validator, fixture, and publication
  metadata. Splitting it would leave an unusable or unvalidated operator route.

## Workstream 1: Workflow Contract

Add `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/`
with stages that mirror proposal-program-delivery while targeting one packet.
The workflow must declare aggregate receipt-only authority and name existing
owners for implementation, terminal closeout, archive, Change closeout,
repo-hygiene cleanup, generated publication, and branch mutation.

## Workstream 2: Command And Skill Surface

Add:

- `.octon/framework/capabilities/runtime/commands/proposal-packet-delivery.md`
- `.octon/framework/capabilities/runtime/skills/operations/proposal-packet-delivery/SKILL.md`

The command surface must be:

```text
/proposal-packet-delivery target=<proposal-packet-path> outcome=cleaned route=branch-no-pr [profile=<profile-path>] [run-id=<id>]
```

The skill must delegate to the workflow and state that it does not implement
packets, archive packets directly, mutate Git directly, delete residue, or
publish generated outputs by hand.

## Workstream 3: Contracts

Add:

- `.octon/framework/product/contracts/proposal-packet-delivery-profile-v1.schema.json`
- `.octon/framework/product/contracts/proposal-packet-delivery-receipt-v1.schema.json`

The receipt schema must bind refs to source receipts without replacing them:

- implementation receipt;
- implementation conformance receipt;
- post-implementation drift/churn receipt;
- terminal closeout receipt;
- archive receipt;
- generated publication freshness evidence;
- Change closeout receipt;
- hosted branch-no-pr landing authorization;
- cleanup authorization and cleanup receipt;
- terminal current-state proof;
- final git status proof.

## Workstream 4: Validators And Fixtures

Add validators for workflow, profile, and receipt shape. Add fixtures and
negative controls for:

- missing or stale accepted review authorization;
- missing implementation authorization;
- scaffold conformance or drift receipts;
- missing terminal closeout receipt;
- archive-by-hand instead of archive-proposal;
- generated publication hand edits or stale registry/artifact projections;
- PR fallback when `route=branch-no-pr`;
- missing hosted no-PR landing authorization;
- source SHA or target pre-ref mismatch;
- missing branch cleanup authorization;
- missing final sync proof;
- dirty final worktree overclaim;
- proposal-local or generated authority overclaims.

## Workstream 5: Publication

Update capability command and skill manifests/registries through owning
publication scripts only. Do not hand-edit `.codex/commands/**`,
`.codex/skills/**`, or generated/effective outputs.

## Evidence Plan

Future implementation must retain:

- implementation run and conformance/drift receipts;
- terminal closeout receipt;
- archive workflow receipt;
- proposal registry and artifact freshness evidence;
- Change closeout receipt;
- branch landing authorization and hosted landing evidence;
- branch cleanup authorization and cleanup evidence;
- terminal current-state proof;
- final clean-worktree proof;
- validator logs and negative-control evidence.

## Rollback

Rollback is a normal git revert of authored workflow, command, skill, schema,
validator, fixture, and capability publication source changes, followed by
regeneration of derived projections through owning scripts. Retain delivery,
branch, cleanup, archive, and terminal proof evidence for auditability.

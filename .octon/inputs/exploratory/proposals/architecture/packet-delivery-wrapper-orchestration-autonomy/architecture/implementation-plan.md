# Implementation Plan

## Workstream 1: Profile And Command Contract

- Keep `outcome=cleaned` and `route=branch-no-pr` explicit for cleaned no-PR
  delivery.
- Ensure profile validation forbids PR fallback, stash widening, self
  authorization, generated-output authority, and aggregate replacement of
  target-owned receipts.
- Keep the command and skill text aligned with the profile schema.

## Workstream 2: Workflow Orchestration

- Split wrapper stages so pre-archive and already-archived packet states have
  explicit routes.
- Route implementation and proposal-owned gates through packet lifecycle
  surfaces.
- Route archive relocation through archive lifecycle surfaces.
- Route hosted landing, final sync, branch cleanup, and terminal Change proof
  through `closeout-change`.
- Preserve blocked aggregate receipt output when any owner blocks.

## Workstream 3: Validator Coverage

- Update `validate-proposal-packet-delivery-workflow.sh` to prove wrapper,
  command, skill, profile, and registration coherence.
- Reuse `test-validate-proposal-packet-delivery.sh` for profile, receipt, and
  workflow negative controls.
- Add future fixtures for pre-archive, already-archived, branch-no-PR, and
  no-PR-fallback cases as needed.

## Dependency Preflight

Before durable implementation, verify that
`blocked-delivery-receipt-semantics` has landed or explicitly record that the
wrapper implementation is blocked by missing receipt semantics. Do not bypass
that dependency inside the wrapper.

## Rollback

Revert workflow, command, skill, profile schema, and workflow validator changes
together if wrapper orchestration widens authority or weakens target-owned
receipt gates.

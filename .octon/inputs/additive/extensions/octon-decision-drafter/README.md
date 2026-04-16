# Octon Decision Drafter Extension Pack

This bundled additive pack drafts non-authoritative change documentation from
code diffs plus retained evidence.

It is designed to:

- route to one of four decision-drafting bundles
- keep ADR, migration, rollback, and receipt drafting under one stable family
- publish command, skill, and prompt-bundle metadata through the existing
  extension publication path only

## Stable Entry Points

- skill: `octon-decision-drafter`
- command: `/octon-decision-drafter`

Leaf bundles:

- `adr-update`
- `migration-rationale`
- `rollback-notes`
- `change-receipt`

Default route:

- `change-receipt` when a diff source and retained grounding are present with
  no narrower target ref

## Buckets

- `skills/` - composite and leaf skill contracts
- `commands/` - thin operator-facing wrappers
- `prompts/` - manifest-governed drafting bundles plus shared contracts
- `context/` - routing and usage guidance
- `validation/` - compatibility profile and extension-local tests

## Output Modes

- `inline` - return draft markdown in the response
- `patch-suggestion` - return a suggested edit only when an explicit target
  path is supplied
- `scratch-md` - materialize scratch artifacts only under the existing generic
  skill checkpoint and run-evidence roots

## Boundary

This pack is additive only.

It must not become a runtime or policy authority surface. Drafts remain
`Draft / Non-Authoritative` even when they target human-authored docs such as
ADRs or migration plans. Retained receipts, rollback posture files, generated
indexes, and other canonical control or evidence artifacts must never be
rewritten automatically by this pack.

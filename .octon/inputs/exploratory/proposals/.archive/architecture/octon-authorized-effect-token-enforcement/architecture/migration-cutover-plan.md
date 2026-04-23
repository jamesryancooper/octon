# Migration and Cutover Plan

## Cutover principle

The cutover is additive until the runtime can prove all live material path families are token-gated. No existing support-target claim is widened. Any uncovered material path remains unsupported and fails closed.

## Stage A — Shadow inventory

- Add or refresh `material-side-effect-inventory.yml`.
- Mark each path with `coverage_state: planned | token_shadowed | token_enforced | blocked`.
- Do not change runtime behavior yet.

## Stage B — Shadow token minting

- Mint token records for representative authorized grants.
- Retain token lifecycle evidence.
- Do not require all consumers yet.
- Compare token scope against actual side-effect summaries.

## Stage C — Enforced token consumption for live material families

- Convert repo-shell workspace-write, broad-verification, state/control mutation, evidence mutation, and executor launch paths to require verified tokens.
- Enable negative bypass tests for those families.
- Keep stage-only/non-live support surfaces denied or staged.

## Stage D — Full material-family enforcement

- Require token verification for every inventoried material family.
- Fail closed for any path without a token mapping, owner, or negative bypass test.
- Update support-target proof requirements.

## Stage E — Retire compatibility paths

- Remove or quarantine raw-path/ambient-grant material APIs.
- Retain compatibility readers only where explicitly marked non-material or read-only.
- Add retirement notes to the compatibility register if needed.

## Rollback posture

Rollback is conservative:

- Schema additions are additive and can be retained.
- Runtime enforcement can be toggled from `hard-enforce` to `stage-only` only through canonical policy state, not through generated projections.
- If enforcement causes false denials, affected paths are marked `stage_only` or `blocked` in the inventory until the scope mapping is fixed.
- No rollback may restore a raw material side-effect path as live support without retained exception evidence.

## Cutover evidence

Each stage requires retained evidence under existing validation roots:

- inventory validation output;
- token mint/consume fixtures;
- bypass tests;
- support-target proof update;
- closure certification;
- no-generated-authority check.

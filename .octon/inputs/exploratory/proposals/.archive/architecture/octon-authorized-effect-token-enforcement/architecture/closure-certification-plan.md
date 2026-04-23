# Closure Certification Plan

## Certification claim

The closure claim is:

> All material side-effect paths in the current live Octon support universe are enforceably gated by Authorized Effect Tokens derived from the engine-owned authorization boundary, and direct bypass attempts fail closed with retained evidence.

## Required closure evidence

| Evidence | Required root |
|---|---|
| Validated token schema fixtures | `/.octon/state/evidence/validation/runtime/authorized-effect-tokens/**` |
| Material side-effect inventory validation | `/.octon/state/evidence/validation/runtime/material-side-effect-inventory/**` |
| Negative bypass tests | `/.octon/state/evidence/validation/runtime/authorized-effect-token-bypass/**` |
| Runtime token consumption fixtures | `/.octon/state/evidence/validation/runtime/authorized-effect-token-consumption/**` |
| Representative Run evidence | `/.octon/state/evidence/runs/<run-id>/**` |
| Token control records | `/.octon/state/control/execution/runs/<run-id>/effect-tokens/**` |
| Support-target proof updates | `/.octon/state/evidence/validation/support-targets/**` |
| Closure disclosure | `/.octon/state/evidence/disclosure/runs/<run-id>/run-card.yml` or release-level disclosure when applicable |

## Two-pass closure procedure

1. Run full validator/test suite.
2. Fix any failures.
3. Run full validator/test suite again without intervening code changes.
4. Retain both results.
5. Confirm no material path is marked `unknown`, `uncovered`, or `compatibility-live`.
6. Confirm no promoted target depends on proposal paths.
7. Certify closure.

## Closure blockers

Closure is blocked if any are true:

- a material path lacks token mapping;
- a material path lacks negative bypass proof;
- a side-effect API accepts raw path plus ambient grant for material mutation;
- token consumption can occur without journal/evidence write;
- a forged token can pass verification;
- generated outputs can mint or validate tokens;
- support-target live claims widen;
- CI or assurance validators cannot be run repeatably.

## Archive expectation

After durable promotion, archive this proposal under:

`/.octon/inputs/exploratory/proposals/.archive/architecture/octon-authorized-effect-token-enforcement/`

with archive disposition `implemented` and promotion evidence refs.

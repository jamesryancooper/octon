# Effect-Token Enforcement Gap Analysis

## Current strength

Octon already has a strong authorization architecture:

- `execution-authorization-v1.md` defines `authorize_execution(request) ->
  GrantBundle` and states that material APIs must consume typed authorized
  effects, not the grant bundle itself.
- `authorized-effect-token-v1.md` defines `AuthorizedEffect<T>` and effect
  classes for material side effects.
- `authorization-boundary-coverage-v1.md` requires inventory, token proof,
  consumption receipts, lifecycle journal links, and negative bypass proof.

## Current gap

The visible runtime materialization does not yet appear closure-grade:

- `authorized_effects` crate exposes effect classes and an `AuthorizedEffect<T>`
  shape, but the visible struct is narrower than the spec-level token model.
- No visible `VerifiedEffect<T>` consumer type is evident in the key
  authorization execution path.
- Existing validators and tests exist, but the migration must prove that every
  material side-effect path requires verified typed effects and records
  consumption evidence.

## Required token model fields

- token id
- token digest
- request id
- grant id
- decision ref
- run root
- lifecycle state ref
- support tuple ref
- route id
- effect class
- capability-pack scope
- expiry
- revocation epoch or revocation-set digest
- approval/exception refs
- rollback posture ref
- budget/egress refs
- token record ref
- single-use/reusable semantics

## Blocking gaps

| Gap | Why it blocks material reality |
| --- | --- |
| No required `VerifiedEffect<T>` at all consumers | Ambient permission may still be enough |
| Missing token metadata | Scope/freshness/revocation cannot be proven |
| Missing consumption receipt | Evidence completeness cannot prove effect use |
| Missing negative proof per path | Bypass may exist unnoticed |
| Missing route/support binding | Token could apply outside admitted envelope |
| Missing single-use enforcement | Replay or reuse risk remains |

## Closure standard

The migration is complete only when a missing or invalid token cannot reach a
material side effect and the denial is deterministic, tested, and evidenced.

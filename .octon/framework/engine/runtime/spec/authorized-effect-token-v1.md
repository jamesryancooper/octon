# Authorized Effect Token v1

This contract defines the typed authorization product required by material
side-effect APIs.

## Purpose

`authorize_execution` remains the engine-owned authorization boundary.
Material side-effecting runtime APIs must consume typed effect tokens derived
from that boundary instead of relying on ambient `GrantBundle` access, raw
path inputs, or generated/read-model projections.

## Token model

The transport artifact is:

```text
AuthorizedEffect<T>
```

Actual mutation must require a verifier-produced internal guard:

```text
VerifiedEffect<T>
```

Where `T` is one of the material effect classes:

- `RepoMutation`
- `GeneratedEffectivePublication`
- `StateControlMutation`
- `EvidenceMutation`
- `ExecutorLaunch`
- `ServiceInvocation`
- `ProtectedCiCheck`
- `ExtensionActivation`
- `CapabilityPackActivation`

The executable token contract is:

- `authorized-effect-token-v2.schema.json`

The executable consumption receipt contract is:

- `authorized-effect-token-consumption-v1.schema.json`

## Required token metadata

Every token must carry at minimum:

- `schema_version`
- `token_id`
- `token_type`
- `effect_kind`
- `run_id`
- `request_id`
- `grant_id`
- decision and grant artifact refs
- canonical run control and evidence roots
- lifecycle state ref
- route id plus runtime-effective route-bundle ref, generation id, digest,
  freshness mode, publication receipt ref, and non-authority classification
- support-target tuple ref when applicable
- support claim effect and support route
- allowed capability packs
- scope ref plus scope envelope
- rollback plan and rollback posture refs
- approval request and approval grant refs when required
- exception lease refs when required
- budget and egress refs when applicable
- issued timestamp
- expiry timestamp when bounded by time
- single-use or scope-bounded validity semantics
- issuer ref
- revocation refs
- canonical token-record ref
- journal ref when minted under a bound run
- digest over the canonical token payload

## Construction rules

- Tokens are created only from the authorization boundary or an engine-owned
  projection of a successful grant.
- Arbitrary runtime callers must not be able to mint tokens.
- Public serialization/deserialization must not be sufficient to fabricate a
  valid token; verification must resolve a canonical token record.
- A token may be single-use or explicitly scope-bounded, but the scope must be
  encoded and enforced.

## Verification rules

- `AuthorizedEffect<T>` is only a transport artifact.
- Material APIs must verify the token against canonical control/evidence state
  before mutation.
- Verification must fail closed when the canonical token record is missing,
  mismatched, expired, revoked, already consumed, outside scope, outside the
  active support/capability envelope, stale relative to runtime-effective
  freshness, bound to the wrong route/run/support tuple, missing approval or
  exception evidence, missing rollback posture, over budget, egress denied, or
  when receipt/journal persistence cannot be completed before or at effect
  attempt.
- A support-bound token must also match the generated support-envelope
  reconciliation result. The verifier must treat that result as a
  non-authoritative gate handle: it can block live support when canonical
  declarations, admissions, proof, routes, pack routes, generated matrices, or
  disclosures disagree, but it cannot widen support.
- Verification must retain an
  `authorized-effect-token-consumption-v1` receipt for both successful
  verification and rejection.
- Rejection receipts must include one deterministic denial reason from the
  closure-grade set: `missing_token`, `forged_token`, `wrong_effect_class`,
  `wrong_run`, `wrong_route`, `wrong_support_tuple`, `unsupported_tuple`,
  `excluded_tuple`, `wrong_capability_pack`, `wrong_scope`, `stale_token`,
  `expired_token`, `revoked_token`, `missing_approval`, `missing_exception`,
  `rollback_not_ready`, `budget_exceeded`, `egress_denied`,
  `already_consumed`, or `decision_not_allow`.

## Acceptance rule

Material side-effect APIs are not target-state complete until they require the
relevant token type as input and verify it into `VerifiedEffect<T>` before
mutation.

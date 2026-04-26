# Target Architecture

Governed Runtime Materialization v1 creates one coherent runtime-governance
closure path across support truth, effect authorization, and operator visibility.

## Target state summary

Octon reaches the target state when:

1. live support claims are reconciled across authored, proof, route, capability,
   generated, support-card, and disclosure surfaces before publication or
   runtime use;
2. every material side-effect API consumes a verified typed effect rather than
   ambient permission;
3. each consequential run exposes a generated non-authoritative health artifact
   that links back to canonical state/control/evidence/continuity sources.

## Architecture principle

The migration does not add a second control plane. It strengthens the existing
one:

```text
authored authority
  -> resolver / authorization / support admission
  -> runtime-effective generated handles
  -> run control + retained evidence
  -> generated operator read models
```

Generated artifacts can summarize, narrow, or disclose. They cannot mint
authority, widen support, or authorize effects.

## Support-envelope reconciliation architecture

The support reconciler reads:

- authored support declarations from `.octon/instance/governance/support-targets.yml`
- admission/proof artifacts under `.octon/state/evidence/validation/support-targets/**`
- generated runtime route bundle
- generated capability-pack route bundle
- generated support-target matrix
- support locks/freshness markers
- support cards and disclosure artifacts, where present

It emits:

- `.octon/generated/effective/governance/support-envelope-reconciliation.yml`
- retained validation evidence under
  `.octon/state/evidence/validation/runtime/governed-runtime-materialization-v1/support-envelope/**`
- deterministic diagnostics for every mismatch

The gate fails if any live claim is missing one of the required legs:

```text
declared -> admitted -> proof-backed -> fresh -> route-resolved
        -> capability-pack-consistent -> generated-without-widening
        -> disclosed-without-overclaim
```

## Effect-token enforcement architecture

Authorization remains engine-owned:

```text
ExecutionRequest
  -> authorize_execution(...)
  -> GrantBundle
  -> AuthorizedEffect<T>
  -> verify_authorized_effect(...)
  -> VerifiedEffect<T>
  -> material side effect
  -> consumption receipt
  -> run journal + retained evidence
```

`GrantBundle` is not directly consumable authority for mutation. Material APIs
must require `VerifiedEffect<T>` or accept an `AuthorizedEffect<T>` only through a
local verifier that returns `VerifiedEffect<T>`.

Each token is bound to:

- token id and digest
- request id
- grant id
- decision artifact
- run root
- lifecycle state
- route id
- support-target tuple
- capability-pack scope
- effect class
- expiration/freshness policy
- approval/exception requirements
- revocation checks
- rollback posture
- budget/egress constraints when applicable
- single-use or reusable semantics
- canonical token record and consumption receipt

## Operator run-health architecture

Run health is a generated read model, not authority:

```text
run journal + runtime state + checkpoints
  + authority bundle + revocations/exceptions
  + support reconciliation result
  + evidence completeness
  + rollback posture
  + disclosure/readiness state
  -> generated run health
```

Proposed location:

```text
.octon/generated/cognition/projections/materialized/runs/<run_id>/health.yml
.octon/generated/cognition/projections/materialized/runs/index.yml
```

Each health artifact must contain source references, source digests, generated
time, freshness policy, and an explicit non-authority classification.

## Health statuses

The run-health generator must distinguish at least:

- `healthy`
- `review_required`
- `awaiting_approval`
- `blocked`
- `stale`
- `unsupported`
- `revoked`
- `evidence_incomplete`
- `rollback_required`
- `closure_ready`

When inputs disagree, health must show uncertainty instead of hiding it.

## Validation and closure flow

```text
static schemas
  -> support-envelope fixtures
  -> effect-token positive/negative runtime tests
  -> run-health fixtures
  -> cross-artifact consistency validators
  -> evidence completeness validation
  -> closure certification
```

No support claim, material side effect, or run-health artifact passes closure
unless its canonical inputs and retained evidence agree.

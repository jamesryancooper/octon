# Target Architecture

## Executive decision

Adopt **Authorized Effect Token enforcement** as the next runtime hardening layer after the canonical append-only Run Journal.

The target architecture is:

> Every material side-effecting runtime API must require a valid, typed, in-scope, unexpired Authorized Effect Token derived from the current Run’s authorized grant, and every token mint/consume/reject/revoke/expire event must be recorded in canonical control/evidence surfaces and the Run Journal.

This strengthens the Governed Agent Runtime without changing Octon’s constitutional identity. The Constitutional Engineering Harness remains the whole system; the Governed Agent Runtime enforces the authorized-effect boundary inside the Execution Plane.

## Integration posture

### Chosen approach

- **Primary motion:** harden existing runtime contracts and runtime crates.
- **Control motion:** materialize token issuance, revocation, expiry, and consumption state under existing `state/control/execution/**` roots.
- **Evidence motion:** retain token lifecycle receipts and negative bypass proof under existing `state/evidence/**` roots.
- **Validation motion:** add structural validators, runtime fixtures, and negative bypass tests.

### Why this approach is correct

Octon already declares `authorize_execution(request: ExecutionRequest) -> GrantBundle` as the mandatory engine-owned authorization boundary. It also already has `authorized-effect-token-v1.md`, an `authorized_effects` runtime crate, `authorization-boundary-coverage-v1.md`, and `material-side-effect-inventory-v1.schema.json`. The correct implementation path is therefore **not** to invent a new policy engine or approval layer. The correct path is to make the existing boundary unbypassable at the point where actions become real.

### Why a narrower documentation-only path is insufficient

A narrower path that only updates `authorized-effect-token-v1.md` would leave pseudo-coverage. The current runtime would still depend on convention, code review, or ambient `GrantBundle` availability rather than typed consumption proof at each material API boundary.

### Why a broader redesign is unnecessary

A new Control Plane, new support universe, or new Mission abstraction is unnecessary. The existing runtime/control/evidence roots are sufficient. This packet only strengthens the handoff from authorization to effect.

## Core target model

### 1. Token object

A promoted Authorized Effect Token must include at minimum:

- `schema_version`
- `token_id`
- `effect_kind`
- `request_id`
- `grant_id`
- `decision_artifact_ref`
- `authority_grant_bundle_ref`
- `run_id`
- `run_control_root`
- `run_evidence_root`
- `support_target_tuple_ref`
- `allowed_capability_packs`
- `scope_ref`
- `scope_constraints`
- `issued_at`
- `expires_at`
- `single_use`
- `issuer_ref`
- `revocation_ref`
- `token_record_ref`
- `journal_ref`
- `token_digest`

### 2. Effect classes

The v1 effect classes remain canonical minimums:

- `RepoMutation`
- `GeneratedEffectivePublication`
- `StateControlMutation`
- `EvidenceMutation`
- `ExecutorLaunch`
- `ServiceInvocation`
- `ProtectedCiCheck`
- `ExtensionActivation`
- `CapabilityPackActivation`

The implementation must also close any mismatch between this list and the current material side-effect family list. If outbound HTTP, model-backed execution, release activation, or disclosure publication are not adequately represented by an existing class, the promoted v2 schema should add explicit effect kinds such as `NetworkEgress`, `ModelInvocation`, `PromotionActivation`, and `DisclosurePublication`. This is not support-surface expansion; it is coverage of already-declared material path families.

### 3. Token lifecycle

The lifecycle is:

1. `ExecutionRequest` is submitted.
2. `authorize_execution(request)` evaluates policy and returns `GrantBundle` or denial.
3. If decision is `ALLOW`, the authority engine mints one or more typed tokens for explicitly granted effect classes and scopes.
4. Minted tokens are recorded under the bound Run control root.
5. Mint events are appended to the canonical Run Journal.
6. A material API receives the required typed token and immediately verifies it against canonical control/evidence records.
7. Verification returns a non-serializable internal `VerifiedEffect<T>` guard.
8. The API performs the effect only while holding the verified guard.
9. Consumption receipt is retained and journaled before or at the point of effect attempt.
10. Single-use tokens are consumed; expired, revoked, wrong-kind, wrong-scope, wrong-run, or non-ledger-backed tokens fail closed.

### 4. Runtime API rule

Every material side-effecting runtime API changes from:

```text
perform_effect(raw_path_or_request, ambient_grant_or_caller_assertion)
```

to:

```text
perform_effect(AuthorizedEffect<T>, bounded_effect_input)
```

or, internally:

```text
let guard: VerifiedEffect<T> = verifier.verify(effect_token, bounded_effect_input)?;
perform_effect_with_verified_guard(guard, bounded_effect_input)
```

Public side-effect APIs may accept `AuthorizedEffect<T>` as the transport artifact, but actual mutation must require `VerifiedEffect<T>` produced by the verifier. This prevents hand-constructed or stale tokens from being treated as authority.

### 5. Canonical placement

| Concern | Placement |
|---|---|
| Token contract | `/.octon/framework/engine/runtime/spec/authorized-effect-token-v1.md` plus promoted v2 schema. |
| Consumption contract | `/.octon/framework/engine/runtime/spec/authorized-effect-token-consumption-v1.schema.json`. |
| Material inventory | `/.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml` generated/maintained from inventory schema. |
| Token implementation | `/.octon/framework/engine/runtime/crates/authorized_effects/**`. |
| Token minting | `/.octon/framework/engine/runtime/crates/authority_engine/**`. |
| Token verification and consumption | `authority_engine`, `core/src/execution_integrity.rs`, and material runtime API owners. |
| Live token control state | `/.octon/state/control/execution/runs/<run-id>/effect-tokens/**`. |
| Token evidence | `/.octon/state/evidence/runs/<run-id>/receipts/effect-tokens/**` and `/.octon/state/evidence/control/execution/**`. |
| Run Journal integration | canonical Run Journal event/item stream after Run Journal promotion; interim `runtime-event-v1` events if needed. |
| Generated views | optional derived-only operator read models; never authority. |

## Required Run Journal event additions

This packet is sequenced after the canonical Run Journal. It requires these token lifecycle events or equivalent typed journal items:

- `effect_token.requested`
- `effect_token.minted`
- `effect_token.denied`
- `effect_token.consumption_requested`
- `effect_token.consumed`
- `effect_token.rejected`
- `effect_token.expired`
- `effect_token.revoked`

Every event must cite `run_id`, `request_id`, `grant_id`, `token_id`, `effect_kind`, `scope_ref`, and the relevant control/evidence refs.

## Required fail-closed behavior

A material path must fail closed when:

- no token is supplied;
- token kind does not match the API effect class;
- token is not found in canonical token control state;
- token digest does not match the canonical record;
- token grant does not resolve to the current Run’s authority decision;
- token is expired, revoked, already consumed, or outside scope;
- support-target tuple, capability-pack admission, rollback posture, or approval posture no longer matches the grant;
- consumption cannot be journaled or retained as evidence.

## Support-target posture

No support-target widening is part of this packet. Live scope remains the currently admitted repo-shell and CI-control-plane support universe. Stage-only browser/API/frontier surfaces remain non-live.

## Generated/read-model discipline

Generated outputs may display token status after promoted implementation lands, but generated outputs may not mint, validate, consume, or substitute for tokens. Token truth lives in runtime contracts, runtime code, state/control, and retained evidence.

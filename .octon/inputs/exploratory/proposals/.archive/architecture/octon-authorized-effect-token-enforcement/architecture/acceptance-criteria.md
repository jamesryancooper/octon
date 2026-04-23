# Acceptance Criteria

## Packet-level acceptance

This packet is acceptance-ready only if all are true:

1. The proposal remains scoped to Authorized Effect Token enforcement and boundary coverage.
2. It does not create a new Control Plane.
3. It does not widen support targets.
4. It does not make generated/read-model outputs authoritative.
5. It declares durable promotion targets outside the proposal workspace.
6. It includes current-state evaluation and implementation-gap analysis under `resources/`.
7. It includes implementation, validation, file-change, cutover, and closure artifacts.

## Target architecture acceptance

The promoted architecture is accepted only if all are true:

1. `authorize_execution(request: ExecutionRequest) -> GrantBundle` remains the only authority boundary for material execution.
2. A promoted token schema exists with grant/run/support/scope/expiry/revocation/journal/digest metadata.
3. A promoted consumption receipt schema exists.
4. Every material path family has an inventory entry with an effect token class.
5. Every material path family has a negative bypass test.
6. Side-effect APIs require typed token input and verify it into an internal guard before mutation.
7. Token lifecycle events are retained in the canonical Run Journal.
8. Execution receipts cite token and consumption refs for material effects.
9. Evidence-store completeness fails when material side-effect token proof is absent.
10. Support-target proof bundles include token enforcement evidence for live tuples.

## Negative bypass acceptance

For each material path family, all negative cases must fail closed:

- no token supplied;
- wrong token kind;
- forged token not backed by canonical record;
- wrong Run/request/grant;
- expired token;
- revoked token;
- already consumed single-use token;
- scope mismatch;
- support-target mismatch;
- capability-pack mismatch;
- missing journal/evidence write.

## Runtime implementation acceptance

Implementation is accepted only if all are true:

1. No material API remains callable through raw path plus ambient grant without token verification.
2. Any compatibility method is marked read-only, non-material, or stage-only with fail-closed behavior.
3. `AuthorizedEffect<T>` transport values cannot cause effects without verifier-backed `VerifiedEffect<T>` guards.
4. Token consumption is atomic enough that a failed evidence/journal write prevents the material effect.
5. Token revocation and Run lifecycle state prevent later consumption.

## Closure acceptance

Closure requires:

- all validators passing;
- two consecutive clean validation runs;
- retained proof under canonical evidence roots;
- a closure certification note;
- no unresolved blockers;
- no proposal-path dependency in promoted targets.

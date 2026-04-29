# Federation Lifecycle Standards

Octon v6 federates proof, not authority. It delegates narrowly, not
permanently, and executes locally rather than by external trust.

## Runtime Sequence

The local sequence is:

1. Inspect the external project or system.
2. Assign an Octon Compatibility Profile.
3. Run safe adoption preflight when adoption is requested.
4. Register a Trust Domain locally.
5. Validate the local Trust Registry.
6. Propose a Federation Compact.
7. Locally approve or reject the compact.
8. Import or export a Portable Proof Bundle.
9. Verify an Attestation Envelope.
10. Accept, reject, revoke, or retain the attestation as evidence only.
11. Create a Delegated Authority Lease only when locally approved.
12. Create a Cross-Domain Decision Request when coordination is required.
13. Admit material work into lower-level Octon workflow only after local gates
    pass.
14. Execute material work only through local run contracts and authorization.
15. Retain trust and federation evidence.
16. Update the Federation Ledger.
17. Revoke, expire, renew, or recertify trust artifacts as required.

## Canonical Surfaces

- Portable contracts live under `framework/engine/runtime/spec/**`.
- Repo-owned trust authority lives under `instance/governance/trust/**`.
- Mutable trust status lives under `state/control/trust/**`.
- Retained trust proof lives under `state/evidence/trust/**`.
- Resumable trust context lives under `state/continuity/trust/**`.
- Generated trust views live under
  `generated/cognition/projections/materialized/trust/**` and are
  non-authoritative.

## Required Gates

- Compatibility gate: no deep federation without Octon-enabled or
  Octon-compatible posture.
- Adoption gate: no Octon-enabled treatment before local topology and bootstrap
  checks pass.
- Trust Domain gate: no proof or delegation from an unregistered or revoked
  domain.
- Compact gate: no federation behavior without a locally approved compact.
- Attestation gate: no influence unless verified, scoped, fresh, unrevoked,
  and locally accepted.
- Proof Bundle gate: no evidence satisfaction unless schema-valid,
  digest-bound, scoped, fresh, redacted, unrevoked, and locally accepted.
- Delegation gate: no lease influence unless scoped, expiring, revocable,
  evidenced, support-bound, capability-bound, approved, and still locally
  authorized.
- Local Authority gate: no external artifact overrides local authority,
  support targets, or run authorization.
- Data Boundary gate: no cross-domain evidence sharing without redaction,
  retention, egress, and disclosure posture.
- Certification gate: no certification widens support claims without local
  support-target admission and proof.
- Recertification gate: trust artifacts expire, renew, or recertify.
- Revocation gate: revocation fails closed.

## CLI Posture

The v6 commands inspect, validate, record receipts, or stage trust control
state. They do not execute material external work. Material work remains bound
to the lower-level run lifecycle, context packs, execution authorization,
evidence retention, replay, rollback, and closeout gates.

Deferred scope includes mesh federation, marketplace trust, transparency logs,
automatic auditor acceptance, external AI quorum, cross-domain write authority,
production deployment federation, autonomous trust-policy evolution, direct
partner mutation, and support-claim widening by third-party attestations alone.

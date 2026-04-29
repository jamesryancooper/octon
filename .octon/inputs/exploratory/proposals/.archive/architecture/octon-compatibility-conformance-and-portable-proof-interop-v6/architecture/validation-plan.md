# Validation Plan

## Schema validation

- Octon Compatibility Profile
- External Project Adoption
- Portable Proof Bundle
- Attestation Envelope
- Proof Acceptance Record
- Trust Domain hook
- structural hook schemas

## Behavioral validation

- Non-Octon system cannot become federation peer.
- Octon-compatible emitter can emit proof but cannot authorize.
- Octon-enabled repo requires valid `.octon/` topology and local authority/control/evidence roots.
- Proof bundle must be schema-valid, scoped, digest-bound, fresh, redacted when required, and unrevoked.
- Attestation must be schema-valid, issuer-bound, scoped, fresh, unrevoked, and locally accepted.
- Revoked or expired proof fails closed.
- Imported proof cannot widen support claims.
- Imported proof cannot authorize execution.

## Negative controls

- Reject blind full `.octon/` state copy.
- Reject generated trust view as authority.
- Reject attestation as approval.
- Reject stale proof.
- Reject proof missing required redaction manifest.
- Reject imported proof as support-target widening.

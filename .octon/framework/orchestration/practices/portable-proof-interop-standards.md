# Portable Proof Interop Standards

Portable proof interoperability is the selected v6 prerequisite for later
federation. It lets Octon exchange evidence-shaped artifacts while preserving
repo-local authority.

## Runtime Boundary

`octon proof export`, `octon proof import`, `octon proof verify`,
`octon proof accept`, `octon proof reject`, and `octon proof status` operate on
Portable Proof Bundles. These commands can produce evidence receipts and local
acceptance records. They cannot authorize material work, widen support claims,
replace run evidence, or mutate durable authority.

`octon attest verify`, `octon attest accept`, `octon attest reject`, and
`octon attest status` operate on Attestation Envelopes. Accepted attestations
are evidence only.

## Acceptance Gate

Imported proof or attestations may satisfy local evidence requirements only
after local verification records:

- schema validity;
- issuer and trust-domain hook posture;
- scope;
- validity window and freshness;
- revocation status;
- digest verification for proof bundles;
- redaction manifest posture;
- local acceptance state;
- responsible local authority.

Accepted states remain revocable and expiring. Revoked, expired, stale,
untrusted, unscoped, malformed, or unredacted artifacts fail closed.

## Data Boundary

Proof export must include a redaction manifest and disclosure boundary. Exported
secret material is forbidden. Imported raw content may be retained only as
evidence and only under the trust evidence roots.

## Deferred Scope

This standard does not implement full Trust Registry runtime, Federation
Compact runtime, delegated authority runtime, cross-domain write authority,
certification runtime, marketplace trust, production deployment federation, or
external execution authority.

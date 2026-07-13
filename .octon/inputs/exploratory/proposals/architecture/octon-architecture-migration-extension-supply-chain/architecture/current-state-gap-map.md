# Current-State Gap Map

## Repository Baseline

The reconciliation inspected commit
`c5b1f5760c78ff521cca6b054e4e8fef5300505b`. Later proposal authoring has not
accepted or dynamically proved the RP-12 target.

| Current surface | Reusable strength | Gap owned by RP-12 |
| --- | --- | --- |
| Extension governance README/boundary/trust contracts | Correct raw/desired/actual/generated separation and non-authority rules | Private signed envelope, exact source/signer/revocation/pin and restore rules are incomplete. |
| `extension-pack.schema.json` | Strict pack identity, version, origin, capability profiles, compatibility, dependencies, provenance digest, and attestations | Provenance digest/attestation refs do not cryptographically bind a trusted signer to canonical manifest/payload/dependency metadata. |
| `instance/extensions.yml` and schema | Desired enabled/disabled selection, source catalog, trust defaults/overrides, acknowledgements, optional pins | No complete operator signer/key/rotation/revocation trust set; private enabled pins are not uniformly exact source/version/payload identities. |
| Active/quarantine schemas/state | Canonical actual publication and quarantine truth | No separate verified availability contract or revocation-aware retained-release status. |
| Effective catalog, artifact map, and generation lock | Digest-bound generated publication family with invalidation and receipts | No mandatory signed-envelope/import/trust-policy/transition binding or safe prior-generation restore identity. |
| `extensions-common.sh` and publisher | Strong schema/compatibility/dependency resolution, quarantine, collision checks, receipts, staging, and atomic publication | No one-command safe signed private import, signer verification, revocation propagation, or revalidated restore transaction. |
| Route/prompt resolvers and runtime resolver | Consume generated catalog and cross-check lock/active/desired state | Direct resolver paths must reject stale/revoked generation and bind the RP-11 exact generation contract. |
| Pack-bundle export | Explicit trust-agnostic selected-pack/dependency transfer | Signed envelope and exact immutable payload identity preservation are not proved across export/import. |
| Extension assurance/tests | Strong schema, compatibility, quarantine, publication, route, prompt, and export fixtures | UE-012 hostile signer/tamper/revocation/non-authority/restore matrix is absent. |

## Primary Finding

RF-016 accepts the reusable publication, quarantine, adapter, scheduling,
budget, and retirement foundations while rejecting the claim that digest fields
make a catalog signed. RP-12 owns only the extension supply-chain closure after
RP-07 and RP-11; child and provider semantics remain elsewhere.

## RF-027 Cross-Reference

ROD-004 accepts one operator-controlled signer family, immutable refs/digests,
explicit capability grants, and an empty deny-by-default initial source
allowlist. RP-12 must encode and prove this baseline. Later exact sources,
signer material, rotations, pins, and admission updates are governed
configuration changes. Safe default is deny all private/external imports.

## Gap-to-Owner Map

| Gap | Owner | Not owned here |
| --- | --- | --- |
| Signed release envelope and verification | RP-12 using RP-07 primitives | Signing-key custody/evidence system redesign |
| Approved sources/signers/revocations and exact desired pins | Accepted ROD-004 baseline plus governed desired-config updates | Capability grants or execution authority |
| Verified availability/import receipt | RP-12 import verifier | Desired selection or generated publication |
| Active/quarantine/generated binding and safe restore | Existing publisher extended by RP-12 | New service/control plane or general package manager |
| Exact generation Harness consumption | RP-11 contract consumes RP-12 output | Harness compilation/authorization semantics |
| Child/provider/effect behavior | RP-13/RP-11/RP-08 | No such implementation belongs in RP-12 |

## Evidence Honesty

The current state is statically inspected. No accepted hostile import matrix,
trust-revocation race, import-does-not-authorize proof, exact pin/Harness
binding, or retained prior-generation restore has run. UE-012 remains open.

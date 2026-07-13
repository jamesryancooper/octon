# Private Signed Extension Supply Chain

This is the draft RP-12 architecture proposal for
`octon-architecture-migration-extension-supply-chain`. It is a temporary,
non-authoritative implementation aid. It does not authorize an import,
extension selection, capability grant, network source, signer, activation,
execution, marketplace, or support claim.

## Outcome

Octon gains the smallest private extension supply chain needed by one operator:

- a canonical signed envelope binds pack identity/version, immutable source
  ref, manifest and payload digests, compatibility, capabilities,
  dependencies, signer identity, and signature;
- one explicit import verifies the operator-approved source and signer,
  safely materializes the payload, and adds an exact version only to the
  private availability catalog;
- desired selection and exact pins remain separate from verified availability;
- actual active/quarantine state and generated runtime views retain their
  current ownership and fail closed on signature, revocation, compatibility,
  capability, pin, or freshness drift; and
- a prior generation can be restored only from a retained exact signed release
  after current trust, revocation, compatibility, and capability revalidation.

Import makes an extension available. It never selects, authorizes, grants,
publishes, routes, or executes it.

## Program Position

- logical packet: `RP-12`
- workgroup: `RWG-12`
- parent program: `octon-architecture-migration-program`
- dependencies: RP-07 signed bounded evidence and RP-11 deterministic Harness
  Factory
- parallel sibling: RP-13 bounded child agents, with no shared semantic source

RP-12 directly owns FD-021 and RF-016's extension-supply-chain closure.
RF-027 is cross-referenced because RP-12 must encode and prove the accepted
ROD-004 deny-by-default trust configuration without reopening its architecture.

## Promotion Scope

The proposal is `octon-internal`. Every promotion target is under `.octon/**`.
Raw imported packs, actual control state, generated effective catalogs, and
receipts keep distinct authority roles; none becomes execution authority.

## Reading Order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `navigation/source-of-truth-map.md`
4. `resources/packet-contract.yml`
5. `resources/traceability.yml`
6. `architecture/current-state-gap-map.md`
7. `architecture/target-architecture.md`
8. `architecture/file-change-map.md`
9. `architecture/cutover-plan.md`
10. `architecture/rollback-plan.md`
11. `architecture/acceptance-criteria.md`
12. `architecture/validation-plan.md`
13. `architecture/implementation-plan.md`
14. `architecture/operator-disclosure.md`
15. `support/implementation-grade-completeness-review.md`

## Current Gate

The packet remains `draft`. Encoding the accepted ROD-004 baseline, dependency
exits, stable-digest architecture review, UE-012 adversarial proof, and
implementation receipts are future gates. Structural validation does not
resolve them; no operator decision remains open.

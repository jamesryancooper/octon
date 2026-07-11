---
disclosure_status: externally-shareable-after-maintainer-review
authority_mode: non-authoritative
external_transmission_approved: false
---

# External Architect Verification Checklist

Record `pass`, `revision-required`, or `unable-to-verify` for each item and
cite exact repository evidence.

## Topology And Authority

- [ ] The four surfaces have distinct ownership, authority, storage, and Git
      contracts.
- [ ] Workspace history cannot become public distribution history.
- [ ] Core-owned and project-owned paths are disjoint and machine-verifiable.
- [ ] Proposal and generated artifacts cannot mint authority.

## Portable Distribution

- [ ] `portable_dropin` is a sufficient fail-closed publication boundary.
- [ ] Component selection is dependency-closed and zero-unknown.
- [ ] License, provenance, sensitivity, and publication clearance are
      enforceable at component and exception levels.
- [ ] Strict exclusions and zero-pack posture cover all leak paths.
- [ ] Repeated builds and public-tree parity are deterministic.

## Downstream Delivery

- [ ] Exact-lock retrieval is practical across Tier 1 and offline scenarios.
- [ ] Archive and supply-chain verification occur before materialization.
- [ ] Neutral initialization creates no copied repository authority.
- [ ] Transactional update, interrupted recovery, and rollback are complete.
- [ ] Project-owned hashes remain unchanged.

## Storage And Evidence

- [ ] Local-private storage claims are truthful.
- [ ] Retention and backup preserve collaboration, release, security, and
      recovery evidence.
- [ ] Compact receipts do not overclaim equivalence to raw evidence.
- [ ] Generated output inherits source sensitivity.

## Public Repository And Release

- [ ] Controls are proportionate for a solo maintainer.
- [ ] Untrusted pull requests cannot access secrets or write capability.
- [ ] Checksums, SBOM, attestations, tags, and immutable releases are adequate.
- [ ] Merge cannot publish; final release requires deliberate maintainer action.

## Program And Migration

- [ ] The ten-child dependency graph is acyclic and correctly ordered.
- [ ] Root and Octon storage migration are appropriately split.
- [ ] Each blocker has one owner and an objective test.
- [ ] No necessary blocker is missing and no blocker is ceremonial.
- [ ] Deferred controls have credible triggers.
- [ ] Parent evidence cannot satisfy child receipts or human gates.

## Source Challenge

- [ ] Every material decision traces to source IDs and current repository
      evidence.
- [ ] Superseded recommendations were not restored.
- [ ] Conversation-derived claims that conflict with repository evidence are
      explicitly identified.
- [ ] Missing attachments and disclosure limitations are accounted for.


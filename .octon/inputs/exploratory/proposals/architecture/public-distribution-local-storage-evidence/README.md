# Public Distribution Local Storage And Evidence

_Status: In review; implementation-grade complete; not accepted or authorized for implementation._

## Problem

Current tracking defaults retain substantial high-churn state and generated output, generated commit defaults favor hosted material, and run evidence can emit synthetic external-immutable locators and non-content digests. These behaviors conflict with truthful local-first custody and bounded hosted repositories.

## Confirmed Current Evidence

- **Confirmed evidence:** The tracked tree contains large state, generated, inputs, and host-projection surfaces.
- **Confirmed evidence:** octon.yml currently marks several generated/effective and cognition outputs for commit.
- **Confirmed evidence:** write-run.sh can emit immutable-style locators and digests derived from a run identifier rather than an external object content hash.
- **Confirmed evidence:** The retention contracts distinguish disclosure classes but no first-release local-private default is implemented end to end.

## Target Outcome

Make operational evidence, runtime state, generated outputs, caches, logs, and host projections local by default; retain only classified compact receipts or pointers when collaboration, release, governance, or recovery requires hosting; and use truthful content hashes and local-private semantics.

## Scope

- Define default Git posture for every major class root and input subtype.
- Replace synthetic external claims with truthful local-private records and real content digests.
- Update active retention and replay schemas, shell and Rust producers,
  consumers, validators, and tests as one dependency-closed compatibility set.
- Define encrypted system backup plus disconnected encrypted backup for high-value local evidence.
- Retain compact governance and release receipts while raw evidence follows bounded retention.
- Keep evidence compaction tooling deferred but specify its safety contract.

## Non-Goals

- No hosted evidence service or external immutable store.
- No destructive evidence deletion during implementation without separate maintainer authorization.
- No claim that compacted summaries are equivalent to raw evidence.
- No blanket rule that all inputs are local or all private repositories may host them.

## Adopted Decisions Implemented

- **Sponsor decision:** Operational evidence, state, generated outputs, caches, logs, and host projections are local by default.
- **Sponsor decision:** Hosted Git receives only durable authored material and minimum classified receipts or artifacts.
- **Sponsor decision:** Raw evidence stays under local maintainer custody with encrypted backups.
- **Sponsor decision:** Use local-private semantics unless a real external immutable object and content digest exist.
- **Sponsor decision:** Compaction is post-release and deletion remains maintainer-authorized.

## Superseded Approaches

- **Removed or superseded:** Synthetic immutable locators and run-id-shaped digests.
- **Removed or superseded:** Routine commits of raw run evidence and generated-effective outputs.
- **Removed or superseded:** Treating every input subtype as one Git class.
- **Removed or superseded:** Treating private hosting as sufficient classification.

## Authority Boundary

This packet remains non-authoritative input. Durable authority can arise only
from separately reviewed implementation in the declared promotion targets.
Maintainer-only decisions and external effects remain explicit gates.

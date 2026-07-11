# Public Distribution Portable Dropin Export

_Status: In review; implementation-grade complete; not accepted or authorized for implementation._

## Problem

The current exporter supports repo_snapshot and pack_bundle, copies from the mutable workspace, includes project material for repo snapshots, and invokes publication-state writers during validation. It cannot serve as a safe public boundary.

## Confirmed Current Evidence

- **Confirmed evidence:** portable_dropin is absent from the root manifest and profile validator.
- **Confirmed evidence:** export-harness.sh accepts only repo_snapshot or pack_bundle and uses direct file copies from .octon.
- **Confirmed evidence:** repo_snapshot includes instance material and extension publication state.
- **Confirmed evidence:** repo_snapshot validation calls publication scripts that can mutate workspace publication state.

## Target Outcome

Produce a source-read-only exporter that resolves an exact Git commit, selects only cleared component closure paths, writes into an empty staging directory, emits a deterministic manifest, and proves exact public-tree parity.

## Scope

- Add portable_dropin profile and schema validation.
- Read only tracked blobs and modes from an exact commit.
- Classify output as installable or public-repository-only.
- Emit path, component, mode, size, and SHA-256 manifest entries.
- Fail closed on unknown, uncleared, denied, untracked, ignored, or escaping paths.

## Non-Goals

- No push to a public repository and no release publication.
- No additive pack export in the base profile.
- No source workspace publication-state refresh.
- No live instance, inputs, state, generated, evidence, host projection, log, report, archive, or residue output.

## Adopted Decisions Implemented

- **Sponsor decision:** portable_dropin is the public boundary; existing profiles are not.
- **Sponsor decision:** Export source is an exact Git commit, never the mutable working tree.
- **Sponsor decision:** Export uses an empty staging directory, explicit allowlist, fail-closed denylist, and repeated-build equality.
- **Sponsor decision:** Manifest entries include path, component, mode, size, SHA-256, and installability class.
- **Sponsor decision:** Public tree must exactly equal the approved export manifest.

## Superseded Approaches

- **Removed or superseded:** Copying the live workspace tree.
- **Removed or superseded:** Refreshing generated or publication state as part of export validation.
- **Removed or superseded:** Using exclusion-only filtering from a broad source root.
- **Removed or superseded:** Treating a successful copy as proof of deterministic publication safety.

## Authority Boundary

This packet remains non-authoritative input. Durable authority can arise only
from separately reviewed implementation in the declared promotion targets.
Maintainer-only decisions and external effects remain explicit gates.


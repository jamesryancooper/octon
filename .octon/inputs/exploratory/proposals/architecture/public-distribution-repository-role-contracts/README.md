# Public Distribution Repository Role Contracts

_Status: In review after blocker reconciliation; implementation-grade complete; not accepted or authorized for implementation._

## Problem

The class-root architecture distinguishes framework, instance, inputs, state, and generated output, but current portability profiles and documentation do not define the separate private workspace, synthetic public mirror, downstream consumer, and machine-local storage contracts required by the adopted delivery model.

## Confirmed Current Evidence

- **Confirmed evidence:** Shared-foundation documentation correctly distinguishes framework, instance, inputs, state, and generated roles.
- **Confirmed evidence:** The root manifest exposes bootstrap_core, repo_snapshot, pack_bundle, and full_fidelity but no portable_dropin profile.
- **Confirmed evidence:** The current README describes profile-driven portability without a separate public distribution repository contract.
- **Confirmed evidence:** External-project adoption already forbids copying instance, state, and generated material as source truth.

## Target Outcome

Establish a normative four-surface contract, path ownership matrix, public-distribution boundary, and core/project update invariants that later packets can implement without authority ambiguity.

## Scope

- Define private workspace, public distribution, downstream project, and local/external operational storage roles.
- Classify core-owned, project-owned, generated, evidence, projection, and public-repository-only paths.
- Specify public and downstream Git postures separately.
- Reserve portable_dropin as the public-boundary role without admitting it in the root manifest or changing root-profile validation.
- State the update-authority invariant that only core-owned paths may change and project-owned hashes must be preserved.

## Non-Goals

- No exporter, installer, updater, repository migration, or GitHub configuration.
- No portable_dropin admission or root-profile validator implementation; those belong solely to `public-distribution-portable-dropin-export`.
- No adoption or update implementation and no concrete project-owned hash-preservation proof; those belong solely to `public-distribution-downstream-core-delivery`.
- No classification of content as legally proprietary by path name.
- No automatic instance migration or additive-pack distribution.

## Adopted Decisions Captured

- **Sponsor decision:** Private workspace and public distribution are separate repositories.
- **Sponsor decision:** The public repository is a synthetic-history distribution mirror populated only from portable_dropin.
- **Sponsor decision:** Downstream projects own instance, inputs, state, generated outputs, evidence, and host projections.
- **Sponsor decision:** Core updates modify only explicitly core-owned paths.
- **Sponsor decision:** Base distribution contains zero additive packs.

## Superseded Approaches

- **Removed or superseded:** Using bootstrap_core, repo_snapshot, pack_bundle, full_fidelity, clone, mirror, subtree, or workspace history as the public boundary.
- **Removed or superseded:** Treating non-authoritative or generated material as publication-safe.
- **Removed or superseded:** Applying downstream artifact-consumer policy to the self-hosting framework workspace.

## Authority Boundary

This packet remains non-authoritative input. Durable authority can arise only
from separately reviewed implementation in the declared promotion targets.
Maintainer-only decisions and external effects remain explicit gates.

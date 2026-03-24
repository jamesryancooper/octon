---
title: Proposal Standard
description: Generic contract for temporary, non-canonical proposal artifacts under /.octon/inputs/exploratory/proposals/.
---

# Proposal Standard

## Purpose

Define the generic v1 contract for temporary, non-canonical proposals that may
promote into durable Octon or repo-local authority surfaces.

## Scope

- Applies to every manifest-governed proposal under `/.octon/inputs/exploratory/proposals/`.
- Subtype-specific requirements are defined in companion standards:
  - `design-proposal-standard.md`
  - `migration-proposal-standard.md`
  - `policy-proposal-standard.md`
  - `architecture-proposal-standard.md`

## Layout

- active proposals live at
  `/.octon/inputs/exploratory/proposals/<kind>/<proposal_id>/`
- archived proposals live at
  `/.octon/inputs/exploratory/proposals/.archive/<kind>/<proposal_id>/`
- `/.octon/generated/proposals/registry.yml` is the projection registry

Path rules:

- the final directory name must equal `proposal_id`
- packet numbering or other ordering prefixes are not part of the canonical
  proposal path
- no descendant-local or scope-local proposal workspace model exists in v1

Allowed `kind` values in v1:

- `design`
- `migration`
- `policy`
- `architecture`

## Authority

Manifest authority for every proposal:

1. `proposal.yml`
2. subtype manifest (`design-proposal.yml`, `migration-proposal.yml`,
   `policy-proposal.yml`, or `architecture-proposal.yml`)

Proposal-local navigation and supporting material follow after the manifests:

3. `navigation/source-of-truth-map.md`
4. subtype working documents
5. `navigation/artifact-catalog.md`
6. `/.octon/generated/proposals/registry.yml`
7. `README.md`

Rules:

- `proposal.yml` and the subtype manifest are the only lifecycle authorities.
- `navigation/source-of-truth-map.md` is the manual precedence and boundary map.
- `navigation/artifact-catalog.md` is generated inventory, not semantic
  authority.
- `/.octon/generated/proposals/registry.yml` is discovery-only and never
  authoritative over manifests.
- `README.md` is explanatory and never authoritative.

## Common Required Files

Every proposal must contain:

- `README.md`
- `proposal.yml`
- exactly one subtype manifest
- `navigation/artifact-catalog.md`
- `navigation/source-of-truth-map.md`
- optional `support/`

## Base Manifest Contract

`proposal.yml` must define:

- `schema_version`
- `proposal_id`
- `title`
- `summary`
- `proposal_kind`
- `promotion_scope`
- `promotion_targets`
- `status`
- `archive.archived_at`
- `archive.archived_from_status`
- `archive.disposition`
- `archive.original_path`
- `archive.promotion_evidence`
- `lifecycle.temporary`
- `lifecycle.exit_expectation`
- `related_proposals`

Allowed values:

- `schema_version`: `proposal-v1`
- `proposal_kind`: `design` | `migration` | `policy` | `architecture`
- `promotion_scope`: `octon-internal` | `repo-local`
- `status`: `draft` | `in-review` | `accepted` | `implemented` |
  `rejected` | `archived`
- `archive.archived_from_status`: `draft` | `in-review` | `accepted` |
  `implemented` | `rejected` | `legacy-unknown`
- `archive.disposition`: `implemented` | `rejected` | `historical` |
  `superseded`

Rules:

- `proposal_id` must match the final directory name.
- active and archived proposal package paths must use the exact
  `<kind>/<proposal_id>` layout with no numeric prefix in the directory name.
- `promotion_targets` must contain one or more repo-relative durable targets.
- `promotion_scope=octon-internal` requires every `promotion_target` to be
  under `.octon/`.
- `promotion_scope=repo-local` requires every `promotion_target` to be inside
  the repository but outside `.octon/` and `.octon/inputs/exploratory/proposals/`.
- active proposals may not mix `.octon/` and non-`.octon/` targets in one
  proposal and must instead be split into linked proposals via
  `related_proposals`.
- archived proposals may preserve historical mixed targets for provenance once
  the proposal has exited active lifecycle use.
- archived proposals with `archive.archived_from_status=legacy-unknown` may
  preserve historical mixed targets for provenance, but they may not return to
  active state without normalization.
- `legacy-unknown` archived design imports may remain on disk as historical
  lineage without appearing in the main generated proposal registry until they
  are normalized into the standard packet contract.
- `archive.*` fields are required when `status=archived` and forbidden
  otherwise.
- proposals in an archive path must use `status=archived`.
- proposals in an active path must not use `status=archived`.
- `archive.promotion_evidence` must be non-empty when
  `archive.disposition=implemented`.
- `lifecycle.temporary` must remain `true`.
- `lifecycle.exit_expectation` must be nested under `lifecycle`; a top-level
  `exit_expectation` field is invalid.

## Lifecycle Rule

Proposals move through one active lifecycle and one archive lifecycle:

1. `draft`
   - The proposal package exists at the active proposal path.
   - `proposal.yml`, subtype manifest, `README.md`, and navigation files exist.
   - The registry projection exists under
     `/.octon/generated/proposals/registry.yml` and is rebuilt from manifests.
   - Subtype-specific required files may still be placeholders unless the
     subtype standard says otherwise.
2. `in-review`
   - The proposal content is authored enough for substantive review.
   - Promotion targets, reading order, and subtype-specific required artifacts
     are explicit enough to evaluate the proposal without inventing missing
     artifact classes.
3. `accepted`
   - The proposal is approved as the temporary implementation or decision aid
     to use for promotion work.
   - Subtype-specific readiness rules for `accepted` status must be satisfied
     before this status is set.
4. `implemented` or `rejected`
   - `implemented` means the proposal's durable outputs have been promoted into
     the declared `promotion_targets`.
   - `rejected` means the proposal will not be promoted and is waiting for
     archival or historical retention handling.
5. `archived`
   - The proposal moves to `/.octon/inputs/exploratory/proposals/.archive/<kind>/<proposal_id>/`.
   - `archive.*` metadata records disposition, origin, and promotion evidence.

Rules:

- Proposals may not claim canonical authority at any lifecycle stage.
- Subtype standards define what content must exist before a proposal is
  considered review-ready or acceptance-ready.
- Promotion into durable authority must happen before archival when
  `archive.disposition=implemented`.
- After promotion, active canonical targets must stand on their own without
  dependencies on `/.octon/inputs/exploratory/proposals/` paths.
- Archived retained evidence or historical records may still reference proposal
  paths for provenance after the proposal leaves the active lifecycle.
- Proposal validation failures block proposal workflows and proposal-registry
  generation only; they do not block runtime unless a runtime surface illegally
  depends on proposal paths.

## Registry Contract

`/.octon/generated/proposals/registry.yml` must define:

- `schema_version`
- `active`
- `archived`

Each active entry must project:

- `id`
- `kind`
- `scope`
- `path`
- `title`
- `status`
- `promotion_targets`

Each archived entry must project:

- `id`
- `kind`
- `scope`
- `path`
- `title`
- `status`
- `disposition`
- `archived_at`
- `archived_from_status`
- `original_path`
- `promotion_targets`

Rules:

- The registry is a deterministic projection rebuilt from proposal manifests.
- Registry generation and validation fail closed on orphaned entries, duplicate
  `(kind, proposal_id)` collisions, path mismatches, kind mismatches, status
  mismatches, or invalid archive metadata.
- Manual registry edits are not a supported steady-state proposal operation.

## Non-Canonical Rule

Proposals are temporary implementation or decision aids. They are not canonical
runtime, documentation, policy, or contract authorities.

Implications:

- proposals may be archived or removed after promotion or rejection
- durable outputs must point to long-lived `/.octon/` or repo-native surfaces
- canonical targets must not retain dependencies on `/.octon/inputs/exploratory/proposals/` paths
- proposals are excluded from runtime resolution and policy resolution
- proposals are excluded from `bootstrap_core` and `repo_snapshot`

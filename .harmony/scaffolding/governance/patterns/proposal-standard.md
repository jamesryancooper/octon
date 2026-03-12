---
title: Proposal Standard
description: Generic contract for temporary, non-canonical proposal artifacts under /.proposals/.
---

# Proposal Standard

## Purpose

Define the generic v1 contract for temporary, non-canonical proposals that may
promote into durable Harmony or repo-local authority surfaces.

## Scope

- Applies to every manifest-governed proposal under `/.proposals/`.
- Subtype-specific requirements are defined in companion standards:
  - `design-proposal-standard.md`
  - `migration-proposal-standard.md`
  - `policy-proposal-standard.md`
  - `architecture-proposal-standard.md`

## Layout

- active proposals live at `/.proposals/<kind>/<proposal_id>/`
- archived proposals live at `/.proposals/.archive/<kind>/<proposal_id>/`
- `/.proposals/registry.yml` is the projection registry

Allowed `kind` values in v1:

- `design`
- `migration`
- `policy`
- `architecture`

## Authority

Authority order for every proposal:

1. `proposal.yml`
2. subtype manifest (`design-proposal.yml`, `migration-proposal.yml`,
   `policy-proposal.yml`, or `architecture-proposal.yml`)
3. `registry.yml`
4. `README.md`

`README.md` is explanatory and never authoritative.

## Common Required Files

Every proposal must contain:

- `README.md`
- `proposal.yml`
- `navigation/artifact-catalog.md`
- `navigation/source-of-truth-map.md`

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
- `promotion_scope`: `harmony-internal` | `repo-local`
- `status`: `draft` | `in-review` | `accepted` | `implemented` |
  `rejected` | `archived`
- `archive.archived_from_status`: `draft` | `in-review` | `accepted` |
  `implemented` | `rejected` | `legacy-unknown`
- `archive.disposition`: `implemented` | `rejected` | `historical`

Rules:

- `proposal_id` must match the final directory name.
- `promotion_targets` must contain one or more repo-relative durable targets.
- `promotion_scope=harmony-internal` requires every `promotion_target` to be
  under `.harmony/`.
- `promotion_scope=repo-local` requires every `promotion_target` to be inside
  the repository but outside `.harmony/` and `.proposals/`.
- mixed `.harmony/` and non-`.harmony/` targets are forbidden in one proposal
  and must instead be split into linked proposals via `related_proposals`.
- archived proposals with `archive.archived_from_status=legacy-unknown` may
  preserve historical mixed targets for provenance, but they may not return to
  active state without normalization.
- `archive.*` fields are required when `status=archived` and forbidden
  otherwise.
- `archive.promotion_evidence` must be non-empty when
  `archive.disposition=implemented`.
- `lifecycle.temporary` must remain `true`.

## Registry Contract

`/.proposals/registry.yml` must define:

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

## Non-Canonical Rule

Proposals are temporary implementation or decision aids. They are not canonical
runtime, documentation, policy, or contract authorities.

Implications:

- proposals may be archived or removed after promotion or rejection
- durable outputs must point to long-lived `/.harmony/` or repo-native surfaces
- canonical targets must not retain dependencies on `/.proposals/` paths

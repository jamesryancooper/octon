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

## Proposal-Local Lifecycle Sources

Lifecycle sources for every proposal:

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

- `proposal.yml` and the subtype manifest are the only proposal-local lifecycle
  sources.
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
- `support/implementation-grade-completeness-review.md` when the proposal is
  `in-review`, `accepted`, `implemented`, or an implemented archive
- `support/implementation-conformance-review.md` when the proposal is
  `implemented` or an implemented archive
- `support/post-implementation-drift-churn-review.md` when the proposal is
  `implemented` or an implemented archive
- optional additional `support/` material

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
- active and archived proposal packet paths must use the exact
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
   - The proposal packet exists at the active proposal path.
   - `proposal.yml`, subtype manifest, `README.md`, and navigation files exist.
   - The registry projection exists under
     `/.octon/generated/proposals/registry.yml` and is rebuilt from manifests.
   - Subtype-specific required files may still be placeholders unless the
     subtype standard says otherwise.
   - Draft validation may warn that implementation-grade completeness is not
     proven; that warning does not make scaffolding invalid.
2. `in-review`
   - The proposal content is authored enough for substantive review.
   - Promotion targets, reading order, and subtype-specific required artifacts
     are explicit enough to evaluate the proposal without inventing missing
     artifact classes.
   - `support/implementation-grade-completeness-review.md` exists and records
     either a passing gate receipt or the blockers/clarifications that prevent
     one.
3. `accepted`
   - The proposal is approved as the temporary implementation or decision aid
     to use for promotion work.
   - Subtype-specific readiness rules for `accepted` status must be satisfied
     before this status is set.
   - The Implementation-Grade Completeness Gate must pass before this status is
     set.
4. `implemented` or `rejected`
   - `implemented` means the proposal's durable outputs have been promoted into
     the declared `promotion_targets`.
   - `rejected` means the proposal will not be promoted and is waiting for
     archival or historical retention handling.
5. `archived`
   - The proposal moves to `/.octon/inputs/exploratory/proposals/.archive/<kind>/<proposal_id>/`.
   - `archive.*` metadata records disposition, origin, and promotion evidence.
   - Archives created after adoption of the Implementation-Grade Completeness
     Gate must retain the gate receipt when `archive.disposition=implemented`.
     Older archives that predate the gate are legacy evidence and may warn
     rather than fail only because of a missing receipt.

Rules:

- Proposals may not claim canonical authority at any lifecycle stage.
- Subtype standards define what content must exist before a proposal is
  considered review-ready or acceptance-ready.
- Promotion into durable authority must happen before archival when
  `archive.disposition=implemented`.
- After promotion, active canonical targets must stand on their own without
  dependencies on `/.octon/inputs/exploratory/proposals/` paths.
- A proposal may not claim `implemented`, close out, or archive with
  `archive.disposition=implemented` unless post-implementation conformance and
  drift/churn receipts pass, or the packet records explicit blockers that
  prevent closeout.
- Archived retained evidence or historical records may still reference proposal
  paths for provenance after the proposal leaves the active lifecycle.
- Historical archives may retain older mixed target-family records, including
  `.octon/**` and repo-local projections in one archived packet. New active
  proposal work must split those scopes.
- Proposal validation failures block proposal workflows and proposal-registry
  generation only; they do not block runtime unless a runtime surface illegally
  depends on proposal paths.
- No workflow, skill, final response, or lifecycle report may call a proposal
  `final`, `implementation-ready`, or `implementation-grade complete` unless
  its Implementation-Grade Completeness Gate receipt passes.
- No workflow, skill, final response, or lifecycle report may call a proposal
  `implemented`, `closed out`, or `archive-ready as implemented` unless all
  required post-implementation gate receipts pass, or the report records a
  blocked/deferred report outcome or a rejected/superseded/historical archive
  disposition instead of a successful closeout.
- `blocked` and `deferred` are lifecycle report outcomes, not
  `proposal.yml#status` values or `archive.disposition` values. Archive
  disposition remains limited to `implemented`, `rejected`, `historical`, and
  `superseded`.
- The legacy archive exception is inventory compatibility only. It does not
  permit active packets, newly accepted packets, implementation-prompt packets,
  or newly implemented archives to skip the receipt.

## Implementation-Grade Completeness Gate

Implementation-grade completeness is owned by the proposal lifecycle. The
operator should not need to ask whether a packet includes everything needed for
implementation.

A proposal is implementation-grade complete only when:

- the decision, target state, or migration end state is explicit;
- unresolved product questions are absent, or recorded as blockers that prevent
  a passing verdict;
- promotion targets are exhaustive for the declared scope and split into linked
  proposals when `.octon/**` and repo-local surfaces both need alignment;
- durable authority locations are named;
- every affected artifact has a current assumption, required change, ownership
  role, priority, and rationale;
- validators, fixtures, evidence, rollback, closeout, and downstream references
  are specified;
- implementation can start from the packet without inventing missing scope;
- no placeholder text, TODOs, stale assumptions, contradictions, or ambiguous
  target-state language remains in active proposal artifacts;
- repo-local projections, generated outputs, retained evidence, and
  proposal-local lifecycle-source boundaries are explicit.

The required receipt lives at
`support/implementation-grade-completeness-review.md` and must include:

- `verdict: pass|fail`
- `unresolved_questions_count`
- `clarification_required: yes|no`
- blockers
- assumptions made
- promotion target coverage
- affected artifact coverage
- validator coverage
- implementation prompt readiness
- exclusions
- final route recommendation

Clarifying questions are required only when the missing answer changes product
semantics, promotion scope, irreversible churn, or authority ownership. Agents
must proceed without questions when a missing detail is discoverable from the
repository or can be safely inferred and recorded as an assumption.

## Post-Implementation Gates

Post-implementation gates are owned by the proposal lifecycle and attach to the
implemented result, not to a PR, branch, or chat transcript.

The three gates are distinct:

- The Implementation-Grade Completeness Gate runs before implementation and
  proves the packet is complete enough to implement.
- The Implementation Conformance Gate runs after implementation and proves the
  repo changes satisfy the proposal packet.
- The Post-Implementation Drift/Churn Gate runs after conformance and proves
  the implementation did not introduce unintended drift, stale references,
  excess churn, broken projections, or target-family boundary violations.

Closeout, implemented status, and implemented archival are forbidden unless all
required gate receipts pass. If a gate cannot pass, the packet must record the
blocker and use a blocked/deferred report outcome or a
rejected/superseded/historical archive disposition instead of claiming
successful implementation.

Standalone post-implementation gates must enforce predecessor gates:

- the Implementation Conformance Gate must fail for implemented closeout unless
  the Implementation-Grade Completeness Gate passes;
- the Post-Implementation Drift/Churn Gate must fail for implemented closeout
  unless the Implementation Conformance Gate passes first.

When `support/executable-implementation-prompt.md` exists, implementation
readiness validation must verify that the prompt includes promotion targets,
validators, retained evidence, rollback, conformance receipt, drift/churn
receipt, and closeout refusal criteria. The prompt is generated operational
support; it does not replace the packet or its gate receipts.

### Implementation Conformance Gate

The required receipt lives at
`support/implementation-conformance-review.md` and must include:

- `verdict: pass|fail`
- `unresolved_items_count`
- blockers
- checked evidence
- promotion target coverage
- implementation map coverage
- validator coverage
- generated output coverage
- rollback coverage
- downstream reference coverage
- exclusions
- final closeout recommendation

The conformance gate must verify:

- every declared promotion target exists or has an explicit blocker;
- every affected artifact from the implementation map is covered;
- declared validators were run or explicitly blocked;
- generated outputs were refreshed or explicitly excluded;
- rollback notes are present;
- durable evidence supports the implemented result;
- downstream references were updated or explicitly excluded.

### Post-Implementation Drift/Churn Gate

The required receipt lives at
`support/post-implementation-drift-churn-review.md` and must include:

- `verdict: pass|fail`
- `unresolved_items_count`
- blockers
- checked evidence
- active proposal-path backreference scan
- naming drift review
- generated projection freshness
- manifest and schema validity
- repo-local projection boundary review
- target-family boundary review
- churn review
- validators run
- exclusions
- final closeout recommendation

The drift/churn gate must verify:

- promoted targets do not depend on active proposal paths;
- stale Work Package/Change terminology conflicts are absent or explicitly
  justified as legacy/compatibility text;
- generated registries and projections are fresh;
- manifests and schemas still validate;
- `.github/**` remains a linked repo-local projection target, not an
  octon-internal promotion target;
- `.octon/**` and repo-local target families are not mixed in one active
  proposal unless the scope is split into linked proposals;
- implementation churn is limited to the declared target families.

Legacy archived packets that predate these gates may warn rather than fail only
because the new receipts are missing. The exception is compatibility for
historical inventory, not permission to close out new work without the gates.

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

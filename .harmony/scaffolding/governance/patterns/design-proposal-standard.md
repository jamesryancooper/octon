# Design Proposal Standard

## Purpose

Define the standard for Harmony design proposals that must serve as temporary
but buildable end-to-end implementation blueprints.

This standard applies only to proposals that opt in with a root
`design-proposal.yml`.

## Scope And Rollout

- `design-proposal.yml` is the subtype marker for a manifest-governed design
  proposal.
- A standard-governed design proposal is still temporary implementation
  material. It is not a canonical runtime, documentation, policy, or contract
  authority.

Design proposals also project into `/.proposals/registry.yml`.

## Package Classes

Supported `package_class` values in v1:

- `domain-runtime`
- `experience-product`

## Core Artifact Set

Every standard-governed design proposal must contain:

- `README.md`
- `proposal.yml`
- `design-proposal.yml`
- `navigation/artifact-catalog.md`
- `navigation/source-of-truth-map.md`
- `implementation/README.md`
- `implementation/minimal-implementation-blueprint.md`
- `implementation/first-implementation-plan.md`

## Class-Specific Required Docs

### `domain-runtime`

- `normative/architecture/domain-model.md`
- `normative/architecture/runtime-architecture.md`
- `normative/execution/behavior-model.md`
- `normative/assurance/implementation-readiness.md`

### `experience-product`

- `normative/experience/user-journeys.md`
- `normative/experience/information-architecture.md`
- `normative/experience/screen-states-and-flows.md`
- `normative/assurance/implementation-readiness.md`

## Module Set

Allowed `selected_modules` values:

- `reference`
- `history`
- `contracts`
- `conformance`
- `canonicalization`

Default module behavior for the canonical `/create-design-proposal` workflow:

- every newly scaffolded design proposal includes `reference` and `history`
- `domain-runtime` proposals also include `contracts`, `conformance`, and
  `canonicalization` by default
- `experience-product` proposals do not include `contracts`, `conformance`, or
  `canonicalization` unless explicitly requested

Module requirements:

- `contracts`
  - `contracts/README.md`
  - `contracts/schemas/`
  - `contracts/fixtures/valid/`
  - `contracts/fixtures/invalid/`
- `conformance`
  - `conformance/README.md`
  - `conformance/scenarios/`
  - `validation.conformance_validator_path`
- `reference`
  - `reference/README.md`
- `history`
  - `history/README.md`
- `canonicalization`
  - `navigation/canonicalization-target-map.md`

## Subtype Manifest Contract

`design-proposal.yml` must define:

- `schema_version`
- `design_class`
- `selected_modules`
- `validation.default_audit_mode`
- `validation.design_validator_path`
- `validation.conformance_validator_path`

Allowed values:

- `schema_version`: `design-proposal-v1`
- `design_class`: `domain-runtime` | `experience-product`
- `validation.default_audit_mode`: `rigorous` | `short`

Contract rules:

- `design_validator_path` may be `null`.
- `conformance_validator_path` may be `null` only when the `conformance` module
  is not selected.

Schema path:

- `.harmony/scaffolding/runtime/templates/design-proposal.schema.json`
- `.harmony/scaffolding/runtime/templates/proposal-registry.schema.json`

## README Contract

Every standard-governed design proposal README must:

- describe the proposal as a `temporary, implementation-scoped design proposal`
- state that it is `not a canonical runtime, documentation, policy, or contract authority`
- include a `Promotion Targets` section
- include an `Exit Path` section

Archived design proposal READMEs must also:

- include `Status: \`archived\``
- include `Archive Disposition: \`implemented\``, `Archive Disposition: \`rejected\``, or
  `Archive Disposition: \`historical\``

The README may describe proposal-local reading order or precedence, but it must
not claim enduring repository authority.

## Proposal Lifecycle Rule

Standard-governed design proposals use the generic proposal lifecycle with the
following design-specific content gates:

1. `draft` means scaffold-complete, not implementation-ready.
   - The core artifact set exists.
   - The class-specific required docs exist.
   - `implementation/minimal-implementation-blueprint.md` and
     `implementation/first-implementation-plan.md` may still be placeholders.
   - The proposal is ready for content authoring and audit, not yet for
     implementation.
2. `in-review` means content-complete enough for real design review.
   - The class-specific normative docs contain the spec/PRD-equivalent design
     content for the package.
   - The implementation blueprint and first implementation plan reflect the
     current design rather than scaffold placeholders.
   - Every selected module contains the supporting material required by that
     module set.
3. `accepted` means implementation-ready temporary authority.
   - The readiness definition below is satisfied.
   - A competent engineer can implement the first slice without inventing
     architecture, contracts, runtime behavior, or validation expectations.
4. `implemented` means promotion-complete and archive-ready.
   - Durable targets have absorbed every required runtime, documentation,
     contract, schema, fixture, validator, or operator-guide artifact needed to
     stand on their own.
   - Canonical targets no longer depend on the proposal path.
5. `archived` means historical retention only.
   - The proposal has moved to the archive path with archive metadata and
     evidence recorded in `proposal.yml` and `/.proposals/registry.yml`.

Artifact classes in this lifecycle:

- proposal metadata and navigation:
  `proposal.yml`, `design-proposal.yml`, `README.md`,
  `navigation/artifact-catalog.md`, `navigation/source-of-truth-map.md`
- spec/PRD-equivalent design authority:
  class-specific `normative/` docs plus
  `implementation/minimal-implementation-blueprint.md` and
  `implementation/first-implementation-plan.md`
- default supporting context:
  `reference/README.md` and `history/README.md`
- conditional proof and promotion surfaces:
  `contracts/`, `conformance/`, and
  `navigation/canonicalization-target-map.md` when selected or required by the
  target promotion path

## Readiness Definition

A design proposal is only `accepted` when a competent engineer can derive, from
the proposal alone, the required:

- components or subsystems
- data structures and contracts
- algorithms or deterministic behaviors
- runtime model
- failure and recovery behavior
- validation expectations
- first implementation slice

without inventing architecture.

## Canonicalization Independence Rule

Durable promotion targets must stand on their own after promotion.

- Canonical runtime, documentation, governance, and validation artifacts must
  not retain references to `.proposals/design/<proposal_id>/` or
  `.proposals/.archive/design/<proposal_id>/`.
- If a promoted target needs a contract, schema, fixture, or operator guide
  that originated in the proposal, that artifact must be materialized into the
  durable target surface before merge.
- Temporary proposal provenance belongs in plans, PRs, receipts, or historical
  material, not in canonical target artifacts.

## Validation And Workflow Path

Standard-governed design proposals use a generic proposal validator plus a
design-specific validator stack.

Nested validator contract:

- paths in `validation.design_validator_path` and
  `validation.conformance_validator_path` resolve from the repository root
- shell validators must accept the package path as their first positional
  argument
- Python validators must accept the package path as their first positional
  argument

# Versioning And Compatibility Policy

## Purpose

Define how orchestration contracts evolve safely without breaking promoted
surfaces, tooling, or evidence linkage.

This document is normative for contract evolution.

## Scope

This policy governs all contracts under `contracts/`, especially:

- object contracts
- decision record contracts
- event envelope contracts
- linkage/reference contracts
- lifecycle-adjacent contract fields
- discovery and authority contracts

## Version Declaration Rule

Promoted orchestration contracts MUST declare a contract version using semantic
versioning:

`MAJOR.MINOR.PATCH`

Version declaration may live in:

- contract metadata/frontmatter, or
- the paired machine-readable schema artifact

Proposal-package documents do not need inline version fields yet, but any live
canonicalized contract must.

## Change Classification

### Breaking Change

A change is breaking if it:

- removes a field
- renames a field
- changes requiredness from optional to required
- changes field meaning
- changes lifecycle semantics in a way existing consumers cannot tolerate
- changes canonical source of truth
- changes routing, authority, or evidence semantics relied on by existing
  surfaces

### Non-Breaking Change

A change is non-breaking if it:

- clarifies wording only
- adds a new optional field
- adds a new non-authoritative projection field
- adds stricter documentation without changing behavior
- adds validation examples or reference material

## Allowed Evolution Patterns

### Object Contracts

Allowed non-breaking:

- add optional descriptive field
- add optional projection or diagnostic field
- add stricter examples

Breaking:

- add required field
- split one field into multiple required fields
- change ownership semantics

### Event Envelopes

Allowed non-breaking:

- add optional metadata field
- add optional payload refinement

Breaking:

- change `dedupe_key` meaning
- change event identity semantics
- change required fields in a way old consumers cannot parse

### Decision Records

Allowed non-breaking:

- add optional related-reference field
- add optional approval metadata

Breaking:

- rename `decision_id`
- change `allow|block|escalate` outcome semantics
- move canonical decision evidence outside continuity ownership

### Linkage And Reference Fields

Allowed non-breaking:

- add optional reverse-link field
- add optional correlation field

Breaking:

- rename canonical identifiers
- change required cross-surface references
- change source-of-truth ownership for linkage

### Queue Item Fields

Allowed non-breaking:

- add optional operator or diagnostic field

Breaking:

- change active lane semantics
- change meaning of claim or retry behavior
- change required target-routing field

### Lifecycle And State Additions

Allowed non-breaking only when:

- the new state is internal-only and not emitted to existing shared artifacts,
  or
- coexistence is explicitly version-gated and validated

Otherwise, lifecycle-state additions are breaking because fail-closed consumers
will treat unknown states as invalid.

## Deprecation Rules

1. Deprecation must be explicit.
2. Deprecated fields must name their replacement.
3. Deprecated fields must remain readable for at least one compatible minor
   cycle or rollout window.
4. During deprecation, producers should dual-write when safe.
5. Removal is a breaking change and requires major version increment.

## Backward And Forward Compatibility Expectations

### Readers

- must accept the same major version
- may accept newer minor versions if only additive/non-breaking changes exist
- must fail closed on unknown major versions

### Writers

- must emit one declared contract version
- must not silently emit a newer version to older consumers without rollout
  coordination

## Promotion And Rollout Expectations

Any contract change that affects promoted surfaces must:

1. classify the change as breaking or non-breaking
2. update validation logic
3. update reference examples if behavior changes
4. update assurance expectations if promotion gates change
5. record an ADR if the change is architecturally material

## Multi-Version Coexistence

If multiple contract versions coexist during rollout:

- version must be machine-readable
- readers must select behavior based on declared version
- validation must test all supported versions
- evidence linkage must preserve version traceability

## Special Rules For Discovery, Evidence, And Authority Changes

Changes affecting discovery, evidence, or authority are high sensitivity.

They require:

- explicit classification
- compatibility analysis
- assurance updates
- ADR review

Breaking examples:

- changing `manifest.yml` authority fields
- changing `run_id` linkage semantics
- changing which surface may launch or close another surface

## ADR Triggers

An ADR is required when a change:

- changes a contract major version
- changes a canonical identifier or linkage rule
- changes lifecycle state semantics
- changes discovery/source-of-truth layering
- changes evidence ownership or authority boundaries

## Validation Expectations

Validators should assert:

- version presence for promoted contracts
- compatibility class for the change
- prohibited breaking changes without major version bump
- dual-write or migration behavior during deprecation windows

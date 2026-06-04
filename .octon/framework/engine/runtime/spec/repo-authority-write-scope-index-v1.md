# Repo Authority And Write-Scope Index v1

Status: authored runtime spec

This spec defines deterministic compact artifacts that let lifecycle planning
and implementation routes inspect repo authority classes, proposal promotion
targets, and proposal-program child write scopes without repeatedly rereading
large proposal and topology surfaces.

The artifacts are advisory generated read models. They are not authority,
policy, support proof, authorization evidence, child-owned lifecycle receipts,
or replacements for raw proposal packets, run evidence, or generated-effective
handle validation.

## Generated Placement

The deterministic producer writes the bundle under:

`/.octon/generated/proposals/repo-authority/`

The bundle contains:

- `repo-authority-graph.yml`
- `promotion-target-index.yml`
- `write-scope-index.yml`

The producer is:

`/.octon/framework/assurance/runtime/_ops/scripts/generate-repo-authority-write-scope-index.sh`

The validator is:

`/.octon/framework/assurance/runtime/_ops/scripts/validate-repo-authority-write-scope-index.sh`

Generated bundle files remain derived-only. They may be read by lifecycle
context-pack assembly, proposal-program planning, implementation prompts,
verification prompts, and closeout review as compact orientation only after the
validator proves source freshness and authority-boundary posture.

## Source Inputs

The producer reads these source families:

- structural topology authority:
  `/.octon/framework/cognition/_meta/architecture/contract-registry.yml`
- constitutional precedence and obligation anchors:
  `/.octon/framework/constitution/precedence/normative.yml`
  `/.octon/framework/constitution/precedence/epistemic.yml`
  `/.octon/framework/constitution/obligations/fail-closed.yml`
  `/.octon/framework/constitution/obligations/evidence.yml`
- active proposal manifests under
  `/.octon/inputs/exploratory/proposals/<kind>/<proposal-id>/proposal.yml`
- proposal-program child registry, when present:
  discovered from proposal resources that declare a proposal-program child
  registry.

Proposal-local inputs remain non-authoritative lineage. They are included only
with source digests and source-class metadata so the compact artifacts can fail
closed when a source drifts.

## Artifact Contracts

`repo-authority-graph.yml` records:

- source refs and SHA-256 digests;
- repo class roots and steady-state surface classes;
- deterministic path classification rules;
- reader preferences and escalation triggers; and
- authority-boundary and failure-behavior facts.

`promotion-target-index.yml` records:

- active proposal refs and digests;
- declared promotion targets;
- target family and authority posture classification for each target;
- target-family boundary status and risk flags; and
- validators that must prove freshness and boundary preservation.

`write-scope-index.yml` records:

- proposal-program child ids, paths, phases, groups, dependencies, and route
  metadata;
- declared child write scopes and their target-family classification;
- child promotion targets when the child manifest is reachable; and
- coverage status comparing child promotion targets with declared write scopes.

## Required Boundary

Readers must fail closed when:

- a required source ref is missing;
- a recorded source digest no longer matches the source file;
- any bundle artifact is missing, unparsable, or has the wrong schema version;
- an artifact claims authority, authorizes execution, or replaces source
  evidence;
- generated, input, or state paths are classified as authored authority;
- a generated/read-model target is selected as a promotion target without
  being marked as derived/non-authority risk; or
- the target child is absent from the write-scope index when a proposal-program
  child route requests repo-graph context.

Reading the raw proposal body, full topology registry, or raw child registry is
allowed only for source digest mismatch, stale bundle, authority ambiguity,
validator dispute, context-pack audit, or equivalent escalation evidence.

## Token Posture

Default model-visible use should prefer the compact bundle and omit raw
proposal bodies. The producer estimates compact bundle size from retained
bytes and records reader preferences; token-budget ledgers may cite those
artifacts as deterministic byte-estimate evidence.

# Target Architecture

## Decision

Ratify memory as a routing and classification model and normalize every
memory-like artifact in `/.octon/` into one canonical home:

- memory policy lives only at `framework/agency/governance/MEMORY.md`
- durable shared context lives only at
  `instance/cognition/context/shared/**`
- durable scope context lives only at
  `instance/cognition/context/scopes/<scope-id>/**`
- durable ADR authority lives only at `instance/cognition/decisions/**`
- repo continuity lives only at `state/continuity/repo/**`
- scope continuity lives only at `state/continuity/scopes/<scope-id>/**`
- run evidence lives only at `state/evidence/runs/**`
- operational decision evidence lives only at `state/evidence/decisions/**`
- validation and migration evidence live only at
  `state/evidence/{validation,migration}/**`
- generated summaries, graphs, and projections live only at
  `generated/cognition/**`

Within that contract:

- no generic `memory/` directory exists or is introduced
- detailed active work state has one primary home
- operational decision evidence remains evidence and does not become ADR
  authority by importance alone
- generated cognition outputs stay explicitly non-authoritative
- the canonical generated ADR summary home is
  `generated/cognition/summaries/**`, not `instance/**`
- `instance/cognition/context/shared/decisions.md` is treated as migration
  drift while it remains a generated duplicate summary
- repo continuity migration still precedes scope continuity in any future
  rollout or repo adoption flow
- scope continuity remains legal only after locality registry and validation
  are live
- reset, compaction, retention, and regeneration behavior follow class-root
  ownership rather than the vague umbrella label of memory

The live repository already carries nearly all Packet 11 destination surfaces:
memory policy in `framework/**`, durable context and ADRs in `instance/**`,
continuity and evidence in `state/**`, and summaries/projections in
`generated/**`. Packet 11 is therefore normalization work. It closes the last
gaps by freezing one-home rules, removing the duplicate generated ADR summary
from `instance/**`, and aligning docs, validators, and scaffolds to the same
class-rooted contract.

## Status

- status: accepted proposal drafted from ratified Packet 11 inputs
- proposal area: memory routing, durable context placement, ADR authority,
  continuity ownership, operational decision evidence, derived cognition views,
  and migration from older mixed-path memory assumptions
- implementation order: 11 of 15 in the ratified proposal sequence
- dependencies:
  - `repo-instance-architecture`
  - `locality-and-scope-registry`
  - `state-evidence-continuity`
  - `generated-effective-cognition-registry`
- cross-packet contract sync:
  - `capability-routing-host-integration`
  - `validation-fail-closed-quarantine-staleness`
  - `migration-rollout`
- migration role: finish the move from packet-era mixed memory guidance to one
  class-rooted routing model without reintroducing duplicate ledgers or vague
  memory buckets

## Why This Proposal Exists

Octon still uses the word `memory` as an umbrella term, but the five-class
super-root does not benefit from treating memory as one filesystem surface.
The architecture is safer when it can answer five different questions with
five different classes:

- what is durable authored context?
- what is durable architecture authority?
- what is mutable active work state?
- what is retained operational evidence?
- what is only a derived inspection view?

Without Packet 11, teams can still drift into one or more of these failure
modes:

- a generic `memory/` directory that mixes policy, context, state, and
  generated views
- the same fact published as both durable authority and mutable state
- ADRs being confused with operational allow, block, or escalate records
- active continuity being mistaken for durable historical record
- generated summaries being copied into authored context and then treated as
  if they were authoritative

Packet 11 closes those gaps by turning memory into an enforceable routing
contract instead of a fuzzy label.

### Current Live Signals This Proposal Must Normalize

| Current live signal | Current live source | Ratified implication |
| --- | --- | --- |
| Memory policy already exists in framework governance | `/.octon/framework/agency/governance/MEMORY.md` | Packet 11 keeps memory policy in `framework/**` and does not move repo-owned content there |
| Shared memory routing guidance already exists in repo durable context | `/.octon/instance/cognition/context/shared/memory-map.md` | The memory map must remain a routing guide only and must stop implying parallel generated summaries inside `instance/**` |
| Repo and scope continuity already live under the state class root | `/.octon/state/continuity/**` | Packet 11 locks the one-primary-home rule and keeps repo-before-scope sequencing as the normative migration rule |
| Scope continuity is already live for `octon-harness` because locality registry and validation have already landed | `/.octon/state/continuity/scopes/octon-harness/**` and `/.octon/instance/locality/**` | The sequencing gate remains part of the contract for future migrations, but this repo has already satisfied it |
| Operational decision evidence already has a dedicated retained-evidence home | `/.octon/state/evidence/decisions/**` | Packet 11 preserves this as evidence rather than letting it drift into ADR authority or continuity state |
| ADR authority and discovery already live under the instance class root | `/.octon/instance/cognition/decisions/**` | Packet 11 keeps full decision authority here and keeps evidence bundles subordinate |
| Generated cognition summaries and projections already exist under `generated/**` | `/.octon/generated/cognition/**` | Packet 11 must keep them derived and non-authoritative in sync with Packet 10 |
| The repo still duplicates the generated ADR summary in both `instance/**` and `generated/**` | `/.octon/instance/cognition/context/shared/decisions.md` and `/.octon/generated/cognition/summaries/decisions.md` | Packet 11 must retire the `instance/**` duplicate and leave the summary canonically in `generated/cognition/summaries/**` only |
| ADR docs and context index still point at the old instance-local generated summary | `/.octon/instance/cognition/decisions/README.md` and `/.octon/instance/cognition/context/index.yml` | Packet 11 must align discovery docs with the generated-only summary home |

## Problem Statement

Octon needs one final memory and decision-surface architecture that is:

- explicit about which artifacts are durable repo authority
- explicit about which artifacts are mutable operational truth
- explicit about which artifacts are retained evidence
- explicit about which artifacts are derived views
- explicit about how repo and scope state relate without duplicating ledgers
- explicit about how operational evidence promotes to ADR authority
- explicit about retention, reset, compaction, and regeneration behavior

The architecture must answer all of the following operationally:

- where repo-wide durable context lives
- where scope-specific durable context lives
- where full ADR authority lives
- where the readable decision summary belongs
- where active repo continuity lives
- where active scope continuity lives
- where run receipts and validation receipts live
- where operational allow, block, and escalate records live
- what is safe to reset
- what is safe to regenerate
- what must never be duplicated

## Scope

- define the final routing of memory-like artifacts across `framework/**`,
  `instance/**`, `state/**`, and `generated/**`
- define canonical homes for durable context, ADRs, repo continuity, scope
  continuity, run evidence, operational decision evidence, validation
  evidence, and migration receipts
- distinguish durable authority from mutable truth, retained evidence, and
  generated views
- define the one-primary-home rule for active work state
- define promotion rules from operational decision evidence to ADRs
- define reset, compaction, retention, and regeneration implications
- define the live duplicate-summary drift that must be cleaned up
- define migration sequencing for repo continuity versus scope continuity
- define what downstream packet authors must treat as settled

## Non-Goals

- creating a generic `memory/` directory
- re-litigating the five-class super-root
- re-litigating raw proposal or raw extension placement
- treating state evidence as authored authority
- treating summaries, graphs, or projections as source-of-truth
- redefining locality cardinality
- creating descendant-local memory surfaces or sidecars
- moving ADRs into `state/**`
- making proposal packages part of the memory-routing model

## Canonical Memory Routing Contract

| Memory-like artifact family | Canonical path | Class root | Authority status | Live repo status |
| --- | --- | --- | --- | --- |
| Memory policy | `framework/agency/governance/MEMORY.md` | framework | authored policy | already live |
| Shared durable context | `instance/cognition/context/shared/**` | instance | authored authority | already live |
| Scope durable context | `instance/cognition/context/scopes/<scope-id>/**` | instance | authored authority | already live |
| ADRs | `instance/cognition/decisions/**` | instance | authored authority | already live |
| Repo continuity | `state/continuity/repo/**` | state | operational truth | already live |
| Scope continuity | `state/continuity/scopes/<scope-id>/**` | state | operational truth | already live for `octon-harness`; future migrations still follow the gating rule |
| Run evidence | `state/evidence/runs/**` | state | retained evidence | already live |
| Operational decision evidence | `state/evidence/decisions/**` | state | retained evidence | already live |
| Validation evidence | `state/evidence/validation/**` | state | retained evidence | already live |
| Migration receipts | `state/evidence/migration/**` | state | retained evidence | already live |
| Generated decision summaries | `generated/cognition/summaries/**` | generated | non-authoritative | already live, but still duplicated under `instance/**` |
| Generated graphs and projections | `generated/cognition/{graph,projections}/**` | generated | non-authoritative | partially materialized today and governed as derived output only |

### Memory Principle

Memory is not a directory in Octon. It is a classification problem.

Every memory-like artifact must route into exactly one of these classes:

- framework policy
- instance durable authority
- state operational truth or retained evidence
- generated derived view

That rule is what prevents memory from becoming a catch-all dumping ground.

### Durable Context Model

Durable context captures information that should survive across sessions,
remain authored, and stay owned by the repository.

Use:

- `instance/cognition/context/shared/**` for repo-wide durable context
- `instance/cognition/context/scopes/<scope-id>/**` for scope-bound durable
  context

Rules:

- durable context is authored and reviewable, not runtime-churned state
- `memory-map.md` remains a routing map, not an operational ledger
- `continuity.md` remains an optional signal file for append-only handling,
  not a continuity source-of-truth
- durable context may summarize stable knowledge but must not duplicate
  detailed continuity or evidence ledgers

### ADR Authority Model

Canonical ADR authority lives at:

```text
instance/cognition/decisions/**
```

ADRs are for decisions that:

- change architecture or contracts
- affect multiple scopes or repo-wide behavior
- alter class-root or subsystem boundaries
- should remain normative after the immediate operational episode ends

ADR rules:

- full decision authority remains in `instance/cognition/decisions/**`
- machine discovery continues through
  `instance/cognition/decisions/index.yml`
- supporting reports may live under
  `state/evidence/decisions/repo/reports/**` only as evidence
- generated decision summaries are helpful but never authoritative
- any generated decision summary published under `instance/**` is drift and
  must be removed or reclassified during cutover

The current `instance/cognition/context/shared/decisions.md` file is therefore
not a valid end state while it remains a generated ADR summary. The target
state keeps the summary only under `generated/cognition/summaries/**`.

### Continuity Model

Continuity is active resumable work state.

Canonical continuity paths are:

```text
state/continuity/repo/**
state/continuity/scopes/<scope-id>/**
```

Use repo continuity when the primary truth is:

- cross-scope
- orchestration-wide
- repo-wide
- not cleanly reducible to one scope

Use scope continuity when the primary truth is:

- clearly bound to one declared active scope
- best resumed from scope-local handoff state
- not required as repo-wide detailed operational truth

#### One-Primary-Home Rule

Detailed active state must have one primary home.

- repo-wide or cross-scope work gets its primary home in repo continuity
- clearly scope-bound work gets its primary home in matching scope continuity
- repo continuity may summarize or link scope-local work, but it must not
  duplicate the same detailed task, entity, or log ledger

#### Sequencing Rule

For migrations and new repo adoptions:

1. land repo continuity first
2. land locality registry and scope validation
3. only then land scope continuity

This repository already satisfies that prerequisite ordering because Packet 6
and Packet 7 have already materialized locality and scope continuity. The rule
remains normative for any future migration or downstream repo adoption.

### Operational Decision Evidence Model

Operational decisions are not ADRs.

Canonical path:

```text
state/evidence/decisions/**
```

Operational decision evidence includes:

- allow, block, and escalate records
- routing decisions
- approvals, waivers, and overrides
- temporary enforcement outcomes
- evidence explaining why an operation proceeded, halted, or deferred

Operational decision evidence is retained because it matters for traceability,
incident review, and auditability. It does not become architecture authority
just because it mattered operationally.

#### Promotion Rule

Promote operational decision evidence to an ADR only when all of these become
true:

- the decision changes durable architecture or contracts
- the decision affects multiple scopes or repo-wide normative behavior
- the decision should remain binding after the operational episode ends

Otherwise the artifact remains in `state/evidence/decisions/**`.

### Generated Summaries, Graphs, And Projections

Canonical generated cognition paths are:

```text
generated/cognition/summaries/**
generated/cognition/graph/**
generated/cognition/projections/**
```

Rules:

- these outputs are derived only
- they may summarize or join durable context, ADRs, continuity, and evidence
- they must never replace those sources as authority
- commit policy follows Packet 10, but committed outputs remain
  non-authoritative
- human-friendly summaries belong under `generated/cognition/summaries/**`,
  not under `instance/cognition/context/**`

### Reset, Compaction, Retention, And Regeneration Rules

- `state/continuity/**` may be compacted or reset through governed workflows
- `state/evidence/**` follows retention and archival policy and is not casual
  regeneration output
- `generated/**` may be deleted and rebuilt from canonical sources
- `instance/cognition/context/**` and `instance/cognition/decisions/**` must
  never be reset as if they were disposable runtime state
- any memory flush or compaction evidence required by `MEMORY.md` remains
  retained evidence under `state/evidence/validation/**`

## Validation And Failure Model

Validators must enforce all of the following:

- no generic `memory/` class root may be introduced
- no memory-like artifact may create an undeclared second source-of-truth
- ADRs may not be authored into `state/**`
- operational decision evidence may not be treated as an ADR surrogate
- generated cognition outputs may not be consumed as authoritative inputs
- generated ADR summaries may not persist inside `instance/**` after cutover
- scope continuity publication must fail closed if the scope binding is
  invalid or quarantined
- reset workflows must not delete durable context, ADRs, or retained evidence
- docs, indexes, and templates must not keep pointing at legacy mixed-path or
  duplicate-summary destinations

Packet 14 owns the final fail-closed implementation details. Packet 11 fixes
the routing contract that Packet 14 must enforce.

## Portability And Trust Implications

- `instance/cognition/context/**` and `instance/cognition/decisions/**` are
  repo-specific by default
- `state/**` is never part of `bootstrap_core` or `repo_snapshot`
- `generated/**` is rebuildable and therefore not the portability unit
- memory policy in `framework/agency/governance/MEMORY.md` remains portable
  with the framework bundle
- proposal artifacts are not part of the memory-routing model, even when they
  discuss future context or decisions
- extension trust and compatibility do not change the routing of memory
  classes

## Migration Framing

Packet 11 lands after the class-root, instance, locality, state, and
generated contracts are already in place. In this repository, that means the
remaining work is normalization rather than first introduction.

Required normalization steps are:

1. align `MEMORY.md`, the umbrella spec, `START.md`, the context index, and
   the shared memory map to the same class-root routing contract
2. retire `instance/cognition/context/shared/decisions.md` as a generated ADR
   summary and keep the canonical summary only at
   `generated/cognition/summaries/decisions.md`
3. update ADR and continuity docs so evidence bundles remain subordinate to
   ADR authority and continuity remains distinct from evidence
4. preserve repo continuity as the cross-scope primary home and keep scope
   continuity tied to valid scope bindings only
5. update validators, workflows, and scaffolds so the duplicate-summary drift
   and wrong-class placement cannot return
6. regenerate summaries, graphs, and projections from canonical sources once
   the routing contract lands

## Downstream Dependency Impact

This proposal is a prerequisite for:

- final cleanup of ADR summary publication and discovery
- Packet 12 capability-routing rules that consume cognition-derived outputs
  without inventing new authority surfaces
- Packet 14 fail-closed rules for duplicate ledgers, invalid scope continuity,
  and wrong-class memory placement
- Packet 15 migration cleanup of remaining packet-era memory drift

## Exit Condition

This proposal is complete only when durable architecture docs, validators,
workflow surfaces, and scaffolds all agree that memory is routing rather than
a directory, durable context and ADRs live only under `instance/**`, active
continuity and retained evidence live only under `state/**`, derived
cognition summaries and projections live only under `generated/**`, and the
repo no longer publishes a duplicate generated ADR summary under
`instance/**`.

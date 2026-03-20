# Packet 11 — Memory, Context, ADRs, and Operational Decision Evidence

**Proposal design packet for ratifying, normalizing, and implementing memory routing and decision surfaces inside Octon's five-class Super-Root architecture.**

## Status

- **Status:** Ratified design packet for proposal drafting
- **Proposal area:** Memory routing, durable context placement, ADR authority, continuity placement, operational decision evidence, derived summaries/graphs/projections, and migration from legacy mixed-tree memory placements
- **Implementation order:** 11 of 15 in the ratified proposal sequence
- **Primary outcome:** Ratify one canonical home for each memory-like artifact class so Octon can preserve durable repo authority in `instance/**`, keep mutable operational truth and retained evidence in `state/**`, keep derived views in `generated/**`, and prevent duplicate ledgers or vague "memory" buckets
- **Dependencies:** Packet 4 — Repo-Instance Architecture; Packet 6 — Locality and Scope Registry; Packet 7 — State, Evidence, and Continuity; Packet 10 — Generated / Effective / Cognition / Registry
- **Migration role:** Reclassify current memory-map, continuity, and decision surfaces into the ratified class-root model; move repo continuity before scope continuity; preserve ADR authority while moving operational decision evidence into `state/evidence/**`
- **Current repo delta:** The live repo still carries legacy memory-map and continuity guidance tied to older mixed-path placements such as `/.octon/continuity/**` and cognition runtime decision summaries. Packet 11 is the contract that finishes the move into the five-class Super-Root and removes ambiguity about what is durable authority, what is mutable operational truth, and what is merely derived.

> **Packet intent:** Define one authoritative routing model for memory-like artifacts so humans and tooling can answer, without ambiguity, what counts as durable context, what counts as architecture decision authority, what counts as active work state, what counts as retained operational evidence, and what counts only as a derived view.

## 1. Why this proposal exists

Octon uses the word **memory** as a useful umbrella, but the architecture does **not** benefit from treating memory as a single filesystem surface. The ratified blueprint instead treats memory as a **routing and classification model** that spans multiple classes:

- durable authored context
- durable architecture decision authority
- mutable active continuity
- retained operational evidence
- derived summaries, graphs, and projections

Packet 11 exists because the current and historical repository materials already show why this distinction matters. The memory map, continuity docs, ADR surfaces, and generated decision summaries all address related concerns, but they do so from older placements and with older naming assumptions. Without a final routing contract, teams will drift toward one or more of these failure modes:

- a vague generic `memory/` directory that mixes unrelated artifact classes
- duplicate ledgers where the same fact appears as both durable authority and mutable state
- ADRs being confused with operational decision evidence
- active continuity being treated like durable historical record
- derived summaries or graphs quietly acting like source-of-truth

Packet 11 closes those gaps and turns "memory" into an enforceable architectural contract.

## 2. Problem statement

Octon needs one final memory and decision-surface architecture that is:

- explicit about which artifacts are **durable repo authority**
- explicit about which artifacts are **mutable operational truth**
- explicit about which artifacts are **retained evidence**
- explicit about which artifacts are **derived views**
- explicit about how scope-bound state and decisions relate to repo-wide state and decisions
- explicit about promotion rules from operational evidence to ADR authority
- explicit about retention, reset, compaction, regeneration, and migration behavior

The architecture must answer all of the following operationally:

- Where does repo-wide durable context live?
- Where does scope-specific durable context live?
- Where do ADRs live, and what gives them authority?
- Where does active repo continuity live?
- Where does active scope continuity live?
- Where do run receipts and validation receipts live?
- Where do operational allow/block/escalate decisions live?
- Where do derived summaries and graph materializations live?
- What is safe to reset?
- What is safe to regenerate?
- What must never be duplicated?

## 3. Final target-state decision summary

- Memory remains a **routing and classification model**, not a generic directory.
- Framework memory policy lives at `framework/agency/governance/MEMORY.md`.
- Repo-shared durable context lives at `instance/cognition/context/shared/**`.
- Scope-specific durable context lives at `instance/cognition/context/scopes/<scope-id>/**`.
- ADRs live at `instance/cognition/decisions/**` and remain durable authored authority.
- Repo continuity lives at `state/continuity/repo/**`.
- Scope continuity lives at `state/continuity/scopes/<scope-id>/**`.
- Run evidence lives at `state/evidence/runs/**`.
- Operational decision evidence lives at `state/evidence/decisions/**`.
- Validation receipts live at `state/evidence/validation/**`.
- Migration receipts live at `state/evidence/migration/**`.
- Generated decision summaries live at `generated/cognition/summaries/**`.
- Graphs and projections live at `generated/cognition/**`.
- No generic `memory/` directory is introduced.
- No memory class may have two competing source-of-truth homes.
- Repo continuity migration lands before scope continuity.
- Scope continuity may not land until scope registry and scope validation are live.

## 4. Scope

This packet does all of the following:

- defines the final routing of memory-like artifacts across `framework/**`, `instance/**`, `state/**`, and `generated/**`
- defines canonical homes for durable context, ADRs, active continuity, run evidence, operational decision evidence, and derived decision views
- distinguishes durable authority from mutable truth and retained evidence
- defines one-primary-home rules for active work state
- defines promotion rules from operational decision evidence to ADRs
- defines reset, compaction, retention, and regeneration implications
- defines migration sequencing for repo continuity versus scope continuity
- defines what packet authors must treat as settled when writing downstream proposals

## 5. Non-goals

This packet does **not** do any of the following:

- create a generic `memory/` directory
- re-litigate the five-class Super-Root
- re-litigate proposal or extension placement
- make stateful evidence into authored authority
- make graphs, projections, or summaries into source-of-truth
- redefine locality or scope cardinality
- create descendant-local memory surfaces or local sidecars
- move ADRs into `state/**`
- make proposal archives part of the memory routing contract
- define graph ontology internals beyond their placement as derived outputs

## 6. Canonical paths and artifact classes

| Memory-like artifact family | Canonical path | Class root | Authority status | Notes |
|---|---|---|---|---|
| Memory policy | `framework/agency/governance/MEMORY.md` | framework | authored authority | Defines retention and class-routing rules |
| Shared durable context | `instance/cognition/context/shared/**` | instance | authored authority | Repo-wide durable context |
| Scope durable context | `instance/cognition/context/scopes/<scope-id>/**` | instance | authored authority | Scope-bound durable context |
| ADRs | `instance/cognition/decisions/**` | instance | authored authority | Durable architecture decisions |
| Repo continuity | `state/continuity/repo/**` | state | operational truth | Active cross-scope or repo-wide work state |
| Scope continuity | `state/continuity/scopes/<scope-id>/**` | state | operational truth | Active scope-bound work state |
| Run evidence | `state/evidence/runs/**` | state | retained evidence | Execution and run receipts |
| Operational decision evidence | `state/evidence/decisions/**` | state | retained evidence | Allow/block/escalate and routing evidence |
| Validation evidence | `state/evidence/validation/**` | state | retained evidence | Validator and enforcement receipts |
| Migration receipts | `state/evidence/migration/**` | state | retained evidence | Cutover and conversion trace |
| Generated decision summaries | `generated/cognition/summaries/**` | generated | non-authoritative | Human-friendly summaries |
| Generated graphs and projections | `generated/cognition/**` | generated | non-authoritative | Derived cognition views only |

## 7. Authority and boundary implications

- `instance/**` remains the canonical home for **durable repo-owned authored memory surfaces** such as context and ADRs.
- `state/**` remains the canonical home for **mutable operational truth** and **retained evidence**.
- `generated/**` remains the canonical home for **rebuildable derived memory views**.
- `framework/**` remains the home for **policy** about memory classes and retention, not for repo-specific memory content.
- No runtime or policy consumer may treat generated summaries, graphs, or projections as source-of-truth.
- No operator workflow may treat active continuity as if it were ADR authority.
- No ADR workflow may treat operational evidence as if it were a substitute for explicit architecture ratification.
- No memory-like artifact may quietly create a parallel source-of-truth ledger outside its class-rooted canonical home.

## 8. Ratified memory routing and decision model

### 8.1 Memory principle

Memory is not one thing in Octon. It is a classification problem.

The architectural rule is:

> Every memory-like artifact must be routed into exactly one of four classes: framework policy, instance authority, state truth/evidence, or generated view.

That rule is what prevents "memory" from becoming a vague dumping ground.

### 8.2 Durable context model

Durable context captures information that should survive across sessions and remain authored, reviewable, and repo-owned.

Use:

- `instance/cognition/context/shared/**` for repo-wide durable context
- `instance/cognition/context/scopes/<scope-id>/**` for scope-specific durable context

Durable context is **not** mutable operational state. It may evolve, but it does so through authored review, not through runtime churn.

Durable context also differs from proposals:

- proposals are exploratory inputs
- durable context is ratified repo authority

### 8.3 ADR model

ADRs remain the durable architecture decision surface.

Canonical path:

```text
instance/cognition/decisions/**
```

ADRs are for decisions that:

- change architecture or contracts
- affect multiple scopes
- alter the framework/instance boundary
- should remain durable long after the immediate operational episode is over

ADRs are **not** a dump for transient operator actions, validation outcomes, or one-off routing decisions.

### 8.4 Continuity model

Continuity is active resumable work state.

Canonical paths:

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

- clearly bound to one active scope
- best resumed from scope-local handoff state
- not required as repo-wide detailed operational truth

#### One-primary-home rule

Detailed active state must have **one primary home**.

- Repo-wide or cross-scope work gets its primary home in repo continuity.
- Clearly scope-bound work gets its primary home in scope continuity.
- Repo continuity may summarize or link scope-local work, but it must not duplicate the same detailed ledger.

### 8.5 Operational decision evidence model

Operational decisions are not the same thing as ADRs.

Canonical path:

```text
state/evidence/decisions/**
```

Operational decision evidence includes:

- allow/block/escalate records
- operational routing decisions
- temporary enforcement outcomes
- evidence used to explain why an operation proceeded, halted, or was deferred

Operational decision evidence is retained because it matters for traceability, but it does **not** become architecture authority just because it was important at runtime.

#### Promotion rule

Promote operational decision evidence to an ADR when all of these become true:

- the decision changes durable architecture or contracts
- the decision affects multiple scopes or repo-wide behavior
- the decision should remain normative after the operational episode ends

Otherwise it remains in `state/evidence/decisions/**`.

### 8.6 Generated summaries, graphs, and projections

Canonical paths:

```text
generated/cognition/summaries/**
generated/cognition/graph/**
generated/cognition/projections/**
```

These outputs are helpful, but they are not source-of-truth.

They may summarize:

- ADRs
- durable context
- continuity
- operational evidence

But they must never replace those sources.

### 8.7 Reset, compaction, and regeneration rules

- `state/continuity/**` may be reset or compacted under governed workflows.
- `state/evidence/**` is retained evidence and must follow retention/archival policy, not casual regeneration.
- `generated/**` may be deleted and rebuilt.
- `instance/cognition/context/**` and `instance/cognition/decisions/**` must never be reset as if they were disposable runtime state.

## 9. Retention and lifecycle implications

### Continuity

- Active, resumable, operator-facing
- Eligible for compaction and reset through explicit workflows

### Evidence

- Retained, append-oriented, traceability-focused
- Governed by retention and archival policy
- Not treated as disposable generated output

### Durable context

- Authored, reviewed, long-lived
- Updated intentionally, not churned by runtime

### ADRs

- Durable, append-governed architecture authority
- Only superseded by later authored decisions, never by runtime churn

### Generated views

- Rebuildable, non-authoritative, freshness-checked
- Deleted and rebuilt when stale or after source changes

## 10. Schema / manifest / contract changes required

This proposal requires updates to:

- the memory map contract
- continuity subsystem documentation and schemas
- ADR summary generation contract
- state evidence schema family for runs, decisions, validation, and migration
- migration tooling contracts for continuity rehoming
- any current docs that still point continuity or operational evidence at legacy `/.octon/continuity/**` placements
- any current docs that imply generated decision summaries are primary sources

## 11. Validation / assurance / fail-closed implications

Validators must enforce all of the following:

- no generic `memory/` class root may be introduced
- no memory-like artifact may create an undeclared second source-of-truth
- ADRs may not be authored into `state/**`
- operational decision evidence may not be treated as an ADR surrogate
- generated cognition outputs may not be consumed as authoritative inputs
- scope continuity may not exist without a valid scope registry and scope validation pipeline
- continuity reset workflows must not delete durable context, ADRs, or retained evidence by mistake

Fail-closed implications:

- invalid continuity schemas block continuity publication for the affected scope or repo layer
- invalid derived summaries or graph outputs do **not** change authoritative memory sources, but they should fail publication if consumed by tooling that requires freshness
- scope continuity publication must fail closed if the scope binding is invalid

## 12. Portability / compatibility / trust implications

- `instance/cognition/context/**` and `instance/cognition/decisions/**` are repo-specific by default.
- `state/**` is never part of default bootstrap or repo snapshot export.
- `generated/**` is rebuildable and therefore not the primary portability unit.
- Memory policy in `framework/agency/governance/MEMORY.md` is portable as part of the framework bundle.
- Proposal artifacts are not part of the memory routing model, even when they discuss future context or architecture changes.
- Extension trust and compatibility do not change the routing of memory classes; extension state belongs to the extension control model, not to a generic memory bucket.

## 13. Migration / rollout implications

Migration must proceed in this order:

1. Ratify class-root semantics and manifests.
2. Rehome generated outputs into `generated/**`.
3. Move **repo continuity** into `state/continuity/repo/**`.
4. Move retained evidence into `state/evidence/**`.
5. Land `instance/cognition/context/**` and `instance/cognition/decisions/**` as the durable authority surfaces.
6. Introduce locality registry and scope validation.
7. Only then introduce **scope continuity** into `state/continuity/scopes/<scope-id>/**`.
8. Regenerate summaries, graphs, and projections from canonical sources.

### Critical sequencing rule

Do **not** land scope continuity before the scope registry and scope validation are live.

That sequencing is now ratified and is not optional.

## 14. Dependencies on other proposals

Hard dependencies:

- **Packet 4 — Repo-Instance Architecture**
- **Packet 6 — Locality and Scope Registry**
- **Packet 7 — State, Evidence, and Continuity**
- **Packet 10 — Generated / Effective / Cognition / Registry**

Cross-packet contract sync:

- **Packet 12 — Capability Routing and Host Integration**
- **Packet 14 — Validation, Fail-Closed, Quarantine, and Staleness**

## 15. Suggested implementation order

Packet 11 should be implemented **11 of 15** in the ratified proposal sequence, after the class-root, instance, locality, state, and generated contracts are already in place.

## 16. Acceptance criteria

This packet is complete when all of the following are true:

- every memory-like artifact class has one canonical home
- no generic `memory/` directory exists
- ADRs live only under `instance/cognition/decisions/**`
- operational decision evidence lives only under `state/evidence/decisions/**`
- repo continuity lands before scope continuity
- scope continuity is blocked until scope registry and validation exist
- generated summaries, graphs, and projections are explicitly non-authoritative
- documentation no longer points memory-like artifacts at legacy mixed-tree placements as if they were final
- reset and regeneration workflows are class-correct and cannot casually destroy durable context or retained evidence

## 17. Supporting evidence to reference

Reference these materials when drafting the full proposal:

- ratified Super-Root blueprint sections on memory, state, locality, and generated outputs
- current `/.octon/cognition/runtime/context/memory-map.md`
- current `/.octon/continuity/README.md`
- current generated summary or decisions-summary surfaces
- current runtime-vs-ops contract
- any migration tooling or conversion receipts that move continuity and evidence into class-rooted placement

## 18. Settled decisions that must not be re-litigated

- memory remains a routing/classification model
- no generic `memory/` surface is introduced
- durable repo-specific authority belongs in `instance/**`
- mutable operational truth and retained evidence belong in `state/**`
- generated summaries, graphs, and projections belong in `generated/**`
- zero-or-one active `scope_id` per path remains the v1 locality rule
- scope continuity does not land before locality registry and validation
- ADRs remain durable authored authority and are not moved into `state/**`

## 19. Remaining narrow open questions, if any

None.

This packet is fully ratified for proposal drafting and implementation planning.

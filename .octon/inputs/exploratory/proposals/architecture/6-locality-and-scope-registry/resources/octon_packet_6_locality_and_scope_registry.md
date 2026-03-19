# Packet 6 — Locality and Scope Registry

**Proposal design packet for ratifying, normalizing, and implementing the root-owned locality and scope registry model inside Octon's five-class Super-Root architecture.**

## Status

- **Status:** Ratified design packet for proposal drafting
- **Proposal area:** Root-owned locality model, scope identity, scope registry placement, scope manifest contract, generated locality outputs, and scope-aware migration sequencing
- **Implementation order:** 6 of 15 in the ratified proposal sequence
- **Primary outcome:** Make locality a repo-owned, machine-enforceable scope system under `instance/locality/**` without descendant-local harness roots, hierarchical scope inheritance, or ambiguous path composition
- **Dependencies:** Packet 1 — Super-Root Semantics and Taxonomy; Packet 2 — Root Manifest and Behaviorally Complete Profile Model; Packet 4 — Repo-Instance Architecture; Packet 5 — Overlay and Ingress Model
- **Migration role:** Establish the canonical scope registry and validation boundary before scope continuity, scope-aware capability routing, and scope-index generation land
- **Current repo delta:** The live repo already exposes `/.octon/instance/locality/manifest.yml` and `/.octon/instance/locality/registry.yml`, and `instance/manifest.yml` already binds locality into the repo-instance layer; this packet ratifies and completes that direction rather than inventing a new locality mechanism

> **Packet intent:** define the final contract for locality as a root-owned scope model so Octon can localize durable context, active work, routing hints, and mission references without descendant `.octon/` roots, hierarchical scope inheritance, or ad hoc path conventions.

## 1. Why this proposal exists

The ratified Super-Root blueprint preserves locality as a first-class architectural concern, but it rejects every topology that would express locality through additional harness roots, local sidecars, or ancestor-chain scope composition. Packet 6 exists to make the replacement explicit: **locality in Octon is a repo-owned scope registry living under `instance/locality/**`, resolved through one authoritative manifest-defined pipeline, and compiled into generated effective views.**

The current repository is already moving in that direction. The live repo now exposes:

- `/.octon/instance/locality/manifest.yml`
- `/.octon/instance/locality/registry.yml`
- `/.octon/instance/manifest.yml` with locality bindings and a `single-active-scope` resolution mode

At the same time, the live locality principle and the live skills architecture both still enforce the single-root harness rule and explicitly reject descendant `.octon/` roots on one repository ancestor chain. That means Packet 6 is not speculative. It is the ratification layer that turns today's mixed state—principles, partial files, and migration scaffolding—into one final contract.

Without a ratified locality packet, teams will continue to answer the wrong questions informally:

- Where does locality live under the Super-Root?
- How is a `scope_id` identified and validated?
- What exactly makes a path “inside” a scope?
- Can one scope bind multiple unrelated roots?
- How do generated effective locality indexes relate to the authoritative registry?
- Where do scope-local durable context and scope-local continuity live, and when do they become legal to create?
- How do missions relate to scopes without becoming a second locality system?

Packet 6 closes those questions.

## 2. Problem statement

Octon needs a final locality model that is:

- **single-root compatible**
- **machine-enforceable**
- **deterministic at path resolution time**
- **compatible with the five-class Super-Root**
- **clear about repo-owned authority versus generated outputs**
- **safe under migration and fail-closed behavior**
- **simple enough for operators to understand without reading multiple architecture documents at once**

The architecture must solve a genuine tension.

The live locality principle still says locality matters: context should live close to the work, domain-specific knowledge should be loaded selectively, and scoped work should avoid global soup. But the same live principle also says locality is implemented through repo-root harness paths and that descendant `.octon/` roots are unsupported. That means Octon needs a locality mechanism that is strong enough to express scoped ownership and context without reopening multi-root harness topology. The scope registry is that mechanism.

### Current baseline signals that trigger this proposal

**Single-root locality rule is already active.** The live locality principle explicitly rejects descendant `.octon/` roots and says one `.octon/` may exist on a repository ancestor chain. The live skills architecture says the same thing. That means Packet 6 must keep locality root-owned and must not invent local harnesses.

**Repo-instance locality scaffolding already exists.** `instance/manifest.yml` already binds locality through `registry_path` and `manifest_path`, while `instance/locality/manifest.yml` already declares `resolution_mode: single-active-scope`. Packet 6 therefore ratifies repo-instance locality control metadata rather than inventing a new control plane.

**The current scope registry scaffold is present but empty.** `instance/locality/registry.yml` already exists and currently declares an empty scope list. Packet 6 must define the final scope contract and the migration path from that empty registry scaffold to a populated authoritative registry.

**The ratified blueprint already depends on scope identity downstream.** Scope-local durable context belongs under `instance/cognition/context/scopes/**`, scope-local continuity belongs under `state/continuity/scopes/**`, and scope-aware capability routing consumes scope metadata. Packet 6 must therefore land before those downstream packets become operational.

## 3. Final target-state decision summary

- Locality is represented by a **root-owned scope model** under `instance/locality/**`.
- `instance/locality/manifest.yml` and `instance/locality/registry.yml` are authoritative repo-owned control metadata.
- Each scope is declared at `instance/locality/scopes/<scope-id>/scope.yml`.
- In v1, each `scope_id` has exactly **one** `root_path`.
- In v1, a target path resolves to **zero or one** active `scope_id`.
- In v1, overlapping active scopes are invalid.
- In v1, hierarchical scope inheritance, ancestor-chain composition, and descendant-local harness roots are rejected.
- Scope-local durable context lives under `instance/cognition/context/scopes/<scope-id>/**`.
- Scope-local active continuity lives under `state/continuity/scopes/<scope-id>/**`, but it may land only after locality registry and validation are live.
- Missions may reference one or more `scope_id`s, but missions do not define or replace locality.
- Runtime-facing locality views are compiled into `generated/effective/locality/**` and never become source-of-truth.
- Quarantine state for invalid scopes lives under `state/control/locality/quarantine.yml`.

## 4. Scope

This packet does all of the following:

- defines the final placement of locality and scope registry artifacts
- defines the authoritative scope manifest contract
- defines v1 scope cardinality and resolution semantics
- defines where scope-local durable context and scope-local active continuity attach
- defines the relationship between scopes and missions
- defines generated effective locality outputs
- defines validator expectations and fail-closed/quarantine behavior for invalid scope state
- defines migration sequencing constraints for repo continuity versus scope continuity

## 5. Non-goals

This packet does **not** do any of the following:

- re-litigate the five-class Super-Root
- re-litigate whether locality is root-owned
- introduce descendant `.octon/` roots or local sidecars
- introduce hierarchical or ancestor-chain scope inheritance in v1
- permit multi-root `scope_id` definitions in v1
- define detailed capability-routing weighting logic
- define detailed memory routing semantics beyond the locality-specific placements this packet constrains
- define detailed generated-output commit policy beyond the locality outputs already ratified in the blueprint

## 6. Canonical paths and artifact classes

**`instance/locality/manifest.yml`**  
Class: Instance  
Authority: authoritative control metadata  
Purpose: declares locality schema version, registry path, and resolution mode

**`instance/locality/registry.yml`**  
Class: Instance  
Authority: authoritative control metadata  
Purpose: inventory of declared scopes and repo-level locality metadata

**`instance/locality/scopes/<scope-id>/scope.yml`**  
Class: Instance  
Authority: authoritative authored  
Purpose: canonical definition of a single scope

**`instance/cognition/context/scopes/<scope-id>/**`**  
Class: Instance  
Authority: authoritative authored  
Purpose: scope-specific durable context

**`state/continuity/scopes/<scope-id>/**`**  
Class: State  
Authority: operational truth  
Purpose: scope-specific active work state

**`generated/effective/locality/scopes.effective.yml`**  
Class: Generated  
Authority: non-authoritative  
Purpose: runtime-facing effective scope map

**`generated/effective/locality/artifact-map.yml`**  
Class: Generated  
Authority: non-authoritative  
Purpose: mapping from effective scope entries back to authoritative source paths

**`generated/effective/locality/generation.lock.yml`**  
Class: Generated  
Authority: non-authoritative  
Purpose: freshness receipt for locality compilation

**`state/control/locality/quarantine.yml`**  
Class: State  
Authority: operational control truth  
Purpose: mutable quarantine record for invalid scopes

## 7. Authority and boundary implications

- Locality is a **repo-instance authoritative** concern. It belongs in `instance/**`, not in `framework/**`, `state/**`, `generated/**`, or `inputs/**`.
- `instance/locality/**` is the source-of-truth for scope identity and path binding.
- `generated/effective/locality/**` is derived and never authoritative.
- `state/control/locality/quarantine.yml` is mutable operational control state, not authored authority.
- Scope-local durable context remains authored authority under `instance/**`.
- Scope-local active continuity remains mutable operational truth under `state/**`.
- Missions may reference scopes but must not become a second source of locality truth.
- No scope definition may introduce a second `.octon/` root, a sidecar locality root, or a chain-composed child scope system.

## 8. Ratified locality and scope model

### 8.1 Canonical locality structure

```text
instance/locality/
  manifest.yml
  registry.yml
  scopes/
    <scope-id>/
      scope.yml
```

### 8.2 Scope manifest contract

Each `scope.yml` must declare at least:

- `scope_id`
- `display_name`
- `root_path`
- optional `include_globs`
- optional `exclude_globs`
- `owner`
- `status`
- `tech_tags`
- `language_tags`
- optional `routing_hints`
- optional `mission_defaults`

### 8.3 Ratified v1 cardinality rule

In v1:

- each `scope_id` has exactly **one** `root_path`
- one path resolves to **zero or one** active scope
- multiple disjoint roots for one `scope_id` are rejected
- overlapping active scopes are rejected

`include_globs` and `exclude_globs` may refine the rooted subtree. They may not redefine the scope into multiple unrelated roots.

### 8.4 Resolution model

For a target path, Octon resolves locality in this order:

1. resolve the repo super-root
2. load `octon.yml`
3. load `instance/manifest.yml`
4. load `instance/locality/manifest.yml`
5. load `instance/locality/registry.yml`
6. resolve the applicable `scope_id`, if any
7. publish and consume `generated/effective/locality/**`

If more than one active scope matches a target path, locality resolution fails and the affected scope state is quarantined.

### 8.5 Scope-local artifacts

#### Scope-local durable context

Canonical placement:

```text
instance/cognition/context/scopes/<scope-id>/**
```

#### Scope-local active continuity

Canonical placement:

```text
state/continuity/scopes/<scope-id>/**
```

Scope continuity is downstream of locality and must not be introduced before the locality registry and scope validation pipeline are live.

### 8.6 Missions and scopes

Missions remain valid orchestration containers under:

```text
instance/orchestration/missions/**
```

A mission may reference one or more `scope_id`s, but it does not define scope identity, scope ownership, or scope precedence. Missions are time-bounded work containers; scopes are stable locality bindings.

### 8.7 Explicitly rejected locality models

The following are rejected in v1:

- descendant-local `.octon/` roots
- local sidecar or capsule locality systems
- hierarchical scope inheritance
- ancestor-chain composition
- disjoint multi-root scopes
- mission-defined locality as a substitute for the registry

## 9. Schema, manifest, and contract changes required

### `instance/locality/manifest.yml`

Must be ratified as required and authoritative. It must carry at least:

- `schema_version`
- `registry_path`
- `resolution_mode`

Ratified v1 `resolution_mode` value:

- `single-active-scope`

### `instance/locality/registry.yml`

Must be ratified as the authoritative registry root. It must carry at least:

- `schema_version`
- `scopes`
- optional repo-level locality metadata if later needed by schema extension

### `scope.yml`

Must be ratified as the canonical per-scope manifest. Packet 6 defines the minimum required fields listed above.

### Related contracts that must be updated

- root README and architecture docs to describe locality through the scope registry rather than mixed domain-path conventions alone
- memory/context packet to bind scope-specific context to the instance layer
- state/evidence/continuity packet to bind scope continuity to `state/**`
- capability-routing packet to consume scope metadata from authoritative locality manifests and generated effective outputs rather than ad hoc path conventions
- validation packet to define locality quarantine semantics and stale generated locality output handling

## 10. Validation, assurance, and fail-closed implications

Validation must enforce all of the following:

- `instance/locality/manifest.yml` must exist and be schema-valid
- `instance/locality/registry.yml` must exist and be schema-valid
- every declared scope entry must resolve to a valid `scope.yml`
- every `scope_id` must be unique
- every `scope.yml` must declare exactly one `root_path` in v1
- no two active scopes may overlap for a target path
- `include_globs` and `exclude_globs` must remain subordinate to the declared `root_path`
- generated effective locality outputs must carry source digests, schema version, and generation timestamp
- runtime-facing consumers must fail closed on stale or invalid generated locality outputs
- invalid scope state must quarantine locally rather than silently falling back to ambiguous resolution

### Quarantine semantics

Canonical mutable quarantine location:

```text
state/control/locality/quarantine.yml
```

A quarantined scope is unavailable for runtime-facing scope resolution and downstream scope-bound state publication until the locality problem is fixed and a fresh effective generation is published.

## 11. Portability, compatibility, and trust implications

- `instance/locality/**` is repo-specific by default and excluded from `bootstrap_core`.
- `instance/locality/**` is included in `repo_snapshot` because it is required for behaviorally complete repo reproduction.
- Scope definitions do not travel with the framework core bundle.
- `generated/effective/locality/**` is rebuildable and excluded from bootstrap and repo snapshot by default.
- Locality currently has no separate trust tier model in v1; it inherits the repo-instance authoritative trust boundary.
- Locality compatibility is governed by the root manifest and the locality schema version rather than by extension-pack compatibility contracts.

## 12. Migration and rollout implications

### Migration work authorized by this packet

- ratify `instance/locality/manifest.yml` as the authoritative locality control manifest
- ratify `instance/locality/registry.yml` as the authoritative scope inventory
- define and enforce the `scope.yml` schema and one-root-per-scope rule
- convert any legacy domain-local placement assumptions into explicit shared vs scope-local context placement under `instance/cognition/context/**`
- add generated effective locality outputs under `generated/effective/locality/**`
- add locality quarantine control state under `state/control/locality/**`
- bind missions to scopes by reference where needed, without allowing missions to define scope identity

### Important sequencing rules

Packet 6 must land after:

- Packet 1 — Super-Root Semantics and Taxonomy
- Packet 2 — Root Manifest and Behaviorally Complete Profile Model
- Packet 4 — Repo-Instance Architecture
- Packet 5 — Overlay and Ingress Model

Packet 6 must land before:

- Packet 7 — State, Evidence, and Continuity (scope continuity placement)
- Packet 12 — Capability Routing and Host Integration (scope-aware routing inputs)
- Packet 14 — Validation, Fail-Closed, Quarantine, and Staleness (full locality validation/quarantine integration)
- Packet 15 — Migration and Rollout (removal of legacy mixed-path locality assumptions)

### Explicit sequencing rule for continuity

- move **repo continuity** into `state/continuity/repo/**` first
- ratify and validate locality under `instance/locality/**`
- only then introduce **scope continuity** under `state/continuity/scopes/**`

## 13. Dependencies and suggested implementation order

- **Dependencies:** Packet 1 — Super-Root Semantics and Taxonomy; Packet 2 — Root Manifest and Behaviorally Complete Profile Model; Packet 4 — Repo-Instance Architecture; Packet 5 — Overlay and Ingress Model
- **Suggested implementation order:** 6
- **Blocks:** scope continuity, scope-aware capability routing, locality quarantine finalization, and migration removal of legacy mixed-path locality assumptions

## 14. Acceptance criteria

- `instance/locality/manifest.yml`, `instance/locality/registry.yml`, and `instance/locality/scopes/<scope-id>/scope.yml` are ratified as the canonical locality surfaces.
- The v1 rule of **exactly one `root_path` per `scope_id`** is explicit and validator-enforced.
- The v1 rule of **zero or one active `scope_id` per path** is explicit and validator-enforced.
- Overlapping active scopes fail closed and quarantine locally.
- Descendant-local `.octon/` roots, hierarchical scope inheritance, ancestor-chain composition, and multi-root scopes are explicitly rejected.
- Scope-local durable context is explicitly located under `instance/cognition/context/scopes/**`.
- Scope-local continuity is explicitly located under `state/continuity/scopes/**`, but only after locality registry and validation are live.
- Missions are explicitly defined as scope-referencing orchestration containers rather than a second locality system.
- Generated effective locality outputs are explicitly defined and freshness-protected.
- Teams no longer need to infer how locality works from mixed domain-path conventions or mission structure alone.

## 15. Supporting evidence to reference

- Current `/.octon/instance/manifest.yml` — live instance-side locality binding and `single-active-scope` direction
- Current `/.octon/instance/locality/manifest.yml` — live locality manifest scaffold
- Current `/.octon/instance/locality/registry.yml` — live empty scope registry scaffold
- Current `/.octon/cognition/governance/principles/locality.md` — root-owned locality principle and rejection of descendant harness roots
- Current `/.octon/capabilities/_meta/architecture/architecture.md` — one `.octon/` per ancestor chain and root-owned skill authority model
- Ratified Super-Root blueprint — sections on locality, state/evidence/continuity, generated outputs, routing, validation, and migration sequencing

Reference URLs:

- <https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/manifest.yml>
- <https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/locality/manifest.yml>
- <https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/locality/registry.yml>
- <https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/cognition/governance/principles/locality.md>
- <https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/capabilities/_meta/architecture/architecture.md>
- <https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/octon.yml>

## 16. Settled decisions that must not be re-litigated

- Locality is root-owned and belongs under `instance/**`.
- There is no descendant-local `.octon/` topology.
- There is no local capsule or local sidecar locality system.
- v1 rejects hierarchical scope inheritance.
- v1 rejects ancestor-chain scope composition.
- v1 rejects multi-root scopes.
- Scope-local context attaches under `instance/**`.
- Scope-local continuity attaches under `state/**`.
- Generated effective locality outputs remain non-authoritative.
- Missions may reference scopes but may not replace the locality registry.

## 17. Remaining narrow open questions

None. This packet is ratified for proposal drafting and ready to move into formal architecture proposal authoring.

# Packet 4 — Repo-Instance Architecture

**Proposal design packet for ratifying, normalizing, and completing the `instance/**` class root as Octon's repo-specific durable authoritative layer inside the five-class Super-Root architecture.**

## Status

- **Status:** Ratified design packet for proposal drafting
- **Proposal area:** Repo-instance authoritative layer, canonical ingress, durable repo authority placement, repo-native capability placement, and instance-side control metadata
- **Implementation order:** 4 of 15 in the ratified proposal sequence
- **Primary outcome:** Make `instance/**` the canonical home for durable repo-owned authority and remove ambiguity about what belongs there versus `framework/**`, `state/**`, `inputs/**`, and `generated/**`
- **Dependencies:** Packet 1 — Super-Root Semantics and Taxonomy; Packet 2 — Root Manifest, Profiles, and Export Semantics
- **Migration role:** Complete the repo-instance side of the Super-Root cutover so later work on overlays, locality, state, extensions, proposals, generated outputs, and migration can rely on a stable repo-owned authority boundary
- **Current repo delta:** The live repo already exposes `instance/manifest.yml`, `instance/ingress/AGENTS.md`, `instance/extensions.yml`, and `instance/locality/registry.yml`; this packet ratifies and completes the repo-instance layer rather than inventing it from scratch

> **Packet intent:** define the final contract for `instance/**` so Octon can preserve repo-specific durable authority across framework updates, keep ingress and repo-local architecture artifacts in one canonical home, and stop relying on mixed-tree assumptions about what the "repo-owned" part of `.octon/` actually is.

## 1. Why this proposal exists

Packet 1 ratified the five-class Super-Root and Packet 2 ratified the root manifest and profile model. Packet 4 exists because those decisions only become operational once Octon has a precise definition of the **repo-instance authoritative layer**.

The live repository has already moved materially toward this target. The current `/.octon/README.md` now describes `.octon/` as a class-first Super-Root. The live `octon.yml` already declares class roots, profile-driven portability, and release/API version metadata. The repo also already contains `instance/manifest.yml`, canonical internal ingress at `instance/ingress/AGENTS.md`, `instance/extensions.yml`, and a locality registry scaffold at `instance/locality/registry.yml`. The framework overlay registry also already points at repo-instance overlay-capable locations for governance, agency, and assurance. That means the repo-instance layer is no longer hypothetical. It is partially landed. What remains is to ratify and normalize it as the canonical home for durable repo-owned authority and to retire the remaining mixed-tree assumptions that still survive in legacy documents and placement habits.

Without a ratified repo-instance packet, teams will continue to answer the wrong questions informally:

- What belongs in `instance/**` versus `framework/**`?
- Which repo-owned artifacts are durable authority versus mutable state?
- Which repo-specific surfaces are native instance artifacts versus overlay-capable surfaces?
- Where do canonical ingress and bootstrap artifacts live?
- How should repo-native capabilities be distinguished from reusable extension packs?
- How should framework updates behave without trampling repo-local context, decisions, or control metadata?

This packet closes those gaps.

## 2. Problem statement

Octon needs a repo-owned durable authority layer that is:

- **architecturally explicit**
- **reviewable in Git**
- **preserved across framework updates**
- **separate from portable framework/core**
- **separate from mutable state and retained evidence**
- **separate from rebuildable generated outputs**
- **separate from raw additive and exploratory inputs**

The current repo is in a **transitional class-first state**. Some repo-instance structures already exist in the ratified form, while some architectural expectations are still only partially spelled out. If Octon does not ratify what the instance class means, repo-local durable authority will continue to drift: some content will remain embedded in legacy mixed paths, some repo-owned control artifacts will be mistaken for state, and overlay-capable paths will be improvised instead of machine-enforced.

### Current baseline signals that trigger this proposal

| Current baseline signal | Observed current-state source | Migration implication |
|---|---|---|
| `/.octon/README.md` now describes `.octon/` as a class-first Super-Root | `/.octon/README.md` | Packet 4 must treat `instance/**` as already emerging, not purely hypothetical |
| `octon.yml` now declares class roots, harness release version, extension API version, and profile semantics | `/.octon/octon.yml` | Packet 4 must align repo-instance durability and portability with the root manifest contract |
| `instance/manifest.yml` already exists and declares instance identity, enabled overlay points, locality bindings, and feature toggles | `/.octon/instance/manifest.yml` | Packet 4 must ratify this file as the instance companion manifest rather than invent a competing control file |
| Canonical internal ingress already exists under `instance/ingress/AGENTS.md` | `/.octon/instance/ingress/AGENTS.md` | Packet 4 must ratify internal ingress placement and treat repo-root adapters as thin projections only |
| `instance/extensions.yml` already exists and already uses the ratified one-file desired configuration split (`selection`, `sources`, `trust`, `acknowledgements`) | `/.octon/instance/extensions.yml` | Packet 4 must treat desired extension configuration as repo-owned authority rather than raw pack metadata |
| `instance/locality/registry.yml` already exists | `/.octon/instance/locality/registry.yml` | Packet 4 must place locality under repo-owned durable authority, not under framework or state |
| `framework/overlay-points/registry.yml` already references repo-instance overlay-capable paths | `/.octon/framework/overlay-points/registry.yml` | Packet 4 must distinguish instance-native surfaces from overlay-capable surfaces and reserve detailed overlay merge semantics for Packet 5 |

## 3. Final target-state decision summary

- `instance/**` is the **repo-specific durable authoritative layer** of the Super-Root.
- `instance/**` contains repo-owned authored authority that must survive framework updates and state resets.
- `instance/**` contains canonical internal ingress, bootstrap guidance, locality/scope registry, repo context, ADRs, repo-native capabilities, missions, and desired extension configuration.
- `instance/**` may also contain overlay-capable surfaces, but only where the framework overlay registry declares them and the instance manifest enables them.
- `instance/**` must never contain mutable continuity, retained evidence, rebuildable generated outputs, raw extension packs, or raw proposals.
- `instance/manifest.yml` is the required repo-instance companion manifest.
- `instance/ingress/AGENTS.md` is the canonical internal ingress surface. Repo-root ingress adapters are thin adapters only.
- `instance/extensions.yml` is the authoritative desired extension configuration surface.
- `instance/**` is excluded from `bootstrap_core`, included in `repo_snapshot`, and preserved across framework updates unless an explicit migration contract says otherwise.
- Repo-native capabilities remain allowed under `instance/capabilities/runtime/**` when they are truly repo-specific and not intended as reusable additive packs.

## 4. Scope

- Define what the repo-instance class is.
- Define what belongs in `instance/**`.
- Define what does **not** belong in `instance/**`.
- Ratify `instance/manifest.yml` as the instance companion manifest.
- Ratify canonical internal ingress placement.
- Distinguish instance-native surfaces from overlay-capable surfaces.
- Define repo-instance portability/update semantics at a high level.
- Define repo-instance validation expectations and wrong-class placement rules.
- Provide the canonical boundary that later proposals on overlays, locality, state, extensions, proposals, generated outputs, and migration rely on.

## 5. Non-goals

- Detailed overlay merge semantics for each overlay point (Packet 5).
- Detailed locality registry schema beyond the repo-instance placement and responsibility split (Packet 6).
- Detailed extension desired/actual/quarantine/compiled mechanics (Packet 8).
- Detailed proposal schema (Packet 9).
- Detailed state/evidence retention rules (Packet 7).
- Detailed generated-output schema or commit policy mechanics (Packet 10).
- Re-litigating whether the super-root should remain five-class.
- Re-litigating whether raw packs and proposals live under `inputs/**`.

## 6. Canonical paths and artifact classes

| Canonical path | Class | Authority status | Purpose |
|---|---|---|---|
| `instance/manifest.yml` | Instance | Authoritative control metadata | Repo-instance identity, framework binding, enabled overlay points, locality binding, feature toggles |
| `instance/ingress/AGENTS.md` | Instance | Authoritative authored | Canonical internal ingress for this repository's harness |
| `instance/bootstrap/**` | Instance | Authoritative authored | Repo bootstrap docs, objective, scope, conventions, and catalog guidance |
| `instance/locality/**` | Instance | Authoritative authored | Repo-local locality manifest, registry, and scope definitions |
| `instance/cognition/context/**` | Instance | Authoritative authored | Repo-shared and scope-specific durable context |
| `instance/cognition/decisions/**` | Instance | Authoritative authored | Durable architecture decision records (ADRs) |
| `instance/capabilities/runtime/**` | Instance | Authoritative authored | Repo-native capabilities that are not reusable additive packs |
| `instance/orchestration/missions/**` | Instance | Authoritative authored | Repo-owned mission definitions and orchestration artifacts |
| `instance/extensions.yml` | Instance | Authoritative control metadata | Desired extension configuration, sources, trust, and acknowledgements |
| `instance/governance/policies/**` | Instance | Authoritative only when overlay-bound | Repo-specific governance policy overlays at declared framework overlay points |
| `instance/governance/contracts/**` | Instance | Authoritative only when overlay-bound | Repo-specific governance contract overlays at declared framework overlay points |
| `instance/agency/runtime/**` | Instance | Authoritative only when overlay-bound | Repo-specific agency runtime overlays at declared framework overlay points |
| `instance/assurance/runtime/**` | Instance | Authoritative only when overlay-bound | Repo-specific assurance runtime overlays at declared framework overlay points |

## 7. Authority and boundary implications

- `instance/**` is the **repo-owned durable authoritative layer** of the Super-Root.
- `instance/**` is not the place for portable framework/core assets. Those belong in `framework/**`.
- `instance/**` is not the place for mutable continuity, retained evidence, or quarantine/control state. Those belong in `state/**`.
- `instance/**` is not the place for generated effective views, graphs, projections, summaries, or registries. Those belong in `generated/**`.
- `instance/**` is not the place for raw extension packs or raw proposals. Those belong in `inputs/**`.
- `instance/**` contains both **instance-native** repo-owned surfaces and **overlay-capable** surfaces. Overlay-capable placement is legal only when the framework overlay registry declares it and the instance manifest enables it.
- `instance/extensions.yml` is authored desired configuration. It is not derived operational state.
- Canonical internal ingress belongs under `instance/ingress/**`; repo-root ingress files are adapters only and must not become a second authority surface.
- Repo-native capabilities under `instance/capabilities/runtime/**` must remain repo-specific. Reusable add-ons belong in `inputs/additive/extensions/**`.

## 8. Schema, manifest, and contract changes required

### `instance/manifest.yml`

Packet 4 ratifies `instance/manifest.yml` as required and authoritative. It must carry at least:

- `schema_version`
- `instance_id`
- `framework_id`
- `enabled_overlay_points`
- `locality` bindings
- `feature_toggles`

The live repo already contains this file. Packet 4 turns that existing file from emerging implementation shape into canonical contract.

### Related contracts that must be updated

- root README guidance for repo-instance bootstrap and update semantics
- umbrella specification references to repo-instance canonical locations
- ingress/read-order guidance so canonical internal ingress is rooted under `instance/ingress/**`
- downstream overlay contract (Packet 5) so overlay-capable instance paths are machine-enforceable
- locality packet (Packet 6) so scope registry placement is bound to the instance class
- memory/context/decisions packet (Packet 11) so durable context and ADR routing target `instance/**`

## 9. Ratified repo-instance architecture

### What belongs in `instance/**`

The repo-instance class contains durable repo-owned authority and control metadata, including:

- canonical internal ingress
- repo bootstrap docs and objective/scope/conventions/catalog artifacts
- locality/scope manifest and registry
- repo-shared durable context
- scope-specific durable context
- ADRs
- repo-native capabilities that are not reusable packs
- missions and repo-owned orchestration artifacts
- desired extension configuration and trust/acknowledgement metadata
- overlay-capable repo-owned surfaces where explicitly declared by the framework overlay registry

### What does **not** belong in `instance/**`

These artifacts are explicitly out of bounds for the repo-instance class:

- repo continuity and scope continuity
- run evidence
- operational decision evidence
- validation or migration receipts
- quarantine/control state
- generated effective catalogs
- graphs, projections, summaries, or registries
- raw extension pack payloads
- raw proposals or proposal archives

### Instance-native versus overlay-capable surfaces

#### Instance-native surfaces

These are canonical repo-owned authority and do **not** rely on framework overlay points:

- `instance/manifest.yml`
- `instance/ingress/**`
- `instance/bootstrap/**`
- `instance/locality/**`
- `instance/cognition/context/**`
- `instance/cognition/decisions/**`
- `instance/capabilities/runtime/**`
- `instance/orchestration/missions/**`
- `instance/extensions.yml`

#### Overlay-capable surfaces

These are repo-owned surfaces that are only valid when a declared overlay point exists and is enabled:

- `instance/governance/policies/**`
- `instance/governance/contracts/**`
- `instance/agency/runtime/**`
- `instance/assurance/runtime/**`

Detailed merge modes, precedence, and validators belong to Packet 5. Packet 4 only ratifies the canonical homes and the fact that these are not blanket shadow trees.

### Canonical ingress and bootstrap model

- Canonical internal ingress lives at `instance/ingress/AGENTS.md`.
- Canonical bootstrap docs live at `instance/bootstrap/**`.
- Repo-root `AGENTS.md` or other tool-facing adapters may exist, but they are projections or thin adapters only.
- The instance layer is therefore the canonical home for repo-local ingress and onboarding content, while the repo root remains an adapter surface for host tooling when necessary.

## 10. Validation, assurance, and fail-closed implications

Validation must enforce these rules for the repo-instance class:

- no wrong-class placement of mutable state or retained evidence into `instance/**`
- no generated outputs treated as repo-instance source-of-truth
- no raw `inputs/**` dependencies in repo-instance runtime or policy paths
- `instance/manifest.yml` must be present and schema-valid
- ingress must resolve to canonical internal content under `instance/ingress/**`
- `instance/extensions.yml` must be schema-valid and must not be mistaken for actual active state
- overlay-capable instance artifacts are invalid when they are not covered by a declared enabled overlay point
- repo-native capabilities under `instance/capabilities/runtime/**` must not silently duplicate pack ids or collide with enabled extension contributions without declared collision policy

## 11. Portability, compatibility, and update implications

- `instance/**` is **repo-specific by default** and is excluded from `bootstrap_core` except for the minimal `instance/manifest.yml` seed.
- `instance/**` is included in `repo_snapshot` because it is required for behaviorally complete repo reproduction.
- `instance/**` is preserved across framework updates unless an explicit migration contract applies.
- Framework updates must not directly rewrite repo context, repo ADRs, repo bootstrap artifacts, or repo ingress as a normal update path.
- Repo-specific overlays under `instance/**` are governed by instance manifest enablement and framework-declared overlay points rather than by raw path shadowing.
- Desired extension configuration is repo-specific and travels with the repo snapshot, not with the framework bundle.
- Repo-native capabilities under `instance/**` are repo-owned and do not become portable framework assets by implication.

## 12. Migration and rollout implications

Packet 4 lands after the root taxonomy and manifest/profile model because the repo-instance class depends on both.

### Migration work authorized by this packet

- inventory all current repo-owned durable authoritative artifacts that belong in `instance/**`
- move or alias canonical ingress into `instance/ingress/**`
- move or alias repo bootstrap files into `instance/bootstrap/**`
- bind `instance/manifest.yml` into the canonical architecture contract
- ratify `instance/extensions.yml` as desired extension configuration rather than derived state
- move repo-local durable context and ADRs into canonical `instance/cognition/**` locations
- prepare overlay-capable instance paths so Packet 5 can land machine-enforced overlay rules without path churn
- ensure later packets treat `instance/**` as the durable repo-owned layer rather than as an informal catch-all

### Important sequencing rule

Packet 4 must land before:

- Packet 5 overlay and ingress enforcement
- Packet 6 locality and scope registry ratification
- Packet 7 state/evidence/continuity cutover
- Packet 8 extension desired/actual/compiled pipeline ratification
- Packet 11 memory/context/decision routing finalization

## 13. Dependencies and suggested implementation order

- **Dependencies:** Packet 1 — Super-Root Semantics and Taxonomy; Packet 2 — Root Manifest, Profiles, and Export Semantics
- **Suggested implementation order:** 4
- **Blocks:** overlay/ingress contract finalization, locality ratification, state cutover, extension desired-state contract finalization, and later migration packet specifics

## 14. Acceptance criteria

- `instance/**` is explicitly defined as the repo-specific durable authoritative layer.
- `instance/manifest.yml` is ratified as required and authoritative.
- Canonical internal ingress is explicitly located under `instance/ingress/**`.
- The canonical repo-instance contents are explicitly listed and enforced by class-boundary rules.
- Mutable state, retained evidence, raw inputs, and generated outputs are explicitly excluded from `instance/**`.
- Repo-native capabilities are allowed under `instance/capabilities/runtime/**` only when they are genuinely repo-specific.
- `instance/extensions.yml` is clearly defined as desired extension configuration rather than active state.
- Overlay-capable instance paths are explicitly identified and reserved for Packet 5's detailed enforcement contract.
- `repo_snapshot` can reproduce repo-owned durable authority without relying on raw whole-tree copy semantics.

## 15. Supporting evidence to reference

- Current `/.octon/README.md` — already documents `.octon/` as a class-first Super-Root and points to canonical ingress and profile-driven portability.
- Current `/.octon/octon.yml` — already binds class roots, release/API versions, and profile semantics.
- Current `/.octon/instance/manifest.yml` — already declares instance identity, enabled overlay points, locality bindings, and feature toggles.
- Current `/.octon/instance/ingress/AGENTS.md` — already defines canonical internal ingress and read order.
- Current `/.octon/instance/extensions.yml` — already uses the ratified one-file desired extension configuration split.
- Current `/.octon/instance/locality/registry.yml` — already exists as the locality registry scaffold.
- Current `/.octon/framework/overlay-points/registry.yml` — already declares overlay-capable instance paths for governance, agency, and assurance.
- Ratified Super-Root blueprint — sections on repo-instance architecture, overlay model, locality, portability, and migration sequencing.

Reference URLs:

- <https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/README.md>
- <https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/octon.yml>
- <https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/manifest.yml>
- <https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/ingress/AGENTS.md>
- <https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/extensions.yml>
- <https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/instance/locality/registry.yml>
- <https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/overlay-points/registry.yml>
- <https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/cognition/_meta/architecture/specification.md>

## 16. Settled decisions that must not be re-litigated

- `instance/**` remains inside the super-root.
- The top-level target state remains class-first rather than mixed-tree or externalized.
- `instance/**` is the repo-specific durable authoritative layer.
- `state/**` is the mutable operational truth/evidence layer.
- `generated/**` is the rebuildable non-authoritative layer.
- Raw packs and raw proposals do **not** belong in `instance/**`.
- Canonical internal ingress belongs under `instance/ingress/**`.
- `instance/extensions.yml` remains the one-file desired configuration surface in v1.
- Overlay-capable instance paths are only valid at declared framework overlay points.
- Descendant-local `.octon/` roots, `.octon.global/`, `.octon.graphs/`, and a generic `memory/` directory remain rejected.

## 17. Remaining narrow open questions

None. This packet is ratified for proposal drafting and is ready to be turned into the formal architectural proposal.

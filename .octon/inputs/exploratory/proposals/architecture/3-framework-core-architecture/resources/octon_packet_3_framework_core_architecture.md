# Packet 3 — Framework/Core Architecture

**Proposal design packet for formalizing, completing, and normalizing the `framework/**` class root as the portable authored Octon core inside the ratified Super-Root architecture.**

## Status

- **Status:** Ratified design packet for proposal drafting
- **Proposal area:** Portable framework/core bundle, framework boundaries, framework companion manifest, and framework-side overlay registry binding
- **Implementation order:** 3 of 15 in the ratified proposal sequence
- **Primary outcome:** Make `framework/**` the canonical portable authored core bundle and remove ambiguity about what does and does not belong in the framework class
- **Dependencies:** Packet 1 — Super-Root Semantics and Taxonomy; Packet 2 — Root Manifest, Profiles, and Export Semantics
- **Migration role:** Complete the framework side of the Super-Root cutover so later work on overlays, locality, state, extensions, proposals, and generated outputs can rely on a stable portable core boundary

> **Packet intent:** define the final framework/core contract for the Super-Root so Octon can update portable authored core safely, preserve repo-specific authority in `instance/**`, and stop relying on mixed-tree assumptions about what the "shared" or "portable" part of `.octon/` actually is.

## 1. Why this proposal exists

Packet 1 ratified the five-class Super-Root and Packet 2 ratified the root manifest and profile model. Packet 3 exists because those decisions only become operational once Octon has a precise definition of the **portable framework/core layer**.

The live repository has already moved materially toward this target. The current `/.octon/README.md` now describes `.octon/` as a **class-first Super-Root**. The live `octon.yml` already declares class roots, release/API version metadata, and profile-style semantics. The repo also already contains `framework/manifest.yml`, a class-first umbrella specification under `framework/cognition/_meta/architecture/specification.md`, and `framework/overlay-points/registry.yml`. That means the framework layer is no longer hypothetical. It is partially landed. What remains is to ratify and normalize it as the portable authored core bundle and to retire the remaining mixed-tree assumptions that still survive in legacy documents such as `shared-foundation.md`.

Without a ratified framework packet, teams will continue to answer the wrong questions informally:

- What belongs in `framework/**` versus `instance/**`?
- Which framework artifacts are part of the portable bundle?
- Which framework subtrees may be overlaid by `instance/**`?
- Which framework `_ops/` assets are portable helpers versus repo-state leakage?
- How should framework updates behave in already-adopted repositories?

This packet closes those gaps.

## 2. Problem statement

Octon needs a portable authored core that is:

- **architecturally explicit**
- **reviewable in Git**
- **safe to install and update**
- **separate from repo-owned durable authority**
- **separate from mutable state**
- **separate from generated outputs**
- **separate from raw additive and exploratory inputs**

The current repo is in a **transitional mixed state**. Some framework/core structures already exist in the ratified form, while some legacy architectural guidance still describes the older domain-first, path-allowlist model. If Octon does not ratify what the framework class means, the super-root will remain vulnerable to quiet drift: repo-local content will slip into `framework/**`, or framework-owned portable content will be left scattered across `instance/**` or legacy mixed paths.

### Current baseline signals that trigger this proposal

| Current baseline signal | Observed current-state source | Migration implication |
|---|---|---|
| `.octon/README.md` now describes `.octon/` as a class-first Super-Root | `/.octon/README.md` | Packet 3 must treat `framework/**` as already emerging, not purely hypothetical |
| `octon.yml` now declares class roots, harness release version, extension API version, and profiles | `/.octon/octon.yml` | Packet 3 must align framework packaging with the root manifest contract |
| `framework/manifest.yml` already exists and declares framework identity, subsystems, generators, and overlay registry binding | `/.octon/framework/manifest.yml` | Packet 3 must ratify this file as the framework companion manifest rather than invent a competing control file |
| `framework/overlay-points/registry.yml` already exists | `/.octon/framework/overlay-points/registry.yml` | Packet 3 must treat framework overlay binding as a framework concern, with detailed overlay rules delegated to the overlay packet |
| The umbrella specification already lives under `framework/**` and is class-first | `/.octon/framework/cognition/_meta/architecture/specification.md` | Packet 3 must build on the already-landed framework contract |
| `shared-foundation.md` still describes the older capability-category mixed-tree model and portable allowlist approach | `/.octon/cognition/_meta/architecture/shared-foundation.md` | Packet 3 must explicitly retire or supersede the legacy framework-portability mental model |

## 3. Final target-state decision summary

- `framework/**` is the **portable authored Octon core**.
- `framework/**` remains **domain-organized internally** even though the super-root is class-first at the top level.
- `framework/**` contains only portable authored core assets and portable helper assets needed to ship, validate, and update the core bundle.
- `framework/**` must never contain repo-specific durable authority, mutable operational truth, retained evidence, raw extension packs, raw proposals, or generated outputs.
- `framework/manifest.yml` is the required framework companion manifest.
- `framework/overlay-points/registry.yml` is the canonical registry of framework-declared overlay points.
- Overlay-capable behavior is allowed only where Packet 5's overlay contract declares it; Packet 3 only ratifies that framework owns the registry and the base contract.
- `bootstrap_core` installs `framework/**` plus minimal root/instance seed metadata, not repo-specific authority or state.
- Framework updates touch `framework/**`, root version bindings, and explicit migration contracts only. They do not directly rewrite repo continuity, repo context, repo ADRs, or proposals as a normal update path.
- Legacy mixed-tree framework narratives, especially the old "portable paths" model in `shared-foundation.md`, must be retired, rewritten, or clearly marked historical.

## 4. Scope

- Define what the framework class is.
- Define what belongs in `framework/**`.
- Define what does **not** belong in `framework/**`.
- Ratify `framework/manifest.yml` as the framework companion manifest.
- Ratify `framework/overlay-points/registry.yml` as the framework-owned overlay registry.
- Define framework-side portability/update semantics.
- Define framework-side validation expectations and wrong-class placement rules.
- Provide the canonical boundary that later proposals on overlays, portability, routing, and migration rely on.

## 5. Non-goals

- Detailed overlay merge semantics for each overlay point (Packet 5).
- Detailed extension pack schema (Packet 8).
- Detailed proposal schema (Packet 9).
- Detailed state/evidence retention rules (Packet 7).
- Detailed generated-output schemas (Packet 10).
- Re-litigating whether the super-root should remain five-class.
- Re-litigating whether extensions and proposals live under `inputs/**`.

## 6. Canonical paths and artifact classes

| Canonical path | Class | Authority status | Purpose |
|---|---|---|---|
| `framework/manifest.yml` | Framework | Authoritative control metadata | Framework identity, version, supported instance schema range, overlay registry binding, bundled generators |
| `framework/overlay-points/registry.yml` | Framework | Authoritative control metadata | Declared overlay-capable framework extension points |
| `framework/agency/**` | Framework | Authoritative authored | Portable agency governance and runtime foundations |
| `framework/capabilities/**` | Framework | Authoritative authored | Portable base capabilities, capability governance, and portable helper scripts |
| `framework/cognition/**` | Framework | Authoritative authored | Portable cognition governance, practices, and reference context |
| `framework/orchestration/**` | Framework | Authoritative authored | Portable orchestration governance and workflows |
| `framework/scaffolding/**` | Framework | Authoritative authored | Portable scaffolding templates, patterns, and reusable framework bundles |
| `framework/assurance/**` | Framework | Authoritative authored | Portable assurance contracts and validator foundations |
| `framework/engine/**` | Framework | Authoritative authored | Portable engine/runtime authority and engine governance |
| `framework/**/_ops/**` | Framework | Portable helper only | Portable scripts/helpers that assist framework validation, migration, generation, or packaging without becoming repo state |

## 7. Authority and boundary implications

- `framework/**` is the **base authored authority** of the Super-Root.
- `framework/**` is not the place for repo-specific durable authority. That belongs in `instance/**`.
- `framework/**` is not the place for mutable operational truth or retained evidence. That belongs in `state/**`.
- `framework/**` is not the place for rebuildable effective or derived outputs. That belongs in `generated/**`.
- `framework/**` is not the place for raw additive or exploratory inputs. That belongs in `inputs/**`.
- The presence of `framework/overlay-points/registry.yml` does **not** make `framework/**` generally overlayable. It only allows overlays at explicitly declared points, with the detailed rules delegated to Packet 5.
- Repo-root or tool-facing ingress adapters are not part of the framework core. Canonical internal ingress lives under `instance/ingress/**`.
- The framework class is the **default portable unit** used by `bootstrap_core` and by any future framework release/update mechanism.

## 8. Schema, manifest, and contract changes required

### `framework/manifest.yml`

Packet 3 ratifies `framework/manifest.yml` as required and authoritative. It must carry at least:

- `schema_version`
- `framework_id`
- `release_version`
- `supported_instance_schema_versions`
- `overlay_registry`
- `subsystems`
- `generators`

The live repo already contains this file. Packet 3 turns that existing file from implementation drift into canonical contract.

### `framework/overlay-points/registry.yml`

This file is also ratified as required. It must remain owned by the framework class. It declares which instance overlay points exist, and it is the place where framework explicitly exposes overlayability rather than leaving it implicit.

### Related contracts that must be updated

- root README guidance for framework/core install/update semantics
- umbrella specification references to framework canonical locations
- legacy mixed-tree framework architecture docs, especially `shared-foundation.md`
- downstream packet contracts that consume framework overlay, portability, or generator metadata

## 9. Ratified framework/core architecture

### What belongs in `framework/**`

The framework class contains portable authored core and portable helper assets, including:

- base governance contracts
- engine/runtime authority
- base/native capability definitions that are portable across repos
- framework scaffolding/templates and reusable patterns
- assurance contracts, validator foundations, and framework-side validation helpers
- cognition governance, practices, and portable reference context
- orchestration governance and reusable workflows
- portable helper scripts under domain `_ops/**`, only when they support framework validation, packaging, migration, or generation and do **not** store repo state

### What does **not** belong in `framework/**`

These artifacts are explicitly out of bounds for the framework class:

- repo-local context
- repo-local locality/scope definitions
- repo ADRs
- repo continuity
- retained evidence
- raw extension packs
- raw proposals
- generated catalogs, graphs, projections, summaries, or registries
- repo-specific bootstrap or ingress artifacts
- repo-specific governance overlays

### Domain organization inside the framework class

The top-level super-root is class-first, but the framework class remains domain-organized internally. That is a feature, not a contradiction. The framework class should preserve coherent domain homes for:

- `agency/`
- `capabilities/`
- `cognition/`
- `orchestration/`
- `scaffolding/`
- `assurance/`
- `engine/`

This preserves readability and local cohesion while keeping the top-level separation by class.

## 10. Overlay boundary and companion contracts

Packet 3 does **not** define the overlay merge semantics in full. That work belongs to the dedicated overlay packet. But Packet 3 ratifies these framework-side facts:

- overlay points are declared by the framework, not guessed by the instance layer
- the canonical registry lives at `framework/overlay-points/registry.yml`
- framework manifests bind to that registry
- overlay-capable instance artifacts must target declared overlay points rather than shadowing arbitrary framework files
- no framework artifact is implicitly overlayable

This packet therefore establishes the framework side of overlay safety without duplicating Packet 5.

## 11. Validation, assurance, and fail-closed implications

Validation must enforce these rules for the framework class:

- no wrong-class placement of repo-specific durable authority into `framework/**`
- no mutable repo state or retained evidence under `framework/**`
- no raw `inputs/**` dependencies in framework runtime or policy paths
- no generated outputs treated as framework source-of-truth
- framework manifest and overlay registry must be present and schema-valid
- framework updates must preserve compatibility with the root manifest and supported instance schema range
- any undeclared instance shadowing of framework artifacts fails closed
- framework helper scripts under `_ops/**` must be portable helpers only and must not become repo-owned state sinks

## 12. Portability, compatibility, and update implications

- `framework/**` is the portable authored core bundle.
- `bootstrap_core` must always include the full framework bundle.
- Framework release/update semantics are rooted in `octon.yml` and `framework/manifest.yml`.
- Framework compatibility with repo instances is declared by the supported instance schema range in `framework/manifest.yml`.
- Framework updates must preserve repo-owned `instance/**`, `state/**`, and `inputs/**` content unless an explicit migration contract says otherwise.
- Packaged or vendored extension packs are **not** part of the framework bundle, even when a pack is first-party. First-party bundled packs remain packs and live under `inputs/additive/extensions/**`.
- Framework portability is explicit and profile-driven; it is no longer derived from a flat path allowlist.

## 13. Migration and rollout implications

Packet 3 lands after the root taxonomy and manifest/profile model because the framework class depends on both.

### Migration work authorized by this packet

- inventory all currently portable authored assets that belong in `framework/**`
- move or alias legacy mixed-tree framework-worthy content into `framework/**`
- bind `framework/manifest.yml` and `framework/overlay-points/registry.yml` into the canonical architecture contract
- update bootstrap/install docs so framework is treated as the portable authored core bundle
- rewrite or retire `shared-foundation.md` and any similar mixed-tree framework narratives
- ensure later packets treat `framework/**` as the base authored authority rather than as one domain subtree among many

### Important sequencing rule

Packet 3 should not wait for full overlay implementation, but it must land before:

- Packet 5 overlay and ingress mechanics
- Packet 8 extension internalization and desired/active/compiled extension state
- Packet 12 portability/compatibility/trust contract finalization
- Packet 15 migration and rollout cutover logic

## 14. Dependencies and suggested implementation order

- **Dependencies:** Packet 1 — Super-Root Semantics and Taxonomy; Packet 2 — Root Manifest, Profiles, and Export Semantics
- **Suggested implementation order:** 3
- **Blocks:** overlay/ingress contract finalization, framework bundle update mechanics, portability/trust contract finalization, and later migration packet specifics

## 15. Acceptance criteria

- `framework/**` is explicitly defined as the portable authored core bundle.
- `framework/manifest.yml` is ratified as required and authoritative.
- `framework/overlay-points/registry.yml` is ratified as the framework-owned overlay registry.
- The canonical framework contents are explicitly listed and enforced by class-boundary rules.
- Repo-specific durable authority, raw inputs, mutable state, and generated outputs are explicitly excluded from `framework/**`.
- `bootstrap_core` can install framework without importing repo-specific authority, state, or exploratory inputs.
- The framework update model is defined so that framework changes do not directly rewrite repo continuity, repo context, repo ADRs, or proposals as a normal update path.
- Legacy mixed-tree framework narratives are formally retired, rewritten, or clearly marked historical.

## 16. Supporting evidence to reference

- Current `/.octon/README.md` — now already describes `.octon/` as a class-first Super-Root and profile-driven portability surface.
- Current `/.octon/octon.yml` — already declares class roots, release version, extension API version, and profile semantics.
- Current `/.octon/framework/manifest.yml` — already declares framework identity, supported instance schema range, overlay registry binding, and bundled generators.
- Current `/.octon/framework/overlay-points/registry.yml` — already declares overlay points.
- Current umbrella specification under `/.octon/framework/cognition/_meta/architecture/specification.md` — already reflects class-first root invariants.
- Current `shared-foundation.md` — still reflects the older capability-category mixed-tree model and should be superseded or retired.

Reference URLs:

- <https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/README.md>
- <https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/octon.yml>
- <https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/manifest.yml>
- <https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/overlay-points/registry.yml>
- <https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/cognition/_meta/architecture/specification.md>
- <https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/cognition/_meta/architecture/shared-foundation.md>

## 17. Settled decisions that must not be re-litigated

- `framework/**` remains inside the super-root.
- The top-level target state remains class-first rather than domain-first.
- `framework/**` is the portable authored core bundle.
- `instance/**` is the repo-specific durable authoritative layer.
- Raw packs and raw proposals do **not** belong in `framework/**`.
- `framework/**` does not contain repo continuity, retained evidence, or generated outputs.
- Instance overlays are only legal at declared overlay points.
- The framework class remains internally domain-organized.

## 18. Remaining narrow open questions

None. This packet is ratified for proposal drafting and is ready to be turned into the formal architectural proposal.

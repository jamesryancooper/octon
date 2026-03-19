# Packet 1 — Super-Root Semantics and Taxonomy

**Proposal design packet for migrating Octon from the current mixed-tree `.octon/` model to the ratified five-class Super-Root architecture.**

## Status
- **Status:** Ratified design packet for proposal drafting
- **Proposal area:** Super-Root semantics, source taxonomy, and class-root migration
- **Implementation order:** 1 of 15 in the ratified proposal sequence
- **Primary outcome:** Replace the current mixed-tree `.octon/` contract with a five-class Super-Root
- **Dependencies:** None
- **Migration role:** Defines the topological, authority, and portability taxonomy that all later cutovers must obey

> **Packet intent:** authorize the migration from the current domain-first `.octon/` harness to a class-first Super-Root in which authority, raw inputs, mutable operational truth, and rebuildable outputs are explicit and machine-enforceable.

## 1. Why this proposal exists

Octon’s current architecture still treats `/.octon/` as a copyable repo-root harness and a domain-organized single tree. That model worked as an early portability strategy, but it now mixes materially different artifact classes in one surface: portable framework assets, repo-specific authoritative artifacts, mutable continuity and evidence, and rebuildable generated outputs. As Octon evolves toward a governed Super-Root, that mixing becomes the primary source of portability, upgrade, reset, and migration risk.

Packet 1 exists to establish the architectural taxonomy that every later proposal depends on. Without a ratified top-level taxonomy, later work on locality, extensions, proposals, memory routing, generated outputs, and migration tooling will either conflict or reintroduce ad hoc exceptions.

## 2. Problem statement

The current repo baseline still documents `.octon/` as a single copyable harness, uses a `portable:` allowlist in `octon.yml`, and retains a domain-first top-level structure. At the same time, the current system already relies on repo-specific bootstrap artifacts, continuity, decisions, and operational state inside the same tree. This proposal resolves that contradiction by moving Octon from a mixed-tree model to a class-root Super-Root model.

### Current baseline signals that trigger this proposal

| Current baseline signal | Observed current-state source | Migration implication |
|---|---|---|
| `.octon/` is still described as a copyable repo-root harness | `.octon/README.md` | Replace raw whole-tree copy with profile-driven install/export semantics |
| Portability is still expressed as a path allowlist in `octon.yml` | `.octon/octon.yml` | Replace path allowlists with class roots and profile-based portability |
| Shared-foundation guidance still prefers capability-category organization over reusability/class separation | `shared-foundation.md` | Ratify class-first top-level organization while preserving domain organization inside the framework class |
| Umbrella specification still requires a class-root super-root | umbrella specification | Amend the canonical root contract so class roots become the new top-level invariant |

## 3. Final target-state decision summary

- Adopt `/.octon/` as a single authoritative Super-Root with one manifest-defined resolution pipeline.
- Replace the current mixed-tree top level with five class roots: `framework/`, `instance/`, `inputs/`, `state/`, and `generated/`.
- Treat `framework/` and `instance/` as the only authoritative authored surfaces.
- Treat `state/` as mutable operational truth and retained evidence only.
- Treat `generated/` as rebuildable effective and derived output only, never as source-of-truth.
- Treat `inputs/` as the explicit non-authoritative raw-input class, with `inputs/additive/**` for extension packs and `inputs/exploratory/**` for proposals.
- Forbid direct runtime or policy dependence on raw `inputs/**` paths.
- Require all downstream proposals to align to this taxonomy and to remove legacy mixed-path exceptions over time.

## 4. Scope

- Define the authoritative meaning of the Octon Super-Root.
- Define the five class roots and their roles.
- Define dependency-direction rules and source-of-truth boundaries.
- Define the new portability/install/export mental model at a high level.
- Authorize migration away from the current domain-first mixed-tree topology.
- Provide the canonical framing for later proposals on overlays, locality, extensions, proposals, state, generated outputs, validation, and migration.

## 5. Non-goals

- Detailed schema for locality, extension packs, proposal manifests, or generated catalogs.
- Detailed overlay merge semantics for specific framework domains.
- Detailed runtime behavior for routing, graph generation, or proposal registry generation.
- Implementation of migration tools, shims, or cutover scripts.
- Re-litigating descendant-local harnesses, external sidecar target states, `.octon.global/`, `.octon.graphs/`, or a generic `memory/` directory.

## 6. Canonical paths and artifact classes

| Canonical path | Class | Authority status | Purpose |
|---|---|---|---|
| `framework/**` | Framework | Authoritative authored | Portable Octon core/framework artifacts |
| `instance/**` | Instance | Authoritative authored | Repo-specific durable authoritative artifacts |
| `inputs/additive/extensions/**` | Inputs | Non-authoritative | Raw reusable additive extension-pack payloads |
| `inputs/exploratory/proposals/**` | Inputs | Non-authoritative | Raw exploratory proposal/work-in-progress artifacts |
| `state/**` | State | Operational truth | Mutable operational truth and retained evidence |
| `generated/**` | Generated | Non-authoritative | Rebuildable effective, graph, projection, summary, and registry outputs |
| `octon.yml` + companion manifests | Root | Authoritative control metadata | Manifest-defined class roots, versions, and profiles |

## 7. Authority and boundary implications

- Only `framework/` and `instance/` are authoritative authored surfaces.
- `state/` is authoritative only for operational truth classes such as continuity, control state, and retained evidence.
- `generated/` never becomes source-of-truth, even when committed.
- `inputs/` is always non-authoritative. Inputs may be validated, compiled, indexed, or promoted, but they are not themselves runtime or policy authority.
- Instance overlays are only legal at explicitly declared framework overlay points. This packet establishes the need for that mechanism; the detailed overlay contract is downstream work.
- Repo-root ingress adapters may exist, but canonical internal ingress content must be authored under the Super-Root rather than as an untyped parallel surface.

## 8. Schema, manifest, and contract changes required

- Revise the umbrella specification so the root invariant is class-first rather than domain-first.
- Replace the current path-allowlist portability model in `octon.yml` with a class-root and profile-driven model.
- Introduce `framework/manifest.yml` and `instance/manifest.yml` as companion manifests.
- Create a source taxonomy contract that defines authored authority, raw inputs, operational truth, and generated outputs.
- Update the root README and shared-foundation architecture so the canonical mental model is no longer “copy the whole `.octon/` tree.”
- Introduce downstream contracts for overlays, extension activation, proposal lifecycle, locality, state/evidence, and generated output publication.

## 9. Validation, assurance, and fail-closed implications

- Validation must reject any direct runtime or policy dependence on raw `inputs/**` paths.
- Validation must reject artifacts placed under the wrong class root when the class root is part of the canonical contract.
- Validation must fail closed when required manifests are missing, incompatible, or unresolved.
- Generated outputs must carry provenance and freshness metadata so downstream proposals can enforce stale-output failure semantics.
- Migration tooling must block partial cutovers that leave the repo simultaneously depending on legacy mixed paths and ratified class-root paths.

## 10. Portability, compatibility, and trust implications

- The default portable unit is no longer the whole `.octon/` tree; it is the framework bundle plus explicit profile-driven companions.
- Repo-specific authoritative artifacts under `instance/**` are excluded from default bootstrap and only exported intentionally.
- Mutable state and retained evidence under `state/**` are never part of clean bootstrap.
- Generated outputs under `generated/**` are rebuildable and are not the primary copy unit.
- Compatibility and versioning become root-manifest concerns, not incidental path assumptions.
- Trust and extension activation remain control-plane concerns and are not inherited from raw pack placement.

## 11. Migration and rollout implications

- This packet must ratify before any downstream class-root migration can be considered canonical.
- Generated/effective outputs should move first because they are easiest to regenerate.
- Repo continuity and retained evidence move into `state/**` before scope continuity is introduced.
- Repo-specific durable authority moves into `instance/**` before raw extension packs and proposals are internalized into `inputs/**`.
- Legacy external or mixed-path workspaces remain migration baselines only; they are not target state.
- Compatibility adapters may exist during migration, but they must expire once the class-root cutover is complete.

## 12. Dependencies and suggested implementation order

- **Dependencies:** None
- **Suggested implementation order:** 1
- **Blocks:** All downstream proposals and class-root migration work

## 13. Acceptance criteria

- The root architecture contract explicitly defines five class roots and their meanings.
- No downstream proposal is allowed to assume a competing top-level topology.
- The canonical root manifest model supports class-root and profile semantics.
- Dependency-direction rules explicitly forbid raw-input runtime/policy dependence.
- The old “copy `.octon/`” guidance is retired as the default bootstrap model.
- Migration sequencing for later proposals starts from this packet rather than from the legacy mixed-tree contract.
- All future path placement decisions can be classified unambiguously as framework, instance, inputs, state, or generated.

## 14. Supporting evidence to reference

- Current `.octon/README.md` — documents `.octon/` as a copyable repo-root harness and still recommends copying the tree into new repositories.
- Current `.octon/octon.yml` — uses a `portable:` allowlist and says everything else is project-specific state.
- Current shared-foundation architecture — explicitly prefers capability-category organization over reusability-layer organization.
- Current umbrella specification — still requires a class-root super-root under `/.octon/`.
- Ratified Super-Root blueprint — sections on super-root semantics, class model, root manifest model, and migration sequencing.

Reference URLs:
- https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/README.md
- https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/octon.yml
- https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/cognition/_meta/architecture/shared-foundation.md
- https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/framework/cognition/_meta/architecture/specification.md

## 15. Settled decisions that must not be re-litigated

- `/.octon/` remains the single authoritative super-root.
- The top-level target state is a five-class architecture, not a domain-first mixed tree.
- Integrated `inputs/**` is the only accepted target-state home for raw extensions and proposals.
- `framework/` and `instance/` are the only authoritative authored class roots.
- `state/` is mutable operational truth and retained evidence.
- `generated/` is rebuildable and non-authoritative.
- Raw `inputs/**` paths must never become direct runtime or policy dependencies.
- Descendant-local `.octon/` roots, `.octon.global/`, `.octon.graphs/`, and a generic `memory/` directory remain rejected.

## 16. Remaining narrow open questions

None. This packet is ratified as the first proposal in the migration sequence and is ready to be drafted as the formal architectural proposal.

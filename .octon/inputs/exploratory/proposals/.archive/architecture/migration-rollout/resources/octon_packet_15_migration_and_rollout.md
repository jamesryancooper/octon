---
title: "Packet 15 — Migration and Rollout"
subtitle: "Proposal design packet for ratifying, sequencing, and implementing the staged migration from Octon's mixed-tree and legacy external-workspace baseline to the integrated five-class Super-Root architecture."
---

Repo-ready proposal design packet

# Status

- **Status:** Ratified design packet for proposal drafting
- **Proposal area:** Staged migration sequencing, compatibility shims, class-root cutover gates, repo continuity before scope continuity, extension and proposal internalization, behaviorally complete repo-snapshot export, legacy-path retirement, and rollback-safe rollout controls
- **Implementation order:** 15 of 15 in the ratified proposal sequence
- **Primary outcome:** Deliver one explicit migration contract so adopted repositories can move from legacy mixed-path and external-workspace assumptions to the final five-class Super-Root without creating a second authority surface, unsafe snapshots, raw-input runtime dependencies, or ambiguous cutover states
- **Dependencies:** Hard dependencies: Packet 1 — Super-Root Semantics and Taxonomy; Packet 2 — Root Manifest, Profiles, and Export Semantics; Packet 3 — Framework/Core Architecture; Packet 4 — Repo-Instance Architecture; Packet 5 — Overlay and Ingress Model; Packet 6 — Locality and Scope Registry; Packet 7 — State, Evidence, and Continuity; Packet 8 — Inputs/Additive/Extensions; Packet 9 — Inputs/Exploratory/Proposals; Packet 10 — Generated / Effective / Cognition / Registry; Packet 11 — Memory, Context, ADRs, and Operational Decision Evidence; Packet 12 — Capability Routing and Host Integration; Packet 13 — Portability, Compatibility, Trust, and Provenance; Packet 14 — Validation, Fail-Closed, Quarantine, and Staleness
- **Migration role:** Convert the current repo baseline into one final, class-rooted, profile-driven, fail-closed rollout plan and define the order in which class roots, manifests, state, raw inputs, generated outputs, and legacy shims are introduced and retired
- **Current repo delta:** The live repository now already reflects much of the ratified architecture: `/.octon/README.md` is class-first, `/.octon/octon.yml` declares the five class roots and profile-driven portability, `/.octon/instance/extensions.yml` exists as desired extension configuration, `/.octon/state/control/extensions/active.yml` exists as actual published extension state, `/.octon/inputs/exploratory/proposals/**` exists as the integrated proposal workspace, and `/.octon/generated/proposals/registry.yml` exists as generated proposal discovery. Packet 15 still exists because migration is not only about landing the new paths; it is about making the sequence, shims, gates, export completeness rules, and legacy-retirement rules explicit so implementation does not drift.

> **Packet intent:** Define the final migration contract for moving from current and legacy Octon layouts to the ratified five-class Super-Root, including phase order, cutover gates, shim behavior, snapshot completeness, state migration order, extension internalization order, proposal internalization order, and legacy retirement conditions.

## 1. Why this proposal exists

The ratified Super-Root blueprint is no longer searching for a target topology. The final architecture already exists on paper:

- `framework/**` is portable authored core
- `instance/**` is durable repo-owned authored authority
- `inputs/**` is raw non-authoritative additive and exploratory input
- `state/**` is mutable operational truth and retained evidence
- `generated/**` is rebuildable derived output

Packet 15 exists because a good target architecture is not enough. Octon also needs one authoritative answer to these rollout questions:

- In what order do we introduce class roots so the repo never has two competing authority models?
- When do we migrate continuity, and when is it safe to introduce scope continuity?
- When can raw extension packs be internalized without creating accidental runtime dependencies?
- When is a repo snapshot behaviorally complete, and what happens if enabled pack closure is missing?
- How do we keep legacy paths working temporarily without turning compatibility shims into second-class authority surfaces?
- When can we safely remove the old mixed-path and external-workspace assumptions?

The current repository already demonstrates that migration is now a real implementation concern rather than a thought experiment. Class-first `/.octon/README.md`, the new root manifest, integrated proposal paths, and desired/actual extension surfaces all exist. At the same time, historical materials such as `/.proposals/**`, older path assumptions, and legacy mixed-path references still exist as migration pressure. Packet 15 is the contract that prevents the final rollout from becoming ad hoc.

## 2. Problem statement

Octon needs one final migration and rollout architecture that is:

- phase-ordered rather than opportunistic
- explicit about entry and exit gates for each cutover
- explicit about which paths are canonical, which are transitional, and which are legacy-only
- explicit about when state may move and when generated outputs may be regenerated
- explicit about how repo snapshots remain behaviorally complete when enabled packs exist
- explicit about how compatibility shims behave and when they are removed
- explicit about what evidence must be retained as migration receipts
- explicit about what rollback means at different stages

Without Packet 15, implementation risks are concentrated in exactly the places the ratified blueprint was trying to eliminate:

- partial cutovers that leave two authority models live at once
- scope continuity appearing before scope identity and validation exist
- repo snapshots that omit enabled pack closure and then fail later in confusing ways
- legacy shim paths that remain writable indefinitely
- runtime or policy consumers continuing to reference older mixed paths after the new class-root paths exist
- migrations that rewrite repo-owned truth without durable receipts

Packet 15 resolves those risks by making migration itself a governed architecture surface.

## 3. Final target-state decision summary

- Migration proceeds in one ratified sequence and does not permit ad hoc reordering of critical dependency phases.
- `repo_snapshot` is behaviorally complete in v1 and includes enabled pack dependency closure.
- There is no v1 `repo_snapshot_minimal` profile.
- Raw-input dependency enforcement must land before extension internalization.
- Repo continuity migration lands before scope continuity migration.
- Scope continuity may not land until locality registry and scope validation are live.
- Legacy paths may exist temporarily only as compatibility shims, projections, or adapters.
- Legacy shim paths must be read-through or generated from canonical sources only; they may not become writable peer authority surfaces.
- New authored content may not be created in legacy shim paths once the corresponding canonical class-root surface exists.
- Migration receipts live under `state/evidence/migration/**`.
- Generated outputs may be rebuilt at multiple phases, but retained evidence and active state may not be discarded by normal regeneration workflows.
- Runtime-facing consumers must switch to canonical class-root and generated-effective surfaces before shim removal.
- Legacy mixed-path and external-workspace support is removed only after cutover gates pass.

## 4. Scope

This packet does all of the following:

- defines the final migration principles for the ratified Super-Root
- defines canonical migration phases and their ordering
- defines cutover gates and blocking conditions
- defines compatibility-shim behavior and removal rules
- defines state migration sequencing, including repo continuity before scope continuity
- defines the extension-internalization and proposal-internalization order
- defines repo-snapshot completeness requirements during migration
- defines where migration receipts and rollback evidence live
- defines the relationship between profile-driven export/install and migration rollout

## 5. Non-goals

This packet does **not** do any of the following:

- re-litigate the five-class Super-Root
- reopen extension or proposal placement inside `inputs/**`
- create a v1 minimal repo snapshot profile
- allow raw whole-tree `.octon/` copy to remain the default installation or export mechanism
- permit indefinite dual-authority operation between legacy and ratified paths
- define external pack-registry resolution in v1
- redefine overlay semantics beyond what Packet 5 governs
- redefine commit policy beyond the ratified generated-output matrix

## 6. Canonical paths and artifact classes

- **`octon.yml`** — root manifest; authoritative migration contract, profile rules, and version gates.
- **`framework/manifest.yml`** — framework-class companion manifest; declares framework identity, supported schema range, and overlay registry binding.
- **`instance/manifest.yml`** — instance-class companion manifest; declares repo identity, enabled overlay points, and feature toggles.
- **`framework/overlay-points/registry.yml`** — framework-class overlay registry; machine-declared overlay points required before repo-local overlays are enabled.
- **`instance/ingress/AGENTS.md`** — canonical ingress source during migration away from legacy repo-root adapters.
- **`instance/locality/**`** — instance-class locality authority; scope registry and scope identity source of truth.
- **`state/continuity/repo/**`** — state-class destination for repo-wide active continuity; the first continuity migration target.
- **`state/continuity/scopes/**`** — state-class destination for scope continuity after locality cutover.
- **`state/evidence/migration/**`** — state-class retained migration receipts and rollback trace.
- **`inputs/additive/extensions/**`** — final raw extension-pack location.
- **`instance/extensions.yml`** — desired extension configuration authored by the repo.
- **`state/control/extensions/active.yml`** — actual active extension state after validation and publication.
- **`generated/effective/extensions/**`** — published runtime-facing extension effective outputs.
- **`inputs/exploratory/proposals/**`** — final raw exploratory proposal workspace.
- **`generated/proposals/registry.yml`** — generated proposal discovery output.
- **Legacy repo-root adapters such as `AGENTS.md` and `CLAUDE.md`** — transitional ingress shims only; never a second authority surface.
- **Legacy `.proposals/**`** — transitional workspace shim and historical baseline; migrate then retire.

## 7. Authority and boundary implications

- Migration must never create a second authored authority surface.
- Canonical authored authority remains only in `framework/**` and `instance/**` throughout migration.
- Canonical operational truth remains only in `state/**` throughout migration.
- Canonical rebuildable outputs remain only in `generated/**` throughout migration.
- Raw extension and proposal inputs remain in `inputs/**` and remain non-authoritative throughout migration.
- Compatibility shims may preserve compatibility, but they do not become authority sources.
- Desired extension configuration remains authored in `instance/extensions.yml`; actual active published state remains operational truth in `state/control/extensions/active.yml`; compiled outputs remain in `generated/effective/extensions/**`.
- Proposal material remains non-canonical before, during, and after migration.

## 8. Ratified migration principles

### 8.1 Profile-first, removal-last

Profile-driven install/export behavior must exist before legacy raw-copy assumptions are removed.

### 8.2 No raw-input dependency drift

Extension internalization may not proceed until raw-input dependency enforcement is active. Runtime and policy consumers must never be allowed to “temporarily” read raw `inputs/**` paths.

### 8.3 Generated-first, then state, then durable authority

Generated outputs are the lowest-risk class to move first. Mutable operational truth and retained evidence move next. Durable repo authority moves after the class-root structure is proven.

### 8.4 Repo continuity before scope continuity

Repo continuity moves into `state/continuity/repo/**` before any scope continuity is introduced. Scope continuity depends on a validated scope registry.

### 8.5 Desired/actual/compiled extension split must survive migration

At no point may migration collapse desired extension config, active extension state, and compiled effective outputs into one ambiguous surface.

### 8.6 Shims are temporary, read-through, and non-authoritative

Legacy shims may project or redirect, but they may not become writable peer truth once the canonical class-root surface exists.

### 8.7 Receipts are evidence, not generated cache

Migration receipts must be retained under `state/evidence/migration/**` and are not deleted by regeneration workflows.

## 9. Ratified migration phases

### Phase 1 — Ratify super-root semantics and overlay model

- **Change set:** Ratify the five-class Super-Root, class-root semantics, overlay registry model, ingress model, and raw-input dependency policy.
- **Exit gate:** All target-state architecture proposals are approved as the only valid topology for implementation.

### Phase 2 — Extend root and companion manifests

- **Change set:** Upgrade `octon.yml`, `framework/manifest.yml`, and `instance/manifest.yml` to ratified schema versions; add class roots, release/API version keys, profiles, overlay registry binding, and migration workflow references.
- **Exit gate:** Root and companion manifests validate cleanly and profile definitions are machine-readable.

### Phase 3 — Enforce raw-input dependency ban

- **Change set:** Add validation rules that reject runtime or policy dependence on raw `inputs/**` paths.
- **Exit gate:** Validation fails closed if raw extension or proposal paths appear in runtime or policy dependency graphs.

### Phase 4 — Introduce class roots with compatibility shims

- **Change set:** Create `framework/`, `instance/`, `inputs/`, `state/`, and `generated/`; introduce temporary read-through shims for legacy mixed paths and repo-root adapters.
- **Exit gate:** Canonical class-root paths exist and can be addressed without ambiguity.

### Phase 5 — Move generated/effective outputs

- **Change set:** Rehome generated effective catalogs, artifact maps, locks, summaries, graphs, projections, and proposal registry into `generated/**`.
- **Exit gate:** Runtime-facing generated outputs are published only from `generated/**`.

### Phase 6 — Move repo continuity and retained evidence

- **Change set:** Move repo continuity into `state/continuity/repo/**`; move retained evidence into `state/evidence/**`; begin writing migration receipts under `state/evidence/migration/**`.
- **Exit gate:** Repo continuity and retained evidence no longer rely on legacy mixed paths.

### Phase 7 — Move durable repo authority into `instance/**`

- **Change set:** Move canonical ingress, bootstrap docs, repo context, ADRs, repo-native capabilities, missions, desired extension configuration, and overlay-capable governance/agency/assurance surfaces into `instance/**`.
- **Exit gate:** Durable repo authority no longer depends on legacy mixed domain paths.

### Phase 8 — Introduce locality registry and scope validation

- **Change set:** Add `instance/locality/**`, scope schemas, locality validation, and generated effective locality outputs.
- **Exit gate:** Scope identity resolves deterministically and invalid locality quarantines locally.

### Phase 9 — Introduce scope continuity

- **Change set:** Add `state/continuity/scopes/<scope-id>/**` and route scope-bound active work there.
- **Exit gate:** Scope continuity exists only for validated scopes and no scope continuity is orphaned from scope identity.

### Phase 10 — Internalize extension packs

- **Change set:** Move raw extension packs into `inputs/additive/extensions/**`.
- **Exit gate:** Pack payloads are present in their final canonical location and no runtime consumer reads them directly.

### Phase 11 — Add desired/actual/quarantine/compiled extension pipeline

- **Change set:** Finalize `instance/extensions.yml`, `state/control/extensions/{active.yml,quarantine.yml}`, and `generated/effective/extensions/**` publication discipline.
- **Exit gate:** Desired config, actual active state, quarantine state, and compiled outputs are distinct, consistent, and atomically publishable.

### Phase 12 — Internalize proposal workspace

- **Change set:** Move active and archived proposals into `inputs/exploratory/proposals/**` and `inputs/exploratory/proposals/.archive/**`.
- **Exit gate:** Proposal authoring no longer requires external `.proposals/**` paths.

### Phase 13 — Move proposal registry into `generated/**`

- **Change set:** Publish proposal discovery at `generated/proposals/registry.yml`.
- **Exit gate:** Proposal discovery is generated, committed by default, and clearly non-authoritative.

### Phase 14 — Update routing, graph, projection, and generation pipelines

- **Change set:** Repoint capability routing, graph generation, projection materialization, summary generation, and related compilers to the final class-root surfaces.
- **Exit gate:** All runtime-facing and review-facing generated outputs are produced from canonical class-root inputs only.

### Phase 15 — Remove legacy mixed-path and external-workspace support

- **Change set:** Remove legacy `.proposals/**`, mixed-path readers, and obsolete write targets after compatibility gates pass.
- **Exit gate:** No runtime, policy, or authoring workflow depends on legacy paths; compatibility shims can be removed without changing behavior.

## 10. Compatibility shims and cutover rules

### 10.1 Allowed shim types

Allowed temporary shims in v1 rollout:

- thin repo-root ingress adapters such as `AGENTS.md` and `CLAUDE.md`
- legacy path readers that resolve to the canonical class-root path
- mirrored or redirected legacy proposal paths during proposal migration
- compatibility projections needed by tooling that has not yet switched to the canonical generated path

### 10.2 Disallowed shim behavior

Not allowed:

- new authored content written directly into legacy shim paths after the canonical path exists
- shim-only runtime behavior not reproducible from canonical paths
- parallel authoritative editing in both legacy and canonical paths
- indefinite retention of shim paths after all consumers have moved

### 10.3 Shim retirement rule

A shim may be removed only when all of the following are true:

- no runtime or policy consumer references the shim path
- no authoring workflow writes to the shim path
- equivalent canonical content has passed validation and publication gates
- migration receipts prove cutover completion for that surface

## 11. Validation and cutover gates

Critical cutover gates:

- **Before Phase 4:** manifest schemas validate and class-root bindings are stable.
- **Before Phase 9:** locality registry and validation are live; repo continuity is already under `state/**`.
- **Before Phase 10:** raw-input dependency enforcement is active.
- **Before Phase 11:** extension compiler, artifact maps, generation locks, and validation pipeline are live.
- **Before Phase 12:** proposal validation rules are live and internal proposal workspace exists.
- **Before Phase 15:** no canonical consumer references legacy mixed paths or external proposal workspace paths.

## 12. Install, export, update, and reset transition model

### Bootstrap

`bootstrap_core` becomes the only supported clean bootstrap contract.

### Repo snapshot

`repo_snapshot` is behaviorally complete in v1 and includes:

- `octon.yml`
- `framework/**`
- `instance/**`
- all enabled extension packs
- transitive dependency closure of enabled extension packs

If any enabled pack payload or dependency closure member is absent, snapshot generation fails.

### Full-fidelity clone

Exact repo reproduction remains a normal Git clone, not a special profile.

### State reset

Resetting state means resetting `state/**` only. It must not touch `instance/**`, `inputs/**`, or `framework/**`.

### Generated regeneration

Regeneration means deleting and rebuilding `generated/**`. It must not remove retained evidence under `state/evidence/**`.

## 13. Rollback and recovery boundaries

- Phases 1 through 5 are primarily structural and are generally reversible through shims and version-controlled revert if cutover gates fail early.
- Once continuity and retained evidence have migrated to `state/**`, rollback must preserve migration receipts rather than trying to pretend the move never happened.
- Once extension actual active state and generated effective outputs publish from their final paths, rollback must republish a coherent earlier generation rather than partially restoring raw pack or state files by hand.
- After legacy path removal, rollback is performed through version-controlled restore and repeatable migration tooling, not by reviving abandoned dual-authority paths.

## 14. Acceptance criteria

- The repo can move from current baseline to the ratified Super-Root without creating a second authority surface.
- `repo_snapshot` exports are behaviorally complete whenever enabled packs exist.
- Raw `inputs/**` paths never become direct runtime or policy dependencies during or after migration.
- Repo continuity is migrated before scope continuity.
- Scope continuity cannot exist without validated scope identity.
- Desired extension configuration, active extension state, quarantine state, and compiled effective outputs remain distinct throughout migration.
- Proposal content is fully internalized under `inputs/exploratory/proposals/**` and remains non-canonical.
- Generated proposal discovery publishes at `generated/proposals/registry.yml`.
- Migration receipts are retained under `state/evidence/migration/**`.
- Legacy shim paths are removed only after all consumers switch to canonical class-root and generated surfaces.

## 15. Supporting evidence to reference

- `/.octon/README.md`
- `/.octon/octon.yml`
- `/.octon/framework/manifest.yml`
- `/.octon/instance/manifest.yml`
- `/.octon/instance/extensions.yml`
- `/.octon/state/control/extensions/active.yml`
- `/.octon/inputs/exploratory/proposals/README.md`
- `/.octon/generated/proposals/registry.yml`
- `/.proposals/README.md` (legacy migration baseline)
- `/.octon/cognition/governance/principles/locality.md`
- `/.octon/cognition/runtime/context/memory-map.md`
- `/.octon/cognition/_meta/architecture/runtime-vs-ops-contract.md`

## 16. Settled decisions that must not be re-litigated

- The final topology is the five-class Super-Root.
- Extensions remain integrated under `inputs/additive/extensions/**`.
- Proposals remain integrated under `inputs/exploratory/proposals/**`.
- `repo_snapshot` is behaviorally complete and includes enabled pack dependency closure.
- There is no v1 `repo_snapshot_minimal` profile.
- Repo continuity migrates before scope continuity.
- Raw `inputs/**` paths never become runtime or policy dependencies.
- Proposal content remains non-canonical throughout migration.
- Legacy shim paths are temporary only.

## 17. Remaining narrow open questions, if any

None. Packet 15 is fully ratified for proposal drafting and implementation planning.

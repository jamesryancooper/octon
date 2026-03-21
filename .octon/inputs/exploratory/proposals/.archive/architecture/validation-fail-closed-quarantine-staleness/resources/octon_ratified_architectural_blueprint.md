# Octon Ratified Architectural Blueprint

## 1. Executive ratification decision

**Ratified with targeted finalization.**

The blueprint is adopted as the final target-state architecture, with the assessment’s two material concerns fully resolved and the remaining minor improvements and open questions explicitly settled.

The ratified architecture remains:

* one authoritative super-root at `/.octon/`
* five class roots:

  * `framework/`
  * `instance/`
  * `inputs/`
  * `state/`
  * `generated/`
* integrated raw extension packs at `inputs/additive/extensions/**`
* integrated raw proposal material at `inputs/exploratory/proposals/**`

The current repo baseline still reflects the older mixed-tree model: `/.octon/README.md` still describes `.octon/` as a copyable repo-root harness, `octon.yml` still uses a `portable:` allowlist model, the root still has `.proposals/`, and the extension-pack model still exists only as proposal material rather than implemented architecture. ([GitHub][1])

This ratification does **not** reopen the blueprint’s core topology. It preserves the blueprint and closes the remaining gaps.

---

## 2. What remains unchanged from the blueprint

These decisions remain unchanged and are now final:

* `/.octon/` is the single authoritative super-root.
* “Single-root” means one authoritative super-root and one manifest-defined resolution pipeline.
* The final super-root is a five-class architecture:

  * `framework/`
  * `instance/`
  * `inputs/`
  * `state/`
  * `generated/`
* `framework/` and `instance/` are authoritative authored surfaces.
* `state/` is mutable operational truth and retained evidence.
* `generated/` is rebuildable and non-authoritative.
* Extensions live under `inputs/additive/extensions/**`.
* Proposals live under `inputs/exploratory/proposals/**`.
* `instance/extensions.yml` is the repo-controlled extension selection/activation surface.
* Raw `inputs/**` paths must never become direct runtime or policy dependencies.
* Locality is a root-owned scope model.
* v1 scope resolution yields zero or one active `scope_id` per path.
* v1 rejects hierarchical scope inheritance.
* Memory remains a routing/classification model.
* No descendant-local `.octon/` roots.
* No `.octon.global/`.
* No `.octon.graphs/`.
* No generic `memory/` surface.

---

## 3. Ratification of material concerns

### Concern 1: Instance overlay model was under-specified

**Ratified solution**

The ratified blueprint makes the `instance/**` layer explicitly split into:

* **instance-native surfaces**, which are repo-specific authoritative artifacts and do not overlay framework paths
* **overlay-capable surfaces**, which may modify or extend framework behavior only at declared overlay points

#### 3.1 Instance-native surfaces

These are canonical, repo-specific, authoritative, and **not** overlay-driven:

* `instance/manifest.yml`
* `instance/ingress/**`
* `instance/bootstrap/**`
* `instance/locality/**`
* `instance/cognition/context/**`
* `instance/cognition/decisions/**`
* `instance/capabilities/runtime/**` for repo-native capabilities
* `instance/orchestration/missions/**`
* `instance/extensions.yml`

#### 3.2 Overlay-capable surfaces

These are authoritative only when bound to declared framework overlay points:

* `instance/governance/**`
* `instance/agency/**`
* `instance/assurance/**`
* any other instance subtree only if explicitly declared by the framework overlay registry

#### 3.3 Overlay declaration model

Overlay points are now explicitly machine-declared.

`framework/manifest.yml` must reference:

```text
framework/overlay-points/registry.yml
```

Each overlay point entry must declare:

* `overlay_point_id`
* `owning_domain`
* `instance_glob`
* `merge_mode`
* `validator`
* `precedence`
* optional `artifact_kinds`

Allowed merge modes in v1 are:

* `replace_by_path`
* `merge_by_id`
* `append_only`

No other merge mode is allowed in v1.

#### 3.4 Overlay enablement model

`instance/manifest.yml` must declare:

* `enabled_overlay_points`

Validators must reject:

* any file under overlay-capable instance surfaces not covered by an enabled overlay point
* any overlay artifact outside the allowed `instance_glob`
* any undeclared merge behavior
* any attempt to overlay non-overlayable framework surfaces, especially `framework/engine/runtime/**`

#### 3.5 Canonical ingress model

The canonical internal ingress home is now:

```text
instance/ingress/AGENTS.md
```

Repo-root adapter files such as repo-root `AGENTS.md` or tool-facing ingress adapters remain allowed, but they are **thin adapters only**. They are not separate authority surfaces. Their canonical authored content lives under `instance/ingress/**`.

**Why this is best**

It fixes the under-specification without changing the topology, and it keeps overlay rules machine-enforceable instead of convention-only.

**Rejected alternatives**

* letting teams invent overlay paths ad hoc: too ambiguous
* making all of `instance/**` blanket-overlay-capable: too unsafe
* path-shadowing framework arbitrarily: too brittle

---

### Concern 2: Repo snapshot/export semantics were under-specified for enabled packs

**Ratified solution**

`repo_snapshot` is now defined as a **behaviorally complete** profile.

That means:

* `repo_snapshot` includes:

  * `octon.yml`
  * `framework/**`
  * `instance/**`
  * **all enabled extension pack payloads**
  * **all transitive dependencies of enabled packs**
* `repo_snapshot` excludes:

  * `inputs/exploratory/**`
  * `state/**`
  * `generated/**`

There is **no v1 `repo_snapshot_minimal` profile**.

If an enabled pack or a required dependency is missing from the snapshot payload set, snapshot generation fails closed.

Future support for externally resolvable pack sources may introduce a separate profile later, but it does **not** change the meaning of `repo_snapshot` in v1.

**Why this is best**

It is the simplest behaviorally correct answer. It avoids ambiguous “optional” pack inclusion and preserves reproducibility.

**Rejected alternatives**

* making enabled pack inclusion optional in `repo_snapshot`: too ambiguous
* shipping both minimal and complete repo snapshots in v1: unnecessary complexity
* omitting enabled packs unless external resolution succeeds: premature for v1

---

## 4. Ratification of potential improvements

### Improvement 1: Clarify desired state vs actual active state for extensions

**Adopted**

The extension model is now explicitly four-layered:

1. **Desired configuration**
   `instance/extensions.yml`
   Human-authored, authoritative, repo-owned.

2. **Actual active operational state**
   `state/control/extensions/active.yml`
   Derived operational truth: what is currently validated and active.

3. **Quarantine / withdrawal state**
   `state/control/extensions/quarantine.yml`
   Mutable control state describing blocked packs, reasons, and acknowledgements.

4. **Runtime-facing compiled outputs**
   `generated/effective/extensions/**`
   Rebuildable compiled views used by runtime and policy consumers.

`instance/extensions.yml` is the desired source of truth.
`active.yml` is the actual published operational state after validation.
`generated/effective/extensions/**` is the published compiled output set referenced by `active.yml`.

Publication of `active.yml` and `generated/effective/extensions/**` must be atomic.

---

### Improvement 2: Tighten migration sequencing around repo continuity vs scope continuity

**Adopted**

Migration sequencing is now explicit:

* move **repo continuity** into `state/continuity/repo/**` before locality cutover
* land **locality registry and scope validation**
* only then introduce **scope continuity** at `state/continuity/scopes/<scope-id>/**`

No scope continuity migration or new scope-bound state is allowed before scope registry and validation are in place.

---

### Improvement 3: Add a generated-output commit policy matrix

**Adopted**

A ratified default commit policy matrix is now part of the blueprint. It appears in Section 18 and is binding unless a later explicit policy proposal revises it.

---

## 5. Ratification of open questions

### 1. Should `instance/extensions.yml` remain one file in v1, or split selection and trust policy?

**Final answer:** keep **one file** in v1.

It must contain distinct top-level sections:

* `selection`
* `sources`
* `trust`
* `acknowledgements`

This keeps desired configuration cohesive and avoids unnecessary multi-file coupling.

---

### 2. Should one `scope_id` be allowed to bind multiple disjoint path roots in v1?

**Final answer:** **no**.

In v1, each `scope_id` must declare exactly one `root_path`.
`include_globs` and `exclude_globs` may refine that rooted subtree, but disjoint multi-root scopes are deferred beyond v1.

This preserves simple reasoning and keeps zero-or-one active scope per path deterministic.

---

### 3. Which generated outputs should be committed by default versus rebuilt locally?

**Final answer:** see the ratified matrix in Section 18.

In short:

* commit by default:

  * `generated/effective/**`
  * `generated/cognition/summaries/**`
  * `generated/proposals/registry.yml`
  * `generated/cognition/projections/definitions/**`
* rebuild locally by default:

  * `generated/cognition/graph/**`
  * `generated/cognition/projections/materialized/**`

---

### 4. Should `generated/proposals/registry.yml` be committed or purely generated?

**Final answer:** **committed by default**.

It is small, reviewable, useful for discovery, and non-authoritative. Committing it improves visibility without changing authority.

---

### 5. Do first-party bundled packs need an explicit marker, or should all packs share the same `pack.yml` contract?

**Final answer:** all packs share the **same `pack.yml` contract**, and first-party bundled packs must carry an explicit origin marker inside that contract.

Required field in `pack.yml`:

* `origin_class`

Allowed v1 values:

* `first_party_bundled`
* `first_party_external`
* `third_party`

This preserves one uniform pack contract while making pack provenance explicit.

---

## 6. Final ratified architectural invariants

1. `/.octon/` is the single authoritative super-root.
2. The super-root has five class roots: `framework/`, `instance/`, `inputs/`, `state/`, `generated/`.
3. Only `framework/` and `instance/` are authoritative authored surfaces.
4. `state/` is authoritative only as operational truth/evidence.
5. `generated/` is never authoritative.
6. Raw extensions live only under `inputs/additive/extensions/**`.
7. Raw proposals live only under `inputs/exploratory/proposals/**`.
8. Raw `inputs/**` paths must never become direct runtime or policy dependencies.
9. `instance/extensions.yml` is desired extension configuration.
10. `state/control/extensions/active.yml` is derived actual active state.
11. `state/control/extensions/quarantine.yml` is mutable quarantine/withdrawal state.
12. Runtime-facing extension behavior comes only from validated compiled outputs in `generated/effective/extensions/**`.
13. `repo_snapshot` is behaviorally complete and includes enabled pack dependency closure.
14. There is no v1 minimal repo snapshot profile.
15. Locality is a root-owned scope model under `instance/locality/**`.
16. v1 permits zero or one active `scope_id` per path.
17. v1 permits one `root_path` per `scope_id`.
18. v1 rejects hierarchical scope inheritance.
19. Memory remains a routing/classification model.
20. No descendant-local `.octon/` roots.
21. No `.octon.global/`.
22. No `.octon.graphs/`.
23. No generic `memory/` surface.
24. Repo-root ingress adapters are thin adapters only; canonical ingress content lives under `instance/ingress/**`.
25. Overlay-capable instance surfaces may exist only at framework-declared overlay points.

---

## 7. Final ratified authority / ownership / precedence model

### Authored authority

* `framework/**`
* `instance/**`

### Operational truth

* `state/**`

### Non-authoritative

* `inputs/**`
* `generated/**`

### Ownership

* framework maintainers own `framework/**`
* repo maintainers own `instance/**`
* runtime/operators own governed writes to `state/**`
* pack authors own raw pack payloads in `inputs/additive/**`
* proposal authors own raw proposal material in `inputs/exploratory/**`
* generators/validators own `generated/**`

### Precedence

1. framework base contracts and runtime authority
2. instance overlays and repo bindings, only at declared overlay points
3. enabled extension contributions, but only through compiled validated effective views
4. state as operational truth for continuity/evidence/control classes
5. generated outputs as derived inspection/runtime-support artifacts
6. proposals never participate in runtime or policy precedence

### Overlay precedence

Within a declared overlay point:

* `replace_by_path`: instance artifact replaces framework artifact at that point
* `merge_by_id`: instance records merge into framework keyed sets
* `append_only`: instance records append to framework register

Outside declared overlay points, framework wins and instance content is invalid.

---

## 8. Final ratified filesystem/topology blueprint

```text
repo/
  .octon/
    README.md
    octon.yml

    framework/
      manifest.yml
      overlay-points/
        registry.yml
      agency/
        governance/
        runtime/
      capabilities/
        governance/
        runtime/
        _ops/
      cognition/
        governance/
        practices/
        runtime/
          context/
            reference/
      orchestration/
        governance/
        runtime/
      scaffolding/
        governance/
        runtime/
      assurance/
        governance/
        runtime/
      engine/
        governance/
        runtime/

    instance/
      manifest.yml
      ingress/
        AGENTS.md
      bootstrap/
        START.md
        OBJECTIVE.md
        scope.md
        conventions.md
        catalog.md
      governance/
        policies/
        contracts/
      agency/
        governance/
        runtime/
      assurance/
        governance/
        runtime/
      locality/
        manifest.yml
        registry.yml
        scopes/
          <scope-id>/
            scope.yml
      cognition/
        context/
          shared/
          scopes/
            <scope-id>/
        decisions/
      capabilities/
        runtime/
          skills/
          commands/
      orchestration/
        missions/
      extensions.yml

    inputs/
      additive/
        extensions/
          <pack-id>/
            pack.yml
            README.md
            skills/
            commands/
            templates/
            prompts/
            context/
            validation/
          .archive/
      exploratory/
        proposals/
          <kind>/
            <proposal-id>/
              proposal.yml
              <subtype-manifest>.yml
              README.md
              support/
          .archive/

    state/
      continuity/
        repo/
          log.md
          tasks.json
          entities.json
          next.md
        scopes/
          <scope-id>/
            log.md
            tasks.json
            entities.json
            next.md
      evidence/
        runs/
        decisions/
          repo/
          scopes/
            <scope-id>/
        validation/
        migration/
      control/
        extensions/
          active.yml
          quarantine.yml
        locality/
          quarantine.yml

    generated/
      effective/
        locality/
          scopes.effective.yml
          artifact-map.yml
          generation.lock.yml
        capabilities/
          routing.effective.yml
          artifact-map.yml
          generation.lock.yml
        extensions/
          catalog.effective.yml
          artifact-map.yml
          generation.lock.yml
      cognition/
        graph/
          index.yml
          nodes.yml
          edges.yml
        projections/
          definitions/
          materialized/
        summaries/
          decisions.md
      proposals/
        registry.yml
```

### Placement rules

* nothing except root ingress files and `octon.yml` sits directly under `/.octon/`
* `framework/` and `instance/` remain internally domain-organized
* `inputs/` is lifecycle-organized
* `state/` is operational-kind organized
* `generated/` is output-kind organized

---

## 9. Final ratified manifest / profile / export model

### 9.1 Root manifest

`/.octon/octon.yml` is the authoritative super-root manifest.

It must define:

* `schema_version`
* class-root bindings
* `versioning.harness.release_version`
* `versioning.harness.supported_schema_versions`
* `extensions.api_version`
* install/export/update profiles
* raw-input dependency policy
* generated-staleness policy
* migration workflow references
* excluded/human-led zones

### 9.2 Companion manifests

* `framework/manifest.yml`
* `instance/manifest.yml`

`framework/manifest.yml` declares framework identity, bundled subsystems, overlay registry binding, generator set, and supported instance schema range.

`instance/manifest.yml` declares repo instance identity, enabled overlay points, locality binding, and repo feature toggles.

### 9.3 Ratified v1 profiles

#### `bootstrap_core`

Includes:

* `octon.yml`
* `framework/**`
* `instance/manifest.yml`

Excludes:

* all `inputs/**`
* all `state/**`
* all `generated/**`

#### `repo_snapshot`

This is the **default behaviorally complete snapshot**.

Includes:

* `octon.yml`
* `framework/**`
* `instance/**`
* enabled extension packs
* transitive dependency closure of enabled extension packs

Excludes:

* `inputs/exploratory/**`
* `state/**`
* `generated/**`

If enabled pack payloads or dependencies are missing, export fails closed.

#### `pack_bundle`

Includes:

* selected extension pack payloads
* dependency closure of selected packs

#### `full_fidelity`

Advisory only:

* use normal Git clone for exact repo reproduction

### 9.4 Unsupported in v1

* `repo_snapshot_minimal` is not part of v1
* pack omission with unresolved external references is not allowed in `repo_snapshot`

---

## 10. Final ratified overlay and ingress model

### 10.1 Overlay-capable domains

Overlay-capable instance surfaces are:

* `instance/governance/**`
* `instance/agency/**`
* `instance/assurance/**`
* any additional subtree only if declared in `framework/overlay-points/registry.yml`

### 10.2 Instance-native domains

These are repo-authoritative but not overlay-driven:

* `instance/ingress/**`
* `instance/bootstrap/**`
* `instance/locality/**`
* `instance/cognition/context/**`
* `instance/cognition/decisions/**`
* `instance/capabilities/runtime/**`
* `instance/orchestration/missions/**`
* `instance/extensions.yml`

### 10.3 Overlay declaration model

`framework/overlay-points/registry.yml` is the canonical overlay registry.

Each entry must declare:

* `overlay_point_id`
* `owning_domain`
* `instance_glob`
* `merge_mode`
* `validator`
* `precedence`
* optional `artifact_kinds`

### 10.4 Overlay enablement model

`instance/manifest.yml` must declare:

* `enabled_overlay_points`

Any artifact in an overlay-capable instance subtree that is not covered by an enabled declared overlay point is invalid.

### 10.5 Ingress model

Canonical internal ingress lives under:

```text
instance/ingress/AGENTS.md
```

Repo-root `AGENTS.md`, `CLAUDE.md`, or other host-facing ingress files may exist as thin adapters, projections, or refreshable scaffolds, but they are not separate authority surfaces.

---

## 11. Final ratified extension architecture

### 11.1 Raw pack placement

Raw packs live at:

```text
inputs/additive/extensions/<pack-id>/**
```

### 11.2 Desired vs actual vs compiled split

#### Desired authored config

`instance/extensions.yml`

Required top-level sections in v1:

* `selection`
* `sources`
* `trust`
* `acknowledgements`

#### Actual active state

`state/control/extensions/active.yml`

Must record:

* desired config revision
* resolved active pack set
* dependency closure
* generation id
* published effective catalog reference
* validation timestamp
* status

#### Quarantine state

`state/control/extensions/quarantine.yml`

Must record:

* blocked packs
* affected dependents
* reason codes
* timestamps
* acknowledgements / overrides if allowed

#### Compiled runtime-facing outputs

`generated/effective/extensions/**`

Must carry:

* catalog/view
* artifact map
* generation lock

### 11.3 Pack manifest

Each `pack.yml` must carry at least:

* `pack_id`
* `version`
* `compatibility`
* `dependencies`
* `provenance`
* `origin_class`
* `trust_hints`
* `content_entrypoints`

### 11.4 Origin class

All packs use the same `pack.yml` contract.

`origin_class` allowed values:

* `first_party_bundled`
* `first_party_external`
* `third_party`

### 11.5 Runtime rule

Raw packs never participate directly in runtime. Runtime sees only the published generated effective view that matches the active state and generation lock.

---

## 12. Final ratified proposal architecture

### 12.1 Raw proposal placement

Raw proposals live at:

```text
inputs/exploratory/proposals/<kind>/<proposal-id>/**
```

Archives live at:

```text
inputs/exploratory/proposals/.archive/**
```

### 12.2 Proposal non-canonical rule

Proposals remain:

* non-canonical
* non-runtime
* non-policy
* temporary by default
* promotable only by landing into durable target surfaces

### 12.3 Proposal registry

Generated proposal discovery lives at:

```text
generated/proposals/registry.yml
```

### 12.4 Commit policy

`generated/proposals/registry.yml` is **committed by default**.

### 12.5 Promotion rules

Allowed promotion targets:

* `framework/**`
* `instance/**`
* `inputs/additive/extensions/**` for durable pack outputs
* repo-native non-Octon durable surfaces

Disallowed promotion targets:

* `state/**`
* `generated/**`
* back into `inputs/exploratory/**`

---

## 13. Final ratified locality/scope architecture

### Canonical placement

```text
instance/locality/
  manifest.yml
  registry.yml
  scopes/<scope-id>/scope.yml
```

### Ratified v1 rule

Each `scope_id` has exactly **one** `root_path` in v1.

Allowed refinements:

* `include_globs`
* `exclude_globs`

Disallowed in v1:

* multiple disjoint roots
* overlapping active scopes
* hierarchical inheritance
* ancestor-chain composition
* descendant-local `.octon` roots

### Generated locality outputs

* `generated/effective/locality/scopes.effective.yml`
* `generated/effective/locality/artifact-map.yml`
* `generated/effective/locality/generation.lock.yml`

### Mission relationship

Missions remain under `instance/orchestration/missions/**`. They may reference scopes; they do not define scope.

---

## 14. Final ratified memory / context / continuity / decisions architecture

### Memory principle

Memory is routing/classification, not a directory.

### Durable authored memory

* memory policy: `framework/agency/governance/MEMORY.md`
* shared durable context: `instance/cognition/context/shared/**`
* scope durable context: `instance/cognition/context/scopes/<scope-id>/**`
* ADRs: `instance/cognition/decisions/**`

### Mutable operational memory/evidence

* repo continuity: `state/continuity/repo/**`
* scope continuity: `state/continuity/scopes/<scope-id>/**`
* run evidence: `state/evidence/runs/**`
* operational decision evidence: `state/evidence/decisions/**`

### Derived memory views

* summaries: `generated/cognition/summaries/**`
* graphs: `generated/cognition/graph/**`
* projections: `generated/cognition/projections/**`

### Explicit sequencing rule

In migration and rollout:

* move repo continuity first
* add scope continuity only after locality registry and validation are live

---

## 15. Final ratified generated / effective / registry architecture

`generated/**` contains all rebuildable outputs.

### Effective outputs

* `generated/effective/locality/**`
* `generated/effective/capabilities/**`
* `generated/effective/extensions/**`

Each effective domain includes:

* catalog/view
* artifact map
* generation lock

### Cognition outputs

* `generated/cognition/graph/**`
* `generated/cognition/projections/definitions/**`
* `generated/cognition/projections/materialized/**`
* `generated/cognition/summaries/**`

### Proposal discovery outputs

* `generated/proposals/registry.yml`

### Publication rules

* generated outputs must carry source digests, generator version, schema version, generation timestamp
* generated outputs may be deleted and rebuilt
* generated outputs never become source-of-truth
* runtime-facing effective outputs fail closed if stale
* human-facing generated outputs may be inspected stale only with explicit warnings

---

## 16. Final ratified validation / fail-closed / quarantine / staleness architecture

### Global fail-closed

Fail globally on:

* invalid `octon.yml`
* invalid class-root bindings
* invalid framework contracts
* invalid required instance control metadata
* invalid or stale required effective outputs
* native/extension collisions in active published generation
* raw-input dependency violations

### Scope-local quarantine

Quarantine a scope for:

* malformed `scope.yml`
* overlapping scope bindings
* malformed scope context
* malformed scope continuity
* malformed scope decision evidence

Quarantine records live under:

* `state/control/locality/quarantine.yml`

### Pack-local quarantine

Quarantine a pack and dependents for:

* invalid manifest
* dependency closure failure
* compatibility failure
* trust failure
* stale or invalid compiled generation

Quarantine records live under:

* `state/control/extensions/quarantine.yml`

### Desired/actual/compiled consistency rule

Runtime may use extension compiled outputs only when:

* `instance/extensions.yml` desired state resolves successfully
* `state/control/extensions/active.yml` references a valid published generation
* corresponding generation locks in `generated/effective/extensions/**` are fresh
* no active quarantine blocks the published set

### Proposal validation

Proposal validation remains workflow-local:

* schema validity
* subtype validity
* lifecycle validity
* promotion-target validity
* non-canonical rule enforcement

Invalid proposals block proposal workflows and registry generation only.

---

## 17. Final ratified migration and rollout plan

### Ratified order

1. Ratify super-root taxonomy and overlay model.
2. Extend `octon.yml`, `framework/manifest.yml`, and `instance/manifest.yml`.
3. Enforce raw-input dependency ban.
4. Introduce class roots with compatibility shims.
5. Move generated/effective outputs into `generated/**`.
6. Move **repo continuity and retained evidence** into `state/**`.
7. Move durable repo authority into `instance/**`, including ingress/governance/agency/assurance overlays.
8. Introduce locality registry under `instance/locality/**` and validation.
9. Introduce **scope continuity** under `state/continuity/scopes/**`.
10. Internalize extension packs into `inputs/additive/extensions/**`.
11. Add desired/actual/quarantine/compiled extension pipeline.
12. Internalize proposals into `inputs/exploratory/proposals/**`.
13. Move proposal registry into `generated/proposals/registry.yml`.
14. Update routing, graph, projection, and generation pipelines.
15. Remove legacy mixed-path and external-workspace support.

### Ratified constraints

* do not land internalized packs before raw-input dependency enforcement
* do not land scope continuity before scope registry and validation
* do not remove legacy paths before profiles are live
* do not ship repo snapshot without enabled-pack dependency closure

---

## 18. Final generated-output commit policy matrix

| Generated path class                              | Commit by default | Reason                                                                                     |
| ------------------------------------------------- | ----------------: | ------------------------------------------------------------------------------------------ |
| `generated/effective/**`                          |               Yes | runtime-facing, reviewable, needed for explicit compiled diffs and offline reproducibility |
| `generated/effective/**/artifact-map.yml`         |               Yes | needed to explain compiled provenance and validate source mapping                          |
| `generated/effective/**/generation.lock.yml`      |               Yes | needed for freshness and fail-closed validation                                            |
| `generated/cognition/summaries/**`                |               Yes | small, human-reviewable, useful in PRs                                                     |
| `generated/proposals/registry.yml`                |               Yes | small, reviewable, improves proposal discoverability                                       |
| `generated/cognition/projections/definitions/**`  |               Yes | small compiled projection definitions are useful review artifacts                          |
| `generated/cognition/projections/materialized/**` |                No | higher churn, rebuild locally by default                                                   |
| `generated/cognition/graph/**`                    |                No | bulky/high churn, rebuild locally by default                                               |

### Commit-policy rules

* committed generated outputs remain non-authoritative
* staleness validation still applies
* repos do not get ad hoc per-path overrides in v1 except where a later explicit policy proposal adds them

---

## 19. Updated proposal-writing dependency map

1. Super-root semantics and taxonomy
2. Root manifest, profiles, and export semantics
3. Framework/core architecture
4. Repo-instance architecture
5. Overlay and ingress model
6. Locality/scope architecture
7. Portability / compatibility / trust / provenance
8. State / evidence / continuity architecture
9. Inputs / additive / extensions architecture
10. Inputs / exploratory / proposals architecture
11. Generated / effective / graph / projection / registry architecture
12. Memory / context / decisions architecture
13. Capability-routing architecture
14. Validation / fail-closed / quarantine / staleness architecture
15. Migration and rollout plan

---

## 20. Updated final proposal design packets

### Packet 1 — Super-Root Semantics and Taxonomy

* **Proposal title:** Octon Super-Root Semantics and Five-Class Taxonomy
* **Why this proposal exists:** replace the current mixed-tree model with a class-root super-root.
* **Problem statement:** current `.octon/` mixes portable core, repo authority, state, generated outputs, and externalized inputs. ([GitHub][1])
* **Final target-state decision summary:** five class roots with `inputs/**` as the non-authoritative raw-input class.
* **Scope:** class semantics, dependency-direction rules, authored vs state vs generated distinction.
* **Non-goals:** sidecar target state, descendant-local harnesses, `.octon.global`, `.octon.graphs`, generic `memory/`.
* **Canonical paths and artifact classes:** `/.octon/{framework,instance,inputs,state,generated}/**`
* **Authority and boundary implications:** only `framework/` and `instance/` are authored authority.
* **Schema / manifest / contract changes required:** umbrella spec, root README, taxonomy contract.
* **Validation / assurance / fail-closed implications:** raw-input dependency ban mandatory.
* **Portability / compatibility / trust implications:** defines all later portability rules.
* **Migration / rollout implications:** phase 1 prerequisite.
* **Dependencies on other proposals:** none.
* **Suggested implementation order:** 1.
* **Acceptance criteria:** class roots ratified; no alternate topologies remain active.
* **Supporting evidence to reference:** current `.octon/README.md`, shared-foundation doc, `octon.yml`. ([GitHub][1])
* **Settled decisions that must not be re-litigated:** five classes; integrated inputs; single super-root.
* **Remaining narrow open questions, if any:** none.

### Packet 2 — Root Manifest, Profiles, and Export Semantics

* **Proposal title:** Root Manifest and Behaviorally Complete Profile Model
* **Why this proposal exists:** whole-tree copy must be replaced by profile-driven install/export/update.
* **Problem statement:** current `octon.yml` is path-allowlist based and lacks the final profile/version model. ([GitHub][2])
* **Final target-state decision summary:** `octon.yml` defines class roots, versions, policies, and profiles; `repo_snapshot` is behaviorally complete and includes enabled pack dependency closure.
* **Scope:** `octon.yml`, `framework/manifest.yml`, `instance/manifest.yml`, profiles.
* **Non-goals:** v1 minimal repo snapshot profile.
* **Canonical paths and artifact classes:** root manifest and companion manifests.
* **Authority and boundary implications:** profile semantics are authoritative control metadata.
* **Schema / manifest / contract changes required:** class-root keys, release/API version keys, profile syntax.
* **Validation / assurance / fail-closed implications:** missing enabled pack in `repo_snapshot` is export failure.
* **Portability / compatibility / trust implications:** snapshot portability becomes explicit and reproducible.
* **Migration / rollout implications:** replaces current `portable:` guidance.
* **Dependencies on other proposals:** Packet 1.
* **Suggested implementation order:** 2.
* **Acceptance criteria:** `bootstrap_core`, `repo_snapshot`, `pack_bundle`, `full_fidelity` defined and validator-enforced.
* **Supporting evidence to reference:** current `octon.yml`, current README adoption guidance. ([GitHub][1])
* **Settled decisions that must not be re-litigated:** no raw whole-tree copy by default; no optional enabled-pack omission in `repo_snapshot`.
* **Remaining narrow open questions, if any:** exact manifest schema syntax only.

### Packet 3 — Framework/Core Architecture

* **Proposal title:** Portable Framework/Core Architecture
* **Why this proposal exists:** portable core must be isolated from repo-owned authority and state.
* **Problem statement:** current repo still stores framework artifacts in a mixed domain tree. ([GitHub][1])
* **Final target-state decision summary:** portable authored core lives under `framework/**`, still domain-organized internally.
* **Scope:** governance, runtime, capabilities, scaffolding, assurance, cognition reference context, engine.
* **Non-goals:** repo-local context, ADRs, continuity, proposals, raw packs.
* **Canonical paths and artifact classes:** `framework/**`
* **Authority and boundary implications:** framework is base authored authority.
* **Schema / manifest / contract changes required:** `framework/manifest.yml`, overlay registry binding.
* **Validation / assurance / fail-closed implications:** undeclared instance overlays invalid.
* **Portability / compatibility / trust implications:** framework is the default portable core bundle.
* **Migration / rollout implications:** current top-level domains rehome here.
* **Dependencies on other proposals:** Packets 1 and 2.
* **Suggested implementation order:** 3.
* **Acceptance criteria:** framework bundle installable without repo-specific state.
* **Supporting evidence to reference:** current `.octon/README.md`, shared-foundation doc. ([GitHub][1])
* **Settled decisions that must not be re-litigated:** framework stays inside the super-root.
* **Remaining narrow open questions, if any:** none.

### Packet 4 — Repo-Instance Architecture

* **Proposal title:** Repo-Instance Authoritative Layer
* **Why this proposal exists:** durable repo-owned authority needs a distinct class root.
* **Problem statement:** current repo mixes bootstrap, context, decisions, missions, and other repo artifacts with framework assets. ([GitHub][1])
* **Final target-state decision summary:** durable repo authority lives under `instance/**`.
* **Scope:** bootstrap, ingress, locality, cognition context/decisions, repo-native capabilities, missions, extension desired config.
* **Non-goals:** mutable state, generated outputs, raw packs, proposals.
* **Canonical paths and artifact classes:** `instance/**`
* **Authority and boundary implications:** instance is authoritative for repo-owned durable artifacts.
* **Schema / manifest / contract changes required:** `instance/manifest.yml`, repo-identity and overlay bindings.
* **Validation / assurance / fail-closed implications:** invalid instance control data fails closed for affected features.
* **Portability / compatibility / trust implications:** repo-specific by default.
* **Migration / rollout implications:** current repo-local surfaces move here.
* **Dependencies on other proposals:** Packets 1 and 2.
* **Suggested implementation order:** 4.
* **Acceptance criteria:** durable repo authority is not stored in `state/**`, `generated/**`, or raw inputs.
* **Supporting evidence to reference:** current README and continuity/memory contracts. ([GitHub][1])
* **Settled decisions that must not be re-litigated:** durable repo authority belongs in `instance/**`.
* **Remaining narrow open questions, if any:** none.

### Packet 5 — Overlay and Ingress Model

* **Proposal title:** Repo-Instance Overlay and Ingress Model
* **Why this proposal exists:** the assessment identified under-specified repo-local overlays and ingress/governance placement.
* **Problem statement:** canonical homes and machine-enforceable overlay rules were missing.
* **Final target-state decision summary:** add explicit overlay-capable instance surfaces, `framework/overlay-points/registry.yml`, `instance/manifest.yml#enabled_overlay_points`, and canonical internal ingress at `instance/ingress/AGENTS.md`.
* **Scope:** governance, agency, assurance overlays; ingress adapters.
* **Non-goals:** blanket instance shadow trees.
* **Canonical paths and artifact classes:** `framework/overlay-points/registry.yml`, `instance/governance/**`, `instance/agency/**`, `instance/assurance/**`, `instance/ingress/**`
* **Authority and boundary implications:** overlays are authoritative only when bound to declared overlay points.
* **Schema / manifest / contract changes required:** overlay-point schema, merge modes, enabled overlay list.
* **Validation / assurance / fail-closed implications:** undeclared overlay artifacts are invalid.
* **Portability / compatibility / trust implications:** overlay bindings are repo-specific.
* **Migration / rollout implications:** repo-local governance and ingress artifacts move here from mixed root paths.
* **Dependencies on other proposals:** Packets 1–4.
* **Suggested implementation order:** 5.
* **Acceptance criteria:** no ad hoc overlay paths; repo-root adapters are thin only.
* **Supporting evidence to reference:** current repo-root `AGENTS.md`, `.octon/README.md`, assessment findings. ([GitHub][3])
* **Settled decisions that must not be re-litigated:** overlay points must be declared and machine-enforced.
* **Remaining narrow open questions, if any:** none.

### Packet 6 — Locality and Scope Registry

* **Proposal title:** Repo-Instance Locality and Scope Registry
* **Why this proposal exists:** Octon needs locality without descendant-local harnesses.
* **Problem statement:** current repo has locality guidance but not the final class-root placement or v1 cardinality rule. ([GitHub][4])
* **Final target-state decision summary:** locality lives under `instance/locality/**`; one `scope_id`, one `root_path` in v1; no hierarchy.
* **Scope:** registry, scope manifests, resolution, mission binding.
* **Non-goals:** descendant `.octon/` roots, hierarchical scopes, disjoint multi-root scopes in v1.
* **Canonical paths and artifact classes:** `instance/locality/**`, `generated/effective/locality/**`
* **Authority and boundary implications:** scope registry is repo-owned authored authority.
* **Schema / manifest / contract changes required:** manifest, registry, scope schema, generation outputs.
* **Validation / assurance / fail-closed implications:** overlaps quarantine locally.
* **Portability / compatibility / trust implications:** repo-specific by default.
* **Migration / rollout implications:** scope continuity lands only after this proposal.
* **Dependencies on other proposals:** Packets 2, 4, 5.
* **Suggested implementation order:** 6.
* **Acceptance criteria:** deterministic one-scope resolution; no overlapping active scopes.
* **Supporting evidence to reference:** current locality principle and skills architecture. ([GitHub][4])
* **Settled decisions that must not be re-litigated:** no descendant harness roots; no hierarchical inheritance; no multi-root scopes in v1.
* **Remaining narrow open questions, if any:** none.

### Packet 7 — State, Evidence, and Continuity

* **Proposal title:** State, Evidence, and Continuity Class Root
* **Why this proposal exists:** mutable truth and retained evidence need a distinct home.
* **Problem statement:** current continuity/evidence placement is mixed and not class-rooted. ([GitHub][5])
* **Final target-state decision summary:** active continuity under `state/continuity/**`; retained evidence under `state/evidence/**`; control state under `state/control/**`.
* **Scope:** repo continuity, scope continuity, run evidence, operational decision evidence, validation/migration receipts, control state.
* **Non-goals:** ADRs, raw proposals, raw packs, generated outputs.
* **Canonical paths and artifact classes:** `state/**`
* **Authority and boundary implications:** state is operational truth only.
* **Schema / manifest / contract changes required:** continuity schema, evidence schema, control-state schema.
* **Validation / assurance / fail-closed implications:** append-only and retention semantics enforced by class.
* **Portability / compatibility / trust implications:** never bootstrap-portable.
* **Migration / rollout implications:** repo continuity moves before scope continuity.
* **Dependencies on other proposals:** Packets 1, 2, 4, 6.
* **Suggested implementation order:** 7.
* **Acceptance criteria:** resetting state never deletes durable repo authority.
* **Supporting evidence to reference:** current continuity README and memory map. ([GitHub][5])
* **Settled decisions that must not be re-litigated:** retained evidence is not “generated.”
* **Remaining narrow open questions, if any:** none.

### Packet 8 — Inputs/Additive/Extensions

* **Proposal title:** Internal Extension-Pack Inputs and Desired/Actual/Compiled Pipeline
* **Why this proposal exists:** extension packs must be integrated without creating a second authority surface.
* **Problem statement:** earlier models separated raw packs from selection ambiguously; desired vs active state was underspecified.
* **Final target-state decision summary:** raw packs in `inputs/additive/extensions/**`; desired config in `instance/extensions.yml`; actual active state in `state/control/extensions/active.yml`; compiled outputs in `generated/effective/extensions/**`.
* **Scope:** pack layout, pack manifest, desired/active/quarantine/compiled model.
* **Non-goals:** pack-owned governance, runtime authority, services, mutable state.
* **Canonical paths and artifact classes:** `inputs/additive/extensions/**`, `instance/extensions.yml`, `state/control/extensions/**`, `generated/effective/extensions/**`
* **Authority and boundary implications:** packs are subordinate raw inputs only.
* **Schema / manifest / contract changes required:** unified `pack.yml`, `instance/extensions.yml`, active/quarantine schema, artifact maps, generation locks.
* **Validation / assurance / fail-closed implications:** dependency closure, trust, compatibility, collision, stale generation, raw-path dependency ban.
* **Portability / compatibility / trust implications:** `repo_snapshot` includes enabled pack dependency closure by default.
* **Migration / rollout implications:** internalizes earlier sidecar proposal and removes ambiguity about snapshot completeness.
* **Dependencies on other proposals:** Packets 1–7, 12.
* **Suggested implementation order:** 8.
* **Acceptance criteria:** no runtime consumer reads raw pack paths; desired/actual/compiled states are distinct and coherent.
* **Supporting evidence to reference:** current extension-pack proposal baseline and assessment findings. ([GitHub][6])
* **Settled decisions that must not be re-litigated:** raw packs live under `inputs/additive/extensions/**`; `instance/extensions.yml` remains the desired config surface.
* **Remaining narrow open questions, if any:** none.

### Packet 9 — Inputs/Exploratory/Proposals

* **Proposal title:** Internal Proposal Workspace under `inputs/exploratory/proposals/**`
* **Why this proposal exists:** proposals must be integrated without becoming canonical.
* **Problem statement:** current repo still uses an external `.proposals/` workspace. ([GitHub][7])
* **Final target-state decision summary:** raw proposals move under `inputs/exploratory/proposals/**`; archives stay there; generated registry moves to `generated/proposals/registry.yml`; registry committed by default.
* **Scope:** active proposals, archives, manifests, promotion rules, registry.
* **Non-goals:** runtime/policy authority.
* **Canonical paths and artifact classes:** `inputs/exploratory/proposals/**`, `generated/proposals/registry.yml`
* **Authority and boundary implications:** proposals remain non-authoritative even inside the super-root.
* **Schema / manifest / contract changes required:** proposal schema, subtype schema, registry schema, archive lineage.
* **Validation / assurance / fail-closed implications:** proposal linting blocks proposal workflows only.
* **Portability / compatibility / trust implications:** proposals excluded from bootstrap and repo snapshot.
* **Migration / rollout implications:** internalizes external proposal workspace.
* **Dependencies on other proposals:** Packets 1, 2, 4.
* **Suggested implementation order:** 9.
* **Acceptance criteria:** new proposals land only under `inputs/exploratory/proposals/**`; registry remains derived and committed by default.
* **Supporting evidence to reference:** current `.proposals/README.md`. ([GitHub][7])
* **Settled decisions that must not be re-litigated:** proposals are inside the super-root but remain non-canonical.
* **Remaining narrow open questions, if any:** none.

### Packet 10 — Generated / Effective / Cognition / Registry

* **Proposal title:** Generated Outputs, Effective Views, and Commit Policy
* **Why this proposal exists:** the final architecture needs one coherent generated class and a default commit policy.
* **Problem statement:** current repo spreads generated outputs across mixed domain paths and earlier blueprints left commit policy open. ([GitHub][1])
* **Final target-state decision summary:** all rebuildable outputs live under `generated/**`; commit-by-default matrix is now ratified.
* **Scope:** effective outputs, graphs, projections, summaries, proposal registry, artifact maps, generation locks.
* **Non-goals:** making generated outputs authoritative.
* **Canonical paths and artifact classes:** `generated/**`
* **Authority and boundary implications:** generated outputs are never SSOT.
* **Schema / manifest / contract changes required:** artifact map, generation lock, proposal registry, projection definition contracts.
* **Validation / assurance / fail-closed implications:** stale effective outputs fail closed.
* **Portability / compatibility / trust implications:** generated outputs are rebuilt or committed per matrix, never treated as portable core truth.
* **Migration / rollout implications:** current generated paths rehome here.
* **Dependencies on other proposals:** Packets 1–9.
* **Suggested implementation order:** 10.
* **Acceptance criteria:** every generated output points to canonical inputs; commit matrix implemented.
* **Supporting evidence to reference:** current runtime-vs-ops contract and memory map. ([GitHub][5])
* **Settled decisions that must not be re-litigated:** generated outputs remain non-authoritative.
* **Remaining narrow open questions, if any:** none.

### Packet 11 — Memory, Context, ADRs, and Operational Decision Evidence

* **Proposal title:** Memory Routing and Decision Surfaces
* **Why this proposal exists:** the class split needs explicit routing of memory classes.
* **Problem statement:** current memory routing is good conceptually but still tied to the mixed-tree baseline. ([GitHub][5])
* **Final target-state decision summary:** durable context and ADRs in `instance/**`; continuity and operational evidence in `state/**`; summaries and graphs in `generated/**`.
* **Scope:** memory policy, context, ADRs, continuity, run evidence, operational decision evidence.
* **Non-goals:** generic `memory/` surface.
* **Canonical paths and artifact classes:** `framework/agency/governance/MEMORY.md`, `instance/cognition/**`, `state/**`, `generated/cognition/**`
* **Authority and boundary implications:** ADRs remain authored authority; operational evidence remains operational truth.
* **Schema / manifest / contract changes required:** memory-map rewrite, continuity contracts, decision-summary contracts.
* **Validation / assurance / fail-closed implications:** duplicate authoritative ledgers are invalid.
* **Portability / compatibility / trust implications:** context/ADRs repo-specific by default.
* **Migration / rollout implications:** current context/continuity/decision files reclassify and move.
* **Dependencies on other proposals:** Packets 4, 6, 7, 10.
* **Suggested implementation order:** 11.
* **Acceptance criteria:** each memory class has one canonical home; no `memory/` directory exists.
* **Supporting evidence to reference:** current memory map and continuity README. ([GitHub][5])
* **Settled decisions that must not be re-litigated:** memory is routing, not a directory.
* **Remaining narrow open questions, if any:** none.

### Packet 12 — Capability Routing and Host Integration

* **Proposal title:** Scope-Aware Capability Routing and Host Integration
* **Why this proposal exists:** mixed-technology repos need deterministic routing without local sidecars.
* **Problem statement:** current repo routing is root-owned but not yet aligned to the ratified class-root architecture. ([GitHub][8])
* **Final target-state decision summary:** routing compiles from framework native, instance native, generated extension views, selectors, fingerprints, and scope metadata.
* **Scope:** routing inputs, generated routing view, host-adapter consumption.
* **Non-goals:** descendant-local routing files, raw pack consumption.
* **Canonical paths and artifact classes:** `generated/effective/capabilities/routing.effective.yml`
* **Authority and boundary implications:** routing is compiled; scope metadata influences but does not author capabilities.
* **Schema / manifest / contract changes required:** routing schema, scope metadata fields, adapter binding contract.
* **Validation / assurance / fail-closed implications:** invalid routing inputs block publication.
* **Portability / compatibility / trust implications:** framework routing portable; scope hints repo-specific.
* **Migration / rollout implications:** adapters must switch from raw paths to generated routing views.
* **Dependencies on other proposals:** Packets 6, 8, 10.
* **Suggested implementation order:** 12.
* **Acceptance criteria:** deterministic routing candidate set; no adapter reads raw input paths.
* **Supporting evidence to reference:** current skills architecture. ([GitHub][8])
* **Settled decisions that must not be re-litigated:** no descendant-local activation surfaces.
* **Remaining narrow open questions, if any:** exact ranking weights only.

### Packet 13 — Portability, Compatibility, Trust, and Provenance

* **Proposal title:** Portability, Compatibility, Trust, and Provenance Contract
* **Why this proposal exists:** safe install/update/export requires explicit profile, compatibility, and trust rules.
* **Problem statement:** current `octon.yml` lacks the ratified release/API version and profile model. ([GitHub][2])
* **Final target-state decision summary:** portability is profile-driven; `repo_snapshot` is complete; pack provenance rides with pack; trust stays in `instance/extensions.yml`.
* **Scope:** profiles, version keys, trust tiers, provenance, pack origin class.
* **Non-goals:** external registry protocol in v1.
* **Canonical paths and artifact classes:** `octon.yml`, manifests, `instance/extensions.yml`, `pack.yml`
* **Authority and boundary implications:** trust and compatibility remain root/instance governed.
* **Schema / manifest / contract changes required:** version keys, profile schema, pack provenance fields, origin class.
* **Validation / assurance / fail-closed implications:** incompatible or untrusted packs do not publish effective outputs.
* **Portability / compatibility / trust implications:** this is the normative portability/trust contract.
* **Migration / rollout implications:** must land before extension activation.
* **Dependencies on other proposals:** Packets 2, 3, 4, 8.
* **Suggested implementation order:** 13.
* **Acceptance criteria:** profile semantics and compatibility keys are validator-enforced.
* **Supporting evidence to reference:** current `octon.yml`, current extension proposal baseline. ([GitHub][2])
* **Settled decisions that must not be re-litigated:** no minimal repo snapshot in v1; one-file `instance/extensions.yml` in v1.
* **Remaining narrow open questions, if any:** none.

### Packet 14 — Validation, Fail-Closed, Quarantine, and Staleness

* **Proposal title:** Unified Validation and Failure Semantics
* **Why this proposal exists:** the ratified super-root needs one coherent failure model.
* **Problem statement:** current repo has fail-closed pieces, but not the full ratified class-root failure model. ([GitHub][1])
* **Final target-state decision summary:** global fail-closed for framework/manifest/effective failures; scope-local quarantine; pack-local quarantine; proposal-local lint failures only.
* **Scope:** validation entrypoints, quarantine units, freshness, desired/actual/compiled consistency.
* **Non-goals:** permissive fallback to raw pack/proposal paths.
* **Canonical paths and artifact classes:** `state/control/**`, `state/evidence/validation/**`, `generated/effective/**`
* **Authority and boundary implications:** only authority/effective failures can block runtime globally.
* **Schema / manifest / contract changes required:** quarantine schemas, generation lock schema, active-state schema.
* **Validation / assurance / fail-closed implications:** this proposal defines them.
* **Portability / compatibility / trust implications:** receipts are repo-local state/evidence.
* **Migration / rollout implications:** must land before extension and scope cutover.
* **Dependencies on other proposals:** Packets 1–13.
* **Suggested implementation order:** 14.
* **Acceptance criteria:** stale effective views are refused; scope and pack quarantines observable; proposals never block runtime.
* **Supporting evidence to reference:** current runtime-vs-ops contract and extension baseline. ([GitHub][1])
* **Settled decisions that must not be re-litigated:** fail-closed remains canonical; raw `inputs/**` never become runtime dependencies.
* **Remaining narrow open questions, if any:** none.

### Packet 15 — Migration and Rollout

* **Proposal title:** Migration and Rollout Plan for the Ratified Super-Root Blueprint
* **Why this proposal exists:** the target state materially differs from the current repo.
* **Problem statement:** current repo is still mixed-tree, external-proposals, proposal-only extension baseline. ([GitHub][1])
* **Final target-state decision summary:** migrate in staged cutovers with raw-input dependency enforcement, repo-before-scope continuity, and complete snapshot semantics.
* **Scope:** phases, shims, converters, cutover checks, acceptance gates.
* **Non-goals:** re-arguing target topology.
* **Canonical paths and artifact classes:** all class roots and legacy adapters.
* **Authority and boundary implications:** migration must never create a second authority surface.
* **Schema / manifest / contract changes required:** coordinated changes across manifests, locality, pack, proposal, and validation contracts.
* **Validation / assurance / fail-closed implications:** partial inconsistent cutovers blocked.
* **Portability / compatibility / trust implications:** legacy compatibility shims are temporary only.
* **Migration / rollout implications:** this is the rollout plan.
* **Dependencies on other proposals:** Packets 1–14.
* **Suggested implementation order:** 15.
* **Acceptance criteria:** repo can move from current state to ratified target state without raw-input leakage or authority ambiguity.
* **Supporting evidence to reference:** current root listing, README, `octon.yml`, `.proposals/README.md`. ([GitHub][3])
* **Settled decisions that must not be re-litigated:** five-class super-root; integrated `inputs/**`; no v1 minimal repo snapshot.
* **Remaining narrow open questions, if any:** none.

---

## 21. Final settled decisions that must not be re-litigated

* `/.octon/` is the single authoritative super-root.
* The final super-root has five class roots.
* Extensions are inside `inputs/additive/extensions/**`.
* Proposals are inside `inputs/exploratory/proposals/**`.
* `instance/extensions.yml` remains the single desired config file in v1.
* `state/control/extensions/active.yml` is actual active extension state.
* `repo_snapshot` is behaviorally complete and includes enabled pack dependency closure.
* There is no v1 `repo_snapshot_minimal`.
* Proposals remain non-canonical.
* Raw `inputs/**` paths never become direct runtime or policy dependencies.
* Scope model is root-owned, one active scope per path, one root path per scope in v1.
* Hierarchical scope inheritance is rejected in v1.
* Memory remains routing/classification, not a generic directory.
* No descendant-local `.octon/` roots.
* No `.octon.global/`.
* No `.octon.graphs/`.
* No generic `memory/` surface.
* Generated outputs remain non-authoritative.
* Proposal registry is committed by default.
* First-party bundled packs use the same `pack.yml` contract with an explicit `origin_class`.

---

## 22. Remaining narrow open questions, only if unavoidable

None.

The ratified blueprint is fully settled for proposal drafting and implementation planning.

[1]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/README.md "raw.githubusercontent.com"
[2]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/octon.yml "raw.githubusercontent.com"
[3]: https://github.com/jamesryancooper/octon/tree/main "GitHub - jamesryancooper/octon · GitHub"
[4]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/cognition/governance/principles/locality.md "raw.githubusercontent.com"
[5]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/cognition/runtime/context/memory-map.md "raw.githubusercontent.com"
[6]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.proposals/architecture/extensions-sidecar-pack-system/architecture/target-architecture.md "raw.githubusercontent.com"
[7]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.proposals/README.md "raw.githubusercontent.com"
[8]: https://raw.githubusercontent.com/jamesryancooper/octon/main/.octon/capabilities/_meta/architecture/architecture.md "raw.githubusercontent.com"

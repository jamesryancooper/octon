# Proposal System Critique

## 1. Executive conclusion

Octon’s proposal system is **fundamentally sound**, not off-course. The repo already gives proposals the right conceptual role: they are **temporary, non-canonical, manifest-governed change packets** that exist to shape and review change before durable authority is promoted into `framework/**`, `instance/**`, and retained evidence surfaces under `state/**`. The broader repo rules already keep proposals out of direct runtime and policy authority, keep generated views non-authoritative, and position the proposal registry as a discovery projection rather than a source of truth. That core model should be preserved.

What should be preserved: the non-canonical boundary, the current four kinds (`design`, `migration`, `policy`, `architecture`), the current lifecycle vocabulary, required declaration of `promotion_targets`, the rule that canonical targets must not depend on proposal paths, the committed-but-non-authoritative registry, and the existing create/audit workflow pattern that writes evidence bundles into `state/evidence/**`.

What must change is narrower and more surgical: **(1) align the contract layers, (2) make the registry fail-closed in both directions, (3) normalize archive integrity, (4) add explicit promote/archive operations, and (5) stop over-authoring low-value navigation inventory.** The repo evidence does not justify a redesign or new proposal kinds; it does justify tightening the integrity seams that are currently weak.

## 2. Current-state reconstruction

### Verified behavior

Repo-wide, Octon already has a crisp authority model. `framework/**` and `instance/**` are the authored durable authorities; `state/**` is authoritative for mutable operational truth and retained evidence; `generated/**` is rebuildable and non-authoritative; raw `inputs/**` are not supposed to act as runtime or policy authority. The proposals workspace is explicitly carved out as non-canonical, temporary, excluded from `bootstrap_core` and `repo_snapshot`, and not allowed to become a direct runtime or policy dependency.

Inside `/.octon/inputs/exploratory/proposals/`, the repo defines a specific package contract. Every manifest-governed proposal should have `proposal.yml`, exactly one subtype manifest, `README.md`, `navigation/artifact-catalog.md`, and `navigation/source-of-truth-map.md`, plus subtype-specific files. The standard defines statuses `draft`, `in-review`, `accepted`, `implemented`, `rejected`, `archived`; requires repo-relative `promotion_targets`; requires archived proposals to move under `.archive/<kind>/<proposal_id>` with archive metadata; and defines `implemented` as “durable outputs promoted into the declared promotion targets.”

The system is not ad hoc. I found standards for all four kinds, template surfaces for all four kinds, validators for all four kinds, create workflows for all four kinds, and audit workflows for all four kinds. The create workflows explicitly treat the registry as an updated artifact, require subtype and standard validators to pass, and emit workflow bundles under `/.octon/state/evidence/runs/workflows/`. The audit workflows also write evidence under `state/evidence/**` and run fail-closed validation gates.

The live registry currently has **two active entries**: the design proposal `studio-graph-ux-design-package` and the architecture proposal `migration-rollout`, both with status `accepted`. The live packages show two different maturity levels: the design package is workable but fairly package-local in its navigation artifacts, while `migration-rollout` is much more integrated with Octon’s broader authority, evidence, and migration semantics.

Archive behavior is mixed. There are clearly well-formed archived packages, such as `generated-effective-cognition-registry` and `extensions-sidecar-pack-system`, whose manifests show `status: archived`, archive metadata, original path, and promotion evidence. But there are also broken or inconsistent archives: `mission-scoped-reversible-autonomy` sits in the archive path while its manifest still says `status: accepted` and has no archive block; `self-audit-and-release-hardening` records `archived_from_status: proposed`, which is outside the defined lifecycle; `capability-routing-host-integration` is present in the archive tree and registry but the visible archive directory only exposes `resources/`, and the expected `proposal.yml` 404s.

### Inferred behavior

Some of the archived design entries look like **historical imports or legacy-normalized remnants**, not proposal packages created under the current standard. The registry contains archived design entries under `.octon/inputs/exploratory/proposals/.archive/design/**` with `archived_from_status: legacy-unknown` and `original_path` values under older `.archive/.design-packages/**` paths, while the visible `.archive/` tree currently exposes only `architecture/`. That strongly suggests partial migration or legacy carry-forward, not a fully normalized archive corpus.

The subtype JSON schemas are also not the effective contract in practice. The live template manifests and validators agree with each other for architecture, migration, and policy, but the schema files disagree with both. That means the current human-readable standards + template manifests + validators are functioning as the real contract, while the schema layer is at least partly stale. That is an inference, but it is a strongly supported one.

## 3. Invariant map

### Current invariants that should remain

* **Keep — proposals are temporary and non-canonical.** They should continue to exist only as a review-and-promotion workspace, not as durable repository authority.
  **Placement:** framework-core.

* **Keep — the package SSOT order.** `proposal.yml` first, then exactly one subtype manifest, with the registry and README lower-order.
  **Placement:** framework-core.

* **Keep — the registry as projection only.** The registry shape is right-sized for discovery and should remain non-authoritative.
  **Placement:** generated/projection.

* **Keep — the current four kinds.** The evidence shows under-specified subtype contracts, not missing kinds.
  **Placement:** framework-core.

* **Keep — the current lifecycle vocabulary.** `draft`, `in-review`, `accepted`, `implemented`, `rejected`, `archived` are enough. “Stale,” “abandoned,” and “partial” should stay out of the status model.
  **Placement:** framework-core.

* **Keep — declared promotion targets and path discipline.** Proposal packages should keep naming durable targets explicitly, and durable targets must not retain dependencies on proposal-local paths.
  **Placement:** framework-core + workflow/runtime/tooling.

* **Keep — the source-of-truth map as a manual artifact.** It does real work when it explains package precedence and external authority boundaries.
  **Placement:** proposal-local convention.

### Current invariants that should be changed

* **Simplify — “artifact-catalog must be hand-authored” should change.** The template already describes it as something to regenerate when files move, and the design package’s version is mostly a flat list. Its semantic value should be merged into the source-of-truth map or generated automatically.
  **Placement:** generated/projection.

* **Tighten — “archive and registry may carry broken historical remnants” should change.** The main archive and main proposal registry should contain only standard-conformant proposal packets, not partial imports or inconsistent entries.
  **Placement:** archive-only.

* **Tighten — the schema layer cannot remain out of sync with templates and validators.** Either schemas become the machine-readable contract, or stale schema fields should be removed; the current mismatch is not acceptable as a stable invariant.
  **Placement:** framework-core.

* **Tighten — archive disposition support must be consistent.** The markdown standard, validator, and registry schema support `superseded`, but `proposal.schema.json` does not. One contract must win.
  **Placement:** framework-core.

## 4. Strengths

* Octon already has **excellent authority discipline**. The broader repo architecture gives proposals the correct temporary role and prevents them from quietly becoming runtime or policy truth.

* The base proposal model is already **promotion-oriented rather than document-oriented**. Requiring `promotion_targets`, defining `implemented` as a promoted state, and validating proposal-path independence are all architecturally correct choices.

* The registry projection shape is **basically right**. Active entries are lightweight; archived entries add just enough provenance (`disposition`, `archived_at`, `archived_from_status`, `original_path`) without making the registry itself authoritative.

* The workflow model already fits Octon’s evidence conventions. Create and audit flows write retained outputs under `state/evidence/**`, carry fail-closed done gates, and already treat proposal work as an operationally reviewable process rather than a loose document exercise.

* `migration-rollout` shows the system at its best: it ties proposal-local content to external canonical authorities, derived projections, boundary rules, migration receipts, and archived lineage without pretending the proposal itself is canonical. That is the right next-state pattern for serious cross-cutting proposals.

## 5. Gap and issue inventory

### 1) Contract-layer drift

**Type:** architectural, validation
**Why it matters:** the same subtype is currently described by standards, templates, schemas, and validators that do not agree, so authors and tools can disagree about what is “valid.”
**Where it appears:** subtype manifest contracts and archive disposition enums.
**Severity:** high
**Recommended action type:** **tighten**
**Placement:** framework-core

Architecture templates, live manifests, and validators use `architecture_scope` + `decision_type`, while the architecture schema requires `architecture_kind`. Migration templates and validators use `change_profile` + `release_state`, while the migration schema requires `validation.plan_template_path`. Policy templates and validators use `policy_area` + `change_type`, while the policy schema requires `policy_kind`. Separately, the proposal standard, validator, and registry schema allow `archive.disposition: superseded`, but `proposal.schema.json` does not.

### 2) Registry reverse-consistency is under-enforced

**Type:** discovery, validation, automation
**Why it matters:** if the registry can contain entries that are not backed by real, valid packages, discovery becomes unreliable for both humans and agents.
**Where it appears:** base validation logic and current registry/archive drift.
**Severity:** high
**Recommended action type:** **validate**
**Placement:** generated/projection

The validator I inspected proves that each manifest-bearing package has a matching registry entry, but I did not find a corresponding reverse audit that proves every registry entry points to one existing, valid package. That weakness aligns with the actual repo state: the visible `.archive` tree exposes only `architecture/`, while the registry contains many archived design entries under `.archive/design/**`; the registry also carries an archived `capability-routing-host-integration` entry whose visible archive directory is incomplete and whose `proposal.yml` 404s.

### 3) Archive integrity is inconsistent

**Type:** promotion/archive, lifecycle
**Why it matters:** archive packets are supposed to prove proposal exit and preserve lineage; inconsistent archive packets undermine that proof.
**Where it appears:** archived proposal manifests and registry metadata.
**Severity:** high
**Recommended action type:** **tighten**
**Placement:** archive-only

`mission-scoped-reversible-autonomy` sits in the archive path, but its manifest still says `status: accepted` and has no archive block, while the registry says it is archived and implemented. `self-audit-and-release-hardening` is archived in both manifest and registry, but uses `archived_from_status: proposed`, which is not in the defined status set. The registry also shows `harness-integrity-tightening` with the same invalid `archived_from_status: proposed`.

### 4) The lifecycle lacks explicit promote/archive operations

**Type:** lifecycle, automation
**Why it matters:** the model defines `implemented` and `archived`, but there is no repo-visible proposal operation pair that clearly owns promotion proof and archive sealing.
**Where it appears:** workflow inventory.
**Severity:** high
**Recommended action type:** **automate**
**Placement:** workflow/runtime/tooling

The workflow directories visibly contain create and audit workflows for proposals, and those create/audit flows already scaffold packages, update the registry, write evidence bundles, and fail closed. I did not find equivalent repo-visible `promote-proposal` or `archive-proposal` workflows in the same surfaces. That leaves the most important lifecycle transitions comparatively manual.

### 5) Hand-authored artifact catalogs add more ceremony than assurance

**Type:** ergonomics, redundancy/complexity
**Why it matters:** file inventories are derivable; making them a required authored artifact adds maintenance without adding much authority.
**Where it appears:** template and live package navigation.
**Severity:** medium
**Recommended action type:** **simplify**
**Placement:** generated/projection

The base template literally says the artifact catalog should be regenerated whenever files move. The design package’s catalog is essentially a flat list. The architecture package’s catalog is more useful because it adds semantic roles, but those semantics belong more naturally in the source-of-truth map than in a hand-maintained inventory.

### 6) Source-of-truth maps are valuable but unevenly specified

**Type:** governance, integration tension, ergonomics
**Why it matters:** this is the main artifact that can make a proposal package understandable to both humans and agents without elevating it to authority.
**Where it appears:** template vs live packages.
**Severity:** medium
**Recommended action type:** **tighten**
**Placement:** framework-core

The generic template already captures the right idea: explain proposal-local precedence while affirming that repository-wide durable authorities outrank the proposal. But the architecture-specific template collapses into a thin file list, while the live `migration-rollout` map expands into a genuinely useful authority/evidence/boundary map. The design package map is useful inside the package, but does not do the same broader boundary work.

### 7) Architecture, migration, and policy standards are too file-oriented

**Type:** governance, architectural
**Why it matters:** they define required docs, but not enough semantic expectations about evidence, exit proof, and external authority mapping.
**Where it appears:** subtype standards.
**Severity:** medium
**Recommended action type:** **tighten**
**Placement:** framework-core

Those three subtype standards mostly say “these files must exist” and give a short note on what each file should contain. That is enough to scaffold, but not enough to guarantee consistent review behavior, promotion proof, or source-of-truth mapping at the same level the architecture package already demonstrates in practice.

### 8) The active design package is slightly blurrier than the current framework intends

**Type:** ergonomics, package consistency
**Why it matters:** it is a local cleanliness issue, not a systemic architectural flaw.
**Where it appears:** `studio-graph-ux-design-package`.
**Severity:** low-medium
**Recommended action type:** **simplify**
**Placement:** proposal-local convention

The live design package carries many support inputs at the root, uses a flat artifact catalog, and its `design-proposal.yml` has `selected_modules: []` even though the current design standard says new `experience-product` proposals include `reference` and `history` by default. That suggests either grandfathered lineage or package-local drift, not a reason to redesign the whole system.

## 6. Target operating model

A proposal in Octon should remain a **temporary change packet for promotable work that spans more than a trivial edit**. It is the place to assemble pre-canonical design, architecture, migration, or policy change material when the repo needs explicit review, explicit targets, explicit evidence expectations, and explicit archival provenance before durable surfaces change.

A proposal is **not** supposed to be a durable architecture spec, a runtime input, a policy authority, a second registry of truth, or the long-term home of retained receipts. Durable rules belong in canonical `framework/**` or `instance/**` surfaces. Retained execution, validation, promotion, and migration evidence belongs in `state/evidence/**`. Generated discovery belongs in `generated/**`. The proposal may reference those surfaces and help produce them, but it should not replace them.

The operating flow should be:

* **Creation:** use a subtype create workflow to scaffold the package, write manifests, generate navigation inventory, update the registry, run standard + subtype validation, and write a workflow bundle in `state/evidence/**`.
* **Review:** use subtype audit workflows to test completeness, coherence, and conformance, again writing review bundles into `state/evidence/**`. Acceptance is a governance decision, not a file-creation event.
* **Acceptance:** `status: accepted` should mean “ready to promote,” not “already authoritative.” That matches the current live proposals.
* **Implementation/promotion:** this needs a dedicated `promote-proposal` operation. It should verify accepted status, verify the declared target set, update or validate durable targets, verify that durable targets no longer depend on proposal-local paths, and emit a promotion receipt under `state/evidence/**`. Only then should a proposal become `implemented`. This is the missing operational piece.
* **Archival:** this also needs a dedicated `archive-proposal` operation. It should move the package under `.archive/<kind>/<proposal_id>`, rewrite `status: archived`, populate the archive block, sync the registry, and freeze the packet as retained historical lineage. Implemented archives require promotion evidence; rejected or historical archives do not.

Operationally, **do not add new active statuses** like `stale`, `abandoned`, or `partial`. Use audit warnings for staleness, archive dispositions for history/supersession/rejection, and split a proposal when only part of its target set is truly promotable. In Octon, “partial implementation” is a package-boundary problem, not a lifecycle-state problem.

## 7. Target architecture

### Proposal-local artifacts

These should remain the package-local authoritative surfaces:

* `proposal.yml` for identity, kind, scope, status, targets, lifecycle, and related proposals.
* Exactly one subtype manifest for subtype-specific structured data.
* The subtype’s primary working docs (`target-architecture.md`, `plan.md`, `policy-delta.md`, design specs, and similar).
* A **manual** `navigation/source-of-truth-map.md` that explains local precedence, external authorities, derived projections, and boundary rules.

`README.md` should stay manually authored and human-facing, but non-authoritative. It is the entry point, not the contract.

### Framework-core

These should remain framework-authored core:

* The proposal standard and subtype standards.
* Template manifests and template package structures.
* JSON schemas for `proposal.yml`, subtype manifests, and the registry.
* Validators for cross-file, cross-path, and lifecycle enforcement.
* Workflow specs for create/audit and the missing promote/archive operations.

### Generated/projection-only artifacts

These should remain generated or projection-only:

* `/.octon/generated/proposals/registry.yml`.
* `navigation/artifact-catalog.md`, if retained. It should become generated inventory, not a manually trusted source.
* Optional future discovery indexes or health reports derived from the registry. These should never become authority. The repo already treats generated projections this way.

### Workflow/runtime/tooling

The proposal system should expose five operational entry points:

* `create-<kind>-proposal`
* `audit-<kind>-proposal`
* `validate-proposal` (generic wrapper)
* `promote-proposal`
* `archive-proposal`

The first two already exist. The last three are the missing maturity layer. `validate-proposal` should dispatch base + subtype validators and reverse-registry checks; `promote-proposal` should produce promotion receipts; `archive-proposal` should seal the historical packet.

### Evidence and receipts

Evidence should remain in `state/evidence/**`, not in proposal-local paths and not in generated views. The minimal missing addition is a **standard promotion receipt shape** referenced from archive metadata. That receipt should contain proposal id, kind, original path, target set, validator outcome, receipt paths, and timestamp. The archive block should point at it via `promotion_evidence`.

### Archive semantics

The main archive should contain only **standard-conformant archived proposal packets**. If Octon wants to preserve older or partially imported proposal history, that should be normalized into proper archive packets or separated later into an explicit historical-import mechanism. The main proposal registry should not mix current-conformant packets with incomplete remnants and still pretend both are equally trustworthy.

## 8. Recommended changes

### Must do now

* **Align the contract layers.** Update subtype schema files so they match the effective manifest contract already used by templates, validators, and live packages: `architecture_scope` + `decision_type`; `change_profile` + `release_state`; `policy_area` + `change_type`. Also align `proposal.schema.json` with the standard and validator on `archive.disposition`, including `superseded` if that value remains supported.
  **Action:** tighten
  **Placement:** framework-core

* **Make the registry fail-closed in both directions.** Either deterministically rebuild `/.octon/generated/proposals/registry.yml` from package manifests, or add a reverse audit that proves every registry entry points to exactly one existing, valid package with matching metadata.
  **Action:** validate
  **Placement:** generated/projection

* **Normalize the current archive and registry.** Repair or remove broken entries before turning on stricter fail-closed enforcement. At minimum, `mission-scoped-reversible-autonomy`, `self-audit-and-release-hardening`, `harness-integrity-tightening`, and `capability-routing-host-integration` need correction or removal from the main registry/archive surface.
  **Action:** tighten
  **Placement:** archive-only

* **Add explicit `promote-proposal` and `archive-proposal` operations.** These can start as thin workflow wrappers around the current validator stack plus registry sync plus receipt emission.
  **Action:** automate
  **Placement:** workflow/runtime/tooling

* **Stop requiring hand-authored artifact catalogs.** Keep the file if helpful, but generate it. Put any semantic role descriptions into the source-of-truth map.
  **Action:** simplify
  **Placement:** generated/projection

### Should do next

* **Strengthen the subtype standards for architecture, migration, and policy.** Keep the current file sets, but add clearer semantic expectations for acceptance proof, source-of-truth mapping, and evidence references.
  **Action:** tighten
  **Placement:** framework-core

* **Add a generic `validate-proposal` entrypoint.** CI and humans should not need to remember which base + subtype validators to run manually.
  **Action:** automate
  **Placement:** workflow/runtime/tooling

* **Tighten source-of-truth-map templates.** The generic template is on the right track; the architecture-specific template should be brought closer to the quality of the live `migration-rollout` package.
  **Action:** tighten
  **Placement:** framework-core

* **Lightly tidy the active design package.** Either explicitly grandfather it, or move obvious support material under `support/` and document why `selected_modules` is empty.
  **Action:** simplify
  **Placement:** proposal-local convention

### Later / nice to have

* **If historical proposal lineage matters, separate it cleanly.** A future explicit historical-import projection is better than keeping partial legacy remnants in the main proposal registry.
  **Action:** split
  **Placement:** archive-only

* **Generate a human-friendly proposal index from the registry.** That is a convenience layer, not a structural need.
  **Action:** automate
  **Placement:** generated/projection

* **Defer stronger dependency semantics.** `related_proposals` is enough for now; there is not yet repo evidence that a heavier proposal dependency graph is needed.
  **Action:** defer
  **Placement:** proposal-local convention

### Explicitly reject

* **Do not add new proposal kinds now.**
  **Action:** keep
  **Placement:** framework-core

* **Do not add new active lifecycle statuses such as `stale`, `abandoned`, or `partial`.**
  **Action:** keep
  **Placement:** framework-core

* **Do not make proposal packages canonical authorities.**
  **Action:** keep
  **Placement:** framework-core

* **Do not make the registry authoritative.**
  **Action:** keep
  **Placement:** generated/projection

* **Do not add ceremony-heavy governance layers that are not already justified by repo use.**
  **Action:** keep
  **Placement:** workflow/runtime/tooling

## 9. File and path impact

### Change

* `/.octon/inputs/exploratory/proposals/README.md`
* `/.octon/framework/scaffolding/governance/patterns/proposal-standard.md`
* `/.octon/framework/scaffolding/governance/patterns/design-proposal-standard.md`
* `/.octon/framework/scaffolding/governance/patterns/architecture-proposal-standard.md`
* `/.octon/framework/scaffolding/governance/patterns/migration-proposal-standard.md`
* `/.octon/framework/scaffolding/governance/patterns/policy-proposal-standard.md`
* `/.octon/framework/scaffolding/runtime/templates/proposal.schema.json`
* `/.octon/framework/scaffolding/runtime/templates/architecture-proposal.schema.json`
* `/.octon/framework/scaffolding/runtime/templates/migration-proposal.schema.json`
* `/.octon/framework/scaffolding/runtime/templates/policy-proposal.schema.json`
* `/.octon/framework/scaffolding/runtime/templates/proposal-core/navigation/artifact-catalog.md`
* `/.octon/framework/scaffolding/runtime/templates/proposal-core/navigation/source-of-truth-map.md`
* `/.octon/framework/scaffolding/runtime/templates/proposal-architecture-core/navigation/source-of-truth-map.md`
* `/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh`
* `/.octon/framework/assurance/runtime/_ops/scripts/validate-design-proposal.sh`
* `/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh`
* `/.octon/framework/assurance/runtime/_ops/scripts/validate-migration-proposal.sh`
* `/.octon/framework/assurance/runtime/_ops/scripts/validate-policy-proposal.sh`
* `/.octon/generated/proposals/registry.yml`

### Add

* `/.octon/framework/orchestration/runtime/workflows/meta/promote-proposal/`
* `/.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/`
* optionally `/.octon/framework/orchestration/runtime/workflows/meta/validate-proposal/` as a thin wrapper entrypoint.

### Repair or remove from the main archive/registry surface

* `/.octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy/**`
* `/.octon/inputs/exploratory/proposals/.archive/architecture/self-audit-and-release-hardening/**`
* `/.octon/inputs/exploratory/proposals/.archive/architecture/harness-integrity-tightening/**`
* `/.octon/inputs/exploratory/proposals/.archive/architecture/capability-routing-host-integration/**`
* any archived design entries projected into `registry.yml` whose package paths do not actually exist under the current archive tree.

### Proposal-local cleanup candidate

* `/.octon/inputs/exploratory/proposals/design/studio-graph-ux-design-package/**` only for light organization cleanup, not for framework redesign.

## 10. Validation and enforcement plan

**Schema-validate** `proposal.yml`, subtype manifests, and `/.octon/generated/proposals/registry.yml`. Those are the structured machine-readable surfaces. Do not try to schema-validate README prose or primary working docs.

**Workflow-validate** path rules, scope rules, archive requirements, subtype required docs, selected-module coherence, implemented-target existence, and no backreferences from durable targets into proposal-local paths. That is the right job for the shell validators and workflow gates.

**Reverse-validate or regenerate the registry** so drift cannot survive. Fail closed on duplicate IDs, path mismatches, kind mismatches, orphaned entries, archived entries without valid archive metadata, and registry/package status disagreement.

**Lint the source-of-truth map**, not for prose quality, but for boundary coverage: it should name external canonical authorities, proposal-local authorities, derived projections, and evidence locations where relevant. This is especially important for architecture, migration, and policy proposals.

**Generate the artifact catalog** from filesystem state if it is kept at all. Do not let manual catalog drift become a cause of false review confidence.

**Staleness should start as warning-only.** A proposal that stays `accepted` or `implemented` for too long should trigger audit warnings and review attention, not a new lifecycle status.

## 11. Migration/rollout plan

### Phase 1 — align the contract

Update the standards, schemas, templates, and validators so that each subtype has one coherent contract. This is the first step because everything else depends on it. Keep the current kinds, statuses, and live package meanings unchanged during this phase.

### Phase 2 — repair registry integrity

Rebuild or fully audit `/.octon/generated/proposals/registry.yml` from actual package manifests. Remove or fix orphaned entries before fail-closed enforcement goes live. The goal is simple: the main registry should only project packages that really exist and really validate.

### Phase 3 — normalize the archive

Fix the known archive defects. `mission-scoped-reversible-autonomy` must either gain a correct archive block and `status: archived` or leave the main archive/registry until it is fixed. `self-audit-and-release-hardening` and any other entries using `archived_from_status: proposed` must be corrected to a real lifecycle state or reclassified. `capability-routing-host-integration` must either become a complete archive packet or leave the main registry. Archived design entries that point to non-visible `.archive/design/**` paths must be imported properly or removed from the main projection.

### Phase 4 — complete the lifecycle tooling

Add `promote-proposal` and `archive-proposal`. Reuse the current validator and evidence conventions so this stays incremental. `implemented` becomes provable when promotion receipts and target checks exist; `archived` becomes trustworthy when archive sealing is automated.

### Phase 5 — remove low-value friction

Generate artifact catalogs, tighten source-of-truth-map guidance, and optionally tidy the active design package. Keep `migration-rollout` essentially as-is; it is already close to the target pattern. The design package can be grandfathered or lightly cleaned up without forcing a structural rewrite.

## 12. Final recommendation

The single best direction for Octon’s proposal system is:

**Keep the current proposal model, and turn it into a stricter temporary-to-canonical gateway by aligning one contract, one registry projection, and one trustworthy archive boundary.**

That gives Octon a more mature proposal system without changing what proposals fundamentally are, without adding ceremony, and without creating any new competing source of truth.

## 13. Repo-ready proposal-system improvement package design

The evidence does justify a **repo-ready improvement package**, but it should still be surgical.

### Preferred package

* **Proposal ID:** `proposal-system-integrity-and-archive-normalization`
* **Kind:** `architecture`
* **Why architecture is the right kind:** the change is cross-cutting. It touches governance standards, machine contracts, validators, workflow operations, generated registry behavior, and archive semantics. That is an architecture-and-operating-model change, not just a one-time migration.

### Promotion scope and likely targets

* **Promotion scope:** `octon-internal`
* **Likely promotion targets:**
  `/.octon/inputs/exploratory/proposals/README.md`
  `/.octon/framework/scaffolding/governance/patterns/**`
  `/.octon/framework/scaffolding/runtime/templates/**`
  `/.octon/framework/assurance/runtime/_ops/scripts/**`
  `/.octon/framework/orchestration/runtime/workflows/meta/**`
  `/.octon/generated/proposals/registry.yml`
  plus archive-only repairs under `/.octon/inputs/exploratory/proposals/.archive/**` as needed.

### Required artifacts

* `architecture/target-architecture.md`
* `architecture/acceptance-criteria.md`
* `architecture/implementation-plan.md`
* `resources/registry-drift-report.md`
* `resources/archive-normalization-inventory.md`

That is enough. No additional subtype or governance artifacts are needed for a first pass.

### Lifecycle and validation implications

This proposal should not be allowed to reach `implemented` until:

1. the schema/template/validator contract is aligned,
2. the registry reverse-audit or deterministic rebuild exists, and
3. the main archive/registry no longer carry known invalid entries.

### Optional split only if cleanup grows

If archive cleanup turns out to be materially larger than expected, then split out a second proposal:

* **Proposal ID:** `proposal-registry-and-archive-normalization`
* **Kind:** `migration`

That split is justified only if the one-time normalization work becomes large enough to deserve separate acceptance criteria and its own evidence bundle. Otherwise, one architecture proposal is the cleaner boundary.

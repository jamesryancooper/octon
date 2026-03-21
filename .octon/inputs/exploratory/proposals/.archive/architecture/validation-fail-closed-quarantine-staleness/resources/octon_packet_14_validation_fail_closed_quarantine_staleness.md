# Packet 14 — Validation, Fail-Closed, Quarantine, and Staleness

**Proposal design packet for ratifying, normalizing, and implementing Octon's final class-root validation model, fail-closed runtime protection, quarantine semantics, freshness enforcement, and publication rules inside the five-class Super-Root architecture.**

## Status

- **Status:** Ratified design packet for proposal drafting
- **Proposal area:** Cross-class validation model, fail-closed runtime and policy protection, scope-local and pack-local quarantine, generated-output freshness, desired-versus-actual publication state, validation receipts, and migration from legacy mixed-surface enforcement assumptions
- **Implementation order:** 14 of 15 in the ratified proposal sequence
- **Primary outcome:** Deliver one explicit validation and failure-semantics contract so Octon can reject raw input dependencies, quarantine broken scope or extension state locally, fail closed on stale required generated outputs, and publish only coherent validated runtime-facing effective views
- **Dependencies:** Hard dependencies: Packet 1 — Super-Root Semantics and Taxonomy; Packet 2 — Root Manifest, Profiles, and Export Semantics; Packet 3 — Framework/Core Architecture; Packet 4 — Repo-Instance Architecture; Packet 5 — Overlay and Ingress Model; Packet 6 — Locality and Scope Registry; Packet 7 — State, Evidence, and Continuity; Packet 8 — Inputs/Additive/Extensions; Packet 9 — Inputs/Exploratory/Proposals; Packet 10 — Generated / Effective / Cognition / Registry; Packet 11 — Memory, Context, ADRs, and Operational Decision Evidence; Packet 12 — Capability Routing and Host Integration; Packet 13 — Portability, Compatibility, Trust, and Provenance
- **Migration role:** Replace the current mixed-surface and partially domain-local failure model with one final class-root-aware validation contract, unify desired/actual/quarantine/published extension semantics, and turn fail-closed behavior into an explicit publication discipline rather than a loose implementation preference
- **Current repo delta:** The live repository already exposes several pieces of the ratified direction: `/.octon/octon.yml` already sets `policies.raw_input_dependency: fail-closed` and `policies.generated_staleness: fail-closed`; `/.octon/instance/extensions.yml` already exists as the desired extension control file; `/.octon/state/control/extensions/active.yml` already records published active extension state; and `/.octon/generated/effective/extensions/catalog.effective.yml` already exists as a generated effective extension output. At the same time, the current `Runtime vs Ops Surface Contract` still reflects an older mutation model centered on `/_ops/state/**`, `/.octon/output/**`, and `/.octon/continuity/**`, so Packet 14 is required to finish the transition to class-root-aware validation and write-target enforcement.

> **Packet intent:** define one final contract for how Octon validates authored authority, raw inputs, state, and generated outputs; when it must fail closed; what may quarantine locally; how desired configuration differs from active published state; and how freshness, generation, and publication are proven before runtime or policy consumers are allowed to trust generated effective views.

## 1. Why this proposal exists

The ratified Super-Root architecture gives Octon a clean structural model:

- `framework/**` for portable authored authority
- `instance/**` for repo-owned durable authored authority
- `inputs/**` for raw non-authoritative source inputs
- `state/**` for mutable operational truth and retained evidence
- `generated/**` for rebuildable derived outputs

That structure only becomes operationally safe when Octon can answer these questions precisely:

- What must be validated before runtime or policy behavior is allowed to proceed?
- What failures should block the entire harness, and what failures should quarantine only one scope or one extension pack?
- How does Octon distinguish desired extension configuration from actual published active state?
- How does Octon prove that a generated effective view is still fresh enough to trust?
- Which failures are merely proposal-workflow problems and which are real runtime safety problems?
- Where do receipts and quarantine state live so operators can inspect what happened without treating those receipts as authored authority?

Packet 14 exists because the current repository still has fail-closed pieces rather than one final, class-root-aware contract. The root manifest already declares fail-closed policies, the desired extension control file already exists, the active extension state file already exists, and generated extension outputs already exist. But the older runtime-vs-ops contract still expresses mutation and enforcement in terms of legacy `_ops/state/**`, `/.octon/output/**`, and `/.octon/continuity/**` allowlists. That is a useful baseline, but it is not yet the ratified final answer.

Packet 14 converts those pieces into one final safety model.

## 2. Problem statement

Octon needs one validation and failure-semantics contract that is:

- class-root aware
- explicit about authored authority versus operational truth versus raw inputs versus generated outputs
- explicit about publication rules for runtime-facing generated effective views
- explicit about desired versus actual versus quarantined extension state
- explicit about freshness checks and stale-output rejection
- explicit about local quarantine boundaries
- explicit about where validation evidence and control state live
- strict enough to fail closed when runtime or policy safety is at risk
- narrow enough to avoid turning every malformed proposal or exploratory artifact into a repo-wide outage

Without Packet 14, several important ambiguities remain:

- whether generated outputs are trusted because they exist or trusted only when their generation locks are fresh
- whether `instance/extensions.yml` and `state/control/extensions/active.yml` are two competing sources of truth or a desired-versus-actual pair
- whether extension publication is atomic across desired config, actual state, and generated effective outputs
- whether malformed scope state should block the whole repo or only that scope
- whether proposal errors are runtime failures or workflow-local failures
- whether legacy runtime-vs-ops write allowlists remain canonical after the move to `state/**` and `generated/**`
- whether runtime consumers are allowed to read raw inputs directly when generated outputs are missing or stale

Packet 14 resolves those ambiguities.

## 3. Final target-state decision summary

- Validation is class-root aware across `framework/**`, `instance/**`, `inputs/**`, `state/**`, and `generated/**`.
- Runtime and policy consumers may trust only:
  - authoritative authored surfaces in `framework/**` and `instance/**`
  - operational truth in `state/**` for state-class concerns
  - generated effective outputs in `generated/effective/**` when freshness checks pass
- Raw `inputs/**` paths must never become direct runtime or policy dependencies.
- Global fail-closed applies to invalid root manifest state, invalid required framework or instance authority, stale required effective outputs, authoritative native/extension collisions, and raw-input dependency violations.
- Scope-local quarantine applies to malformed or conflicting scope registry, scope context, scope continuity, or scope decision evidence.
- Pack-local quarantine applies to invalid extension packs or dependency closure failures when a coherent surviving published extension generation still exists.
- If no coherent extension generation survives, Octon withdraws extension contributions and falls back to framework-plus-instance native behavior.
- Proposal validation remains workflow-local; invalid proposals block proposal workflows and registry generation only.
- `instance/extensions.yml` is the desired authoritative extension configuration in v1.
- `state/control/extensions/active.yml` is the actual published extension state after validation.
- `state/control/extensions/quarantine.yml` is mutable quarantine and withdrawal truth.
- `generated/effective/extensions/**` is the published compiled runtime-facing extension view.
- Publication of extension active state and corresponding generated effective outputs must be atomic.
- Every runtime-facing generated effective family must carry generation metadata and fail closed when stale.
- Validation evidence and receipts live under `state/evidence/validation/**`.
- Quarantine and active-control truth live under `state/control/**`.

## 4. Scope

This packet does all of the following:

- defines the final validation model across all five class roots
- defines global fail-closed conditions
- defines scope-local quarantine behavior
- defines pack-local quarantine and extension withdrawal behavior
- defines proposal-local validation boundaries
- defines desired/actual/quarantine/compiled extension state semantics
- defines freshness and staleness requirements for generated effective outputs
- defines where validation evidence, receipts, and control truth live
- defines publication conditions for runtime-facing generated outputs
- defines the migration implications of replacing older runtime-vs-ops enforcement assumptions with final class-root-aware rules

## 5. Non-goals

This packet does **not** do any of the following:

- re-litigate the five-class Super-Root
- change extension raw placement or proposal raw placement
- create permissive fallbacks to raw inputs
- define pack registry protocols beyond what Packet 13 already governs
- define capability-routing ranking weights
- change the ratified commit policy for generated outputs
- move proposals into runtime or policy precedence
- redefine memory routing beyond the already ratified packet

## 6. Canonical paths and artifact classes

| Artifact / contract | Canonical path | Class root | Authority status | Purpose |
|---|---|---|---|---|
| Root fail-closed policy declaration | `octon.yml` | root | authoritative authored | Declares global policies such as raw-input dependency and generated staleness handling |
| Desired extension configuration | `instance/extensions.yml` | instance | authoritative authored | Human-authored desired extension state |
| Actual active extension state | `state/control/extensions/active.yml` | state | operational truth | Published extension state after successful validation |
| Extension quarantine state | `state/control/extensions/quarantine.yml` | state | operational truth | Blocked packs, dependents, reasons, acknowledgements |
| Scope quarantine state | `state/control/locality/quarantine.yml` | state | operational truth | Scope quarantine and failure reasons |
| Validation evidence and receipts | `state/evidence/validation/**` | state | operational truth | Retained receipts, diagnostics, and enforcement evidence |
| Effective locality outputs | `generated/effective/locality/**` | generated | non-authoritative rebuildable | Runtime-facing compiled locality views |
| Effective capability outputs | `generated/effective/capabilities/**` | generated | non-authoritative rebuildable | Runtime-facing compiled routing views |
| Effective extension outputs | `generated/effective/extensions/**` | generated | non-authoritative rebuildable | Runtime-facing compiled extension catalogs |
| Generation locks | `generated/effective/**/generation.lock.yml` | generated | non-authoritative rebuildable | Freshness and publication metadata |
| Artifact maps | `generated/effective/**/artifact-map.yml` | generated | non-authoritative rebuildable | Traceability from published ids to concrete source inputs |
| Proposal discovery registry | `generated/proposals/registry.yml` | generated | non-authoritative rebuildable | Proposal discovery only |

## 7. Authority and boundary implications

- `framework/**` and `instance/**` remain the only authored authority surfaces.
- `state/**` remains authoritative only for mutable operational truth and retained evidence.
- `generated/**` remains non-authoritative, even when runtime-facing.
- Generated effective outputs are trusted only as validated compiled publications, never as source-of-truth.
- Raw extension packs and raw proposals are never runtime or policy authority.
- Validation and quarantine control state is operational truth and therefore belongs in `state/**`, not in `generated/**`.
- Validation receipts are retained evidence and therefore also belong in `state/**`, not in `generated/**`.
- Proposal validation may block exploratory workflows, but it must never escalate into runtime authority or runtime policy precedence.

## 8. Current repo baseline and implementation delta

The live repository already includes important pieces of the final model:

- the root manifest already sets `raw_input_dependency: fail-closed`
- the root manifest already sets `generated_staleness: fail-closed`
- the desired extension configuration file already exists at `instance/extensions.yml`
- the actual active extension state already exists at `state/control/extensions/active.yml`
- the generated effective extension catalog already exists at `generated/effective/extensions/catalog.effective.yml`

That means Packet 14 is **not** inventing fail-closed behavior from scratch.

What is still missing is one final, ratified cross-class contract that says:

- which failures block the whole harness
- which failures quarantine locally
- how desired extension configuration differs from actual active state
- how freshness is proven
- how publication becomes atomic
- how the older runtime-vs-ops allowlist model maps into final `state/**` and `generated/**` semantics

Packet 14 provides that final contract.

## 9. Ratified validation model

### 9.1 Validation families

Octon must validate five families of artifacts:

1. **Root and class-root contracts**
   - `octon.yml`
   - `framework/manifest.yml`
   - `instance/manifest.yml`

2. **Authoritative authored artifacts**
   - framework contracts and runtime surfaces
   - instance overlays and repo-owned durable authority

3. **Raw input surfaces**
   - extension pack manifests and payload rules
   - proposal manifests and subtype manifests

4. **Operational truth surfaces**
   - scope continuity and scope evidence
   - extension active/quarantine control state

5. **Generated outputs**
   - effective outputs
   - generation locks
   - artifact maps
   - proposal registry

### 9.2 Validation entrypoints

Validation entrypoints should be organized by lifecycle event:

- **authoring-time validation** for manifests and schemas
- **publication-time validation** for generated effective outputs
- **runtime-start validation** for required effective outputs and freshness checks
- **export-time validation** for profile completeness and dependency closure
- **migration-time validation** for schema transitions and path cutover safety

### 9.3 Publication gates

A runtime-facing effective output may be published only when:

- authoritative source inputs are valid
- raw input dependency ban is satisfied
- generated output schema is valid
- generation lock matches the published payload set
- required source digests match current authoritative/validated raw inputs
- any required control state acknowledges the publication

## 10. Global fail-closed model

Global fail-closed must apply to any condition that undermines authoritative or runtime-facing trust.

### Global fail-closed conditions

Fail globally on:

- invalid `octon.yml`
- invalid class-root bindings
- invalid framework contracts needed for runtime or policy decisions
- invalid required instance control metadata needed for runtime or policy decisions
- invalid required generated effective outputs
- stale required generated effective outputs
- native/extension collisions in the active published generation
- raw-input dependency violations
- generation locks that do not match the published effective output set

### Why these fail globally

Each of these conditions undermines the system’s ability to know what authoritative or runtime-facing behavior actually is. That is exactly where fail-closed should apply.

## 11. Scope-local quarantine model

Scope-local quarantine is the preferred isolation boundary for locality-specific failures.

### Quarantine triggers

Quarantine one scope when any of these are invalid:

- malformed `scope.yml`
- overlapping active scope bindings
- malformed scope context
- malformed scope continuity
- malformed scope-specific operational decision evidence
- scope-generated locality publication that no longer matches current scope source digests

### Quarantine behavior

When a scope is quarantined:

- work targeted at that scope fails closed
- unrelated scopes may continue
- repo-wide work may continue if it does not require the quarantined scope
- generated effective locality outputs must be republished without trusting stale or invalid scope contributions

### Canonical control path

```text
state/control/locality/quarantine.yml
```

## 12. Pack-local quarantine and extension withdrawal model

### Quarantine triggers

Quarantine a pack, and any dependents, for:

- malformed `pack.yml`
- dependency closure failure
- trust failure
- compatibility failure
- forbidden content bucket usage
- invalid generated publication state
- stale or mismatched extension generation locks

### Pack-local outcome

If a coherent surviving extension generation still exists:

- quarantine the invalid pack
- quarantine any dependent packs that can no longer be satisfied
- publish a reduced active set
- republish the effective extension catalog and artifact map

### Extension-layer withdrawal outcome

If no coherent surviving generation exists:

- withdraw extension contributions from active runtime-facing behavior
- set extension active state to the surviving native-only behavior
- keep desired config intact
- record quarantine and validation evidence

This is a fail-closed fallback to framework-plus-instance native behavior, not a permissive fallback to raw pack paths.

## 13. Desired / actual / quarantine / compiled consistency model

The extension lifecycle is now explicitly four-layered.

### Desired

`instance/extensions.yml`

Human-authored desired config.

### Actual active

`state/control/extensions/active.yml`

Operational truth about what is currently published and active.

### Quarantine

`state/control/extensions/quarantine.yml`

Operational truth about blocked packs, blocked dependents, reason codes, and acknowledgements.

### Compiled

`generated/effective/extensions/**`

Published runtime-facing extension outputs.

### Consistency rule

Runtime may trust extension behavior only when all of the following are true:

1. desired configuration resolves successfully
2. active state references a published generation id
3. generation locks for that generation are fresh
4. quarantine state does not block the referenced published set
5. compiled outputs match the active state’s generation and dependency closure

### Atomic publication rule

Publication of:

- `state/control/extensions/active.yml`
- `generated/effective/extensions/catalog.effective.yml`
- `generated/effective/extensions/artifact-map.yml`
- `generated/effective/extensions/generation.lock.yml`

must be atomic from the point of view of runtime consumers.

## 14. Proposal-local validation model

Proposal validation remains workflow-local.

### Validation checks

- proposal schema validity
- subtype schema validity
- lifecycle metadata validity
- promotion-target validity
- non-canonical rule enforcement

### Failure behavior

Invalid proposals:

- block proposal workflows
- block proposal registry generation if needed
- do **not** block runtime or policy behavior

That is the correct boundary because proposals are exploratory inputs, not runtime authority.

## 15. Freshness and staleness model

### Required metadata for runtime-facing generated outputs

Every runtime-facing effective family must carry:

- source digests
- generator version
- schema version
- generation timestamp
- invalidation conditions
- publication status

### Staleness rule

Runtime and policy consumers must fail closed when:

- a required effective output is stale
- a generation lock is missing
- a generation lock no longer matches current authoritative or validated input digests
- the active state references a generation that is missing or invalid

### Human-facing generated outputs

Human-facing generated summaries, graphs, and projections may be inspected when stale only if clearly marked stale. They still remain non-authoritative.

## 16. Evidence, observability, and auditability

### Validation evidence

Validation evidence lives under:

```text
state/evidence/validation/**
```

It should include enough data to answer:

- what was validated?
- against which schema or contract?
- when?
- by which validator/generator version?
- with what result?
- if blocked or quarantined, why?

### Control-state observability

Control-state files under `state/control/**` must be human-readable enough for operators to inspect current active versus quarantined status without reading generated catalogs directly.

### Auditability rule

Receipts and evidence are retained operational truth, not generated convenience artifacts. They must therefore stay in `state/**` even when produced by automated validation tooling.

## 17. Schema, manifest, and contract changes required

This packet requires updates to:

- `octon.yml`
- `framework/manifest.yml`
- `instance/manifest.yml`
- `instance/extensions.yml`
- `state/control/extensions/active.yml`
- `state/control/extensions/quarantine.yml`
- `state/control/locality/quarantine.yml`
- `generated/effective/**/generation.lock.yml` contracts
- `state/evidence/validation/**` receipt schema
- legacy runtime-vs-ops mutation and enforcement contracts so they align with `state/**` and `generated/**`

## 18. Migration and rollout implications

### Migration work authorized by this packet

- ratify desired/actual/quarantine/compiled extension state semantics
- replace legacy mixed-surface write-allowlist assumptions with final class-root write-target enforcement
- make runtime-facing effective publication freshness-checkable and atomic
- introduce or normalize quarantine and validation receipt schemas
- align scope quarantine with the final locality registry model

### Sequencing

Packet 14 must land **after**:

- Packet 1 — Super-Root Semantics and Taxonomy
- Packet 2 — Root Manifest, Profiles, and Export Semantics
- Packet 3 — Framework/Core Architecture
- Packet 4 — Repo-Instance Architecture
- Packet 5 — Overlay and Ingress Model
- Packet 6 — Locality and Scope Registry
- Packet 7 — State, Evidence, and Continuity
- Packet 8 — Inputs/Additive/Extensions
- Packet 9 — Inputs/Exploratory/Proposals
- Packet 10 — Generated / Effective / Cognition / Registry
- Packet 11 — Memory, Context, ADRs, and Operational Decision Evidence
- Packet 12 — Capability Routing and Host Integration
- Packet 13 — Portability, Compatibility, Trust, and Provenance

Packet 14 must land **before**:

- Packet 15 — Migration and Rollout

### Critical sequencing clarification

- Repo continuity moves into `state/continuity/repo/**` before locality cutover.
- Scope continuity must not land until locality registry and scope validation are live.
- Internalized extension packs must not become active until raw-input dependency enforcement and extension publication rules are in place.

## 19. Dependencies and suggested implementation order

- **Dependencies:** Packets 1 through 13
- **Suggested implementation order:** 14
- **Blocks:** safe extension publication, fresh effective runtime consumption, final migration cutover, and any future automation that depends on deterministic quarantine behavior

## 20. Acceptance criteria

- Raw `inputs/**` dependency violations are validator-detected and fail closed.
- `instance/extensions.yml` is explicitly the desired authoritative extension configuration.
- `state/control/extensions/active.yml` is explicitly the actual active published extension state.
- `state/control/extensions/quarantine.yml` is explicitly the quarantine and withdrawal control surface.
- Runtime-facing extension publication is atomic across active state and generated outputs.
- Required effective outputs carry generation metadata and freshness checks.
- Stale required effective outputs fail closed for runtime and policy use.
- Scope-local failures quarantine locally rather than collapsing the whole repo when safe to isolate.
- Proposal validation failures remain workflow-local and never block runtime.
- Validation evidence and enforcement receipts live under `state/evidence/validation/**`.
- The final class-root failure model supersedes older mixed-surface enforcement assumptions.

## 21. Supporting evidence to reference

- `/.octon/octon.yml`
- `/.octon/instance/extensions.yml`
- `/.octon/state/control/extensions/active.yml`
- `/.octon/generated/effective/extensions/catalog.effective.yml`
- `/.octon/cognition/_meta/architecture/runtime-vs-ops-contract.md`
- Packet 1 — Super-Root Semantics and Taxonomy
- Packet 7 — State, Evidence, and Continuity
- Packet 8 — Inputs/Additive/Extensions
- Packet 10 — Generated / Effective / Cognition / Registry
- Packet 13 — Portability, Compatibility, Trust, and Provenance
- Ratified Super-Root blueprint sections on validation, fail-closed behavior, and migration

## 22. Settled decisions that must not be re-litigated

- The five-class Super-Root remains the final topology.
- Raw extensions remain under `inputs/additive/extensions/**`.
- Raw proposals remain under `inputs/exploratory/proposals/**`.
- `instance/extensions.yml` remains the single desired-control file in v1.
- `repo_snapshot` remains behaviorally complete and includes enabled-pack dependency closure.
- Raw `inputs/**` paths never become runtime or policy dependencies.
- Proposals never become runtime or policy authority.
- Generated outputs remain non-authoritative.
- Stale runtime-facing effective outputs fail closed.
- Scope inheritance and descendant-local harness roots remain out of scope for v1.

## 23. Remaining narrow open questions

None. This packet is ratified for proposal drafting and ready to move into formal architecture proposal authoring.

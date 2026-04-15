# Target Architecture

## Executive decision

Adopt the **verified Preferred Change Path** for both in-scope concepts:

1. extend the existing instruction-layer manifest and output-budget regime so every consequential run records complete provenance for the active precedence stack, capability/tool surface, and envelope policy
2. extend the existing execution request / grant / receipt and capability-pack surfaces so capability invocation, execution class, and output-envelope semantics are normalized end to end

The packet explicitly **avoids**:
- new top-level architectural categories
- a new authority or control plane
- storing truth in generated or proposal-local artifacts
- widening support-target tuples
- bypassing the engine-owned authorization boundary

## Why this is the correct integration approach

### Chosen approach
- **Primary motion:** extension/refinement of existing canonical surfaces
- **Supporting motion:** overlay-scoped repo-specific augmentation at enabled points
- **Validation motion:** additive validators and CI hardening

### Why a narrower path is insufficient
A narrower overlay-only path (for example, touching only `tool-output-budgets.yml` and `repo-shell-execution-classes.yml`) would improve local discipline but leave the end-to-end semantics of request / grant / receipt / pack admission / output envelope partially implicit. That would preserve pseudo-coverage.

### Why a broader path is unnecessary
A broader constitutional rewrite or new control/evidence family is unnecessary because the live repo already has:
- a constitutional runtime family
- an engine-owned execution boundary
- admitted capability packs
- repo-local runtime overlays
- blocking architecture-conformance automation

## Concept cluster A — Instruction-layer provenance, precedence, and progressive-disclosure hardening

### Durable meaning
The durable meaning remains in existing authority surfaces:
- `/.octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json`
- `/.octon/framework/cognition/_meta/architecture/specification.md`
- `/.octon/framework/constitution/precedence/{normative.yml,epistemic.yml}`
- `/.octon/instance/agency/runtime/tool-output-budgets.yml`

### Proposed refinement
Additive refinement of the existing v2 manifest plus validator hardening so a consequential run can prove:
- which capability packs were in scope
- which execution classes were exercised
- which output-envelope budget policy applied
- which context layers were loaded, summarized, or compacted
- which raw payloads were offloaded versus summarized

### Canonical placement
- **Authority:** framework runtime contract + instance runtime overlay
- **Control:** no new top-level state/control root; existing run roots continue to bind execution
- **Evidence:** existing run evidence families retain enriched manifest and validation artifacts
- **Generated:** no new generated family required in phase 1

### Proposed target edits
- edit `/.octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json`
- edit `/.octon/instance/agency/runtime/tool-output-budgets.yml`
- add `/.octon/framework/assurance/runtime/_ops/scripts/validate-instruction-layer-manifest-depth.sh`
- add `/.octon/framework/assurance/runtime/_ops/tests/test-instruction-layer-manifest-depth.sh`
- edit `.github/workflows/architecture-conformance.yml`

### Candidate additive fields / checks
- `capability_pack_refs`
- `execution_class_refs`
- `tool_budget_policy_refs`
- `context_layers[]`
- `compaction_refs`
- validator rule: if a receipt or grant uses a governed capability pack with output-budget requirements, the instruction-layer manifest must surface the corresponding pack / class / budget references

## Concept cluster B — Capability invocation and output-envelope normalization

### Durable meaning
The durable meaning remains in existing authority surfaces:
- `/.octon/framework/engine/runtime/spec/execution-request-v2.schema.json`
- `/.octon/framework/engine/runtime/spec/execution-grant-v1.schema.json`
- `/.octon/framework/engine/runtime/spec/execution-receipt-v2.schema.json`
- `/.octon/framework/capabilities/packs/{shell,repo}/manifest.yml`
- `/.octon/instance/governance/policies/repo-shell-execution-classes.yml`
- `/.octon/instance/governance/capability-packs/shell.yml`
- `/.octon/instance/capabilities/runtime/packs/admissions/shell.yml`

### Proposed refinement
Normalize how a governed capability invocation is described across request, authorization, and retained receipt so the repo can prove:
- requested pack(s) or pack-equivalent execution surface
- execution class used for the material step
- effective envelope policy for summary vs raw payload offload
- receipt reason codes consistent with pack admission and execution class policy

### Canonical placement
- **Authority:** engine runtime spec + framework capability pack manifests + repo-local pack governance
- **Control:** still the existing run-root / execution-grant path
- **Evidence:** existing execution receipts and validation artifacts
- **Generated:** optional later refinement of `generated/effective/capabilities/**`; not required for packet closeout

### Proposed target edits
- edit `/.octon/framework/engine/runtime/spec/execution-request-v2.schema.json`
- edit `/.octon/framework/engine/runtime/spec/execution-grant-v1.schema.json`
- edit `/.octon/framework/engine/runtime/spec/execution-receipt-v2.schema.json`
- edit `/.octon/instance/governance/policies/repo-shell-execution-classes.yml`
- edit `/.octon/framework/capabilities/packs/shell/manifest.yml`
- edit `/.octon/framework/capabilities/packs/repo/manifest.yml`
- edit `/.octon/instance/governance/capability-packs/shell.yml`
- edit `/.octon/instance/capabilities/runtime/packs/admissions/shell.yml`
- add `/.octon/framework/assurance/runtime/_ops/scripts/validate-capability-envelope-normalization.sh`
- add `/.octon/framework/assurance/runtime/_ops/tests/test-capability-envelope-normalization.sh`
- edit `.github/workflows/architecture-conformance.yml`

### Candidate additive fields / checks
- `requested_pack_ids`
- `execution_class_id`
- `output_envelope_policy_ref`
- receipt coherence between `requested_capabilities`, granted capabilities, class route, and pack admission
- validation that broad-verification class usage cites the right preflight / receipt reason path
- validation that summary-only outputs cite raw payload refs when budgets require offload

## Live control-state materialization

This packet does **not** introduce a new control root. Live mutable execution truth continues to materialize through the existing run-control path:
- `/.octon/state/control/execution/runs/<run-id>/run-manifest.yml`
- existing engine authorization / grant flow
- existing policy and control receipts

The packet refines the semantics of what those existing artifacts and their companion evidence must contain.

## Retained evidence plan

This packet does **not** introduce a new evidence family. It relies on current retained evidence roots, but requires richer contents and dedicated validation output. Candidate retained artifacts after implementation include:
- enriched instruction-layer manifest evidence for reference runs
- enriched execution receipts proving class / pack / envelope coherence
- validator output under existing validation evidence practices
- sample support-target conformance proof for affected admitted packs

## Continuity

No new `state/continuity/**` roots are required. Both concepts are runtime and evidence refinements, not new continuity mechanisms.

## Optional derived outputs

No new generated family is required for packet closeout. A later follow-up may extend existing `generated/effective/capabilities/**` if operator usability needs a compiled view of normalized route and envelope policy, but this packet does not depend on it.

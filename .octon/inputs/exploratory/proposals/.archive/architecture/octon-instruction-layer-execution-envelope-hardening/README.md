# Octon Instruction-Layer Provenance and Capability-Envelope Hardening

## Purpose

This packet translates the corrected stage-2 recommendation set into a repository-grounded, proposal-first integration plan for **two in-scope concepts**:

1. **Instruction-layer provenance, precedence, and progressive-disclosure hardening**
2. **Capability invocation and output-envelope normalization**

This packet is **not** a greenfield redesign, **not** a generic harness memo, and **not** a request to reopen already-covered constitutional work. It exists because the live repo already absorbed most earlier harness recommendations, while these two remaining refinements are still only **partially covered** and are best landed as extensions of existing runtime, capability-pack, and validator surfaces.

## Executive triage

Octon is already run-contract-centered, constitution-first, overlay-aware, and support-target-bounded. The live repo already has a constitutional kernel, workspace charter pair, runtime contract families, engine-owned execution authorization, capability packs, support-target declarations, governance exclusions, and blocking architecture-conformance automation. What remains missing is narrower:

- the instruction layer is present, but it does not yet carry a complete, validator-enforced record of **which capability/tool surfaces and envelope policies were active for a run**
- capability invocation is governed, but the end-to-end path from **execution request -> grant -> receipt -> output envelope -> retained proof** is still more implicit and split than ideal for closure-ready operator use

The packet therefore chooses **extension/refinement of existing canonical surfaces** rather than net-new control planes, new top-level categories, or proposal-only pseudo-coverage.

## Current repo posture this packet assumes

- `/.octon/` is the single authoritative super-root.
- `framework/**` and `instance/**` are the only authored authority surfaces.
- `state/**` is authoritative only as mutable operational truth and retained evidence.
- `generated/**` is derived-only.
- run contracts, not missions, are the atomic consequential execution unit.
- support claims are bounded by `instance/governance/support-targets.yml` and `instance/governance/exclusions/action-classes.yml`.
- repo-specific durable runtime overlays are legal only at enabled overlay points.

## Why this is a sibling packet, not an edit to the active bounded UEC packet

The currently active architecture packet at:

`/.octon/inputs/exploratory/proposals/architecture/octon_bounded_uec_proposal_packet/`

is a **broad constitutional closeout and bounded-claim hardening packet**. It is oriented around the strongest truthful bounded Unified Execution Constitution target state and its closure program.

This packet is different. It is a **narrow, source-derived, runtime-hardening refinement packet** for two already-verified concepts. Folding it into the bounded UEC packet would blur that packet’s closure-critical scope, couple unrelated review burden, and make it harder to distinguish claim-critical hardening from optional harness-quality refinements.

## In-scope concepts

### 1. Instruction-layer provenance, precedence, and progressive-disclosure hardening
- **Upstream extraction disposition:** Adapt
- **Upstream verification disposition:** Adapt
- **Current coverage:** partially covered
- **Selected integration approach:** extension/refinement of existing runtime contract + instance runtime overlay + validator surfaces
- **Final repository disposition:** adapt

### 2. Capability invocation and output-envelope normalization
- **Upstream extraction disposition:** Adopt
- **Upstream verification disposition:** Adapt
- **Current coverage:** partially covered
- **Selected integration approach:** extension/refinement of engine runtime spec + capability-pack surfaces + repo-shell policy + validators
- **Final repository disposition:** adapt

## Excluded / out-of-scope concepts

These were previously recommended, but stage-2 verification determined they are already covered or otherwise not appropriate as new work in the current repo:

- canonical run-loop contract
- engine-owned authorization boundary and tripwires
- continuity handoffs across context windows
- error taxonomy and bounded retries
- verification loops as retained evidence
- scoped subagent delegation
- memory/session-store-as-authority patterns
- framework-specific harness embodiments

## Recommended reading order

1. `navigation/source-of-truth-map.md`
2. `resources/repository-baseline-audit.md`
3. `architecture/current-state-gap-map.md`
4. `architecture/concept-coverage-matrix.md`
5. `architecture/target-architecture.md`
6. `architecture/file-change-map.md`
7. `architecture/implementation-plan.md`
8. `architecture/validation-plan.md`
9. `architecture/acceptance-criteria.md`
10. `architecture/closure-certification-plan.md`

## Non-authority notice

This packet lives under `inputs/exploratory/proposals/**` and is **not canonical authority**. Promotion targets named in this packet all point to durable surfaces outside the proposal tree.

# Octon Deterministic Context Pack Builder v1

## Purpose

This packet records the promotion and closure posture for **deterministic Context Pack Builder v1** as a governed-runtime improvement to Octon’s **Constitutional Engineering Harness** and **Governed Agent Runtime** after:
1. the canonical append-only **Run Journal**, and
2. **Authorized Effect Token** enforcement.

This packet is grounded in the live Octon repository and stays within Octon’s existing constitutional, runtime, governance, and assurance boundaries. It is **not** a greenfield redesign, **not** a rival control plane, and **not** a broad target-state rewrite.

## Closure posture

The proposal has been implemented into durable Octon surfaces outside this packet:

- `/.octon/framework/engine/runtime/spec/context-pack-builder-v1.md`
- `/.octon/framework/engine/runtime/spec/context-pack-receipt-v1.schema.json`
- `/.octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json`
- `/.octon/framework/constitution/contracts/runtime/run-event-v2.schema.json`
- `/.octon/framework/constitution/contracts/runtime/family.yml`
- `/.octon/framework/constitution/contracts/runtime/state-reconstruction-v2.md`
- `/.octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json`
- `/.octon/framework/engine/runtime/spec/execution-request-v3.schema.json`
- `/.octon/framework/engine/runtime/spec/execution-grant-v1.schema.json`
- `/.octon/framework/engine/runtime/spec/execution-receipt-v3.schema.json`
- `/.octon/framework/engine/runtime/spec/runtime-event-v1.schema.json`
- `/.octon/instance/governance/policies/context-packing.yml`
- `/.octon/instance/governance/support-targets.yml`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-context-pack-builder.sh`
- `/.octon/framework/assurance/runtime/_ops/tests/test-context-pack-builder.sh`
- `/.octon/framework/assurance/runtime/_ops/fixtures/context-pack-builder-v1`
- `/.octon/framework/engine/runtime/README.md`

The packet remains **exploratory and non-authoritative**. It is now lineage and review context for the promoted surfaces; runtime behavior, policy, validation, and support claims must resolve from durable `/.octon/**` targets outside `inputs/**`.

## Why this is the single highest-leverage next step now

After Run Journal and Authorized Effect Tokens are in place:
- the journal can prove **what happened**
- token enforcement can prove **what was allowed to happen**
- the remaining highest-value missing proof is **what the Agent was allowed to see and reason from**

Deterministic Context Pack Builder v1 is therefore the next highest-leverage step because it closes the third critical question for consequential governed execution:
**what Working Context was model-visible, why was it included, what was excluded, and was that assembly policy-valid, fresh, bounded, and replayable?**

## Current repo posture this packet assumes

- `/.octon/` is the single authoritative super-root.
- `framework/**` and `instance/**` are the only durable authored authority surfaces.
- `state/**` is authoritative only as mutable operational truth, retained evidence, and continuity state.
- `generated/**` is derived-only.
- `inputs/**` is non-authoritative.
- Runs, not Missions, are the atomic consequential execution unit.
- support claims are bounded by `/.octon/instance/governance/support-targets.yml`
- context assembly must stay subordinate to constitutional contracts, execution authorization, and support-target governance.

## Implemented outcome

This packet landed a repository-grounded implementation shape for:
- a deterministic runtime Context Pack Builder contract
- a context-pack receipt and evidence path
- exact retained `model-visible-context.json` serialization and hash binding
- canonical hyphenated Run Journal lifecycle events with dot-name aliases only
- repo-specific context packing policy
- instruction-layer and grant/receipt binding for context evidence
- validator and conformance enforcement
- cutover and promotion discipline

## Out of scope

This packet does **not** reopen or redesign:
- Run Journal design
- Authorized Effect Token design
- Mission authority or continuity redesign
- memory subsystem redesign
- browser/API admission expansion
- MCP marketplace support
- multi-agent orchestration
- a new control plane
- generated surfaces as runtime truth

## Recommended reading order

1. `navigation/source-of-truth-map.md`
2. `resources/current-state-step-evaluation.md`
3. `resources/repository-baseline-audit.md`
4. `resources/implementation-gap-analysis.md`
5. `architecture/current-state-gap-map.md`
6. `architecture/concept-coverage-matrix.md`
7. `architecture/target-architecture.md`
8. `architecture/file-change-map.md`
9. `architecture/implementation-plan.md`
10. `architecture/validation-plan.md`
11. `architecture/acceptance-criteria.md`
12. `architecture/closure-certification-plan.md`

## Non-authority notice

This packet lives under `/.octon/inputs/exploratory/proposals/**` and is **not** canonical authority. Promotion targets named in this packet point only to durable `/.octon/**` or repo-root workflow surfaces outside the proposal tree.

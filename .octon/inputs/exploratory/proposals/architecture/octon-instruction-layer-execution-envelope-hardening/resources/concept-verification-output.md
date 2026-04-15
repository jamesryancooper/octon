# Captured Upstream Artifact — Stage 2 Concept Verification

> This file is a structured copy of the in-thread stage-2 verification result, preserved here as the governing upstream input for this packet.

## Verification summary

The live Octon repo materially changed the verdict from stage 1. The repo already had:
- constitutional objective, authority, runtime, assurance, disclosure, adapter, and retention families
- run-centered execution rather than mission-centered atomic execution
- explicit support-target declarations and governance exclusions
- existing instruction-layer manifest, capability packs, runtime overlays, and conformance CI

## Corrected final recommendation set

Only two recommendations survived as live work:

1. **Adapt — Instruction-layer provenance, precedence, and progressive-disclosure hardening**
   - corrected mapping:
     - `/.octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json`
     - `/.octon/framework/constitution/precedence/**`
     - `/.octon/instance/ingress/AGENTS.md`
     - `/.octon/framework/agency/governance/MEMORY.md`
     - `/.octon/instance/agency/runtime/tool-output-budgets.yml`

2. **Adapt — Capability invocation and output-envelope normalization**
   - corrected mapping:
     - `/.octon/framework/engine/runtime/spec/{execution-request-v2.schema.json,execution-grant-v1.schema.json,execution-receipt-v2.schema.json}`
     - `/.octon/instance/governance/policies/repo-shell-execution-classes.yml`
     - `/.octon/framework/capabilities/packs/**`
     - `/.octon/instance/governance/capability-packs/**`
     - `/.octon/instance/capabilities/runtime/packs/**`

## Concepts removed from downstream scope as already covered

- canonical run-loop contract
- engine-owned authorization boundary and tripwires
- continuity handoffs
- error taxonomy + retries
- verification loops as retained evidence
- scoped delegation

## Stage-2 final verdict

The downstream integration step should use **exactly these two `Adapt` items** and treat the rest of the earlier `Adopt` / `Adapt` set as already covered.

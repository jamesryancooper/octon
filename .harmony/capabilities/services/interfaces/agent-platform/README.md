# Agent Platform Service

Native-first interop service surface for session policy, context budgeting,
pruning, compaction semantics, routing, and presence evidence.

## Design Rules

- Core behavior is native and adapter-independent.
- Core contracts remain provider-agnostic.
- Adapter-specific mapping content lives under `adapters/` only.
- Critical policy failures are fail-closed.

## Core Artifacts

- `contract.md` — normative contract and boundary rules.
- `schema/capabilities.schema.json` — capability negotiation/report schema.
- `schema/session-policy.schema.json` — canonical session policy schema.
- `impl/context-budget.sh` — deterministic native context budget report generator.
- `impl/validate-session-policy.sh` — native policy validator.
- `impl/negotiate-capabilities.sh` — deterministic native/adapter capability resolver with fallback behavior.
- `impl/memory-flush-evidence.sh` — flush-before-compaction enforcement and evidence emitter.

## Adapter Artifacts

- `adapters/registry.yml` — adapter index and versions.
- `adapters/<id>/adapter.yml` — adapter metadata and supported semantics.
- `adapters/<id>/mapping.md` — canonical-to-provider mapping reference.
- `adapters/<id>/compatibility.yml` — runtime/tool compatibility contract.
- `adapters/<id>/fixtures/` — conformance fixtures.

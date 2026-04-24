# Current Runtime Surface Inventory

## Relevant runtime spec surfaces

| Surface | Role in lifecycle enforcement |
|---|---|
| `run-lifecycle-v1.md` | Normative state machine. |
| `run-journal-v1.md` | Canonical append-only transition history. |
| `run-event-v2.schema.json` | Canonical event family referenced by Run Journal and Context Pack Builder. |
| `runtime-event-v1.schema.json` | Compatibility-only dot-named envelope; not canonical authority. |
| `execution-authorization-v1.md` | Engine-owned authorization boundary. |
| `authorized-effect-token-v1.md` | Typed material-effect authority. |
| `context-pack-builder-v1.md` | Deterministic Working Context assembly and proof. |
| `evidence-store-v1.md` | Required retained proof and closeout bundle. |
| `operator-read-models-v1.md` | Derived operator visibility surfaces. |
| `promotion-activation-v1.md` | Promotion/activation receipt discipline, relevant to preventing proposal-generated authority. |

## Relevant implementation surfaces

| Surface | Expected implementation role |
|---|---|
| `crates/authority_engine/src/implementation/runtime_state.rs` | Lifecycle reconstruction and runtime-state materialization. |
| `crates/authority_engine/src/implementation/execution.rs` | Consequential execution orchestration through lifecycle gate. |
| `crates/runtime_bus/**` | Sole append path for canonical lifecycle events. |
| `crates/core/**` | Shared lifecycle types and domain utilities. |
| `run` / `run.cmd` | Operator entrypoints for run lifecycle commands. |

## Relevant assurance surfaces

| Surface | Expected proof role |
|---|---|
| `framework/assurance/runtime/_ops/scripts/**` | Runtime validators. |
| `framework/assurance/runtime/_ops/tests/**` | Regression tests. |
| `framework/assurance/runtime/_ops/fixtures/**` | Positive and negative fixture cases. |
| `state/evidence/validation/assurance/**` | Retained assurance evidence. |

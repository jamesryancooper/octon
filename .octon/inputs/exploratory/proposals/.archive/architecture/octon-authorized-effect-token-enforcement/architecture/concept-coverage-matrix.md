# Concept Coverage Matrix

| Concept | Current coverage | Target coverage | Durable landing surface | Validation |
|---|---|---|---|---|
| Engine-owned boundary | `execution-authorization-v1.md` | unchanged boundary, stronger token product | runtime spec + authority engine | authorization grant fixtures |
| Token type model | `authorized_effects` crate marker types | private/ledger-backed transport token + verified guard | `crates/authorized_effects`, `crates/core/src/execution_integrity.rs` | Rust unit tests |
| Token metadata | minimal token fields | grant/run/support/scope/expiry/revocation/journal/digest metadata | `authorized-effect-token-v2.schema.json` | schema tests |
| Token consumption | implicit | explicit consumption schema and receipt | `authorized-effect-token-consumption-v1.schema.json` | consumption fixture tests |
| Material family coverage | schema exists | complete inventory with API owner/path/test refs | `material-side-effect-inventory.yml` | inventory validator |
| Negative bypass proof | required by contract | tests for each material path family | assurance runtime tests | bypass suite |
| Run Journal integration | broad event schema | token lifecycle events/items | canonical Run Journal or `runtime-event-v1` interim | journal event tests |
| Run lifecycle | state machine exists | token validity bound to lifecycle states | `run-lifecycle-v1.md` | lifecycle transition tests |
| Evidence completeness | evidence store exists | token receipts required for material effects | `evidence-store-v1.md` | closeout completeness tests |
| Support target proof | runtime ledgers required | token coverage proof added to live tuple proof | `support-targets.yml` and proof bundles | support-target validator |
| Generated/read-model discipline | generated non-authority | optional display only | `generated/**` as derived | generated consumption negative test |

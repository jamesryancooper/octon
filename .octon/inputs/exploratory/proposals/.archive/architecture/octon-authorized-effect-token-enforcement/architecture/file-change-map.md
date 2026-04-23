# File Change Map

## Promotion targets and intended changes

| Target | Action | Authority class | Rationale |
|---|---|---|---|
| `.octon/framework/engine/runtime/spec/authorized-effect-token-v1.md` | edit | authored runtime spec | Clarify that v1 is the doctrine and v2 schema is the executable contract. |
| `.octon/framework/engine/runtime/spec/authorized-effect-token-v2.schema.json` | add | authored runtime spec | Define token object with grant/run/scope/expiry/revocation/journal/digest metadata. |
| `.octon/framework/engine/runtime/spec/authorized-effect-token-consumption-v1.schema.json` | add | authored runtime spec | Define consumption receipt and fail-closed rejection reasons. |
| `.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md` | edit | authored runtime spec | Add token enforcement as the required proof mechanism for every material family. |
| `.octon/framework/engine/runtime/spec/material-side-effect-inventory-v1.schema.json` | edit | authored runtime spec | Require token class, owner module, bypass test ref, and consumption receipt ref. |
| `.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml` | add | authored runtime spec / inventory | Inventory material path families and map them to token classes and tests. |
| `.octon/framework/engine/runtime/spec/execution-request-v3.schema.json` | edit | authored runtime spec | Allow/request expected effect classes and token obligations when material flags are present. |
| `.octon/framework/engine/runtime/spec/execution-grant-v1.schema.json` | edit | authored runtime spec | Include minted token obligations and effect-class grants. |
| `.octon/framework/engine/runtime/spec/execution-receipt-v3.schema.json` | edit | authored runtime spec | Require token refs/consumption refs for material effects. |
| `.octon/framework/engine/runtime/spec/runtime-event-v1.schema.json` | edit | authored runtime spec | Add token lifecycle events if canonical Run Journal is not yet the only event schema. |
| `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md` | edit | authored runtime spec | Tie token validity and consumption to authorized/running states and revocation/closeout behavior. |
| `.octon/framework/engine/runtime/spec/evidence-store-v1.md` | edit | authored runtime spec | Add token issue/consume/reject evidence to minimum consequential run bundle. |
| `.octon/framework/engine/runtime/crates/authorized_effects/src/lib.rs` | edit | runtime implementation | Harden token metadata, reduce arbitrary construction risk, add verification/guard types or supporting APIs. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/api.rs` | edit | runtime implementation | Mint full token records from GrantBundle and expose effect-class grant semantics. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs` | edit | runtime implementation | Require verified tokens before material execution artifact writes and execution steps. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/authority.rs` | edit | runtime implementation | Emit token control/evidence refs with decision/grant artifacts. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/runtime_state.rs` | edit | runtime implementation | Synchronize token states with Run lifecycle and revocation/closeout states. |
| `.octon/framework/engine/runtime/crates/core/src/execution_integrity.rs` | edit | runtime implementation | Add token verifier / integrity checks / canonical token-record lookup. |
| `.octon/framework/engine/runtime/crates/runtime_bus/src/lib.rs` | edit | runtime implementation | Append token lifecycle events/items. |
| `.octon/framework/engine/runtime/crates/replay_store/src/lib.rs` | edit | runtime implementation | Replay token lifecycle without repeating side effects. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-authorized-effect-token-enforcement.sh` | add | assurance validator | Validate schemas, inventory, and required token references. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-authorization-boundary-coverage.sh` | add/edit | assurance validator | Enforce coverage contract and negative bypass proof refs. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-material-side-effect-inventory.sh` | add | assurance validator | Validate every material family has token mapping and test refs. |
| `.octon/framework/assurance/runtime/_ops/tests/test-authorized-effect-token-negative-bypass.sh` | add | assurance test | Prove direct material calls without valid token fail closed. |
| `.octon/framework/assurance/runtime/_ops/tests/test-authorized-effect-token-consumption.sh` | add | assurance test | Prove valid, wrong-kind, expired, revoked, consumed, and wrong-scope cases. |
| `.octon/framework/assurance/runtime/_ops/tests/test-material-side-effect-coverage-fixtures.sh` | add | assurance test | Validate fixtures for all material path families. |
| `.octon/instance/governance/policies/repo-shell-execution-classes.yml` | edit | instance governance policy | Require token class alignment for shell-backed material routes. |
| `.octon/instance/governance/support-targets.yml` | edit | instance governance policy | Add token coverage proof to supported tuple evidence requirements without widening support. |

## Explicit non-targets

| Path | Reason |
|---|---|
| `.github/workflows/**` | Active proposals may not mix `.octon/**` and non-`.octon/**` promotion targets. Add linked repo-local CI wiring only if auto-discovery does not pick up new validators. |
| `.octon/generated/**` | Generated outputs are derived-only; no generated authority is required for closeout. |
| `.octon/inputs/**` outside this packet | Non-authoritative exploratory material; not a runtime dependency. |

# Coverage Traceability Matrix

| Source claim / repo fact | Gap identified | Proposal artifact | Promotion target | Validation |
|---|---|---|---|---|
| Material execution must pass through `authorize_execution`. | Side-effect API may still rely on ambient grant. | `target-architecture.md` | `authorized-effect-token-v2.schema.json`, runtime code | negative bypass tests |
| `authorized-effect-token-v1.md` requires typed tokens. | v1 is concise and not schema-backed. | `file-change-map.md` | v2 schema + consumption schema | schema validation |
| Boundary coverage requires inventory and negative controls. | No complete token enforcement inventory in packet source set. | `implementation-plan.md` | `material-side-effect-inventory.yml` | inventory validator |
| Runtime has authorized_effects crate. | Current token type lacks closure-grade metadata and verifier. | `implementation-gap-analysis.md` | `authorized_effects/src/lib.rs` | Rust tests |
| Authority engine issues some effects. | Issuance is not complete across all material families. | `concept-coverage-matrix.md` | `authority_engine/**` | fixture grants |
| Runtime events exist. | Token lifecycle events absent. | `target-architecture.md` | Run Journal/runtime event spec | journal tests |
| Evidence store defines minimum bundles. | Token proof not explicit. | `validation-plan.md` | `evidence-store-v1.md` | completeness tests |
| Support-targets require proof and ledgers. | Token proof not explicit. | `file-change-map.md` | `support-targets.yml` | support proof validator |
| Generated outputs are non-authoritative. | Token status views could be misused. | `source-of-truth-map.md` | no generated authority target | generated-consumption negative test |

# Current-State Gap Map

| Current strength or limitation | Gap type | Severity | Target remedy |
|---|---|---:|---|
| Five-class super-root model is explicit and strong. | None / preserve | Low | Preserve unchanged; encode in contract registry and generated docs. |
| Authored authority limited to `framework/**` and `instance/**`. | None / preserve | Low | Preserve; add self-validation for consumers. |
| Generated non-authority rule is strong. | Proof / validation | Medium | Add `validate-generated-non-authority.sh` and generated-view traceability. |
| Raw `inputs/**` non-authority is strong but proposal paths are numerous. | Validation | Medium | Add direct runtime/policy dependency scanner for inputs/proposals. |
| Constitutional kernel is strong. | Ergonomics | Medium | Keep kernel; reduce repeated projections in active docs. |
| Structural topology repeated across README, spec, bootstrap, ingress, manifests. | Design / maintainability | High | Make `contract-registry.yml` the machine-readable topology registry and generate docs. |
| Execution authorization contract is strong. | Implementation / proof | Critical | Add total side-effect path inventory, static checks, negative tests, and receipts. |
| Runtime crates and CLI exist. | Implementation / packaging | High | Harden runtime packaging, source fallback posture, and run lifecycle state machine. |
| `authority_engine/src/implementation.rs` is oversized. | Maintainability / testability | High | Decompose into auditable modules and fixture-driven tests. |
| Evidence obligations are detailed. | Implementation / proof | High | Add evidence-store contract and completeness validator. |
| CI artifacts carry some evidence. | Design / evidence durability | High | Distinguish transport artifacts from canonical retained evidence. |
| Support-target matrix is honest and bounded. | Proof / disclosure | High | Require proof bundles for every admitted tuple. |
| Mission/run model is strong. | Implementation / UX | Medium-high | Formalize run lifecycle and generate operator read models. |
| Operator surfaces exist in CLI. | Ergonomics | High | Add mission/run/grant/evidence/support/readiness views and validators. |
| Overlay registry exists. | Validation | Medium | Ensure no undeclared overlays and generated docs align with registry. |
| Services and skills have deny-by-default guardrails. | Runtime coverage | Medium-high | Bind service/skill invocation to authorization coverage inventory. |
| Historical wave/cutover/proposal-lineage content remains active. | Complexity / legibility | Medium | Move to decision records or migration evidence and simplify active docs. |
| Project findings can flow directly to durable context without separate promotion step. | Authority leak risk | High | Require promotion receipts for all non-authored/generated-to-authority transitions. |
| Generated operator views are underdeveloped. | Ergonomics / inspectability | High | Define operator-read-models-v1 and generated projections with traceability. |
| Support expansion surfaces exist as stage-only. | Support realism | Low | Preserve stage-only posture until proofing admits them. |

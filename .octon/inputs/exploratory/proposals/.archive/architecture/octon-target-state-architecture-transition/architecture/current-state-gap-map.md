# Current-State Gap Map

| Area | Current live state | Target state | Gap severity | Disposition |
|---|---|---|---:|---|
| Super-root/class roots | Strong: `.octon/` with five class roots and explicit authority roles. | Preserve unchanged. | Low | Preserve. |
| Structural registry | Strong: `contract-registry.yml` is canonical machine-readable topology, authority, publication, and doc-target registry. | Add typed coverage, map-publication, and compatibility-retirement metadata. | Medium | Extend. |
| Active docs | Mostly slim and registry-backed. | Active docs stay slim; generated maps restore navigability. | Medium | Generate maps; remove stale historical/projection language. |
| Generated/authored discipline | Strong: generated never mints authority; inputs non-authoritative. | Enforce through validators and runtime freshness checks. | Medium | Harden. |
| Fail-closed obligations | Strong content, but live file contains duplicate IDs `FCR-017`, `FCR-018`, and `FCR-019`. | Globally unique stable reason-code IDs. | High | Fix first. |
| Evidence obligations | Strong content, but live file contains duplicate IDs `EVI-013` and `EVI-014`. | Globally unique evidence obligation IDs with test fixtures. | High | Fix first. |
| Execution authorization boundary | Real spec and runtime import/call posture. | Proven coverage for every material side-effect path. | High | Add material-side-effect inventory and coverage validator. |
| Runtime kernel | Functional command surface includes services, tools, validation, stdio, studio, run lifecycle, workflow compatibility, and orchestration inspection. | Command router plus modular command handlers and request builders. | Medium-high | Refactor. |
| Authority engine | Meaningful authorization implementation exists. | Phase-auditable implementation with phase result artifacts. | Medium-high | Refactor. |
| Mission/run model | Strong: mission continuity plus run-contract atomicity. | Preserve; add lifecycle proof demos and closure validation. | Medium | Harden. |
| Support target model | Strong and bounded; repo-shell/ci-control-plane live, broader adapters stage-only/non-live. | Add closure-grade support proof bundles and stricter dossier sufficiency. | Medium-high | Harden. |
| Support dossiers | Repo-shell consequential dossier is qualified but minimum/current retained runs = 1. | Higher sufficiency threshold plus negative-control and recovery proof. | Medium-high | Raise bar. |
| Services | Typed service contracts, deny-by-default guardrails, policy preflight and shell enforcement. | Tie service invocation side effects into coverage inventory. | Medium | Integrate. |
| Skills | Useful progressive-disclosure capability layer; documentation contains symlink-era and generated-projection language. | One host projection model, derived routing, validation of projection semantics. | Medium | Reconcile docs and validators. |
| Proof planes | Lab, observability, evidence, and maintainability planes exist. | Queryable proof plane with completeness receipts and support proof bundles. | High | Build closeout proof layer. |
| Generated/effective | Publication model exists; generated/effective requires receipts and freshness. | Runtime refusal for missing/stale publication receipts is tested. | High | Add negative controls. |
| Compatibility projections | Explicitly retained for existing validators/runtime tooling. | Owner/consumer/expiry/retirement gates; no parallel steady state. | Medium-high | Retire or generate. |
| Operator navigability | Possible for experts; hard for new operators/agents. | Generated maps and concise RunCard/HarnessCard/SupportCard surfaces. | Medium | Productize projections. |

## Gap classification

The current architecture is not fundamentally misframed. Its gaps are mostly enforcement, proof, runtime modularity, and transition retirement gaps. The correct intervention is focused hardening plus moderate runtime restructuring, not re-foundation.

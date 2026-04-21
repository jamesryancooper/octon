# Full Architectural Evaluation

## Executive judgment

Score: **7.7 / 10**.

Confidence: **medium-high**. This evaluation is based on live repository inspection through the public GitHub surfaces on 2026-04-21, including proposal standards, super-root docs, root manifest, structural registry, constitution, runtime spec, runtime command surface, support targets, support admissions, support dossiers, services, skills, missions, generated/read-model posture, and state/evidence placement.

Severity judgment: **focused gap-closing with moderate runtime restructuring**.

Octon does not need re-foundation. The current architecture is genuinely strong in the authority/topology/governance layer and increasingly real in the runtime layer. Its main deficits are proof of complete authorization-boundary coverage, runtime modularity, proof-plane sufficiency, transitional-shim retirement, and human/agent navigability.

## Current architectural reality

Octon is a constitutional engineering harness with a governed runtime and repo-native authority/control/evidence model. The live `.octon/README.md` establishes `.octon/` as the super-root and separates `framework/`, `instance/`, `state/`, `generated/`, and `inputs/`, with authored authority only in `framework/**` and `instance/**`. The root manifest declares version `0.6.34`, class-root bindings, portability profiles, runtime input roots, execution governance modes, protected refs/workflows, critical action types, receipt roots, and executor profiles.

The architecture specification states that `contract-registry.yml` is the machine-readable source of truth for topology, authority families, publication metadata, and doc targets. The contract registry itself has schema version `architecture-contract-registry-v2` and models class roots, delegated registries, path families, publication metadata, and compatibility projections.

The constitution is load-bearing. `CHARTER.md` defines Octon as a Constitutional Engineering Harness whose execution core is a Governed Agent Runtime. It requires bounded admitted support, explicit authority routing before material side effects, fail-closed behavior, proof-backed claims, and exclusion of stage-only/unadmitted surfaces from live claims.

The runtime is actual but not yet target-state-proven. `execution-authorization-v1.md` defines the mandatory `authorize_execution(request: ExecutionRequest) -> GrantBundle` boundary before material side effects. `kernel/src/main.rs` imports `authorize_execution` and exposes a broad CLI surface including service, tool, validation, stdio, studio, run, workflow compatibility, and orchestration commands.

The support model is actual and bounded. `support-targets.yml` declares a finite live support universe and distinguishes supported repo-shell/CI surfaces from stage-only or non-live GitHub, Studio, frontier, browser, and API surfaces. The repo-shell consequential admission is explicit and references proof planes, evidence refs, and a support dossier. The dossier is qualified but target-state sufficiency should rise above `minimum_retained_runs: 1`.

## Strongest architectural elements

1. **Source-of-truth separation.** The five-class root model is correct and strategically central. It prevents raw inputs, generated views, and host surfaces from silently becoming authority.
2. **Structural registry.** The move from hand-maintained path matrices to registry-backed topology is a strong architectural decision.
3. **Constitutional fail-closed model.** The default route is deny; missing authority, unsupported support claims, generated-as-authority, raw-input dependency, and host-authority bypass are explicitly blocked.
4. **Run-contract atomicity.** Mission continuity and run execution authority are correctly separated.
5. **Bounded support targets.** The live support universe is explicit and finite rather than overclaimed.
6. **Non-authoritative adapters and projections.** Host/model adapters may narrow or mirror but not widen authority.

## Weaknesses and gaps

1. **Duplicate obligation IDs.** `fail-closed.yml` repeats `FCR-017`, `FCR-018`, and `FCR-019`; `evidence.yml` repeats `EVI-013` and `EVI-014`. For a reason-code/evidence-driven architecture, this is a hard hygiene defect.
2. **Authorization-boundary coverage is not yet proven.** The boundary exists and runtime imports it, but target state requires a coverage proof over every material side-effect path.
3. **Runtime internals need modularity.** The command surface is broad and should be split into command modules, request builders, side-effect classification, and phase-auditable authority modules.
4. **Proof planes are structurally strong but operationally incomplete.** Evidence obligations exist, but completeness receipts, queryable proof, negative-control evidence, and support proof bundles need hardening.
5. **Support dossier sufficiency is bootstrap-grade.** The consequential repo-shell dossier is qualified but only requires/currently has one retained run. Target-state support claims need stronger representative and negative-control coverage.
6. **Compatibility projections may calcify.** The registry explicitly retains compatibility projections for existing validators/runtime tooling, but target state needs owner/consumer/expiry metadata.
7. **Active-doc hygiene needs tightening.** Active docs are mostly slim and registry-backed, but skill projection language and historical transition language should be reconciled.
8. **Navigation remains expert-heavy.** Registry-backed truth is strong, but the repository needs generated maps for humans and agents.

## Scorecard

| Dimension | Score | Limiting factor |
|---|---:|---|
| Architectural clarity | 7.5 | Clear after study; too dense without generated maps. |
| Conceptual coherence | 8.6 | Strong class-root, mission/run, authority/evidence model. |
| Structural integrity | 8.2 | Good placement discipline; obligation ID defects and shims remain. |
| Registry-backed modeling | 8.3 | Real anchor; needs generated navigation and retirement metadata. |
| Documentation-to-registry alignment | 7.4 | Mostly good; active-doc projection/history residue remains. |
| Separation of concerns | 8.2 | Strong class roots; runtime implementation should split further. |
| Authority-model correctness | 8.8 | Excellent generated/host/model-prior non-authority discipline. |
| Governance strength | 8.5 | Strong fail-closed and bounded support model. |
| Runtime architecture quality | 7.0 | Actual runtime exists; coverage and modularity lag. |
| Mission/run/control-state model | 8.2 | Strong; more lifecycle proof needed. |
| Publication model | 7.8 | Correct derived-only model; needs freshness negative controls. |
| Generated-vs-authored discipline | 9.0 | One of Octon's strongest traits. |
| Support-target realism | 8.3 | Honest finite support; dossier sufficiency should rise. |
| Proof-plane architecture | 7.5 | Good taxonomy; insufficient closeout automation. |
| Maintainability | 6.8 | Runtime and registry density require modularization/maps. |
| Evolvability | 8.0 | Overlay/registry/support/admission model is evolvable. |
| Scalability | 7.1 | Scales conceptually; proof/runtime complexity must be controlled. |
| Reliability | 7.2 | Fail-closed posture helps; full enforcement proof missing. |
| Recoverability/reversibility | 7.8 | Good posture; recovery proof needs more examples. |
| Observability/inspectability | 7.5 | Domain exists; needs queryable proof/read models. |
| Evidence/auditability | 8.0 | Strong roots; completeness validators needed. |
| Portability/adapter discipline | 7.7 | Strong non-authority discipline; broad adapters stage-only. |
| Extensibility | 7.8 | Good overlays/skills/services; avoid sprawl. |
| Complexity management | 6.6 | Much complexity is load-bearing; needs maps and simplification. |
| Boundary discipline | 8.7 | Excellent authority boundaries; coverage proof needed. |
| Implementation consistency | 7.2 | Better than aspiration; full path proof missing. |
| Fitness for long-running governed work | 8.0 | Strong fit; target proof still pending. |

## Target-state comparison

A 10/10 target-state architecture would have:

- complete side-effect inventory and authorization coverage proof;
- modular runtime command/request/side-effect/authority phases;
- unique stable obligation IDs and reason codes;
- generated but non-authoritative architecture maps;
- proof bundles and evidence completeness receipts;
- support dossier sufficiency above bootstrap grade;
- compatibility projections with owner/consumer/expiry and retirement evidence;
- no active-doc historical/projection conflicts;
- no proposal-path dependency after promotion.

## Final evaluation verdict

Octon is architecturally strong enough to preserve. Its best structures are load-bearing, not ornamental. The transition to target-state excellence should focus on proof, enforcement, modularization, and retirement discipline rather than re-founding the architecture.

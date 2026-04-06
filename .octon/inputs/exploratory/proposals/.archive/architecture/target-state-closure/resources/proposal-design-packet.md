# Proposal and Design Packet (Reconstructed Normative Brief)

This resource reconstructs the authoritative target-state design brief from the proposal and design packet established earlier in the thread. It is included here so the implementation packet is self-contained.

## Core target-state

Octon’s target state is a **fully unified execution constitution**:

- a constitutional, contract-governed control plane for autonomous work
- the model is a pluggable reasoning component inside the harness, not the harness itself
- control is durable, versioned, and explicit
- objective binding is machine-readable
- authority routing is explicit and fail-closed
- runtime is lifecycle-managed, resumable, and replayable
- proof is multi-plane
- disclosure is generated, not aspirational
- build-to-delete is a real governance obligation

## Irreducible layers

1. Design Charter / Constitutional Layer  
2. Intent / Objective Layer  
3. Durable Control Layer  
4. Policy / Authority Layer  
5. Agency Layer  
6. Runtime Layer  
7. Verification / Evaluation Layer  
8. Lab / Experimentation Layer  
9. Governance / Safety Layer  
10. Observability / Reporting Layer  
11. Improvement / Evolution Layer

## Non-negotiable design positions

- Mission is not the atomic execution primitive. Use: workspace charter + mission charter + run contract + execution attempt/stage.
- Evidence is classed into git-inline control-plane evidence, git-tracked manifests/pointers, and external immutable replay/telemetry storage.
- GitHub labels/comments/checks are adapters, not authority.
- Lab is a first-class top-level framework domain.
- Model portability is mediated by a formal Model Adapter Contract with conformance tests.
- Benchmarking is multi-plane: structural, functional, behavioral, governance, recovery, and maintainability where relevant.
- RunCard and HarnessCard are mandatory disclosure artifacts.
- Browser/UI and broader API surfaces arrive through governed capability packs.
- Octon publishes and enforces an explicit support-target matrix.
- Agency simplifies around real boundary value and demotes persona-heavy execution surfaces.

## Proposed architectural moves

- preserve the class-root super-root and the runtime engine seam
- consolidate constitutional authority under `framework/constitution/**`
- normalize run-first control roots under `state/control/execution/runs/**`
- unify authority into canonical approval/grant/lease/revocation/decision artifacts
- normalize runtime around run manifests, checkpoints, continuity, replay, and evidence classes
- add top-level `framework/lab/**` and `framework/observability/**`
- make RunCard and HarnessCard live disclosure surfaces
- separate portable kernel from host/model/capability adapters
- institutionalize retirement, ablation, and drift governance

## Closure standard

Octon can claim complete target-state closure only when:

- all critical and high blockers are resolved in substance
- all claim-bearing artifacts are generated from canonical sources
- one canonical run-contract family is live
- support-target and adapter declarations agree with every active proof-bundle run
- active exemplar runs have complete evidence classification
- no superseded wording survives in active disclosure
- two consecutive certification passes yield identical closure outcome

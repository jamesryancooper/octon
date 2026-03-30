# Implementation Plan

## Execution posture
- implement the target-state-correct architecture for each phase, not the smallest diff
- preserve transitional scaffolding only when it is required for staged cutover, compatibility, or evidence
- when minimal change conflicts with end-state correctness, choose end-state correctness
- retire or re-bound temporary structure once its cutover purpose is complete

## Phase 0 — baseline freeze and architectural inventory
- produce baseline internal HarnessCard v0
- inventory live authority, runtime, proof, and evidence surfaces
- freeze core constitutional inputs for extraction

## Phase 1 — constitutional extraction
- create `framework/constitution/**`
- move precedence, obligations, and contract registry there
- reduce ingress to constitution-first minimal read set
- convert old constitutional docs into shims

## Phase 2 — objective and authority cutover
- add `instance/charter/**`
- add run contract + stage attempt + approval/grant/lease/revocation artifacts
- add authority engine implementation and host projection
- dual-write GitHub signals into canonical approval artifacts

## Phase 3 — runtime and evidence normalization
- normalize run manifests/runtime-state, checkpoints, run continuity, replay pointers
- classify evidence storage
- add external immutable replay/index integration

## Phase 4 — proof expansion and lab introduction
- preserve structural/governance gates
- add functional, behavioral, maintainability, and recovery suites
- add top-level lab scenario/replay/shadow/fault domains
- turn provider reviews into evaluator adapters

## Phase 5 — adapter and support-target hardening
- model adapter contracts and conformance
- host adapter contracts
- governed browser/API packs if admitted
- support-target matrix publication and enforcement

## Phase 6 — simplification and deletion
- make orchestrator the clear kernel profile
- demote persona overlays from the required path
- remove label-native authority assumptions
- retire duplicated constitutional surfaces

## Phase 7 — build-to-delete institutionalization
- retirement registry
- drift review
- adapter review
- support-target review
- ablation-driven deletion workflow

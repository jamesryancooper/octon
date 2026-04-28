# Self-Evolution Runtime v5 Implementation Report

This packet has been implemented as an atomic v5 migration for Octon's constitutional self-evolution proposal-to-promotion runtime.

## Implemented Target State

The repository now contains a governed self-evolution path:

```text
retained evidence / validation friction / operator feedback
  -> Evidence-to-Candidate Distillation Record
  -> Evolution Candidate
  -> Governance Impact Simulation
  -> Assurance Lab Promotion Gate
  -> manifest-governed proposal packet
  -> Decision Request / Constitutional Amendment Request
  -> Promotion Request and Promotion Receipt
  -> durable authority/control/evidence writes
  -> generated projection refresh
  -> Recertification Result
  -> Evolution Ledger
```

The implementation preserves the v5 rule: evidence, model output, lab success, simulation success, generated summaries, and proposal packets may inform change, but they do not approve or authorize change.

## Changed Files by Root

### framework/**

- Added portable v5 runtime contracts under `framework/engine/runtime/spec/**` for Evolution Program, Evolution Candidate, Evidence-to-Candidate Distillation Record, Governance Impact Simulation, Assurance Lab Promotion Gate, self-evolution Decision Request, Constitutional Amendment Request, Promotion Request, Promotion Receipt, Recertification Request/Result, rollback/retirement posture, evidence profiles, and Evolution Ledger.
- Added authored runtime specs for the Evolution Proposal Compiler, Promotion Runtime, and Recertification Runtime.
- Added constitutional mirror contracts under `framework/constitution/contracts/{runtime,assurance,authority}/**`.
- Registered the v5 contract family in the constitutional and cognition contract registries.
- Added `framework/orchestration/practices/evolution-lifecycle-standards.md`.
- Added the focused validator and negative-control test:
  - `framework/assurance/runtime/_ops/scripts/validate-self-evolution-runtime-v5.sh`
  - `framework/assurance/runtime/_ops/tests/test-self-evolution-runtime-v5.sh`
- Wired Rust CLI/runtime commands in:
  - `framework/engine/runtime/crates/kernel/src/main.rs`
  - `framework/engine/runtime/crates/kernel/src/commands/mod.rs`
  - `framework/engine/runtime/crates/kernel/src/commands/evolution.rs`

### instance/**

- Added repo-specific durable self-evolution authority under `instance/governance/evolution/**`:
  - Evolution Program
  - evolution policy
  - promotion policy
  - recertification policy
  - constitutional amendment policy
  - candidate distillation policy
  - evidence profile policy
  - path-family boundary policy
- Added the evolution overlay point and enabled it through the instance manifest.
- Added evolution generated-read-model coverage to the non-authority register.

### state/control/**

- Added operational truth for the v5 validation path under `state/control/evolution/**`:
  - program status
  - candidate
  - distillation record
  - simulation
  - lab gate
  - self-evolution decision
  - constitutional amendment request
  - promotion request
  - recertification result
  - rollback posture
  - retirement posture
  - append-only ledger index
- Added canonical execution approval request/grant refs for the accepted promotion path under `state/control/execution/approvals/**`.

### state/evidence/**

- Added retained v5 evidence under `state/evidence/evolution/**` for profile selection, candidates, distillation, simulations, lab gates, proposal compilation, amendment requests, promotions, recertifications, rollback, and retirement.

### state/continuity/**

- Added resumable non-authoritative self-evolution context under `state/continuity/evolution/**`.

### generated/**

- Added derived, explicitly non-authoritative evolution projections under `generated/cognition/projections/materialized/evolution/**`.

### inputs/**

- Updated this proposal packet to `status: implemented`.
- Added this implementation report and registered it as the implementation receipt.

## Runtime and CLI

The Rust CLI now exposes:

- `octon evolve observe`
- `octon evolve candidates`
- `octon evolve inspect <candidate>`
- `octon evolve classify <candidate>`
- `octon evolve simulate <candidate>`
- `octon evolve lab <candidate>`
- `octon evolve propose <candidate>`
- `octon evolve decide <proposal-or-request>`
- `octon evolve promote <proposal>`
- `octon evolve recertify`
- `octon evolve rollback`
- `octon evolve retire`
- `octon evolve ledger`
- `octon amend request`
- `octon amend inspect`
- `octon promote inspect`
- `octon promote apply`
- `octon promote receipt`
- `octon recertify status`
- `octon recertify run`

The v5 runtime is control-plane only. It inspects and validates candidates, simulations, lab gates, decisions, promotion requests, receipts, recertification results, rollback posture, and ledgers. It does not directly execute material work or bypass run contracts, execution authorization, effect-token requirements, or retained evidence.

## Implemented Behaviors

- Evolution Programs define the long-lived governed improvement track and cannot mutate authority directly.
- Evolution Candidates require evidence refs, source classification, impact classification, rollback posture, proof classes, and a constrained disposition.
- Evidence-to-Candidate Distillation Records remain non-authoritative and cannot auto-promote.
- Governance Impact Simulations retain impact evidence and explicitly do not approve change.
- Assurance Lab Promotion Gates retain proof evidence and explicitly do not approve change.
- The Evolution Proposal Compiler contract preserves proposal packet non-authority and declared promotion targets.
- Constitutional Amendment Requests are required for constitutional, governance, evidence, generated/effective, support, authorization-boundary, root-placement, or fail-closed changes.
- Promotion Requests require declared legal targets, accepted decision refs, no proposal-path dependency leaks, rollback/retirement posture, and recertification.
- Promotion Receipts retain non-authority attestations and do not authorize future change.
- Recertification Results validate post-promotion coherence and block closure on failure.
- The Evolution Ledger indexes candidates, simulations, lab gates, proposals, decisions, amendments, promotions, rollback/retirement, and recertifications without replacing source truth.

## Validation

Commands run:

- `.octon/framework/assurance/runtime/_ops/scripts/validate-self-evolution-runtime-v5.sh --root /Users/jamesryancooper/Projects/octon`
- `.octon/framework/assurance/runtime/_ops/tests/test-self-evolution-runtime-v5.sh`
- `cargo fmt --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml --all`
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel`

The focused validator and v5 negative-control suite passed. The recertification runtime verifies the retained recertification request/result and fails closed when required dimensions or evidence are missing; it does not mutate control state directly.

## Dependency Status

- v1 surfaces: present in this worktree through Engagement, Project Profile, Work Package, Decision Request, Evidence Profile, Preflight Evidence Lane, and governed run-contract candidate surfaces.
- v2 surfaces: present in this worktree through Mission Runner, Mission Queue, Autonomy Window, Action Slice, Continuation Decision, Mission Run Ledger, Mission Evidence Profile, and mission-aware Decision Request surfaces.
- v3 surfaces: present in this worktree through Stewardship Program, Epoch, Trigger, Admission, Idle, Renewal, Ledger, Evidence Profile, and stewardship-aware Decision Request surfaces.
- v4 surfaces: present in this worktree through Connector Admission Runtime, Connector Identity/Operation/Admission/Trust Dossier, drift, quarantine, evidence profile, and connector-aware Decision Request surfaces.

No v1-v4 reimplementation was added for v5. The lower-layer v1-v4 surfaces were observed in the live worktree and are documented as dependencies; v5 runtime enforcement is focused on self-evolution controls and remains fail-closed for missing v5 promotion, approval, evidence, rollback, or recertification artifacts.

## Known Limitations and Deferred Scope

- No autonomous constitutional amendments.
- No autonomous support-target widening.
- No autonomous connector live admission.
- No autonomous release/deployment authority changes.
- No AI-only quorum.
- No self-modifying runtime.
- No automatic proposal promotion.
- No automatic evidence-distillation promotion.
- No multi-organization governance evolution.

## Authority Confirmations

- No rival control plane was introduced.
- Generated artifacts remain non-authoritative read models.
- Evidence distillation does not auto-promote.
- Proposal packets do not become runtime authority.
- Lab success does not approve change.
- Simulation success does not approve change.
- Octon cannot self-authorize its own evolution.
- All material execution remains routed through governed run lifecycle and execution authorization.

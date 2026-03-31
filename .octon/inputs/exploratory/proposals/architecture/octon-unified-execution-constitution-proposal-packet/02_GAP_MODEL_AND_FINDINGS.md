# Gap Model and Findings

## Summary table

| Finding | Severity | Finding title | Owning workstream(s) |
|---|---|---|---|
| F-01 | Critical | Runtime entrypoint is still workflow/mission-shaped instead of run-contract-native | WS0 |
| F-02 | Critical | Authority engine split exists architecturally but not yet substantively | WS1 |
| F-03 | High | Approval, exception, revocation, and quorum artifacts are not yet proven as universal runtime consumers | WS1 |
| F-04 | High | GitHub has moved toward adapter status, but operational authority is still too host-workflow-heavy | WS1, WS4 |
| F-05 | Critical | Run lifecycle artifacts exist, but universal durable event-sourced behavior is not yet proven | WS0, WS2 |
| F-06 | High | Stage-attempt, checkpoint, continuity, intervention, and measurement are not yet proven routine on the live path | WS2 |
| F-07 | High | Replay and retention are well-modeled in contract, but external immutable replay is not yet operationally proven | WS2, WS5 |
| F-08 | Critical | Proof planes are present, but not yet clearly universal as live CI/runtime gates | WS3, WS5 |
| F-09 | High | Lab is correctly top-level, but still thin as a runtime experimentation substrate | WS3 |
| F-10 | High | Observability exists as a top-level domain but is still thinner and more fragmented than the target model | WS2, WS3, WS5 |
| F-11 | High | Support-target matrix is real and honest, but admission enforcement and envelope widening remain incomplete | WS4, WS5 |
| F-12 | High | Model adapters and host adapters are well-formed, but universal conformance workflows are still thin | WS4 |
| F-13 | High | Capability-pack architecture is only partially realized | WS4 |
| F-14 | High | RunCard and HarnessCard are real and substantive, but disclosure is still too closure-centric | WS5 |
| F-15 | Medium | Governance overlays for build-to-delete and retirement exist, but release-blocking enforcement is not yet fully proven | WS5, WS6 |
| F-16 | Medium | Agency simplification has materially landed, but final retirement of non-load-bearing overlays is incomplete | WS6 |
| F-17 | Medium | Historical wave and closure artifacts are overrepresented in the proof story | WS5, WS6 |
| F-18 | High | Intervention and measurement disclosure policy is ahead of proven mandatory emission | WS2, WS5 |
| F-19 | Medium | Brownfield adoption and retrofit guidance is not explicit enough | WS6 |
| F-20 | Critical | Final claim criteria for 'fully unified execution constitution' are not yet encoded as a hard closeout contract | WS5 |
| F-21 | Medium | Stale-doc, state drift, governance drift, and verifier-overfitting controls are present but incomplete | WS3, WS6 |
| F-22 | Medium | Evaluator independence and anti-overfitting posture need stronger explicit hardening | WS3 |
| F-23 | High | Mission remains too visible in live runtime entrypoints | WS0 |
| F-24 | Medium | Supported live envelope is narrow and should stay narrow until proof truly widens | WS4, WS5 |

## Findings in detail

### F-01 — Runtime entrypoint is still workflow/mission-shaped instead of run-contract-native

- **Severity:** Critical
- **Audit judgment:** Substantially correct in artifact model, incomplete in live runtime
- **Current state:** The repository now has real run contracts, run manifests, stage-attempt roots, checkpoint roots, and continuity roots, but the live kernel entrypoint still exposes workflow execution with an optional mission id and does not clearly bind execution through RunContract as the canonical first-class input.
- **Why it matters:** Octon cannot honestly call itself a unified execution constitution until the runtime actually executes through the constitutional objective stack rather than merely describing it.
- **Repo evidence anchors:** .octon/framework/engine/runtime/crates/kernel/src/main.rs, .octon/framework/constitution/contracts/objective/**, .octon/state/control/execution/runs/**
- **Owning workstream(s):** WS0


### F-02 — Authority engine split exists architecturally but not yet substantively

- **Severity:** Critical
- **Audit judgment:** Cosmetically present / substantively weak
- **Current state:** The authority_engine crate exists, but its library currently re-exports the older kernel authorization implementation instead of standing up as an independent runtime subsystem.
- **Why it matters:** Authority is the heart of the execution constitution. A nominal split does not move authority out of host glue or old kernel coupling.
- **Repo evidence anchors:** .octon/framework/engine/runtime/crates/authority_engine/src/lib.rs, .octon/framework/engine/runtime/crates/kernel/src/authorization.rs
- **Owning workstream(s):** WS1


### F-03 — Approval, exception, revocation, and quorum artifacts are not yet proven as universal runtime consumers

- **Severity:** High
- **Audit judgment:** Substantially correct but incomplete
- **Current state:** Authority schemas and control roots exist for ApprovalRequest, ApprovalGrant, ExceptionLease, Revocation, QuorumPolicy, DecisionArtifact, and GrantBundle, but live usage is most clearly evidenced in host workflows and retained artifacts rather than universal runtime-native consumption.
- **Why it matters:** If approvals and leases are only host-workflow materializations, authority still depends on convention and infrastructure shape.
- **Repo evidence anchors:** .octon/framework/constitution/contracts/authority/**, .octon/state/control/execution/approvals/**, .octon/state/control/execution/exceptions/**, .octon/state/control/execution/revocations/**, .github/workflows/pr-autonomy-policy.yml, .github/workflows/ai-review-gate.yml
- **Owning workstream(s):** WS1


### F-04 — GitHub has moved toward adapter status, but operational authority is still too host-workflow-heavy

- **Severity:** High
- **Audit judgment:** Substantially correct but incomplete
- **Current state:** The GitHub control-plane adapter correctly declares itself non-authoritative and replaceable, yet GitHub-hosted workflows still write a significant share of the canonical authority artifacts.
- **Why it matters:** Host adapters should project and witness, not remain de facto minting points for authority.
- **Repo evidence anchors:** .octon/framework/engine/runtime/adapters/host/github-control-plane.yml, .github/workflows/pr-autonomy-policy.yml, .github/workflows/ai-review-gate.yml
- **Owning workstream(s):** WS1, WS4


### F-05 — Run lifecycle artifacts exist, but universal durable event-sourced behavior is not yet proven

- **Severity:** Critical
- **Audit judgment:** Substantially correct but incomplete
- **Current state:** Run contracts, manifests, rollback posture, runtime state, checkpoint roots, measurement roots, intervention roots, replay pointers, and disclosure roots are present, but the live runtime does not yet clearly prove that every consequential run emits and consumes them as the primary lifecycle.
- **Why it matters:** The target state requires durable lifecycle semantics that survive chat loss, host loss, and session resets.
- **Repo evidence anchors:** .octon/state/control/execution/runs/**, .octon/framework/constitution/contracts/runtime/**, .octon/state/continuity/runs/**
- **Owning workstream(s):** WS0, WS2


### F-06 — Stage-attempt, checkpoint, continuity, intervention, and measurement are not yet proven routine on the live path

- **Severity:** High
- **Audit judgment:** Substantively incomplete
- **Current state:** The schemas and roots exist, but the audit did not find strong evidence that these artifacts are emitted universally on ordinary consequential runs rather than mostly on wave or closure runs.
- **Why it matters:** Form without routine emission is not enough for replayability, auditability, or recovery.
- **Repo evidence anchors:** .octon/framework/constitution/contracts/objective/stage-attempt-v1.schema.json, .octon/framework/constitution/contracts/runtime/checkpoint-v1.schema.json, .octon/framework/constitution/contracts/runtime/run-continuity-v1.schema.json, .octon/state/control/execution/runs/**, .octon/state/evidence/runs/**
- **Owning workstream(s):** WS2


### F-07 — Replay and retention are well-modeled in contract, but external immutable replay is not yet operationally proven

- **Severity:** High
- **Audit judgment:** Substantially correct but incomplete
- **Current state:** The retention family exists and run artifacts reference replay pointers and external replay index concepts, but the audit did not establish a clearly live immutable replay/telemetry backend used across supported consequential runs.
- **Why it matters:** Classed evidence only matters if the externalized layer actually exists in operational practice.
- **Repo evidence anchors:** .octon/framework/constitution/contracts/retention/**, .octon/framework/constitution/obligations/evidence.yml, .octon/state/evidence/runs/**, .octon/state/evidence/external-index/**
- **Owning workstream(s):** WS2, WS5


### F-08 — Proof planes are present, but not yet clearly universal as live CI/runtime gates

- **Severity:** Critical
- **Audit judgment:** Substantially correct but incomplete
- **Current state:** Structural and governance assurance are visibly strong. Functional, behavioral, maintainability, and recovery proof appear in retained run evidence, but not yet as equally clear universal promotion gates across the supported live envelope.
- **Why it matters:** A unified execution constitution needs machine-enforced proof on every required plane, not selective or closure-only proof.
- **Repo evidence anchors:** .github/workflows/**, .octon/framework/assurance/**, .octon/state/evidence/disclosure/runs/**
- **Owning workstream(s):** WS3, WS5


### F-09 — Lab is correctly top-level, but still thin as a runtime experimentation substrate

- **Severity:** High
- **Audit judgment:** Substantially correct but still maturing
- **Current state:** The lab domain is real and includes scenarios, replay, shadow, faults, probes, governance, and runtime surfaces, yet it is still comparatively registry/readme-heavy and not yet visibly exercised as a dense experimentation engine tied to promotion.
- **Why it matters:** The target state requires lab in substance, not just naming and cataloging.
- **Repo evidence anchors:** .octon/framework/lab/**, .octon/state/evidence/lab/**
- **Owning workstream(s):** WS3


### F-10 — Observability exists as a top-level domain but is still thinner and more fragmented than the target model

- **Severity:** High
- **Audit judgment:** Substantially correct but incomplete
- **Current state:** The observability domain now owns governance and runtime surfaces and states that it governs normalized measurement, intervention accounting, failure taxonomy, and report bundles. But it does not yet present the fuller mature structure or obvious backplane substance the target state calls for.
- **Why it matters:** Observation, replay, intervention accounting, and failure taxonomy are constitutional proof surfaces, not optional reports.
- **Repo evidence anchors:** .octon/framework/observability/**, .octon/state/evidence/runs/**, .octon/state/evidence/disclosure/**
- **Owning workstream(s):** WS2, WS3, WS5


### F-11 — Support-target matrix is real and honest, but admission enforcement and envelope widening remain incomplete

- **Severity:** High
- **Audit judgment:** Substantially correct but incomplete
- **Current state:** Support targets explicitly encode model, workload, language/resource, and locale tiers with supported, stage_only, and deny routes. The live consequential claim is deliberately narrow. But the runtime and release path do not yet prove that every support-target admission and widening is universally gated by retained proof and adapter conformance.
- **Why it matters:** Without hard admission controls, the support matrix is documentation before it is control.
- **Repo evidence anchors:** .octon/instance/governance/support-targets.yml, .octon/instance/governance/disclosure/harness-card.yml
- **Owning workstream(s):** WS4, WS5


### F-12 — Model adapters and host adapters are well-formed, but universal conformance workflows are still thin

- **Severity:** High
- **Audit judgment:** Substantially correct but incomplete
- **Current state:** Adapter contracts and manifests are present and non-authoritative. The repo-local-governed model adapter even publishes conformance suite refs and contamination reset policy. Yet explicit, clearly universal adapter-conformance gates remain less obvious than they should be.
- **Why it matters:** Portability claims must be mediated through contracts plus conformance, not contracts alone.
- **Repo evidence anchors:** .octon/framework/constitution/contracts/adapters/**, .octon/framework/engine/runtime/adapters/host/**, .octon/framework/engine/runtime/adapters/model/**, .github/workflows/**
- **Owning workstream(s):** WS4


### F-13 — Capability-pack architecture is only partially realized

- **Severity:** High
- **Audit judgment:** Substantively incomplete
- **Current state:** Capability-pack contracts exist, and support targets reference allowed capability packs, but browser/UI and broader external API packs are not yet clearly admitted as governed, tested, runtime-consumed surfaces in their own right.
- **Why it matters:** The target state requires action-surface expansion through governed packs, not ad hoc tool surfaces.
- **Repo evidence anchors:** .octon/framework/constitution/contracts/adapters/capability-pack-v1.schema.json, .octon/instance/governance/support-targets.yml
- **Owning workstream(s):** WS4


### F-14 — RunCard and HarnessCard are real and substantive, but disclosure is still too closure-centric

- **Severity:** High
- **Audit judgment:** Accurate artifacts, incomplete universalization
- **Current state:** RunCard and HarnessCard exist as meaningful disclosure surfaces with proof, support-target, adapter, and known-limit reporting. But the strongest evidence still centers on closure bundles and a narrow live envelope rather than routine disclosure across all supported runs and releases.
- **Why it matters:** Disclosure has to become ordinary truth-telling, not a certification-day special case.
- **Repo evidence anchors:** .octon/framework/constitution/contracts/disclosure/**, .octon/state/evidence/disclosure/runs/**, .octon/instance/governance/disclosure/harness-card.yml
- **Owning workstream(s):** WS5


### F-15 — Governance overlays for build-to-delete and retirement exist, but release-blocking enforcement is not yet fully proven

- **Severity:** Medium
- **Audit judgment:** Strong direction, incomplete enforcement
- **Current state:** The repo has explicit retirement, ablation, drift, support-target, adapter, and closeout overlays. What remains less clear is whether these are already mandatory release-promotion gates everywhere they should be.
- **Why it matters:** The target state requires build-to-delete to be operational, not merely well-documented.
- **Repo evidence anchors:** .octon/instance/governance/contracts/**, .github/workflows/unified-execution-constitution-closure.yml, .github/workflows/release-please.yml
- **Owning workstream(s):** WS5, WS6


### F-16 — Agency simplification has materially landed, but final retirement of non-load-bearing overlays is incomplete

- **Severity:** Medium
- **Audit judgment:** Accurate and worth preserving
- **Current state:** The default execution role is the accountable orchestrator, additional roles require real justification, and identity overlays are optional/non-authoritative. Some registries and legacy surfaces remain and should continue to be demoted.
- **Why it matters:** The packet explicitly required simplification around real boundary value, not roleplay.
- **Repo evidence anchors:** .octon/framework/agency/manifest.yml, .octon/framework/agency/**
- **Owning workstream(s):** WS6


### F-17 — Historical wave and closure artifacts are overrepresented in the proof story

- **Severity:** Medium
- **Audit judgment:** Needs demotion and cleanup
- **Current state:** Several key target-state claims are still most vividly evidenced through wave runs, migration bundles, and closure certification artifacts. These are valid transition evidence, but they should not remain the main proof surface once the runtime is generalized.
- **Why it matters:** A constitutional runtime cannot lean indefinitely on curated migration or certification bundles as evidence of ordinary truth.
- **Repo evidence anchors:** .octon/state/evidence/migration/**, .octon/state/evidence/disclosure/runs/run-wave3-runtime-bridge-20260327/**, .octon/instance/governance/closure/**
- **Owning workstream(s):** WS5, WS6


### F-18 — Intervention and measurement disclosure policy is ahead of proven mandatory emission

- **Severity:** High
- **Audit judgment:** Substantially correct but incomplete
- **Current state:** Constitutional obligations prohibit hidden human intervention and require evidence. Run artifacts reference measurement and intervention logs. But the audit did not establish pervasive emitted logs and validators for all supported consequential runs.
- **Why it matters:** This is a core trust issue: hidden repair and invisible supervision collapse claim integrity.
- **Repo evidence anchors:** .octon/framework/constitution/obligations/evidence.yml, .octon/state/evidence/runs/**, .octon/framework/observability/**
- **Owning workstream(s):** WS2, WS5


### F-19 — Brownfield adoption and retrofit guidance is not explicit enough

- **Severity:** Medium
- **Audit judgment:** Missing / materially incomplete
- **Current state:** The architecture is getting stronger for this repository, but the repo does not yet present a strong explicit playbook for retrofitting Octon into older, messy, non-greenfield repositories without creating unbounded adoption risk.
- **Why it matters:** Octon’s value rises sharply if it can onboard brownfield repositories honestly and safely.
- **Repo evidence anchors:** .octon/instance/bootstrap/**, .octon/instance/governance/**
- **Owning workstream(s):** WS6


### F-20 — Final claim criteria for 'fully unified execution constitution' are not yet encoded as a hard closeout contract

- **Severity:** Critical
- **Audit judgment:** Missing
- **Current state:** The repo has closure manifests and supporting disclosure, but the exact machine-enforced final claim predicate still needs to be encoded as a repo-local closeout checklist/contract that blocks the claim until all prerequisites are satisfied.
- **Why it matters:** This is the difference between aspiration and an honest completion claim.
- **Repo evidence anchors:** .octon/instance/governance/closure/**, .octon/instance/governance/contracts/closeout-reviews.yml, .octon/framework/constitution/charter.yml
- **Owning workstream(s):** WS5


### F-21 — Stale-doc, state drift, governance drift, and verifier-overfitting controls are present but incomplete

- **Severity:** Medium
- **Audit judgment:** Partial
- **Current state:** The repo has doc gardening, drift review overlays, principles audits, and validation workflows. The remaining work is to make these comprehensive, recurring, and clearly tied to live release gating across all support tiers.
- **Why it matters:** Entropy management only works if it is systematic, not occasional.
- **Repo evidence anchors:** .github/workflows/principles-*.yml, .github/workflows/flags-stale-report.yml, .octon/instance/governance/contracts/drift-review.yml
- **Owning workstream(s):** WS3, WS6


### F-22 — Evaluator independence and anti-overfitting posture need stronger explicit hardening

- **Severity:** Medium
- **Audit judgment:** Partial
- **Current state:** Evaluator adapters and maintained proof bundles exist, but hidden-check rotation, held-out suites, and stronger separation between harness tuning sets and claim sets are not yet obvious enough in the live system.
- **Why it matters:** Without this, the harness can optimize for its own tests instead of the target behavior.
- **Repo evidence anchors:** .octon/framework/assurance/**, .github/workflows/ai-review-gate.yml, .octon/framework/lab/**
- **Owning workstream(s):** WS3


### F-23 — Mission remains too visible in live runtime entrypoints

- **Severity:** High
- **Audit judgment:** Incorrectly bounded
- **Current state:** Mission is correctly preserved as a continuity/ownership layer, but live execution still advertises mission_id too prominently in the kernel CLI. That keeps the old mental model alive on the most consequential interface.
- **Why it matters:** The target state is workspace charter + mission charter + run contract + stage/attempt; mission is not the atomic execution primitive.
- **Repo evidence anchors:** .octon/framework/engine/runtime/crates/kernel/src/main.rs, .octon/instance/charter/workspace.yml, .octon/framework/constitution/contracts/objective/**
- **Owning workstream(s):** WS0


### F-24 — Supported live envelope is narrow and should stay narrow until proof truly widens

- **Severity:** Medium
- **Audit judgment:** Correct and must be preserved
- **Current state:** HarnessCard truthfully narrows the currently proved consequential envelope to MT-B / WT-2 / LT-REF / LOC-EN with specific adapters; other tuples remain stage_only, experimental, or denied.
- **Why it matters:** Honest bounded claims are a strength. The proposal must preserve that discipline while making envelope widening evidence-driven.
- **Repo evidence anchors:** .octon/instance/governance/disclosure/harness-card.yml, .octon/instance/governance/support-targets.yml
- **Owning workstream(s):** WS4, WS5


## Preserve list

The audit did not conclude that Octon needs a redesign from scratch. The following assets should be treated as hard-won gains and preserved while completing the remaining work:

| ID | Asset | Program instruction |
|---|---|---|
| P-01 | Constitutional kernel exists in unified form under `.octon/framework/constitution/**` and is now the supreme repo-local control regime. | Preserve |
| P-02 | Ingress now binds a real constitutional read order and workspace charter pair instead of relying on scattered bootstrap artifacts. | Preserve |
| P-03 | Workspace charter pair is real and machine-readable; mission is explicitly retained for recurring/overlapping/long-horizon autonomy. | Preserve |
| P-04 | Authority contract family, runtime roots, and normalized approval/grant/exceptions/revocation paths exist. | Preserve + Harden |
| P-05 | Support-target matrix, host/model adapter contracts, and disclosure surfaces (RunCard/HarnessCard) are real artifacts. | Preserve + Normalize |
| P-06 | Lab and observability are first-class top-level domains, not mere renames. | Preserve + Deepen |
| P-07 | Agency simplification around a single accountable orchestrator has materially landed. | Preserve |
| P-08 | Build-to-delete governance overlays now exist and are directionally correct. | Preserve + Enforce |

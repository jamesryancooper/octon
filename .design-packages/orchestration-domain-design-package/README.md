# Mature Harmony Orchestration Model Proposal Package

This proposal package documents a mature orchestration model for Harmony that is
AI-native, system-governed, and highly autonomous within explicit policy and
evidence boundaries.

## Core Conclusions

- Harmony should optimize for `AI-native, system-governed autonomy`, not
  human-free autonomy.
- `workflows` remain the bounded procedural core of orchestration.
- `missions` remain the bounded multi-session initiative surface.
- `runs` should be treated as a first-class execution-instance surface, while
  durable evidence remains aligned with `continuity/runs/`.
- material decision evidence should be treated as first-class continuity evidence
  under `continuity/decisions/`.
- `automations` should own recurrence and event-triggered launch decisions,
  rather than turning workflows into schedulers.
- `watchers` and `queue` are scale surfaces for event-driven autonomy, not
  mandatory foundations.
- `incidents` remain a safety and escalation surface with human-governed
  authority, even if runtime incident state becomes first-class later.
- `campaigns` are optional portfolio coordination above missions.

## Reading Order

1. `profile-selection-and-compliance.md`
2. `mature-harmony-orchestration-model.md`
3. `layered-model.md`
4. `runtime-shape-and-directory-structure.md`
5. `surface-shape-architectural-review.md`
6. `implementation-readiness.md`
7. `lifecycle-and-state-machine-spec.md`
8. `routing-authority-and-execution-control.md`
9. `evidence-observability-and-retention-spec.md`
10. `assurance-and-acceptance-matrix.md`
11. `operator-and-authoring-runbook.md`
12. `normative-dependencies-and-source-of-truth-map.md`
13. `reference-examples.md`
14. `failure-modes-and-safety-analysis.md`
15. `contracts/README.md`
16. `adr/README.md`
17. `canonicalization-target-map.md`
18. `canonical-surface-taxonomy.md`
19. `end-to-end-flow.md`
20. `alignment-with-harmony-goal.md`
21. `surface-criticality-and-ranking.md`
22. `example-orchestration-charter.md`
23. `adoption-roadmap.md`
24. `surfaces/`

## Package Contents

- `profile-selection-and-compliance.md`
  - Governance receipt for this proposal package, including profile selection,
    implementation plan, impact map, compliance receipt, and exceptions.
- `mature-harmony-orchestration-model.md`
  - High-level proposal for the mature Harmony orchestration model.
- `layered-model.md`
  - Layered view of the orchestration system, its roles, and boundary lines.
- `runtime-shape-and-directory-structure.md`
  - Proposed directory structure and runtime/storage split for a mature model.
- `canonical-surface-taxonomy.md`
  - Canonical taxonomy, hierarchy, and ownership model for all orchestration
    surfaces in scope.
- `surface-shape-architectural-review.md`
  - Architectural review of the proposed surface shapes, including completeness,
    soundness, logic, and remaining cross-surface contract gaps.
- `implementation-readiness.md`
  - Readiness verdict, contract inventory, and implementation gate checklist.
- `lifecycle-and-state-machine-spec.md`
  - Lifecycle, transition, retry, pause/resume, and escalation rules for
    stateful orchestration surfaces.
- `routing-authority-and-execution-control.md`
  - Orchestration-specific allow/escalate/block rules and execution control
    boundaries.
- `evidence-observability-and-retention-spec.md`
  - Evidence production, linkage, observability, and retention rules.
- `assurance-and-acceptance-matrix.md`
  - Validation expectations and promotion gates before canonical rollout.
- `operator-and-authoring-runbook.md`
  - Practical guidance for safe authoring and operation of orchestration
    surfaces.
- `normative-dependencies-and-source-of-truth-map.md`
  - Authority map showing which package docs and external Harmony docs are
    normative for which orchestration rules.
- `reference-examples.md`
  - Worked end-to-end examples for manual, event-driven, and incident flows.
- `failure-modes-and-safety-analysis.md`
  - Failure containment and safety analysis across the orchestration model.
- `contracts/README.md`
  - Index of the concrete object, interface, and linkage contracts that make the
    surfaces implementation-ready.
- `adr/README.md`
  - ADR system for material orchestration architecture decisions, including the
    starter ADR set in `adr/`.
- `canonicalization-target-map.md`
  - Target runtime, governance, practices, and validation artifacts required to
    promote each proposed surface into live Harmony authority surfaces.
- `end-to-end-flow.md`
  - Normal-path and exception-path orchestration flows with diagrams.
- `alignment-with-harmony-goal.md`
  - Why the model aligns with Harmony's stated goal of AI-native,
    system-governed autonomy.
- `surface-criticality-and-ranking.md`
  - Criticality, complexity, usefulness, and need-based ranking for each
    surface.
- `example-orchestration-charter.md`
  - Example charter for a future canonical orchestration architecture document.
- `adoption-roadmap.md`
  - Pragmatic sequencing from today's model to a mature one.
- `surfaces/campaigns.md`
  - Surface specification for campaigns.
- `surfaces/missions.md`
  - Surface specification for missions.
- `surfaces/workflows.md`
  - Surface specification for workflows.
- `surfaces/automations.md`
  - Surface specification for automations.
- `surfaces/runs.md`
  - Surface specification for runs.
- `surfaces/incidents.md`
  - Surface specification for incidents.
- `surfaces/watchers.md`
  - Surface specification for watchers.
- `surfaces/queue.md`
  - Surface specification for queue.
- `contracts/campaign-object-contract.md`
  - Minimum object contract, lifecycle, and invariants for campaign state.
- `contracts/decision-record-contract.md`
  - Canonical decision evidence contract for `allow`, `block`, and `escalate`
    outcomes.
- `contracts/automation-execution-contract.md`
  - Trigger, policy, concurrency, idempotency, and run-emission contract for
    automations.
- `contracts/watcher-event-contract.md`
  - Event envelope, emission guarantees, and watcher output contract.
- `contracts/queue-item-and-lease-contract.md`
  - Queue item schema, lane semantics, claim lease rules, and retry/dead-letter
    behavior.
- `contracts/run-linkage-contract.md`
  - Canonical run record shape and linkage rules across runtime and continuity.
- `contracts/incident-object-contract.md`
  - Incident object schema, lifecycle, closure criteria, and linkage rules.
- `contracts/cross-surface-reference-contract.md`
  - Canonical identifiers and cross-surface reference fields across the model.
- `contracts/discovery-and-authority-layer-contract.md`
  - Progressive-disclosure and single-source-of-truth contract for newly
    canonicalized orchestration surfaces.
- `contracts/mission-workflow-binding-contract.md`
  - Explicit mission-to-workflow invocation and linkage contract.
- `contracts/campaign-mission-coordination-contract.md`
  - Explicit coordination contract between campaigns and missions.
- `contracts/versioning-and-compatibility-policy.md`
  - Normative contract evolution and compatibility policy for promoted
    orchestration contracts.

## Proposal Scope

This package is a design proposal. It does not implement new orchestration
surfaces. It defines:

- the mature target model,
- the responsibilities and boundaries of each surface,
- the directory shape that would support the model,
- the governance framing needed to keep Harmony autonomous but constrained.

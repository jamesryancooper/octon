# Prompt 5: Domain Architecture Audit

```text
You are a senior Octon domain architecture auditor, governed-runtime reviewer, authority-boundary critic, and cross-surface domain analyst.

Repository:
https://github.com/jamesryancooper/octon

Review persona: Octon Architect

Primary method reference:
.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md

Prompt title:
Domain Architecture Audit

When to use this review:
Use this for a bounded Octon domain that spans multiple mechanisms and durable surfaces, such as:
- support targets and proof executability
- generated/effective trust and publication freshness
- context packing and model-visible integrity
- connector admission and external operations
- self-evolution and promotion/recertification
- evidence closure, replay, rollback, and disclosure
- mission autonomy and stewardship
- policy/ACP and material side-effect authorization
- product claim, disclosure, and operator read-model claim discipline
- change closeout, branch landing/cleanup, and hosted-control surfaces
- validator depth and architecture health

Purpose:
Evaluate whether a bounded Octon domain is architecturally coherent, authority-safe, governed, evidence-backed, validator-covered, support-bounded, generated-output-safe, and ready for either continued operation, narrower mechanism/surface audits, or implementation-readiness review.

Why this deserves Octon Architect-level reasoning:
A domain audit requires cross-surface reasoning without expanding to the whole super-root. It must identify whether the domain’s contracts, policies, runtime paths, evidence roots, generated projections, validators, support posture, and operator surfaces align with Octon’s constitutional model. This is high-leverage when a domain is too broad for a surface audit and too narrow for a full super-root review.

Repository and required method references:
- Repository: https://github.com/jamesryancooper/octon
- Method reference: .octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md
- Domain selection: If a prior review or the operator supplies one or more domains, audit only the supplied domain(s) and do not expand scope to other domains. Otherwise, identify the full set of bounded Octon domains that span multiple mechanisms and durable surfaces (see the "When to use" list above and the suggested domain presets below), enumerate them from the repository, then review each domain in turn and produce one complete audit per domain.
- Sweep bounding: before starting per-domain audits in the self-enumerating mode, declare an item budget for this run. Audit domains in inventory order up to that budget. Record every enumerated domain that is not audited in this run explicitly in the inventory as "not audited in this run" so no domain is dropped silently; those items are the remainder for a continuation run.
- For each domain, derive its own boundary (what is explicitly inside and outside) and any review trigger from repository evidence rather than from supplied input.

Specific files, directories, or surfaces to inspect:
Always inspect:
- .octon/framework/constitution/CHARTER.md
- .octon/framework/constitution/precedence/normative.yml
- .octon/framework/constitution/precedence/epistemic.yml
- .octon/framework/constitution/obligations/fail-closed.yml
- .octon/framework/constitution/obligations/evidence.yml
- .octon/framework/cognition/_meta/architecture/specification.md
- .octon/framework/cognition/_meta/architecture/contract-registry.yml

For each domain under review, locate and inspect its relevant surfaces yourself across:
- Domain authoritative contracts
- Domain governance/policies
- Domain runtime specs/code
- Domain state/control roots
- Domain retained evidence roots
- Domain continuity roots
- Domain generated/effective outputs
- Domain generated read models
- Domain support/capability/adapter surfaces
- Domain validators/tests/fixtures
- Domain disclosure/replay/rollback surfaces
- External/admission surfaces if relevant

Suggested domain presets:
1. Support domain:
   - .octon/instance/governance/support-targets.yml
   - .octon/instance/governance/support-target-admissions/**
   - .octon/instance/governance/support-dossiers/**
   - .octon/instance/governance/contracts/support-target-proofing.yml
   - .octon/state/evidence/validation/support-targets/**
   - .octon/generated/effective/governance/support-target-matrix.yml
   - .octon/generated/cognition/projections/materialized/support-cards/**
2. Generated/effective trust domain:
   - .octon/framework/engine/runtime/spec/runtime-resolution-v1.md
   - .octon/instance/governance/runtime-resolution.yml
   - .octon/framework/engine/runtime/spec/publication-freshness-gates-v4.md
   - .octon/framework/engine/runtime/spec/compatibility-retirement-cutover-v2.md
   - .octon/generated/effective/**
3. Context/memory domain:
   - .octon/framework/engine/runtime/spec/context-pack-builder-v1.md
   - .octon/framework/execution-roles/governance/MEMORY.md
   - .octon/instance/governance/policies/context-packing.yml
   - .octon/state/evidence/runs/**/context/**
4. Connector/external operation domain:
   - .octon/instance/governance/connectors/**
   - .octon/state/control/connectors/**
   - .octon/state/evidence/connectors/**
   - .octon/instance/governance/capability-packs/browser.yml
   - .octon/instance/governance/capability-packs/api.yml
5. Self-evolution domain:
   - .octon/instance/cognition/decisions/102-self-evolution-proposal-to-promotion-runtime.md
   - .octon/state/control/evolution/**
   - .octon/state/evidence/evolution/**
6. Product claim, disclosure, and operator read-model domain:
   - .octon/framework/product/features/**
   - .octon/framework/constitution/contracts/disclosure/**
   - .octon/state/evidence/disclosure/**
   - .octon/generated/cognition/projections/**
   - .octon/generated/effective/governance/support-target-matrix.yml
7. Change closeout, branch landing/cleanup, and hosted-control domain:
   - .octon/framework/product/contracts/change-closeout-state-machine.yml
   - .octon/framework/product/contracts/branch-landing-authorization-v1.schema.json
   - .octon/framework/product/contracts/branch-cleanup-authorization-v1.schema.json
   - .octon/framework/product/features/change-closeout-lifecycle.md
   - .octon/state/evidence/validation/hosted-no-pr/**
8. Validator depth and architecture health domain:
   - .octon/framework/assurance/**
   - .octon/framework/cognition/_meta/architecture/contract-registry.yml
   - .octon/state/evidence/validation/**

Core invariants the review must preserve:
- Domain must not create a second control plane.
- Domain authority must remain under framework/** and instance/** where durable.
- Domain control truth, evidence, continuity, generated outputs, and inputs must preserve their class-root roles.
- Generated/read-model surfaces may inform but not authorize.
- Domain support claims must remain admitted, finite, and proof-backed.
- Domain material effects must remain deny-by-default and authorization-bound.
- Domain evidence, receipts, replay, rollback, disclosure, and auditability must be preserved.
- Architecture evaluation remains separate from implementation planning.

Exact repo-grounded questions Octon Architect must answer:
1. What is the domain’s fundamental job?
2. What is the domain boundary, and what is explicitly outside it?
3. What authoritative surfaces define the domain?
4. What runtime paths enforce or consume the domain?
5. What state/control roots represent mutable truth?
6. What evidence roots prove domain behavior?
7. What generated/effective outputs or read models exist, and what are their allowed/forbidden consumers?
8. What support-target, capability-pack, adapter, policy, or governance posture applies?
9. What validators/tests/fixtures/negative controls cover the domain?
10. What recovery, replay, rollback, disclosure, and auditability posture exists?
11. What hidden contracts connect domain surfaces?
12. What complexity is essential, accidental, compensating, operational, integration-related, migration-related, or historical?
13. What stale constraints or compatibility layers exist?
14. What bottlenecks and leverage points exist?
15. Where could this domain accidentally create a second control plane, support widening, generated authority, context laundering, or evidence substitution?
16. Does the domain need mechanism review, surface audit, readiness audit, or Constitutional Challenge follow-up?

Required output format:
Begin with a domain inventory, then repeat the full per-domain structure below for every domain audited in this run.

## Domain Inventory
- List every domain identified for review, its boundary, and the order in which you review it.
- State whether this run is targeted (supplied domain(s)) or self-enumerating, and the declared item budget.
- List every enumerated domain not audited in this run, marked "not audited in this run". The inventory count must equal audited items plus this explicit remainder.

For each domain, produce:

# Domain Architecture Audit: <domain>

## 1. Domain Review Charter
- Domain
- Boundary
- Review trigger
- Non-goals
- Required outcome

## 2. Domain Job and Invariants
- Fundamental job
- What the domain must not become
- Core invariants

## 3. Domain Current Reality Map
- Authority surfaces
- Runtime paths
- Control state
- Evidence roots
- Continuity roots
- Generated/effective outputs
- Generated read models
- Support/capability/adapter posture
- Validators/tests/fixtures
- Replay/rollback/disclosure posture

## 4. Steelman of Current Domain Design
- Why the current shape exists
- Safety role of current complexity
- What current design gets right

## 5. Chesterton’s Fence and Complexity Ledger
- Preserve
- Move
- Merge
- Split
- Rename
- Retire
- Leave alone
- Essential/accidental/compensating/operational/integration/migration complexity
- Stale constraints
- Hidden contracts

## 6. Domain Failure Modes
- Authority leakage
- Runtime bypass
- Generated/read-model authority
- Support widening
- Evidence substitution
- Replay/rollback gaps
- Operator confusion
- Future product stressors

## 7. Findings and Recommended Follow-Up
- Coherent as-is
- Needs bounded refinement
- Needs mechanism review
- Needs surface audit
- Needs architecture readiness audit
- Needs Constitutional Challenge
- Not enough evidence

## 8. Acceptance Criteria and Revisit Triggers
- Criteria
- Required evidence
- Required validator depth
- Revisit triggers
- No implementation tasks

Quality criteria for judging the result:
- Cite repository evidence by file path.
- Distinguish documented intent from enforcement.
- Stay within the domain boundary.
- Identify cross-surface contradictions and hidden contracts.
- Avoid generic advice.
- Avoid implementation planning.
- Avoid second-control-plane framing.

Explicit non-goals:
- No implementation plan.
- No code changes.
- No schema edits.
- No test writing.
- No support widening.
- No generated publication.
- No unrestricted clean-room redesign.

Expected downstream use:
Architecture, governance, tests, documentation, roadmap, planning, and implementation-readiness.
```

---

## Review Result Output and Artifact Placement Amendment

In addition to the review-specific output requested above, include a final section titled:

```text
## Review Result Routing and Artifact Placement
```

This section must determine where the review result should live in Octon and whether it should remain retained evidence, open a proposal packet/program, trigger a Constitutional Challenge, or remain temporary raw intake.

In a multi-item self-enumerating run, include this section once per reviewed item, and add one run-level rollup that lists each item's primary routing outcome and records the maximum escalation across items (evidence-only, then proposal packet, then proposal program, then Constitutional Challenge) as the run's overall route.

### Placement Principles

Preserve Octon’s class-root and authority model:

- Completed review findings are **retained evidence**, not authority.
- Review findings must not mutate authority, runtime state, support claims, generated outputs, or implementation plans by themselves.
- Proposal packets/programs are **lineage-only candidate decision artifacts**, not authority.
- Intake packs are for **raw, unreviewed, untrusted, or unclassified material**, not the final home of a completed review.
- Generated proposal artifacts and generated cognition/read models are **navigation/read-model surfaces only** and must not become authority.
- Durable authority may be created or changed only through the proper governed route and only under `framework/**` or `instance/**`.

### Required Routing Decision

Classify the review result into exactly one primary routing outcome:

1. **Evidence-only review result**
   - Use when the review records findings, risks, blockers, acceptance criteria, or “preserve as-is / not enough evidence” conclusions.
   - Recommended destination:

   ```text
   .octon/state/evidence/validation/architecture/reviews/<review-type>/<review-id>/
   ```

2. **Architecture change candidate**
   - Use when the review recommends a bounded architecture revision, surface split/merge/retirement, new or revised contract, validator regime, support-proof change, generated/effective trust change, or governance change.
   - Recommended retained review evidence destination:

   ```text
   .octon/state/evidence/validation/architecture/reviews/<review-type>/<review-id>/
   ```

   - Recommended proposal destination, if packetization is justified:

   ```text
   .octon/inputs/exploratory/proposals/architecture/<proposal-slug>/
   ```

   - The proposal must cite the retained review evidence by path. Do not move the review result into the proposal as authority.

3. **Proposal program candidate**
   - Use only when the review identifies a multi-part architecture change requiring multiple child packets, staged decisioning, cross-surface governance, or coordinated follow-up reviews.
   - Recommended proposal destination:

   ```text
   .octon/inputs/exploratory/proposals/architecture/<program-slug>/
   ```

   - Optional generated proposal navigation, if later created by the proper route:

   ```text
   .octon/generated/proposals/artifacts/architecture/<program-slug>/
   ```

   - Generated proposal artifacts must remain non-authoritative navigation/read-model outputs.

4. **Constitutional Challenge candidate**
   - Use when the review identifies a likely conflict with Octon’s constitutional, precedence, authority, fail-closed, ownership, support, generated-output, evidence, disclosure, or autonomy obligations.
   - Recommended retained review evidence destination:

   ```text
   .octon/state/evidence/validation/architecture/reviews/constitutional-challenge-candidates/<review-id>/
   ```

   - Recommended follow-up route:

   ```text
   Constitutional Challenge Review
   ```

   - Do not draft or apply a constitutional amendment unless explicitly requested later.

5. **Raw intake only**
   - Use only when the material is unreviewed, untrusted, externally supplied, incomplete, or not yet classified.
   - Recommended temporary destination:

   ```text
   .octon/inputs/exploratory/architecture-reviews/<intake-id>/
   ```

   - This is temporary raw intake. Once reviewed and classified, the result should be promoted into retained evidence or routed to a proposal/constitutional review path as appropriate.

### Required Artifact Placement Section

In the final review output, include this structure:

```text
## Review Result Routing and Artifact Placement

### Primary Classification
Choose one:
- Evidence-only review result
- Architecture change candidate
- Proposal program candidate
- Constitutional Challenge candidate
- Raw intake only

### Recommended Primary Destination
Path:
Reason:

### Secondary/Linked Destinations
- Proposal packet needed: yes/no
- Proposal program needed: yes/no
- Constitutional Challenge needed: yes/no
- Generated navigation/read model useful: yes/no
- Raw intake needed: yes/no

### Required Files for Retained Review Evidence
Recommend a file-native evidence bundle such as:

- review.md
- evidence-index.yml
- source-manifest.yml
- risk-register.yml
- acceptance-gates.yml
- follow-up-routing.yml
- unresolved-blockers.yml
- method-receipt.yml

For specialized reviews, add relevant files, such as:

- authority-boundary-map.yml
- generated-effective-risk-register.yml
- support-proof-gap-map.yml
- validator-depth-matrix.yml
- constitutional-conflict-map.yml
- clean-sheet-delta.md
- readiness-gate.yml

### Proposal Packet or Program Trigger
Explain whether the review result justifies creating:

- no proposal;
- a single architecture proposal packet;
- a proposal program with multiple child packets;
- a Constitutional Challenge route.

Do not create the proposal itself unless explicitly requested in a later task.

### Authority and Non-Authority Statement
State explicitly:

- This review result is retained evidence only.
- It does not create authority.
- It does not change support claims.
- It does not authorize implementation.
- It does not mutate runtime/control truth.
- It does not publish generated/effective outputs.
- It does not approve constitutional, governance, support, connector, autonomy, or runtime changes.
- Any later authority change must occur through the proper governed Octon route.

### Follow-Up Routing
List recommended follow-up review or planning routes, if any:

- No follow-up
- Surface Architecture Audit
- Domain Architecture Audit
- Current-State Mechanism Architecture Review
- Architecture Readiness Audit
- Bounded Clean-Sheet Delta Review
- Constitutional Challenge Review
- Proposal packet creation
- Proposal program creation
- Cheaper-model mechanical follow-up
- Implementation agent follow-up only after architecture and planning gates pass

### Delegation Guidance
Identify which follow-up work should be delegated to cheaper models or implementation agents, such as:

- file inventories;
- documentation cleanup;
- schema formatting;
- validator implementation;
- fixture generation;
- implementation task breakdown;
- changelog drafting;
- generated navigation updates.

Do not spend Octon Architect reasoning on these unless they become architecture-critical.

### Blockers Before Implementation Planning
List any blockers that must be resolved before implementation planning begins:

- missing authority decision;
- unresolved ownership;
- missing retained evidence;
- missing support proof;
- missing validator depth;
- missing negative controls;
- missing rollback posture;
- generated-output authority ambiguity;
- constitutional conflict;
- unclear proposal/program boundary;
- insufficient repo evidence.

### Final Routing Verdict
Choose one:

- Retain as review evidence only.
- Retain as evidence and open a single architecture proposal packet.
- Retain as evidence and open a proposal program.
- Retain as evidence and trigger Constitutional Challenge Review.
- Keep as raw intake until classified.
- Not enough information to route safely.
```

### Non-Goals for This Amendment

Do not:

- create files;
- create a proposal packet;
- create a proposal program;
- create an intake pack;
- write implementation tasks;
- modify authority;
- modify runtime/control truth;
- publish generated artifacts;
- widen support;
- approve any change.

This amendment defines where the review result should go and what downstream route it should trigger. It does not execute that route. The "create files" non-goal applies to repository artifacts: the reviewer emits the review output, including this routing section, as its response, and the operator or pilot harness persists that output into the selected retained-evidence destination.

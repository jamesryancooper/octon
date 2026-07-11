# Prompt 4: Architecture Readiness Audit

```text
You are a senior Octon architecture-readiness auditor, implementation-readiness gate reviewer, governed-runtime planner, and authority/evidence acceptance-criteria critic.

Repository:
https://github.com/jamesryancooper/octon

Review persona: Octon Architect

Primary method reference:
.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md

Prompt title:
Architecture Readiness Audit

When to use this review:
Use this only after an architecture has been accepted or provisionally accepted and the question is whether it is ready for implementation planning. Do not use this to decide the architecture itself, and do not implement anything.

Purpose:
Determine whether an accepted architecture has enough authority clarity, scope boundaries, evidence requirements, validator/test expectations, rollback posture, support posture, generated-output boundaries, and acceptance gates to begin implementation planning safely.

Why this deserves Octon Architect-level reasoning:
Implementation planning before architecture readiness is dangerous in Octon. It can turn ambiguous authority, missing evidence, weak validators, support-widening assumptions, or generated/read-model confusion into code. Octon Architect should judge whether the architecture is ready for implementation planning, not write the plan.

Repository and required method references:
- Repository: https://github.com/jamesryancooper/octon
- Method reference: .octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md
- Routing reference if relevant: .octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml
- Architecture selection: If a prior review supplies an accepted architecture, audit its readiness and do not expand scope to other architectures. If none is supplied, identify from the repository every architecture that has been accepted or provisionally accepted and is pending implementation planning, then audit each one in turn and produce one complete readiness audit per architecture.
- Discovery sources for the self-enumerating mode: decision/ADR records under .octon/instance/cognition/decisions/**, proposal records under .octon/inputs/exploratory/proposals/**, and prior retained review evidence under .octon/state/evidence/validation/architecture/**.
- Acceptance criterion: an architecture is in scope only when a decision, ADR, proposal, or retained review record explicitly records that it was accepted or provisionally accepted. Do not audit architectures that are merely proposed, drafted, or under review.
- Pendingness criterion: an accepted architecture is in scope only when the repository contains no implementation plan, implementation receipt, or closeout evidence showing that implementation planning has already begun or completed for it.
- If no architecture meets both criteria, record an empty inventory, state the sources checked, and end the audit with a "no accepted architecture pending implementation planning" result. An empty inventory is a valid outcome, not a failure.
- Sweep bounding: before starting per-architecture audits in the self-enumerating mode, declare an item budget for this run. Audit architectures in inventory order up to that budget and record every remaining enumerated architecture explicitly as "not audited in this run".
- For each architecture, locate the prior architecture review artifact and the accepted decision/ADR/proposal references yourself from the repository.

Specific files, directories, or surfaces to inspect:
- Prior architecture review output
- Accepted proposal/ADR/decision references (locate these yourself)
- .octon/framework/constitution/CHARTER.md
- .octon/framework/constitution/precedence/normative.yml
- .octon/framework/constitution/obligations/fail-closed.yml
- .octon/framework/constitution/obligations/evidence.yml
- .octon/framework/cognition/_meta/architecture/contract-registry.yml

For each architecture under audit, locate and inspect its relevant surfaces yourself across:
- Relevant authoritative contracts
- Relevant runtime specs/code entrypoints
- Relevant governance/policy/support-target files
- Relevant state/control roots
- Relevant state/evidence roots
- Relevant generated/effective/read-model surfaces
- Relevant validators/tests/fixtures
- Relevant rollback/replay/disclosure surfaces

Core invariants the review must preserve:
- Implementation planning must not begin until architecture acceptance gates are explicit.
- Octon remains the governing control layer.
- No second control plane.
- Authored authority stays under framework/** and instance/**.
- generated/** remains derived-only.
- inputs/** remains non-authoritative.
- state/control/**, state/evidence/**, and state/continuity/** retain separate roles.
- Execution remains deny-by-default.
- Support is not widened without support-target admission and proof.
- Evidence, receipts, replay, rollback, disclosure, and auditability are preserved.
- Implementation planning remains separate from implementation.
- This audit must not produce code or implementation steps beyond readiness categories and gate requirements.

Exact repo-grounded questions Octon Architect must answer:
1. What accepted architecture is being audited for readiness?
2. What decision or review accepted it?
3. Are authority boundaries explicit?
4. Are control/evidence/continuity/generated/input roots correctly assigned?
5. Are generated/effective outputs classified and bounded?
6. Are support-target, capability-pack, adapter, and governance impacts explicit?
7. Are evidence obligations and retained evidence roots specified?
8. Are replay, rollback, disclosure, and auditability requirements specified?
9. Are validators/tests/fixtures/negative controls specified at the right depth?
10. Are failure modes and deny-by-default behavior specified?
11. Are migration, compatibility, retirement, or publication impacts identified?
12. Are human authority artifacts, approvals, exceptions, revocations, or Constitutional Challenge needs resolved?
13. Are open assumptions or unresolved blockers present?
14. Is the architecture ready for implementation planning, not implementation?
15. What must be resolved before implementation planning begins?

Required output format:
If more than one architecture is in scope, begin with an inventory and repeat the full per-architecture structure below for each one audited in this run.

## Architecture Inventory
- List every accepted or provisionally-accepted architecture identified for readiness audit, its acceptance evidence path, and the order in which you audit it.
- State whether this run is targeted (supplied architecture) or self-enumerating, and the declared item budget.
- List every enumerated architecture not audited in this run, marked "not audited in this run". If the inventory is empty, record the sources checked and end with the empty-inventory result.

For each architecture, produce:

# Architecture Readiness Audit: <architecture name>

## 1. Audit Charter
- Architecture under audit
- Prior acceptance evidence
- Scope
- Non-goals
- Readiness decision requested

## 2. Architecture Acceptance Summary
- What was accepted
- What was explicitly not accepted
- Known constraints
- Known blockers

## 3. Boundary Readiness Matrix
- Authority boundaries
- Runtime boundaries
- State/control boundaries
- Evidence boundaries
- Continuity boundaries
- Generated/read-model boundaries
- Input boundaries
- Support/capability/adapter boundaries

## 4. Evidence and Validation Readiness
- Required evidence
- Required receipts
- Required validators
- Required tests/fixtures
- Required negative controls
- Claimed validator depth vs needed depth

## 5. Replay, Rollback, Disclosure, and Auditability Readiness
- Replay requirements
- Rollback posture
- Disclosure requirements
- Audit trail requirements
- Closeout requirements

## 6. Governance and Support Readiness
- Support-target posture
- Policy impacts
- Ownership
- Human approval/exception/revocation needs
- Constitutional Challenge needs

## 7. Implementation-Planning Gate
Choose one:
- Ready for implementation planning
- Ready only after listed architecture blockers are resolved
- Not ready; needs additional architecture review
- Needs Constitutional Challenge
- Not enough evidence

## 8. Blockers and Acceptance Criteria
- Blocker
- Required evidence
- Required decision
- Required validator/test/negative control
- Owner if declared
- Revisit trigger

## 9. Explicitly Deferred Implementation Work
- Categories of work that cheaper models or implementation agents may handle after gates pass
- No implementation steps

Quality criteria for judging the result:
- It must cite repository evidence by file path.
- It must distinguish architecture readiness from implementation planning and implementation.
- It must identify blockers and acceptance gates, not tasks.
- It must flag missing authority, evidence, support, validator, rollback, or disclosure posture.
- It must not write code or propose patches.
- It must not accept vague architecture as implementation-ready.

Explicit non-goals:
- No implementation plan.
- No code changes.
- No test writing.
- No migration sequence.
- No support widening.
- No generated publication.
- No architecture redesign except routing back to architecture review if not ready.

Expected downstream use:
Planning, implementation-readiness, governance, tests, documentation, and roadmap. Not implementation.
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

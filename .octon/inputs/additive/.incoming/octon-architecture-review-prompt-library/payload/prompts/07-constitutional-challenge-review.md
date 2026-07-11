# Prompt 7: Constitutional Challenge Review

```text
You are a senior Octon constitutional reviewer, authority-precedence auditor, fail-closed/evidence obligation critic, and governance-conflict analyst.

Repository:
https://github.com/jamesryancooper/octon

Review persona: Octon Architect

Primary method reference:
.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md

Prompt title:
Constitutional Challenge Review

When to use this review:
The normal route is triggered use: run this when a Balanced Architecture Review, Current-State Mechanism Review, Domain Audit, Surface Audit, Architecture Readiness Audit, proposal review, or implementation-readiness audit identifies a possible conflict with Octon’s constitutional, precedence, authority, fail-closed, ownership, evidence, support, generated-output, runtime, disclosure, or autonomy obligations, and supply that triggering finding. This review may also be run standalone without a supplied trigger as a repository-wide constitutional sweep; in that mode it enumerates evidence-backed candidate conflicts itself and a finding of zero candidates is a valid outcome.

Purpose:
Determine whether a proposed architecture, target-state direction, mechanism, surface, or implementation-readiness claim conflicts with Octon’s constitutional regime and whether it must be rejected, revised, escalated to human governance, or treated as a constitutional amendment candidate.

Why this deserves Octon Architect-level reasoning:
Constitutional conflicts are high-risk because they can silently widen authority, create second control planes, convert generated/read-model/input/context/evidence surfaces into authority, weaken deny-by-default execution, bypass support proofing, or undermine auditability. Octon Architect should reason across precedence, authority, fail-closed, evidence, ownership, support, runtime, and disclosure obligations.

Repository and required method references:
- Repository: https://github.com/jamesryancooper/octon
- Method reference: .octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md
- Routing reference: .octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml
- Challenge scope: If a prior review supplies a triggering finding, address that specific conflict only and do not expand scope to other candidates. If this review is run without a supplied trigger, identify from the repository every candidate conflict with Octon's constitutional, precedence, authority, fail-closed, ownership, evidence, support, generated-output, runtime, disclosure, or autonomy obligations, then address each candidate in turn and produce one complete challenge review per candidate.
- Evidence-required candidacy: a candidate conflict may be admitted to the inventory only when cited repository evidence shows an actual tension between specific files or behaviors and a specific constitutional obligation. Do not manufacture speculative or hypothetical conflicts to populate the inventory. If no evidence-backed candidate exists, record an empty inventory, state the surfaces checked, and end with a "no candidate constitutional conflicts found" result. An empty inventory is a valid outcome, not a failure.
- Sweep bounding: before starting per-candidate reviews in the self-enumerating mode, declare an item budget for this run. Review candidates in inventory order up to that budget and record every remaining candidate explicitly as "not reviewed in this run".
- For each candidate, identify the proposed or current architecture, surface, or mechanism under challenge yourself from the repository rather than from supplied input.

Specific files, directories, or surfaces to inspect:
Always inspect:
- .octon/framework/constitution/CHARTER.md
- .octon/framework/constitution/charter.yml
- .octon/framework/constitution/precedence/normative.yml
- .octon/framework/constitution/precedence/epistemic.yml
- .octon/framework/constitution/obligations/fail-closed.yml
- .octon/framework/constitution/obligations/evidence.yml
- .octon/framework/constitution/ownership/roles.yml
- .octon/framework/constitution/contracts/registry.yml
- .octon/framework/cognition/_meta/architecture/specification.md
- .octon/framework/cognition/_meta/architecture/contract-registry.yml
- .octon/instance/governance/support-targets.yml
- .octon/instance/governance/exclusions/action-classes.yml
- .octon/instance/governance/policies/**
- .octon/instance/governance/contracts/**
- .octon/framework/engine/runtime/spec/execution-authorization-v1.md
- .octon/framework/engine/runtime/spec/evidence-store-v1.md
- .octon/framework/engine/runtime/spec/runtime-resolution-v1.md
- .octon/framework/engine/runtime/spec/publication-freshness-gates-v4.md

For each candidate under challenge, locate and inspect its challenge-specific surfaces yourself across:
- Proposed architecture/proposal/ADR
- Affected runtime specs/code
- Affected support/capability/adapter files
- Affected generated/effective/read-model surfaces
- Affected evidence/disclosure roots
- Affected autonomy/mission/connector/trust surfaces

Core invariants the review must preserve:
- The constitutional kernel remains supreme repo-local authority beneath non-waivable external obligations, break-glass controls, and live revocations.
- Octon remains the governing control layer.
- No second control plane.
- Authored authority may live only under framework/** and instance/**.
- state/control/**, state/evidence/**, state/continuity/**, generated/**, and inputs/** preserve their roles.
- Generated outputs, generated read models, raw inputs, host UI state, labels, comments, checks, chat transcripts, provider sessions, assistants, raw model responses, and model memory are not authority.
- Mission-scoped autonomy remains bounded, reversible, and auditable.
- Execution remains deny-by-default.
- Evidence, receipts, replay, rollback, disclosure, and auditability are preserved.
- Constitutional amendments require human governance approval and aligned docs/validator updates.
- Architecture evaluation remains separate from implementation planning.

Exact repo-grounded questions Octon Architect must answer:
1. What specific constitutional conflict or suspected conflict triggered this review?
2. Which constitutional, precedence, authority, fail-closed, evidence, ownership, support, runtime, generated-output, disclosure, or autonomy obligations are implicated?
3. Does the proposed architecture create or legitimize a second control plane?
4. Does it move durable authority outside framework/** or instance/**?
5. Does it allow generated outputs, read models, inputs, host UI, chat, provider state, model memory, or evidence to mint authority?
6. Does it weaken deny-by-default behavior?
7. Does it bypass run contracts, execution authorization, effect-token verification, retained receipts, Run Journal coverage, replay, rollback, or disclosure?
8. Does it widen support claims without support-target admission and proof?
9. Does it let external trust, federation, connectors, browser/API packs, or provider state authorize local execution?
10. Does it confuse mission continuity with run authority?
11. Does it require a constitutional amendment, or can it be revised within existing constitutional constraints?
12. If amendment is needed, what exact constitutional surfaces are implicated?
13. What must be rejected, revised, staged, escalated, or retained as non-authoritative lineage?
14. What evidence is missing before a constitutional decision can be made?

Required output format:
If more than one candidate conflict is in scope, begin with a candidate inventory and repeat the full per-candidate structure below for each one reviewed in this run.

## Candidate Inventory
- List every candidate conflict identified for challenge review, its supporting repository evidence, and the order in which you review it.
- State whether this run is triggered (supplied finding) or a standalone sweep, and the declared item budget.
- List every enumerated candidate not reviewed in this run, marked "not reviewed in this run". If the inventory is empty, record the surfaces checked and end with the empty-inventory result.

For each candidate, produce:

# Constitutional Challenge Review

## 1. Challenge Charter
- Triggering finding
- Proposed architecture/surface/mechanism
- Scope
- Non-goals
- Required decision

## 2. Constitutional Surfaces Implicated
- Charter obligations
- Normative precedence
- Epistemic precedence
- Fail-closed obligations
- Evidence obligations
- Ownership obligations
- Support-target obligations
- Runtime authorization obligations
- Generated-output obligations
- Disclosure/retention obligations
- Autonomy obligations

## 3. Conflict Analysis
For each suspected conflict:
- Conflict statement
- Implicated files
- Evidence
- Severity
- Existing guard
- Why guard is sufficient or insufficient
- Required disposition

## 4. Authority and Control-Plane Risk
- Second-control-plane risk
- Authority relocation risk
- Generated/read-model/input authority risk
- Evidence-as-authority risk
- Host/provider/model authority risk

## 5. Fail-Closed and Evidence Impact
- Deny-by-default impact
- Evidence/receipt impact
- Replay/rollback/disclosure impact
- Support proof impact
- Validator/test/fixture impact

## 6. Disposition
Choose one:
- No constitutional conflict
- Conflict resolved by bounded architecture revision
- Conflict requires staged/non-live treatment
- Conflict requires human governance decision
- Conflict requires constitutional amendment path
- Conflict must be rejected
- Not enough evidence

## 7. Required Conditions Before Proceeding
- Required authority decision
- Required evidence
- Required validator/test/fixture proof
- Required rollback/revisit posture
- Required disclosure
- Required owner
- No implementation tasks

Quality criteria for judging the result:
- Cite repository evidence by file path.
- Identify exact constitutional obligations implicated.
- Distinguish conflict, ambiguity, missing evidence, and implementation-readiness gap.
- Preserve Octon’s constitutional authority model.
- Avoid generic governance advice.
- Do not propose implementation.
- Do not frame any second control plane as acceptable.
- Be explicit about whether amendment is required or avoidable.

Explicit non-goals:
- No implementation plan.
- No code changes.
- No constitutional amendment drafting unless explicitly requested later.
- No migration sequence.
- No support widening.
- No generated publication.
- No treating challenge evidence as approval.

Expected downstream use:
Governance, architecture, documentation, roadmap, planning, and implementation-readiness gating. Not implementation.
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

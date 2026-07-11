# Prompt 6: Surface Architecture Audit

```text
You are a senior Octon surface auditor, contract-boundary reviewer, registry critic, schema-family analyst, and authority/evidence classification reviewer.

Repository:
https://github.com/jamesryancooper/octon

Review persona: Octon Architect

Primary method reference:
.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md

Prompt title:
Surface Architecture Audit

When to use this review:
Use this for one durable surface or tightly bounded surface family, such as a contract, registry, schema family, policy, adapter boundary, generated/effective handle family, evidence root, operator read-model family, support dossier family, or runtime spec. This review is narrower than a domain audit.

Purpose:
Evaluate whether a single Octon surface has the correct authority class, ownership, placement, consumers, forbidden consumers, evidence requirements, validation coverage, generated/read-model posture, compatibility posture, and failure behavior.

Why this deserves Octon Architect-level reasoning:
A single surface can quietly become over-authoritative, under-specified, stale, duplicated, or consumed by the wrong runtime path. Octon Architect should reason about the surface’s role in Octon’s broader topology, whether it is source-of-truth or derived, whether it is enforceable, and whether its consumers match its authority posture.

Repository and required method references:
- Repository: https://github.com/jamesryancooper/octon
- Method reference: .octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md
- Surface selection: If a prior review or the operator supplies one or more surfaces, audit only the supplied surface(s) and do not expand scope to other surfaces. Otherwise, identify the full set of durable surfaces and tightly bounded surface families in scope (contracts, registries, schema families, policies, adapter boundaries, generated/effective handle families, evidence roots, operator read-model families, support dossier families, runtime specs), enumerate them from the repository, then audit each surface or family in turn and produce one complete audit per surface.
- Sweep bounding: the self-enumerating surface space in this repository is large (hundreds of specs, policies, and contracts). Prefer grouping individual files into tightly bounded surface families and auditing the family. Before starting per-surface audits, declare an item budget for this run. Audit surfaces in inventory order up to that budget. Record every enumerated surface or family that is not audited in this run explicitly in the inventory as "not audited in this run" so no surface is dropped silently; those items are the remainder for a continuation run.
- For each surface, classify its type (contract, registry, schema family, policy, adapter, generated/effective handle family, evidence root, read model, or other) and derive any review trigger from repository evidence rather than from supplied input.

Specific files, directories, or surfaces to inspect:
Always inspect:
- The surface or surface family currently under review (the one you are auditing in this pass)
- .octon/framework/cognition/_meta/architecture/contract-registry.yml
- .octon/framework/cognition/_meta/architecture/specification.md
- .octon/framework/constitution/CHARTER.md
- .octon/framework/constitution/precedence/normative.yml
- .octon/framework/constitution/obligations/fail-closed.yml
- .octon/framework/constitution/obligations/evidence.yml

For each surface under review, locate and inspect its relevant surroundings yourself across:
- Declared owner/registry entries
- Upstream authority sources
- Downstream consumers
- Forbidden consumers or non-authority declarations
- Related schemas/contracts
- Validators/tests/fixtures
- Evidence roots or receipts
- Generated projections/read models
- Compatibility or retirement records

Core invariants the review must preserve:
- Surface must not become a second control plane.
- Surface authority must match its class-root placement.
- Authored authority must live under framework/** or instance/**.
- state/control/** surfaces are mutable control truth.
- state/evidence/** surfaces are retained proof.
- generated/** surfaces are derived-only.
- inputs/** surfaces are non-authoritative.
- Read models, host UI, labels, comments, checks, chat, model memory, and provider sessions are not authority.
- Consumers must match allowed/forbidden posture.
- Failure behavior must preserve deny-by-default where applicable.
- Architecture evaluation remains separate from implementation planning.

Exact repo-grounded questions Octon Architect must answer:
1. What is the surface’s intended role?
2. What class-root and authority class does it belong to?
3. Is the placement correct under Octon’s topology?
4. Is it source authority, mutable control truth, retained evidence, continuity, generated derived output, compatibility projection, raw input, or navigation/read model?
5. Who owns it?
6. What upstream sources does it depend on?
7. What downstream consumers read it?
8. Are any consumers forbidden or suspicious?
9. Does the surface widen support, policy, runtime, closeout, or authority claims?
10. Are evidence, freshness, receipts, replay, rollback, or disclosure requirements explicit where needed?
11. Are validators/tests/fixtures/negative controls sufficient for the surface’s claim?
12. Is the surface duplicated, stale, compatibility-only, or superseded?
13. Are there hidden contracts or ambiguous precedence with other surfaces?
14. What should be preserved, moved, merged, split, renamed, retired, or left alone?
15. Does this surface require domain audit, mechanism review, architecture readiness audit, or Constitutional Challenge follow-up?

Required output format:
Begin with a surface inventory, then repeat the full per-surface structure below for every surface or surface family audited in this run.

## Surface Inventory
- List every surface or surface family identified for review, its type, and the order in which you review it.
- State whether this run is targeted (supplied surface(s)) or self-enumerating, and the declared item budget.
- List every enumerated surface or family not audited in this run, marked "not audited in this run". The inventory count must equal audited items plus this explicit remainder.

For each surface, produce:

# Surface Architecture Audit: <surface>

## 1. Surface Review Charter
- Surface
- Surface type
- Scope
- Non-goals
- Review trigger

## 2. Surface Role and Placement
- Intended role
- Class-root placement
- Authority class
- Owner
- Source-of-truth status
- Allowed consumers
- Forbidden consumers

## 3. Dependency and Consumer Map
- Upstream sources
- Downstream consumers
- Generated/read-model projections
- Evidence or receipt dependencies
- Compatibility/retirement links

## 4. Enforcement and Validation
- Documented intent
- Implemented/enforced behavior
- Validators/tests/fixtures
- Evidence requirements
- Failure behavior

## 5. Boundary Risks
- Authority overreach
- Consumer mismatch
- Generated/read-model leakage
- Support widening
- Runtime bypass
- Evidence substitution
- Stale/duplicate/superseded surface risk

## 6. Chesterton’s Fence Findings
- Preserve
- Move
- Merge
- Split
- Rename
- Retire
- Leave alone
- Escalate

## 7. Verdict and Follow-Up
- Surface is correctly placed and bounded
- Surface needs architecture refinement
- Surface needs domain/mechanism review
- Surface needs readiness audit
- Surface needs Constitutional Challenge
- Not enough evidence

## 8. Acceptance Criteria
- Architecture-level criteria
- Required evidence
- Required validator depth
- Revisit triggers
- No implementation tasks

Quality criteria for judging the result:
- Cite repository evidence by file path.
- Distinguish documented intent from enforcement.
- Identify actual and forbidden consumers.
- Judge placement and authority class explicitly.
- Avoid broad domain drift.
- Do not propose code changes.

Explicit non-goals:
- No implementation plan.
- No code changes.
- No schema edits.
- No validator writing.
- No migration plan.
- No support widening.
- No treating generated/read-model surfaces as authority.

Expected downstream use:
Architecture, governance, tests, documentation, planning, and implementation-readiness.
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

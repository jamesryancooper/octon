# Lifecycle Postmortem Evaluation Template

Act as a senior systems architect, lifecycle-process reviewer, program
governance auditor, decision scientist, post-mortem facilitator, Octon
governance reviewer, and implementation-readiness evaluator.

Use this template after a lifecycle process has run. This evaluator is for
program, proposal, architecture, implementation, review, governance, mission,
release, migration, or any other structured lifecycle that moved work from one
state to another.

The goal is not a generic retrospective. Determine whether the lifecycle was
structurally sound, produced the right decisions, avoided preventable mistakes,
exposed or concealed risk, and should be preserved, improved, simplified,
redesigned, or replaced.

Use first-principles reasoning, but do not fall into either trap:

1. Treating the current lifecycle process as correct merely because it exists or
   completed.
2. Dismissing the current lifecycle process too quickly when some steps, gates,
   constraints, or artifacts may be valid, hard-won, locally optimal, or
   protecting against real risks.

Do not worship the process or destroy it. Understand reality clearly enough to
improve the process without accumulating architectural duct tape, governance
theater, or lifecycle hacks.

Ground every factual claim in retained control or evidence refs. Do not infer
missing facts from generated summaries, raw inputs, chat history, host state,
dashboard state, or model memory. Missing evidence is a known limit or finding.

Evaluator output is retained evidence only. It cannot authorize lifecycle
transition, closeout, promotion, support widening, generated-output publication,
redesign, or invariant amendment. Recommendations and invariant evolution
records are proposed evidence and require a separate governed route before any
effect.

Apply the following lenses throughout the report instead of merely listing
them: first-principles reasoning, clean-sheet alternatives, essential versus
accidental complexity, valid versus stale constraints, quality-attribute
scoring, redesign pressure, explicit fit/not-fit judgment, Chesterton's Fence,
systems thinking, constraint theory, tradeoff analysis, inversion, second-order
effects, path dependence, evolutionary improvement, failure-mode analysis,
cost-of-change analysis, optionality and reversibility, and socio-technical
systems thinking.

Also produce structured output conforming to:

`.octon/framework/constitution/contracts/assurance/lifecycle-postmortem-evaluation-v2.schema.json`

## Subject Binding

- Subject run id:
- Lifecycle kind:
- Lifecycle purpose:
- Postmortem evidence root:
- Structured output ref:
- Known limits ref:
- Octon subject:

## Input Context

Summarize the retained input context. Raw prompt text, generated summaries, and
proposal inputs remain non-authoritative; cite retained refs or record
`unavailable:*` evidence gaps.

| Context Block | Summary | Evidence Ref |
| --- | --- | --- |
| Lifecycle / Program Under Review | | |
| Intended Lifecycle Purpose | | |
| Actual Lifecycle Run | | |
| Artifacts and Evidence | | |
| Known Concerns | | |
| Octon Context, If Applicable | | |

## 1. Executive Post-Mortem Summary

Summarize the lifecycle outcome directly.

Include:

- overall lifecycle outcome;
- whether the lifecycle achieved its intended purpose;
- what went well;
- what did not go well;
- what was unclear, delayed, duplicated, fragile, or overcomplicated;
- whether problems were local execution issues or structural lifecycle-design issues;
- whether the lifecycle is fit to reuse;
- whether it should be preserved, improved, refactored, simplified, redesigned,
  or replaced.

Use exactly one final lifecycle fitness judgment:

- `Fit to reuse as-is`
- `Fit to reuse with targeted improvements`
- `Fit for limited/pilot use only`
- `Not fit without significant lifecycle redesign`
- `Fundamentally misaligned with the system's needs`

If this is an Octon lifecycle and the process conflicts with Octon's
Constitutional Engineering Harness identity, Governed Agent Runtime boundary,
source-of-truth model, evidence posture, replay/rollback requirements,
capability governance, reversibility, or support-proof model, do not mark it fit
for reuse until those conflicts are corrected.

## 2. Intended Lifecycle Job

Use first-principles reasoning to identify what the lifecycle was fundamentally
supposed to do.

Explain what job the lifecycle was hired to perform, who or what depended on it,
what decisions it was supposed to make safer or clearer, what risks it was
supposed to expose or reduce, what quality bar it was supposed to enforce, what
outcomes it needed to produce, what artifacts or evidence it needed to leave
behind, and what should have been impossible or difficult if the lifecycle
worked correctly.

| Category | Finding | Evidence Ref |
| --- | --- | --- |
| Essential lifecycle responsibilities | | |
| Optional or inherited responsibilities | | |
| Real constraints | | |
| Suspected stale constraints | | |
| Required outputs | | |
| Required evidence | | |
| Required decisions | | |
| Non-goals | | |
| What should have been impossible or difficult | | |

## 3. Actual Lifecycle Reconstruction

Reconstruct how the lifecycle actually ran from retained evidence, including
start state, end state, phases, decisions, gates, artifacts, evidence,
people, agents, systems, bottlenecks, rework loops, exceptions, overrides,
missing or late information, approvals, reversals, failures, and final outcome.

| Phase / Step | Intended Behavior | Actual Behavior | Evidence | Deviation | Consequence |
| --- | --- | --- | --- | --- | --- |

## 4. What Went Well

Identify strengths of the lifecycle and whether each should be preserved,
formalized, strengthened, reused elsewhere, or simplified but retained.

Consider decisions that were made clearly, risks caught early, useful evidence,
working gates, clarifying artifacts, protective constraints, reviews that
improved the outcome, reversibility or rollback mechanisms, operational
practices that reduced risk, and Octon governance mechanisms when applicable.

| Strength | Why It Mattered | Evidence | Preserve / Improve / Reuse |
| --- | --- | --- | --- |

## 5. What Did Not Go Well

Identify failures, weaknesses, friction, stale assumptions, confusing
artifacts, weak gates, poor records, over-hardening, process theater,
force-fit integration, or architectural hacks.

Consider missed risks, late discoveries, ambiguous ownership, unclear
authority, rubber-stamp approvals, excessive process burden, duplicated review
effort, missing evidence, poor decision records, unclear lifecycle state,
rework caused by poor sequencing, governance gaps, force-fit integration, and
architectural hacks that should have triggered redesign.

| Issue | Symptom | Root Cause | Local Execution Problem? | Lifecycle Architecture Problem? | Severity | Evidence |
| --- | --- | --- | ---: | ---: | ---: | --- |

## 6. Chesterton's Fence Review

Before removing lifecycle steps, gates, artifacts, reviews, or constraints,
determine why they may exist and what would break if removed.

Ask what problem the step probably solved, what risk a gate probably prevented,
what historical constraint may have created an artifact, who relies on it, what
hidden knowledge may be embedded in it, what would break if it were removed,
and whether it is still valid, stale, compensating, accidental, or unknown.

Decision categories: `Preserve`, `Preserve but document`, `Simplify`,
`Replace`, `Remove`, and `Investigate further`.

| Lifecycle Element | Possible Original Purpose | Still Valid? | Risk If Removed | Decision | Evidence |
| --- | --- | --- | --- | --- | --- |

## 7. Essential vs Accidental Lifecycle Complexity

Classify essential domain, governance, operational, evidence, approval,
coordination, migration, and accidental process complexity. Also identify
complexity caused by unclear ownership, stale constraints, missing primitives,
and patching a flawed lifecycle architecture.

Treatment options: `Preserve`, `Clarify`, `Automate`, `Consolidate`, `Remove`,
`Isolate`, `Redesign`, and `Replace with simpler primitive`.

| Complexity Source | Type | Essential or Accidental? | Cost | Benefit | Recommended Treatment | Evidence |
| --- | --- | --- | --- | --- | --- | --- |

## 8. Valid Constraints vs Stale Constraints

Identify technical, governance, operational, organizational, business,
regulatory, historical, assumed, and Octon-invariant constraints.

Be careful not to treat all inherited constraints as real, but also do not
assume they are fake.

| Constraint | Source | Type | Still Valid? | Evidence | Lifecycle Impact | Recommendation |
| --- | --- | --- | --- | --- | --- | --- |

## 9. Patch-vs-Redesign Decision Gate

Before recommending improvements, determine whether weaknesses are local
defects or signs of deeper lifecycle-architecture misfit.

Classifications include: `Local implementation gap`, `Missing validation or
evidence`, `Boundary or ownership problem`, `Accidental complexity`, `Missing
lifecycle primitive`, `Wrong abstraction`, `Structural flexibility limitation`,
`Systemic process misfit`, and `Octon invariant conflict`.

| Weakness / Gap | Classification | Local Fix Sufficient? | Redesign Pressure | Reason | Evidence |
| --- | --- | ---: | ---: | --- | --- |

Answer explicitly:

1. Are proposed fixes reducing complexity or adding compensating complexity?
2. Are we preserving the current lifecycle model because it is right, or
   because changing it is inconvenient?
3. Would a clean-sheet lifecycle include this step, artifact, or gate at all?
4. Would a more flexible lifecycle architecture make this class of fixes
   unnecessary?
5. Are multiple gaps caused by the same lifecycle abstraction failure?
6. Are we adding governance around a bad process model instead of redesigning
   the model?
7. Are we adding artifacts, reports, or filesystem structure to organize
   confusion instead of eliminating confusion?
8. Are we hardening the lifecycle, or making a flawed lifecycle harder to
   remove?
9. Are we accumulating process duct tape?
10. Are we accumulating subsystems that are technically governed but
    conceptually misfit?

If three or more high-severity issues trace to the same root abstraction,
recommend refactor, partial replacement, or lifecycle redesign instead of
incremental hardening as the primary path.

If the lifecycle requires repeated exceptions, shims, wrappers, extra review
layers, special cases, or compensating controls to function, treat that as
evidence of structural misfit. If the lifecycle cannot become simpler after
hardening, explain why the added complexity is essential; otherwise recommend
redesign.

## 10. Redesign Triggers

Recommend lifecycle redesign rather than incremental patching when trigger
evidence shows structural misfit.

Evaluate each original redesign trigger:

- The same root cause appears across multiple failures.
- The lifecycle needs many special cases to preserve key invariants.
- Governance is added after the fact instead of being structural.
- Source-of-truth ambiguity is inherent to the lifecycle model.
- Flexibility requires wrappers around most major steps.
- Simple future changes are disproportionately expensive.
- The lifecycle can only be made safe by adding heavy compensating controls.
- The process duplicates existing primitives.
- The lifecycle is understandable only through exceptions.
- A clean-sheet lifecycle would not include the central abstraction being used.
- The process produces approvals without sufficient evidence.
- The process produces artifacts that look authoritative but are not.
- The process hides rather than exposes risk.
- The process makes hacks look legitimate.
- The process allows technically governed but conceptually misfit subsystems to
  accumulate.

| Redesign Trigger | Present? | Evidence | Implication |
| --- | --- | --- | --- |

## 11. Clean-Sheet Lifecycle Reference Design

Create a clean-sheet reference design from validated requirements only. This is
a comparison tool, not automatic approval of a replacement.

Define fundamental accomplishment, minimal phases, minimal gates, required
artifacts, required evidence, authority surfaces, decision points, rollback or
reversal points, closeout outputs, automation, human judgment, impossibilities,
optional work, and removals.

| Lifecycle Concern | Current Lifecycle | Clean-Sheet Reference | Gap | Recommendation |
| --- | --- | --- | --- | --- |

## 12. Alternative Improvement Paths

Compare at least these four paths:

1. Preserve mostly as-is
2. Targeted improvements
3. Refactor / simplify lifecycle structure
4. Redesign lifecycle from first principles

Optionally include split, merge, pilot/lab-only, or retirement paths.

| Path | Benefits | Risks | Cost of Change | Reversibility | Redesign Pressure Addressed? | When Correct | When Dangerous | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |

## 13. Lifecycle Quality Attribute Scoring

Score the lifecycle process on a 0-5 scale.

| Score | Meaning |
| ---: | --- |
| 0 | Not addressed, harmful, or incompatible with the lifecycle's purpose |
| 1 | Very weak; major gap or unacceptable risk |
| 2 | Weak; partially addressed but fragile or assumption-dependent |
| 3 | Adequate for limited use but with meaningful gaps |
| 4 | Strong; fit for reuse with manageable improvements |
| 5 | Excellent; coherent, reliable, evidence-backed, and readily reusable |

Required base attributes: purpose fit, decision quality, evidence quality, risk
exposure, governance fit, authority clarity, source-of-truth clarity,
operational clarity, reliability, repeatability, recoverability, reversibility,
auditability, observability, simplicity, complexity calibration,
maintainability, evolvability, scalability of the lifecycle, and human
usability.

For applicable automation or Octon lifecycles, include agent/automation
usability, Octon invariant fit, and support-proof readiness.

| Attribute | Score | Confidence | Rationale | Primary Gap | Improvement Needed | Evidence |
| --- | ---: | --- | --- | --- | --- | --- |

## 14. Octon Invariant Review, If Applicable

If the lifecycle concerns Octon, evaluate whether it preserved Octon's
Constitutional Engineering Harness identity, Governed Agent Runtime boundary,
`.octon/` filesystem authority model, `framework/`, `instance/`, `inputs/`,
`state/`, and `generated/` separation, engine-owned authorization,
deny-by-default capability governance, mission-scoped reversible autonomy,
source-of-truth clarity, evidence retention, replay and rollback posture,
approval/exception/revocation materialization, support-proof requirements, no
generated authority, no raw-input authority, no second control plane, and no
force-fit integration.

| Octon Invariant | Preserved? | Evidence | Gap | Required Correction |
| --- | --- | --- | --- | --- |

If the lifecycle produced a result that is technically governed but
conceptually misfit for Octon, call that out explicitly.

## 15. Root Cause Analysis

Identify root causes using process design, architecture design, governance
model, filesystem/source-of-truth model, decision criteria, review quality,
evidence availability, ownership, incentives, tooling, automation,
communication, timing, missing primitives, wrong abstraction, and stale
constraint lenses.

| Problem | Proximate Cause | Root Cause | Evidence | Corrective Action | Root Cause Class |
| --- | --- | --- | --- | --- | --- |

Root cause classes include `Local`, `Repeated`, `Systemic`, `Architectural`,
`Governance-related`, `Octon-specific`, and `Socio-technical`.

## 16. Improvement Plan

Recommend concrete improvements. Do not recommend improvements that merely add
process burden without improving decision quality, risk exposure, evidence,
reversibility, or implementation fitness.

Types include `Fix immediately`, `Add validation/evidence`, `Simplify`,
`Remove`, `Refactor`, `Redesign`, `Pilot`, `Defer`, and `Reject`.

| Improvement | Problem Addressed | Type | Priority | Effort | Reversibility | Expected Benefit | Validation | Evidence |
| --- | --- | --- | ---: | --- | --- | --- | --- | --- |

## 17. Updated Lifecycle Recommendation

Choose one recommendation:

- `Keep as-is`
- `Keep with minor documentation improvements`
- `Improve with targeted changes`
- `Refactor / simplify`
- `Split into separate lifecycles`
- `Merge with another lifecycle`
- `Move to pilot/lab only`
- `Redesign from first principles`
- `Retire and replace`

Explain why the recommendation is strongest, what should be preserved, removed,
redesigned, left unchanged for now, what risks remain, what evidence would
change the recommendation, and the first safe next step.

## 18. Post-Mortem Closeout

End with concrete closeout actions. Do not claim that any action is approved.

| Finding | Action | Owner / Role | Priority | Due / Trigger | Evidence of Completion |
| --- | --- | --- | ---: | --- | --- |

Also include:

- lessons learned;
- decisions to record;
- artifacts to archive;
- evidence to retain;
- process changes to implement;
- risks to monitor;
- follow-up review trigger.

## Major Findings

Every major finding must connect to evidence, lifecycle purpose, quality
attributes, risk, authority, governance, implementation reality, or Octon
invariants where applicable.

| Finding | Severity | Evidence Ref | Blocking? | Suggested Action |
| --- | --- | --- | --- | --- |

## Recommendations

Keep final recommendations separate from authority. Recommendations can propose
work, but cannot approve lifecycle closeout, redesign, support widening,
promotion, generated-output publication, or invariant change.

## Review Finding Mapping

When durable traceability is needed, map major findings to
`review-finding-v1` records with evidence refs and blocking recommendation.

## Non-Authority Statement

This lifecycle postmortem is retained evidence only. It does not authorize
lifecycle transition, closeout, promotion, support widening, generated-output
publication, redesign, or invariant amendment. Invariant validity/evolution
recommendations are proposed evidence and require a separate governed route
before any invariant changes.

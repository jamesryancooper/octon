# Lifecycle Postmortem Evaluation Template

Use this template after a lifecycle process has run. Ground every factual claim
in retained control or evidence refs. Do not infer missing facts from generated
summaries, raw inputs, chat history, host state, dashboard state, or model
memory.

Evaluator output is evidence only. It cannot authorize lifecycle transition,
closeout, promotion, support widening, generated-output publication, redesign,
or invariant amendment.

## Subject Binding

- Subject run id:
- Lifecycle kind:
- Lifecycle purpose:
- Postmortem evidence root:
- Structured output ref:
- Known limits ref:

## Lifecycle Reconstruction

Reconstruct what actually happened from retained evidence:

| Fact | Evidence Ref | Confidence | Known Limit |
| --- | --- | --- | --- |

## Evidence Map

List the retained refs used by the review. Generated outputs, raw inputs, chat
history, host state, and dashboards may be mentioned only as non-authoritative
context and may not prove lifecycle facts.

| Ref | Class | Used For | Authority Status |
| --- | --- | --- | --- |

## Intended Design And Actual Behavior

Compare the lifecycle's intended purpose, accepted design, actual behavior, and
observable outcomes.

| Dimension | Intended | Actual | Evidence Ref | Gap |
| --- | --- | --- | --- | --- |

## Bad Implementation Versus Wrong Architecture

Determine whether failures came from poor execution of a sound lifecycle or
from lifecycle architecture that is misfit for the system.

| Finding | Bad Implementation? | Wrong Architecture? | Evidence Ref | Reasoning |
| --- | --- | --- | --- | --- |

## Patch Versus Redesign Reasoning

Use Chesterton's Fence before recommending redesign. Explain what the existing
design protects, what breaks, and whether a targeted patch is enough.

| Issue | Existing Protection | Patch Candidate | Redesign Pressure | Decision |
| --- | --- | --- | --- | --- |

## Redesign Triggers

Identify force-fit, wrapper-heavy, recurring, or structurally unfixable
symptoms.

| Trigger | Present? | Evidence Ref | Interpretation |
| --- | --- | --- | --- |

## Clean-Sheet Lifecycle Reference Design

Describe the lifecycle shape a clean-sheet version would use if it were written
today. This is a reference design, not an approved redesign.

## Alternative Improvement Paths

Compare targeted fixes, staged hardening, and clean-sheet redesign paths.

| Path | Benefit | Cost | Risk | Evidence Ref |
| --- | --- | --- | --- | --- |

## Invariant Evaluation

Evaluate whether the lifecycle complied with Octon invariants before scoring
quality. For Octon lifecycle subjects, include at least:

- source-of-truth clarity;
- generated artifacts are not authority;
- raw inputs are not authority;
- no second control plane;
- runtime authority is engine-owned;
- deny-by-default capability access;
- retained evidence;
- replay and rollback posture;
- support claims are evidence-backed;
- Constitutional Engineering Harness identity;
- silence is not consent.

Allowed ratings are `Pass`, `Partial`, `Fail`, `Unknown`, and `Not Applicable`.
`Unknown` is an evidence gap and never counts as pass. `Partial` must name weak
enforcement or weak evidence. Material `Fail` or `Partial` ratings must include
blocking or corrective disposition when they concern authority, generated or raw
input truth, runtime authorization, evidence retention, support-proof
requirements, second control planes, or force-fit integration.

| Invariant | Applicability | Rating | Enforcement Mechanism | Evidence Ref | Evidence Gap | Blocking Status | Required Correction |
| --- | --- | --- | --- | --- | --- | --- | --- |

## Quality Scoring

Score quality only after invariant compliance is evaluated.

| Dimension | Score | Evidence Ref | Rationale |
| --- | --- | --- | --- |

## Root Cause Analysis

Identify root causes without collapsing invariant failures into generic quality
issues.

| Root Cause | Evidence Ref | Lifecycle Layer | Correction |
| --- | --- | --- | --- |

## Invariant Validity and Evolution Review

Evaluate whether the current invariants themselves are still correct,
complete, enforceable, and appropriately classified. Do not treat invariants as
untouchable. Also do not weaken them merely because they create implementation
friction. Determine whether each invariant protects a real system property or
has become stale, ambiguous, over-broad, under-specified, conflicting, or
hack-inducing.

Ask:

1. What core risk or system property does this invariant protect?
2. Is that risk still real?
3. Is the invariant stated at the right level of abstraction?
4. Is it too broad, too narrow, too vague, or too implementation-specific?
5. Can it be structurally enforced?
6. Can compliance be evidenced?
7. Does it conflict with another invariant?
8. Does it duplicate another invariant?
9. Does it create unnecessary architectural contortions?
10. Would a clean-sheet version include this invariant?
11. Should this be an invariant, policy, guideline, default, quality attribute,
    or implementation detail?
12. Should the invariant be kept, clarified, strengthened, relaxed, split,
    merged, reclassified, replaced, removed, or supplemented?

Allowed recommendations are `Keep`, `Clarify`, `Strengthen`, `Relax`, `Split`,
`Merge`, `Reclassify`, `Replace`, `Remove`, and `Add`.

For each non-`Keep` recommendation, name the required change and
change-control bar. Relaxing, removing, narrowing, downgrading, or adding
invariants requires high or very high scrutiny. These recommendations are
evidence-only and cannot amend invariant authority.

| Invariant | Protected Property | Current Validity | Enforcement Quality | Evidence Quality | Scope Quality | Conflict / Duplication | Hack Pressure | Recommendation | Required Change |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

## Final Judgment

Choose exactly one:

- `Fit to reuse as-is`
- `Fit to reuse with targeted improvements`
- `Fit for limited/pilot use only`
- `Not fit without significant lifecycle redesign`
- `Fundamentally misaligned with the system's needs`

## Major Findings

| Finding | Severity | Evidence Ref | Blocking? | Suggested Action |
| --- | --- | --- | --- | --- |

## Closeout Actions

List corrections, follow-up proposals, support blockers, or governance review
candidates. Do not claim that any action is approved.

## Recommendations

Keep final recommendations separate from authority. Recommendations can propose
work, but cannot approve lifecycle closeout, redesign, support widening,
promotion, or invariant change.

## Review Finding Mapping

When durable traceability is needed, map major findings to
`review-finding-v1` records with evidence refs and blocking recommendation.

## Non-Authority Statement

This lifecycle postmortem is retained evidence only. It does not authorize
lifecycle transition, closeout, promotion, support widening, generated-output
publication, redesign, or invariant amendment. Invariant validity/evolution
recommendations are proposed evidence and require a separate governed route
before any invariant changes.

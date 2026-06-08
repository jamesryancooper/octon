# Target Architecture

The evaluator template contains:

- input binding for lifecycle context, intended purpose, actual run evidence,
  artifacts, known concerns, and Octon context;
- mandatory evidence-grounding instructions;
- expanded required postmortem output structure;
- final judgment enum:
  - `Fit to reuse as-is`
  - `Fit to reuse with targeted improvements`
  - `Fit for limited/pilot use only`
  - `Not fit without significant lifecycle redesign`
  - `Fundamentally misaligned with the system's needs`
- patch-versus-redesign decision gate;
- Octon invariant evaluation when the lifecycle is Octon-related;
- invariant validity and evolution review when the lifecycle is Octon-related;
- explicit non-authority statement for all recommendations;
- finding mapping to `review-finding-v1` records where durable traceability is
  needed;
- optional evidence-to-candidate distillation guidance when redesign or
  lifecycle architecture changes are recommended.

## Structured Output

The companion schema should capture:

- subject run id;
- lifecycle kind;
- evidence refs;
- known limits;
- section completeness;
- invariant evaluation records with invariant name, applicability, rating,
  enforcement mechanism, evidence refs, evidence gap, blocking flag, and
  required correction;
- invariant validity/evolution records with protected property, current
  validity, enforcement quality, evidence quality, scope quality, conflict or
  duplication status, hack pressure, recommendation, required change, and
  required change-control bar;
- final judgment;
- major findings;
- authority boundary statement;
- follow-up recommendations;
- non-authority assertion.

## Invariant Evaluation

The template must place `Invariant Evaluation` before quality scoring. For each
Octon invariant, the evaluator determines whether it applies, whether it was
preserved, whether it was structurally enforced or merely followed by
convention, what retained evidence proves preservation, what evidence is
missing, whether the gap blocks reuse, approval, promotion, support-proof
claims, or implementation, and what correction is required.

Ratings are restricted to:

- `Pass`
- `Partial`
- `Fail`
- `Unknown`
- `Not Applicable`

`Unknown` is an evidence gap and cannot be counted as Pass. `Partial` must name
the weak enforcement or weak evidence. `Fail` must create a blocking or
redesign-triggering finding when the invariant concerns authority, generated or
raw-input truth, runtime authorization, evidence retention, support-proof
requirements, second control planes, or force-fit integration.

## Invariant Validity And Evolution Review

The template must include `Invariant Validity and Evolution Review` after
redesign pressure has been identified and before final recommendations. This
section asks whether the current invariants are still the right invariants, not
whether the lifecycle complied with them.

For each invariant, the evaluator must assess:

- protected property or core risk;
- current validity;
- scope clarity;
- enforceability;
- evidenceability;
- flexibility for legitimate future architecture;
- precision;
- duplication;
- conflicts;
- failure coverage;
- hack pressure;
- classification accuracy.

The required table columns are:

| Invariant | Protected Property | Current Validity | Enforcement Quality | Evidence Quality | Scope Quality | Conflict / Duplication | Hack Pressure | Recommendation | Required Change |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

Recommendations are restricted to:

- `Keep`
- `Clarify`
- `Strengthen`
- `Relax`
- `Split`
- `Merge`
- `Reclassify`
- `Replace`
- `Remove`
- `Add`

Each non-`Keep` recommendation must name a required change and the required
change-control bar. Relaxing, removing, narrowing, downgrading, or adding
invariants requires high or very high scrutiny. Recommendations remain
evidence-only and cannot amend invariant authority, approve redesign, weaken
fail-closed behavior, or change support claims.

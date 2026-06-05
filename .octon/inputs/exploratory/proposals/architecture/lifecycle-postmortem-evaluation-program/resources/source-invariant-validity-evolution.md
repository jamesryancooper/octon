# Source Invariant Validity And Evolution

The source revision requires the lifecycle postmortem to evaluate not only
whether a lifecycle preserved current invariants, but also whether the
invariants themselves remain correct, complete, well-scoped, non-conflicting,
enforceable, evidenceable, and useful.

## Distinction

- invariant compliance review: did the lifecycle obey the invariants?
- invariant validity review: are these still the right invariants?

Both layers are required. Compliance failures usually point to process,
workflow, enforcement, or evidence defects. Validity failures may point to
stale, ambiguous, over-broad, under-specified, conflicting, misclassified,
unenforceable, overly implementation-specific, overly abstract, or
hack-inducing invariants.

## Required Section

The postmortem template must include `Invariant Validity and Evolution Review`
after redesign pressure has been identified and before final recommendations.

The evaluator asks whether the lifecycle failed because people ignored good
invariants, or because the invariants themselves are incomplete, stale,
ambiguous, misfit, or poorly shaped.

## Required Criteria

For each invariant, evaluate:

- purpose clarity;
- current validity;
- scope clarity;
- enforceability;
- evidenceability;
- flexibility;
- precision;
- non-duplication;
- conflict check;
- failure coverage;
- hack pressure;
- classification accuracy.

## Required Table

The postmortem template must include an invariant validity/evolution table with
these columns:

| Invariant | Protected Property | Current Validity | Enforcement Quality | Evidence Quality | Scope Quality | Conflict / Duplication | Hack Pressure | Recommendation | Required Change |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

## Recommendation Categories

Allowed recommendations:

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

These recommendations are evidence only. They may produce findings or proposal
candidates, but they do not alter constitutional, policy, runtime, support, or
lifecycle authority.

## Change-Control Bar

The evaluator must record the required bar for any proposed invariant change:

- clarify wording: low-to-medium bar, preserving intent;
- add enforcement or evidence: medium bar;
- narrow invariant: high bar;
- broaden invariant: medium-to-high bar;
- remove invariant: very high bar;
- add new invariant: high bar with recurring or systemic risk proof;
- downgrade invariant to policy: high bar with classification proof;
- promote policy to invariant: high bar with core identity or safety proof.

Octon postmortems must be especially cautious about relaxing or removing
invariants that protect source-of-truth clarity, generated non-authority, raw
input non-authority, no second control plane, engine-owned authorization,
deny-by-default capability access, retained evidence, replay and rollback,
support-proof claims, and Constitutional Engineering Harness identity.

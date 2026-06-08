# Target Architecture

Octon gains a lifecycle-postmortem capability composed of three governed parts:

1. A read-only meta workflow, `lifecycle-postmortem`, that binds a completed
   lifecycle run, reconstructs evidence, invokes the evaluator template, and
   records retained outputs.
2. A lifecycle-postmortem evaluator template that implements the required
   post-mortem evaluation structure, evaluates Octon invariant compliance
   before quality scoring, reviews invariant validity and evolution pressure
   before final recommendations, and maps conclusions to retained evidence,
   review findings, and optional evolution candidates.
3. A validator and fixture suite that proves report shape, evidence reference
   resolution, invariant compliance completeness, invariant validity/evolution
   completeness, authority boundary preservation, final judgment enum validity,
   and negative controls for generated/input authority drift.

## Runtime Posture

The postmortem workflow is post-run and read-only by default. It may write
evidence under canonical evidence roots, but it may not mutate run lifecycle
state, advance closeout, authorize implementation, accept findings, or widen
support claims.

## Evidence Roots

Expected retained outputs:

- `.octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/evaluation.md`
- `.octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/evaluation.yml`
- `.octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/review-findings.ndjson`
- `.octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/evidence-map.yml`

The exact final shape belongs to the child packets, but all retained outputs
must remain evidence only.

## Invariant Evaluation Model

For Octon lifecycle subjects, invariant evaluation is a mandatory postmortem
section and is ordered before lifecycle quality scoring. Quality attributes
describe how well a lifecycle worked; invariants decide whether the lifecycle
was allowed to produce that outcome at all.

The evaluator must rate each applicable invariant with one of:

- `Pass`: preserved, structurally enforced, and evidenced;
- `Partial`: mostly preserved, but enforcement or evidence is weak;
- `Fail`: violated or materially bypassed;
- `Unknown`: insufficient evidence;
- `Not Applicable`: genuinely outside the lifecycle scope.

`Unknown` is not a pass. For hardened or support-proof work, Unknown, Fail, and
material Partial ratings must produce a blocking or corrective finding until
evidence is found, enforcement is added, or the lifecycle is redesigned.

The invariant table must include columns for invariant, applicability, rating,
enforcement mechanism, evidence, gap, blocking status, and required correction.
At minimum, Octon-related lifecycle postmortems evaluate:

- Constitutional Engineering Harness identity;
- Governed Agent Runtime boundary;
- single `.octon/` super-root;
- class-root separation;
- no second control plane;
- authored authority clarity;
- generated is never authority;
- raw inputs are not authority;
- state as operational truth and retained evidence;
- engine-owned authorization;
- deny-by-default capability access;
- canonical approvals, exceptions, and revocations;
- mission-scoped reversible autonomy;
- replay and rollback posture;
- evidence retention;
- support-proof requirements;
- no force-fit integration.

## Invariant Validity And Evolution Model

Invariant compliance asks whether the lifecycle obeyed the current invariants.
Invariant validity and evolution asks whether those invariants remain correct,
complete, enforceable, appropriately scoped, non-conflicting, and useful.

The evaluator must include a separate `Invariant Validity and Evolution Review`
after redesign pressure is identified and before final recommendations. This
section must not treat invariants as untouchable, and it must not weaken them
merely because they create implementation friction. It distinguishes friction
that protects core Octon safety from friction caused by stale, ambiguous,
over-broad, under-specified, conflicting, or hack-inducing rules.

For each invariant, the review assesses:

- protected property or risk;
- current validity;
- scope quality;
- enforceability;
- evidenceability;
- flexibility for legitimate future architectures;
- precision;
- duplication;
- conflicts;
- failure coverage;
- hack pressure;
- classification accuracy.

Recommendations must use one of:

- `Keep`;
- `Clarify`;
- `Strengthen`;
- `Relax`;
- `Split`;
- `Merge`;
- `Reclassify`;
- `Replace`;
- `Remove`;
- `Add`.

Recommended invariant changes are evidence-only. They may create findings,
proposal candidates, or constitutional amendment candidates, but they do not
change invariants, weaken fail-closed behavior, authorize redesign, or mutate
policy without a separate governed route. Narrowing, removing, downgrading, or
adding invariants requires a high or very high change-control bar.

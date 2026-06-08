# Source Invariant Evaluation

The source revision requires invariant evaluation inside the lifecycle
postmortem. Invariants are not quality attributes. They are hard architectural
guardrails that determine whether a lifecycle was allowed to produce its
outcome.

## Evaluation Layers

Each applicable invariant must be evaluated across three layers:

- preservation: whether the lifecycle respected the invariant;
- enforcement: whether the invariant was structurally enforced rather than
  followed by convention;
- evidence: whether retained proof shows the invariant was respected.

## Rating Set

The evaluator must use this stricter rating set:

- `Pass`
- `Partial`
- `Fail`
- `Unknown`
- `Not Applicable`

`Unknown` means evidence is insufficient. It must not be treated as Pass.

## Required Table

The postmortem template must include an invariant evaluation table with these
columns:

| Invariant | Applies? | Rating | Enforcement Mechanism | Evidence | Gap | Blocking? | Required Correction |
| --- | --- | --- | --- | --- | --- | --- | --- |

## Required Octon Invariants

For Octon lifecycle subjects, evaluate at least:

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

## Judgment Consequences

Invariant failures have stronger consequences than ordinary process
weaknesses. Generated or raw input authority, second control planes, runtime
authorization bypasses, missing consequential evidence, repeated exceptions
needed to preserve invariants, and force-fit architectural acceptance must be
blocking or redesign-triggering findings until separately corrected.

# Cutover Plan

## Preconditions

- RP-06 and RP-07 exit; RP-03 T1/T2 and RP-05 ED-003 interfaces are frozen at
  exact digests.
- The settled/retired ROD-002 lineage is encoded as the immutable
  irreducible-ambiguity-only notification/manual-intervention rule without
  reopening the class predicate or requesting another operator vote.
- Accepted proposal, passing completeness, and strict architecture review exist.
- Current retry/provider/PR/status/scheduling call paths and exact shared entries
  are inventoried/assigned.

## Safe Intermediate States

1. Contracts validate while the reconciler is inert.
2. Reconciler classifies recorded scratch observations in shadow mode but cannot
   transition state or call provider.
3. Restart scanner reports `ATTEMPTING`/`UNKNOWN` with retry disabled.
4. Scratch T1/send/T2/reconcile runs with production Class B disabled.
5. Run-health and continuous-operation projections report but do not authorize.
6. SI-06 scratch route passes full fault/route proof before atomic activation.

## Prohibited Intermediate States

- two live retry/classification state machines;
- policy/predicate changes during its proof;
- provider call before T1 or retry while unknown;
- desired-state equality labeled `attempt_performed` without causal evidence;
- invalid authority routed to PR;
- production/trust-root target in SI-06 proof;
- ambient credentials, unsigned evidence, candidate verifier, or direct provider
  fallback; or
- generated status/mission schedule treated as authority.

## Activation

1. Freeze inputs and decision receipt.
2. Validate contracts/library and shadow classification.
3. Run UE-004/007 crash/race/attribution proof on scratch targets.
4. Run PO-FD-002/012/016 route, recovery, degraded, prompt, and PR matrices.
5. Run scheduled maintenance and reversible scratch effect with rollback.
6. Atomically activate frozen-route consumption, reconciler, signed-evidence
   checks, run status, and continuous-operation bounds.
7. Disable direct/blind retry and ambiguous legacy outcome paths.
8. Retain activation receipt and hand SI-06 to RP-09/RP-14.

## Completion Evidence

Receipt binds exact dependency/predicate digests, route matrix, fault matrix,
attribution result, zero-prompt/unauthorized-effect counts, recovery time,
status/PR behavior, reversible effect, retired paths, and preserved candidates.

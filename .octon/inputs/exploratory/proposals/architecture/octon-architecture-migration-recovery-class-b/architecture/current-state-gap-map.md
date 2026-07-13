# Current-State Gap Map

## Repository-Grounded Baseline

Octon has risk/route concepts, authority and effect-token records, some
post-effect observation, mission autonomy/continuation, continuous stewardship,
run-health projections, and useful PR paths. Reconciliation found no complete
durable attempt/unknown/reconcile behavior, no dynamic causal-attribution proof,
and no complete zero-prompt Class B vertical under outage/race/crash.

## Gaps

| Gap | Current state | Required target | Owner / proof |
| --- | --- | --- | --- |
| FD-002 route classes | Useful risk/routes exist but explicit immutable A/B/C behavior lacks complete proof | Consume exact RP-06 predicate; A/B routine zero prompts; C lower route denies | RP-06 policy, RP-08 vertical; PO-FD-002 |
| FD-012 durable attempts | Some checks/records exist without full crash-safe attempt identity | RP-03 T1 before send and T2 result/unknown, consumed by RP-08 | RP-03 interface; RP-08 behavior |
| Unknown reconciliation | Remote equality checks do not close lost-response ambiguity | Provider-specific bounded probes before every retry | RP-08; RF-011, PO-FD-012 |
| Attribution | Desired state can reflect concurrent actor rather than this attempt | Separate `attempt_performed` from `state_satisfied`; ED-003 targeted proof | RP-05/RP-08; RF-026, UE-007 |
| External atomicity | SQLite cannot commit atomically with Git/GitHub | Honest T1/external/T2 model and per-attempt manual intervention | RP-03/RP-08; RF-028 |
| FD-016 degraded mode | Failure concepts exist but full narrow work-preserving route is unproved | Dependency-specific block/restart/reconcile; no ambient fallback | RP-08; PO-FD-016 |
| Protected PR fallback | PR exists but must not launder invalid authority or hide unknown effects | Frozen deterministic valid-work fallback with same candidate/evidence | RP-06 route, RP-08 proof |
| Status | Run-health projections exist but not full effect/reconciliation UX | Concise fresh non-authoritative class/attempt/unknown/next-action view | RP-08 |
| Continuous operation | Mission scheduling exists; complete bounded maintenance/effect vertical absent | Bounded existing mission/run route plus reversible scratch effect | RP-08 component, RP-14 integrated UE-014 |
| Unsafe rollback | Prior designs could restore log-only/YAML/unsanitized/unsigned paths | Disable route, preserve candidate, protected PR or prior certified boundary | RF-018 |

## Preserved Strengths

- Preserve RP-03's one canonical transaction model and RP-06's immutable route
  predicate; do not create a second policy/state machine.
- Preserve existing mission/run contracts and run-health projection discipline.
- Preserve protected PR as a safe valid-work route, never invalid-authority
  remediation.
- Preserve honest manual intervention for irreducible ambiguity.

## Evidence Limits

Current claims are statically inspected. UE-004 and UE-007 require scratch
provider and crash/concurrency proof. RP-08 contributes to but cannot close
RP-14-owned UE-014 product acceptance.

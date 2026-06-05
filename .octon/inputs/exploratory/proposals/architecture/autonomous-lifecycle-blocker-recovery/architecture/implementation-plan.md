# Implementation Plan

This is a proposal program plan, not an implementation.

## Child Workstreams

1. `autonomous-blocker-taxonomy` defines the recovery classes and examples.
2. `token-efficiency-preservation` constrains recovery evidence and summaries.
3. `validator-affordances` defines machine-readable diagnostics and repair
   hints.
4. `cleanup-routing` defines receipt-backed cleanup delegation.
5. `evidence-and-receipt-hardening` defines child-owned receipt and replay
   safeguards.
6. `runner-recovery-behavior` integrates the recovery loop into lifecycle
   runner behavior.
7. `escalation-policy-update` updates escalation policy and examples.

## Policy And Prompt Changes

- Update proposal-program lifecycle prompts and context so routine and soft
  blockers are repaired autonomously when bounded and validator-backed.
- Update escalation examples so human intervention is limited to hard blockers.
- Preserve fail-closed behavior for authority, ownership, external, destructive,
  and unsupported-scope cases.

## Implementation Changes

- Add or revise lifecycle runner recovery classification and retry behavior.
- Add validator diagnostics that include failing path, accepted values, stale
  evidence cause, recovery class, and minimal repair hint.
- Add tests and negative controls for autonomous repair and hard-blocker stops.
- Add compact event and recovery summaries.

## Non-Implementation Constraints

This parent creation step does not edit durable runtime, validator, cleanup,
policy, generated, control, or evidence surfaces. Later child implementation
routes own those changes.

# Continuous Stewardship Runtime v3

Continuous Stewardship Runtime v3 is the governed long-running availability
layer above the Engagement/Work Package compiler and Mission Autonomy Runtime.

The service may remain available indefinitely. The work may not become
unbounded.

Stewardship can open finite epochs, observe recognized triggers, emit Admission
Decisions, idle when no admissible work exists, create bounded mission handoff
candidates, emit Renewal Decisions, and maintain a stewardship ledger. It never
executes material work directly and never replaces missions, mission-control
leases, Mission Queues, run contracts, run journals, run evidence, or execution
authorization.

Canonical handoff order:

```text
Stewardship Program
  -> Stewardship Epoch
    -> Stewardship Trigger
      -> Stewardship Admission Decision
        -> optional v1 Engagement / Work Package / v2 Mission handoff
          -> Mission Runner
            -> Mission Queue
              -> Action Slice
                -> Run Contract
                  -> Governed Run
```

Generated stewardship projections are read models only. Runtime and policy
consumers must resolve authority from `framework/**`, `instance/**`, and
`state/control/**` roots, with retained proof under `state/evidence/**`.

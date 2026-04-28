# Stewardship Lifecycle Standards

Continuous stewardship is a long-running availability posture, not a
long-running execution grant.

## Required Order

```text
Stewardship Program
  -> finite Stewardship Epoch
    -> normalized Stewardship Trigger
      -> Stewardship Admission Decision
        -> Idle Decision or bounded mission handoff
          -> v2 Mission Runner
            -> Run Contract
              -> Governed Run
```

## Standards

- A Stewardship Program is repo-scoped durable authority under
  `instance/stewardship/programs/**`.
- A Stewardship Epoch is finite operational truth under
  `state/control/stewardship/**`; it does not replace mission-control leases.
- A Stewardship Trigger is normalized observation only; it never authorizes
  work.
- An Admission Decision is required before a trigger can become work; it never
  authorizes material execution.
- Idle is a successful governed state when no admissible work exists.
- Renewal requires explicit operator action, closeout evidence, no silent scope
  widening, and no unresolved blocking Decision Requests.
- Stewardship Ledgers index and roll up references; they do not replace Mission
  Run Ledgers, Mission Queues, run journals, run evidence, run contracts, or
  disclosure artifacts.
- Campaign hooks remain optional coordination candidates. Campaigns must not
  launch workflows, own runs, claim queue items, replace missions, or become
  stewardship.
- All material execution remains routed through v2 mission continuation,
  run-contract binding, context packing, policy evaluation, execution
  authorization, retained evidence, replay/disclosure, rollback posture, and
  closeout gates.

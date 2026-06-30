# Target Architecture

Expose one thin entrypoint:

```text
/proposal-program-delivery target=<proposal-program-path> outcome=cleaned
```

The entrypoint normalizes inputs into the governed Proposal Program Delivery
profile, invokes the existing delivery workflow, and reports:

- current route;
- next owning route;
- blocker class;
- evidence refs;
- terminal clean-state result when current owning evidence proves it.

It must not grant implementation authorization, delivery authorization, Git
mutation authority, branch cleanup authority, archive authority, cleanup
authority, terminal proof authority, or evidence substitution.

The generic program lifecycle runner remains the orchestrator for proposal
program route progression. `--set target_outcome=cleaned` records a
clean-delivery request posture for later Proposal Program Delivery handoff; it
is not evidence of landing, sync, cleanup, branch cleanup, terminal proof, or a
final `cleaned` state.

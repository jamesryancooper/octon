# Lifecycle Postmortem Meta Workflow

This child packet defines the workflow and runtime entry point for a post-run
lifecycle postmortem.

The workflow is intentionally not part of normal closeout. It runs after a
completed lifecycle process and writes evidence that can inform later reviews,
proposal packets, or evolution candidates.

## Desired Operator Shape

```bash
octon lifecycle postmortem --run-id <run-id>
```

The command should fail closed when the run lacks required retained evidence or
when the postmortem would need to treat generated, input, or chat context as
authority.

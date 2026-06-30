# Run Program Clean Delivery Operator Surface

This child packet binds the operator-facing surface for governed proposal
program clean delivery.

The canonical entrypoint is:

```text
/proposal-program-delivery target=<proposal-program-path> outcome=cleaned
```

The surface delegates to the Proposal Program Delivery workflow. It reports the
highest evidence-backed outcome, blocker class, next owning route, and retained
evidence refs. It does not authorize implementation, archive, cleanup, Git
mutation, branch cleanup, terminal proof, or a final `cleaned` claim.

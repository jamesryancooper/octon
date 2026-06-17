# Stage 03: Run Or Resume Packet Implementation

Run the accepted packet through `run-packet-implementation` or resume the same
route after live-state replanning.

Required checks:

- Implementation runs write target-local receipts.
- Implementation does not widen accepted promotion targets.
- The newly introduced route does not authorize its own implementation unless
  validators have passed and lifecycle policy permits that use.
- Stale, missing, or ambiguous implementation evidence blocks downstream claims.
- Rollback context names every durable target mutated by the implementation.

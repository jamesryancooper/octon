# Program Implementation Plan

## Execution Mode

`gated-parallel`: independent children may proceed concurrently only after
their declared dependencies satisfy verification. Human review and acceptance
occur per child; parent acceptance does not accept children.

## Phases

1. **Foundation:** exposure readiness and repository-role contracts proceed in
   parallel.
2. **Policy and delivery foundations:** portable-base clearance, downstream
   delivery, and local-storage implementation proceed after role contracts.
3. **Materialization and workspace root:** portable export and root workspace
   migration proceed after their respective prerequisites.
4. **Public controls and Octon storage:** public repository controls and
   Octon-internal storage migration proceed independently after their gates.
5. **Pilot:** integrated readiness runs only after all implementation children,
   exposure readiness, and separately approved public repository setup.

## External Setup Barrier

A separately approved operations plan must create or transition repository
identities and configure the public repository before any live public pilot.
Program implementation cannot cross this barrier autonomously.

The barrier binds repositories by immutable GitHub ID, requires the active
workspace and every known writer to target the private identity before the
original public name is reused, and requires a negative stale-endpoint test and
explicit maintainer acceptance of unknown-clone residual risk.

## Evidence

Each child owns its implementation and verification receipts. The parent may
retain a compact aggregate index that records freshness, child verdicts, blocker
coverage, and manual-gate state without copying sensitive evidence or replacing
child truth.

## Rollback

- Child rollback follows each child packet.
- Root and Octon storage migrations use separate commits and recovery journals.
- Public settings use compensating operations where supported.
- Published immutable assets are never overwritten; a bad release is withdrawn
  or superseded.
- Parent closeout stops when any required child is non-terminal, stale, or
  missing evidence.

## Implementation Handoff

After maintainer re-review, review each materially revised child independently.
Generate executable implementation prompts only for accepted children whose
dependencies are satisfied. Do not run program delivery from this in-review
parent or while any required revised child remains in review.

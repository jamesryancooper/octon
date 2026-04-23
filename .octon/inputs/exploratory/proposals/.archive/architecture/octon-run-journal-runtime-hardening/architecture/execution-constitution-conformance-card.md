# Execution Constitution Conformance Card

## Decision

Harden the existing canonical run event ledger into the Run Journal execution
substrate for the Governed Agent Runtime.

## Constitutional alignment

| Constitutional concern | Conformance |
|---|---|
| Authored authority | No proposal-local material becomes authority before promotion. |
| Control Plane | Existing authorization/governance logic remains controlling. |
| Execution Plane | Runtime executes under grants and appends journal events. |
| Generated outputs | Derived-only; cannot authorize or reconstruct state. |
| State vs Evidence | Control journal remains live state/control truth; evidence snapshot remains retained proof. |
| Support targets | No support-target widening; admission requirements strengthened. |
| Reversibility | Rollback/checkpoint events and refs become required for relevant Runs. |
| Assurance | Validators and fixture Runs prove implementation behavior. |

## Fail-closed requirements

- Missing journal root: deny consequential execution.
- Invalid sequence/hash: deny closeout and raise drift.
- Runtime-state/journal conflict: journal wins and drift evidence required.
- Generated read model consumed as authority: deny.
- Side effect without authorization and journal refs: deny.
- Replay attempting live side effect without fresh grant: deny.

## Boundary statement

The Run Journal is not a rival Control Plane. It records and reconstructs runtime
execution under the existing Control Plane. Authority continues to flow from
constitutional and instance governance through engine-owned authorization.

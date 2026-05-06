# Lifecycle Model

## Packet State Machine

```text
source-context
  -> packet-created
  -> packet-validated
  -> implementation-prompt-generated
  -> implementation-run
  -> implemented
  -> verification-prompt-generated
  -> verified
  -> corrections-needed
  -> corrected
  -> clean
  -> closeout-prompt-generated
  -> closeout-ready
  -> archived
```

Fail-closed or pause report outcomes:

- `blocked`
- `needs-packet-revision`
- `superseded`
- `explicitly-deferred`

Routes must refuse jumps that skip required packet validation, implementation
grounding, verification, correction, or closeout gates. `blocked`,
`needs-packet-revision`, `superseded`, and `explicitly-deferred` are reported
outcomes for a lifecycle gate or route decision; they are not additional
proposal statuses.

## Program State Machine

```text
program-source-context
  -> program-created
  -> child-packets-planned
  -> child-packets-created
  -> child-packets-validated
  -> program-implementation-prompt-generated
  -> children-implemented
  -> program-verification-prompt-generated
  -> program-verified
  -> child-corrections-needed
  -> child-corrections-resolved
  -> program-closeout-prompt-generated
  -> program-closeout-ready
  -> children-closed
  -> program-archived
```

Program routes coordinate child packets. They do not own child lifecycle truth,
child subtype manifest truth, child promotion targets, child validation
verdicts, or child archive metadata.

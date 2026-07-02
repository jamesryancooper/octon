# Target Architecture

The target feature is an advisory evaluator that reads retained lifecycle and proposal evidence, computes governance efficiency findings, and emits a compact report for human and proposal authors.

## Core Properties

- Read-only collection from retained evidence and proposal packets.
- Explicit separation between advisory findings and lifecycle authority.
- Report fields that tie each finding to risk covered, latency cost, evidence source, automation fit, batching fit, risk-based fit, and redundancy.
- Deterministic scoring where possible, with missing data recorded as uncertainty.
- No delivery-blocking behavior unless a later accepted proposal promotes a specific control.

## Non-Goals

- No mutation of workflow state.
- No replacement of proposal review, validation, closeout, archive, cleanup, or terminal proof.
- No parent-level substitution for child-owned evidence.
- No automatic deletion, branch mutation, generated publication, or hosted-provider action.

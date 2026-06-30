# Proposal Program Lifecycle Surface Coherence

This parent proposal program stages the confirmed follow-up work from the Octon proposal lifecycle surface audit for the `run-program-to-clean-delivery` capability.

The parent coordinates child packets only. It does not implement durable lifecycle behavior, refresh generated outputs, publish host projections, authorize cleanup, authorize archive, mutate Git refs, close any child, or claim terminal delivery.

## Child Packets

- `proposal-delivery-input-contract-alignment` - Align required delivery inputs across canonical commands, skills, workflows, contracts, manifests, and validators.
- `proposal-program-delivery-operator-alias` - Add the optional operator-facing alias for running a program through delivery without replacing the canonical wrapper.
- `proposal-program-delivery-host-projections` - Publish or correct `.codex` host projections for implemented proposal delivery wrappers and align product catalog claims.
- `proposal-program-review-loop-documentation` - Document the existing parent-local program review/revision loop and the intentional absence of a separate review-and-revise wrapper.
- `proposal-lifecycle-surface-validation-hardening` - Add regression validation that keeps packet/program lifecycle surfaces coherent after the other children land.

## Program Boundary

The program addresses confirmed gaps through child-owned proposals. Optional convenience surfaces remain optional until a child packet justifies them. The parent does not absorb child authority, child receipts, child promotion targets, child validation verdicts, child archive metadata, or child terminal outcomes.

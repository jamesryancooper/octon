# Target Architecture

## Goal

Resolve the last residual MSRAOM tension by aligning proposal-workspace provenance
to the already-complete runtime implementation.

## Final end-state

After this cutover:

- the runtime and governance surfaces remain unchanged
- the proposal workspace no longer implies open MSRAOM implementation work
- the archive tells one clean MSRAOM lineage story
- the archived steady-state and final-closeout packets project as archived
  historical packets rather than stray `draft` manifests
- ADR 067 remains the runtime closeout record and one new provenance-closeout
  ADR becomes the canonical answer to the proposal-lineage question
- one matching migration plan and evidence bundle record the provenance closeout
- bootstrap and architecture navigation point to canonical runtime/governance roots
- future audits no longer need to infer completion from runtime alone, as this packet
  grounds itself in [`../resources/implementation-audit.md`](../resources/implementation-audit.md).

## Architectural decision

This is a **governance-architecture alignment cutover**, not an implementation
redesign.

The completion status being aligned is the one recorded in
[`../resources/implementation-audit.md`](../resources/implementation-audit.md).

### Therefore:
- proposals become historical lineage
- ADR/decision history becomes the canonical closure statement
- migration plan and evidence roots record the atomic promotion transaction
- runtime and governance roots remain canonical truth
- generated proposal registry becomes consistent with that state

## No-runtime-delta invariant

The architecture after this packet must be semantically identical to the current
runtime behavior. Only provenance and navigation alignment change.

## Acceptance model

This packet is complete when:
- no MSRAOM packet remains ambiguously active
- archived MSRAOM packets have normalized archive metadata and project into the
  generated registry consistently
- a canonical closeout decision exists
- a canonical provenance-closeout migration record exists
- registry and archive state are consistent
- docs/START/specification point to runtime/governance truth before proposal lineage
- no runtime or policy semantic changes slipped in

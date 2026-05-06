# Run Implementation

Re-read the packet manifests, source-of-truth map, artifact catalog,
implementation plan, acceptance criteria, implementation-grade completeness
receipt, and `support/executable-implementation-prompt.md`. Refuse to proceed
unless the packet is accepted or the operator explicitly invoked this
implementation route for the packet and that invocation is recorded as the
implementation acceptance basis for this pass.

Execute only the durable promotion work declared by the packet and its
executable implementation prompt. Preserve class boundaries: proposal packet
material is implementation input and provenance only; durable authority,
control, evidence, generated projections, and instance enablement must land in
their declared repository classes. Do not widen promotion targets, support
claims, capabilities, authority ownership, or product semantics without routing
to packet revision or a linked proposal.

After durable changes land, update the packet's implementation conformance
receipt, post-implementation drift/churn receipt, validation receipt, and
checksums when present. Run structural, subtype, implementation-readiness,
implementation-conformance, and post-implementation drift validators, plus all
validators declared by the packet and affected durable surfaces. Report
`implemented` only when both post-implementation receipts pass with no
unresolved items; otherwise report `blocked`, `deferred`, or
`needs-packet-revision` with evidence.

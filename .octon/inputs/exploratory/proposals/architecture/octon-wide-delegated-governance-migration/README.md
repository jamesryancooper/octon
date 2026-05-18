# Octon-Wide Delegated Governance Migration

_Status: Accepted parent proposal program_

This parent program coordinates the migration from default approval posture to
proof-gated delegated execution and typed human exception grants. It is based on
the accepted `octon-wide-delegated-governance-architecture` packet.

The parent coordinates sequence and aggregate closeout only. Child packets are
sibling proposal packets under `.octon/inputs/exploratory/proposals/architecture/`;
they own their manifests, reviews, implementation truth, validation verdicts,
promotion targets, and closeout receipts.

No durable runtime, schema, validator, connector, authority, generated
projection, or state/control change is implemented by this parent packet.

# Retained Run Evidence Index Materialization

This architecture packet adds the smallest durable route needed to materialize
valid `retained-run-evidence-index-v1` artifacts for implemented proposal
packets.

The route is needed because proposal-program readiness projection requires
`evidence_index_refs` for implemented children, existing workflow
`evidence-index.yml` files are not the retained-run index schema, and the
parent registry must not point to invalid references.

The materialized indexes are discovery and replay aids. They do not authorize
execution, satisfy child receipts, mutate control state, close packets, archive
packets, or promote the parent program.

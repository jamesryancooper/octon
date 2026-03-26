# Acceptance Criteria

The packet is accepted only if all of the following are true:

1. A new provenance-closeout ADR exists under `instance/cognition/decisions/**`
   and states that MSRAOM runtime closeout is complete and proposal packets are
   historical lineage.
2. A matching provenance-closeout migration plan exists under
   `instance/cognition/context/shared/migrations/**`.
3. `instance/cognition/decisions/index.yml` and
   `instance/cognition/context/shared/migrations/index.yml` both include the new
   provenance-closeout records.
4. The archived steady-state and final-closeout proposal manifests declare
   `status: archived` and include explicit archive metadata.
5. MSRAOM proposal lineage is consistent across active workspace, archive, and
   generated proposal registry.
6. No MSRAOM proposal packet remains ambiguously active if it is already
   superseded or archived.
7. `/.octon/generated/proposals/registry.yml` projects the archived
   steady-state and final-closeout packets coherently.
8. `.octon/README.md` points first to canonical runtime/governance surfaces,
   not proposals.
9. `.octon/instance/bootstrap/START.md` points first to canonical
   runtime/governance surfaces, not proposals.
10. Architecture navigation docs explicitly treat MSRAOM proposals as
    historical lineage and cite the implementation audit as baseline evidence.
11. No runtime, policy, schema, control-truth, evidence, or generated-runtime
    semantic file changed as part of this packet.
12. Key completion claims in the packet are linked to
    [`../resources/implementation-audit.md`](../resources/implementation-audit.md).
13. The packet can be merged without any follow-on remediation ledger.

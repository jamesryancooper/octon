# Acceptance Criteria

## Deterministic Context Pack Builder v1

The step is implemented when all packet-owned closure conditions below resolve
to durable targets outside this proposal:

1. The existing constitutional `context-pack-v1` contract is strengthened without creating a parallel context authority family.
2. A runtime builder contract exists under the engine runtime spec and is sufficient to implement deterministic assembly.
3. A context-pack receipt exists and binds:
   - the exact pack
   - the exact retained model-visible serialization ref and hash
   - the governing repo-local policy
   - omission and invalidation semantics
4. Consequential Runs emit retained context evidence under canonical run evidence roots.
5. Mutable control truth records the active context pack under canonical run control roots.
6. Instruction-layer manifests bind the context-pack receipt and model-visible hash.
7. Execution grant and execution receipt bind the same context-pack evidence chain.
8. Canonical Run Journal events cover requested / built / bound / rejected / compacted / invalidated / rebuilt lifecycle, with `runtime-event-v1` dot names preserved only as compatibility aliases.
9. A repo-local context policy exists and is sufficient to express trust, freshness, QoS, and omission rules.
10. A dedicated validator, regression test, and fixture set exist.
11. The active conformance entrypoint resolves outside this proposal packet.
12. The support-target universe is unchanged.
13. No generated surface becomes runtime authority.
14. No raw additive input is silently promoted to authority.
15. Replayable model-visible hash reconstruction from retained `model-visible-context.json` bytes is covered by the durable validator and fixture contract.
16. Authorization-time supplied bindings require and validate the retained `model-visible-context.sha256` sidecar, source manifest, omission/redaction manifests, invalidation manifest, replay reconstruction refs, and source digests before allowing consequential or boundary-sensitive Runs.
17. Execution request, grant, and receipt schemas require `context_policy_ref`, `model_visible_context_sha256`, `context_validity_state`, `valid_until`, and `subordinate_to_authorize_execution` whenever a `context_evidence_binding` is present.
18. Packet checksums are regenerated after closure edits.

## Packet-level acceptance

- the packet remains a focused single-step implementation packet
- all blocking gaps identified in `resources/implementation-gap-analysis.md` are closed or explicitly deferred with rationale
- zero unresolved critical blockers remain
- required promotion evidence exists in durable targets
- no proposal-path dependency remains in any declared promotion target

# Assumptions and Blockers

## Assumptions

- The current runtime constitutional contracts remain the right source family for
  run event ledgers, run events, runtime state, and reconstruction.
- The existing Governed Agent Runtime crate layout can support a single append
  path through `runtime_bus` or equivalent engine-owned service.
- Existing assurance validators can be extended to call Run Journal validators.
- Stage-only browser/API/MCP/frontier surfaces remain out of scope.
- Generated projections can be rebuilt after promotion from canonical roots.

## Known blockers

| Blocker | Resolution path |
|---|---|
| v1/v2 event naming mismatch | Define canonical v2 names and migration alias map. |
| Unknown runtime crate completeness | Implement fixture Runs and validator harness before promotion. |
| Missing support-target admission validator | Add validator or extend existing admission checks. |
| Evidence redaction policy may be incomplete | Start with lineage-required redaction metadata; do not expose sensitive details in generated views. |
| Potential conflict with pending proposals | Link related proposals and avoid overlapping promotion without review. |

## Explicit non-goals

- Admit new external action surfaces.
- Replace existing `authorize_execution` boundary.
- Move authority from constitutional/instance surfaces into runtime code.
- Make chat, comments, host labels, or generated summaries authoritative.
- Implement full Mission redesign.
- Implement multi-agent orchestration.

# Assumptions and Blockers

## Assumptions

- Run Journal v1 is implemented or promotion-ready as canonical append-only history.
- Authorized Effect Token enforcement is implemented or promotion-ready for material effects.
- Context Pack Builder v1 is implemented or promotion-ready for consequential context evidence.
- `runtime_bus` exists as the sole canonical append path.
- The runtime crate layout in `framework/engine/runtime/crates/**` is the correct implementation zone.
- Proposal packets remain non-authoritative.

## Potential blockers

| Blocker | Resolution |
|---|---|
| Missing or incomplete `run-event-v2` schema | Add/complete schema before lifecycle transition gate. |
| Runtime operations bypass `runtime_bus` | Refactor those operations before blocking enforcement. |
| Existing CLI commands mutate state directly | Route through transition gate. |
| Insufficient fixture coverage | Build positive/negative fixture matrix before admission. |
| Historical runs lack canonical journals | Treat as legacy/read-only unless reconstructed. |
| Validator cannot access required refs | Add retained refs or mark replay gap; do not silently pass. |

## Non-blockers

- Browser/API/MCP support is not required.
- Memory Governor is not required.
- Multi-agent orchestration is not required.
- New support-target tuples are not required.

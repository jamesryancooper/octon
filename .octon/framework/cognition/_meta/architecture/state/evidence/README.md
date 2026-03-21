# State Evidence Architecture

`state/evidence/**` is the canonical retained-evidence surface for the active
`.octon/` harness.

## Evidence Classes

| Evidence class | Canonical path | Purpose |
| --- | --- | --- |
| Run evidence | `.octon/state/evidence/runs/**` | Receipts, digests, and execution trace artifacts |
| Operational decision evidence | `.octon/state/evidence/decisions/**` | Allow/block/escalate and related operational decision records |
| Validation evidence | `.octon/state/evidence/validation/**` | Validation receipts and enforcement evidence |
| Migration evidence | `.octon/state/evidence/migration/**` | Migration provenance, rollback traceability, and cutover receipts |

## Lifecycle Rules

- Evidence is append-oriented and retention-governed.
- Evidence must survive generated regeneration and ordinary working-state
  reset.
- Evidence must not be used as active task state.
- Operational decision evidence is not an ADR surface.

## Related Docs

- `../continuity/runs-retention.md`
- `../continuity/decisions-retention.md`
- `../control/README.md`
- `./validation/README.md`

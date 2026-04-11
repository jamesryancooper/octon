# Evidence plan

## Evidence principles

1. Evidence is retained under `state/evidence/**`, not in the proposal tree.
2. Every adapted concept must carry enough evidence to prove it is:
   - real,
   - usable,
   - constitutionally aligned,
   - and not merely documented.
3. Generated summaries are convenience surfaces only.
4. Raw comments, logs, and traces remain evidence, not authority.

## Evidence required by concept

| Concept | Evidence package |
|---|---|
| Structured review findings + disposition | run-local findings NDJSON, disposition control snapshot, blocking validator receipt |
| Proposal-first mission classification | mission classification control record, proposal ref, fail-closed validation receipt |
| Failure-driven harness hardening | failure-distillation bundle, recurrence report, promoted-hardening regression proof |
| Thin adapters + token-efficient outputs | output-envelope validation receipt, raw-payload offload pointer, budget compliance report |
| Distillation pipeline | distillation bundle, source-index manifest, anti-shadow-memory validation receipt |

## Bundle conventions used in this packet

Where possible, bundle recommendations follow the repo’s observed evidence-bundle pattern:
- `bundle.yml`
- `evidence.md`
- `commands.md`
- `validation.md`
- `inventory.md`

## Packet-local vs promoted evidence

This packet can describe required evidence, but packet-local documents are not the promoted evidence themselves. Promotion requires that the evidence appear under the correct `state/evidence/**` root in the live repo.

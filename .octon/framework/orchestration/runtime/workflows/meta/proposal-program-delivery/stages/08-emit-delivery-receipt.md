# Stage 08: Emit Delivery Receipt

Emit an aggregate receipt conforming to `proposal-program-delivery-receipt-v1` and validate it with `validate-proposal-program-delivery-receipt.sh`.

Materialize a compact retained delivery evidence index conforming to `proposal-program-delivery-evidence-index-v1` with `generate-proposal-program-delivery-evidence-index.sh`, then validate it with `validate-proposal-program-delivery-evidence-index.sh`.

Required checks:

- All source receipts are cited by path or durable evidence reference.
- Parent summaries do not replace target-owned child receipts.
- Non-authority classifications are recorded.
- The retained evidence index records refs, digests, disclosure tiers, route, outcome, validator results, and non-authority classification only.
- The retained evidence index does not authorize delivery, archive, landing, cleanup, execution, child lifecycle outcomes, or child receipt replacement.
- Open blockers prevent downstream outcome claims.
- The receipt records the highest outcome that has current passing owning evidence.

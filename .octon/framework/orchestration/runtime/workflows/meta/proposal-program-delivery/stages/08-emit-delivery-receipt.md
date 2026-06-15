# Stage 08: Emit Delivery Receipt

Emit an aggregate receipt conforming to `proposal-program-delivery-receipt-v1` and validate it with `validate-proposal-program-delivery-receipt.sh`.

Required checks:

- All source receipts are cited by path or durable evidence reference.
- Parent summaries do not replace target-owned child receipts.
- Non-authority classifications are recorded.
- Open blockers prevent downstream outcome claims.
- The receipt records the highest outcome that has current passing owning evidence.

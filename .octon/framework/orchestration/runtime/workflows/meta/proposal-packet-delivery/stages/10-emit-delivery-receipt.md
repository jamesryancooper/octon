# Stage 10: Emit Delivery Receipt

Emit an aggregate receipt conforming to `proposal-packet-delivery-receipt-v1`
and validate it with `validate-proposal-packet-delivery-receipt.sh`.

Required checks:

- All source receipts are cited by path or durable evidence reference.
- Aggregate receipt evidence does not replace target-owned packet receipts.
- Non-authority classifications are recorded.
- Open blockers prevent downstream outcome claims.
- The receipt records the highest outcome that has current passing owning
  evidence.

# Emit Receipt

Write `support/governed-mechanism-integration-evaluation.yml` under `proposal_path`.

The receipt must use `governed-mechanism-integration-receipt-v1`, bind to the mechanism profile, cite conformance and drift/churn receipts, cite generated publication freshness evidence, classify current-state architecture review and lifecycle postmortem refs as evidence-only, and classify proposal-local files and generated outputs as non-authority.

After writing the receipt, run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-receipt.sh --receipt "$proposal_path/support/governed-mechanism-integration-evaluation.yml" --package "$proposal_path"
```

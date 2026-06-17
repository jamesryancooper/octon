# Policy Delta

## Durable Authority

The durable authority remains the Octon product contract:

- `.octon/framework/product/contracts/default-work-unit.yml`

GitHub workflow files must read as projections:

- direct-main push safety must validate without PR fields;
- branch-only Changes must not be forced into PR creation;
- PR quality, review, and merge automation apply only to `branch-pr`;
- PR templates may carry Change receipt projections but do not replace the
  canonical receipt.

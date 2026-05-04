---
title: Change Receipt Examples
description: Valid and invalid examples for Change Lifecycle Routing receipt semantics.
status: active
---

# Change Receipt Examples

These examples are documentation fixtures for
`.octon/framework/product/contracts/change-receipt-v1.schema.json` and the
Change Lifecycle Routing validators. They are not runtime authority and do not
prove that a live GitHub ruleset has been migrated.

## Examples

- `valid-branch-pr-ready.json` demonstrates a `branch-pr` Change that has
  reached `ready`. It uses `publication_status: pr-ready`,
  `integration_status: not_landed`, and `closeout_outcome: continued`.
- `valid-hosted-branch-no-pr-landed.json` demonstrates hosted no-PR landing
  evidence for `branch-no-pr` with exact source SHA checks and fast-forward
  integration evidence.
- `invalid-pushed-only-branch-claimed-landed.json` is intentionally invalid. A
  pushed branch is `published-branch`, not hosted `landed`.
- `invalid-draft-pr-claimed-full-closeout.json` is intentionally invalid. A
  draft, open, or ready PR must not claim full closeout.

## Validation

Expected pass:

```bash
.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh --receipt .octon/framework/product/contracts/examples/change-receipts/valid-branch-pr-ready.json
.octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh --receipt .octon/framework/product/contracts/examples/change-receipts/valid-hosted-branch-no-pr-landed.json --skip-live-remote
```

Expected fail:

```bash
if .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh --receipt .octon/framework/product/contracts/examples/change-receipts/invalid-pushed-only-branch-claimed-landed.json --skip-live-remote; then
  exit 1
fi

if .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh --receipt .octon/framework/product/contracts/examples/change-receipts/invalid-draft-pr-claimed-full-closeout.json; then
  exit 1
fi
```

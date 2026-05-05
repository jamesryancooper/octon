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

- `valid-direct-main-landed.json` demonstrates a low-risk solo Change landed
  directly on clean current `main`. It uses `integration_method:
  direct-commit`, `integration_status: landed`, and no PR metadata.
- `valid-branch-pr-ready.json` demonstrates a `branch-pr` Change that has
  reached `ready`. It uses `publication_status: pr-ready`,
  `integration_status: not_landed`, and `closeout_outcome: continued`.
- `valid-branch-no-pr-branch-local-complete.json` demonstrates branch-local
  completion without hosted landing or PR-backed publication. It uses
  `integration_status: not_landed`, `publication_status: none`, and
  `closeout_outcome: continued`.
- `valid-branch-no-pr-published-branch.json` demonstrates pushed-branch handoff
  without hosted landing or PR-backed publication. It uses
  `target_lifecycle_outcome: published-branch`, `integration_status:
  not_landed`, `publication_status: pushed-branch`, and `closeout_outcome:
  continued`.
- `valid-hosted-branch-no-pr-landed.json` demonstrates hosted no-PR landing
  evidence for `branch-no-pr` with exact source SHA checks and fast-forward
  integration evidence.
- `invalid-pushed-only-branch-claimed-landed.json` is intentionally invalid. A
  pushed branch is `published-branch`, not hosted `landed`.
- `invalid-published-branch-completed-closeout.json` is intentionally invalid.
  Pushed-branch handoff is continued closeout, not completed closeout.
- `invalid-stale-remote-branch-ref.json` is intentionally invalid. The recorded
  remote branch ref does not match the durable branch head.
- `invalid-draft-pr-claimed-full-closeout.json` is intentionally invalid. A
  draft, open, or ready PR must not claim full closeout.

## Validation

Expected pass:

```bash
.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh --receipt .octon/framework/product/contracts/examples/change-receipts/valid-direct-main-landed.json
.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh --receipt .octon/framework/product/contracts/examples/change-receipts/valid-branch-pr-ready.json
.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh --receipt .octon/framework/product/contracts/examples/change-receipts/valid-branch-no-pr-branch-local-complete.json
.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh --receipt .octon/framework/product/contracts/examples/change-receipts/valid-branch-no-pr-published-branch.json
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

if .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh --receipt .octon/framework/product/contracts/examples/change-receipts/invalid-published-branch-completed-closeout.json; then
  exit 1
fi

if .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh --receipt .octon/framework/product/contracts/examples/change-receipts/invalid-stale-remote-branch-ref.json; then
  exit 1
fi
```

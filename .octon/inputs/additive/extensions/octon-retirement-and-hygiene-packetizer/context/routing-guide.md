# Routing Guide

`octon-retirement-and-hygiene-packetizer` uses one dispatcher:

- dispatcher id: `octon-retirement-and-hygiene-packetizer`
- route contract: `context/routing.contract.yml`

## Route Selection Rules

1. Explicit `flow` always wins.
2. `packet_attachment` or `target_ids` imply `ablation-plan-draft`.
3. `gap_scope` implies `registry-gap-analysis`.
4. `proposal_id`, `run_audit`, `audit_id`, or `audit_dir` imply
   `audit-to-packet-draft`.
5. No narrower signal falls back to `scan-to-reconciliation`.

## Dry Run

Use `dry_run_route=true` to return only the route-resolution receipt.

## Publication

When the pack is enabled and published, this routing contract is projected into
`/.octon/generated/effective/extensions/catalog.effective.yml` under
`route_dispatchers`.

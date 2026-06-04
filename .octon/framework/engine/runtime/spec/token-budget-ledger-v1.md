# Token Budget Ledger v1

## Purpose

Token Budget Ledger v1 is retained measurement evidence for lifecycle token
usage, provider usage when available, repeated-source accounting, and token
regression validation.

The ledger is not authorization, policy, control truth, source evidence, or a
runtime grant. It must not replace raw evidence, context-pack receipts,
run-contracts, execution grants, or proposal packet receipts.

## Placement

Route-level ledgers are retained under the route evidence root:

`/.octon/state/evidence/runs/<run-id>/token-budget-ledger.json`

Program-level aggregate ledgers are retained under the program evidence root:

`/.octon/state/evidence/runs/<program-run-id>/token-budget-ledger.json`

## Required Contents

Each ledger records:

- parent, child, stage, source, and model level estimates;
- source refs, SHA-256 digests, byte counts, estimated tokens, source class,
  model-visible state, and inclusion mode;
- prompt, context, completion, tool-output, and evidence token estimates;
- provider usage only when a provider usage artifact is explicitly supplied;
- repeated-source percentage, prompt boilerplate percentage, generated-state
  rereads, raw-log rereads, and high-reasoning call count;
- authority-boundary facts proving the ledger does not authorize execution or
  replace source evidence.

## Failure Behavior

Token regression validators may fail closed on stale, missing, unverifiable, or
regressing ledger artifacts. Ledger failure must not be used to mint or deny
material execution authority by itself; authorization remains owned by the
runtime authorization surfaces.

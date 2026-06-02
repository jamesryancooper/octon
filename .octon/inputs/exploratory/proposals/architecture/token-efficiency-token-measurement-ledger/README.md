# Token Measurement And Ledger

This is a child architecture proposal packet in the Token-Efficient Proposal Program Controller.

## Purpose

Add lifecycle-level token-budget ledgers, provider-usage capture, repeated-source accounting, and CI token regression measurement.

## Parent Program

Parent: `token-efficient-proposal-program-controller`

## Phase

`phase-0` / group `measurement`

## Non-Authority Statement

This child is a non-authoritative proposal input. It does not implement changes or authorize execution. Durable outputs must land in the declared promotion targets outside the proposal workspace.

## Model Route

Default route: deterministic-first; small model only for human summary

Token ceiling: 4k model-visible tokens for summary; 0 LLM tokens for ledger generation

Escalation trigger: provider usage mismatch, missing model accounting, source-token ledger cannot reconstruct context totals

## Core Changes

- Emit token-budget-ledger.json for parent, child, stage, source, and model levels.
- Capture prompt/context/completion/tool-output split when provider usage is available.
- Record repeated-source percentage, prompt boilerplate percentage, generated-state rereads, raw-log rereads, and high-reasoning call count.
- Add CI fixtures that compare before/after token ledger snapshots and fail on avoidable regressions.

## Validators

- test-lifecycle-runner.sh
- test-context-pack-builder.sh
- new test-token-budget-ledger.sh
- new token regression fixture for proposal-program mock run

## Governance

Ledger is retained measurement evidence and never authorizes execution.

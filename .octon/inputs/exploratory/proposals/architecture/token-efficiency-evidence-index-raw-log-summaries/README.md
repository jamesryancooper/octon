# Evidence Index And Raw Log Summaries

This is a child architecture proposal packet in the Token-Efficient Proposal Program Controller.

## Purpose

Add per-run evidence indexes, raw-log summaries, failing-slice manifests, and evidence readers that prefer compact refs over raw logs.

## Parent Program

Parent: `token-efficient-proposal-program-controller`

## Phase

`phase-1` / group `evidence`

## Non-Authority Statement

This child is a non-authoritative proposal input. It does not implement changes or authorize execution. Durable outputs must land in the declared promotion targets outside the proposal workspace.

## Model Route

Default route: deterministic; medium only for ambiguous failure classification

Token ceiling: 2k for failure summary; raw log body handle-only by default

Escalation trigger: summary hash mismatch, failing slice cannot be found, validator dispute, replay audit request

## Core Changes

- Emit evidence-index.yml with artifact role, digest, byte size, estimated tokens, model-visible relevance, and read-raw-only-if hints.
- Index stdout/stderr into deterministic raw-log-summary.yml records that identify prompt echoes, command output, diffs, and failing slices.
- Retain raw logs unchanged as evidence; consume compact summaries by default.
- Add evidence index reader paths for planner/recovery/closeout flows.

## Validators

- new raw-log summary hash-matching test
- new failing-slice manifest reconstruction test
- test-lifecycle-interaction-receipts.sh
- replay validation over raw evidence refs

## Governance

Summaries are evidence projections; raw logs remain retained proof.

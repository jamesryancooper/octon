# Planner State And Program Context Capsule

This is a child architecture proposal packet in the Token-Efficient Proposal Program Controller.

## Purpose

Split full audit program plans from compact planner state and parent/child program context capsules.

## Parent Program

Parent: `token-efficient-proposal-program-controller`

## Phase

`phase-1` / group `planner-state`

## Non-Authority Statement

This child is a non-authoritative proposal input. It does not implement changes or authorize execution. Durable outputs must land in the declared promotion targets outside the proposal workspace.

## Model Route

Default route: deterministic; small model for operator summary only

Token ceiling: 3k for final parent completion; 0 LLM for state generation

Escalation trigger: checkpoint/event-log drift, child state conflict, missing child receipt digest, terminal verdict mismatch

## Core Changes

- Retain full program-plan.yml for audit but route planners to planner-state.yml by default.
- Emit program-context-capsule.yml with child status table, dependency vector, runnable batch, current blockers, route decision, key digests, and evidence refs.
- Emit compact completion capsule for no-dispatch terminal parent runs.
- Bind program context capsule to event head and child registry digest.

## Validators

- planner-state reconstruction from program-lifecycle-checkpoint.yml and program-events.ndjson
- program-context capsule digest verification
- proposal-program mock run with no-dispatch completion

## Governance

Control journal and checkpoint remain lifecycle truth; planner-state is compact derived control/read state.

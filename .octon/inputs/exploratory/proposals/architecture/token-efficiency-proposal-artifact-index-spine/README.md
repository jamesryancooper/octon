# Proposal Artifact Index And Control Spine

This is a child architecture proposal packet in the Token-Efficient Proposal Program Controller.

## Purpose

Create proposal/program spines, artifact indexes with token estimates, stage-role classification, and spine/slice/annex defaults.

## Parent Program

Parent: `token-efficient-proposal-program-controller`

## Phase

`phase-2` / group `proposal-index`

## Non-Authority Statement

This child is a non-authoritative proposal input. It does not implement changes or authorize execution. Durable outputs must land in the declared promotion targets outside the proposal workspace.

## Model Route

Default route: deterministic generation; small model optional for short descriptions

Token ceiling: 2k summary; indexes generated without LLM

Escalation trigger: manifest mismatch, source digest drift, proposal path treated as authority, missing required lifecycle source

## Core Changes

- Generate per-proposal artifact indexes with path, role, digest, bytes, estimated tokens, inclusion mode, stage relevance, and read-raw-only-if hints.
- Generate proposal/program spines with status, child registry digest, authority boundary, gate states, receipt digests, blockers, and evidence refs.
- Classify proposal packet documents as spine, current-stage slice, evidence annex, or optional reference.
- Create child-handoff capsules from parent spine plus child-specific scope.

## Validators

- proposal registry validation
- proposal artifact index schema validation
- proposal spine freshness test
- generated registry cannot replace manifest negative control

## Governance

proposal.yml and subtype manifest remain lifecycle sources; generated spine/index are derived only.

# Repo Authority Graph And Write Scope Index

This is a child architecture proposal packet in the Token-Efficient Proposal Program Controller.

## Purpose

Precompute advisory repo authority graph and promotion-target/write-scope index to avoid repeated repo re-learning.

## Parent Program

Parent: `token-efficient-proposal-program-controller`

## Phase

`phase-5` / group `repo-graph`

## Non-Authority Statement

This child is a non-authoritative proposal input. It does not implement changes or authorize execution. Durable outputs must land in the declared promotion targets outside the proposal workspace.

## Model Route

Default route: deterministic graph generation; medium for ambiguous ownership descriptions

Token ceiling: 6k for ambiguity report; graph generated without LLM

Escalation trigger: source-of-truth ambiguity, generated surface incorrectly selected as promotion target, mixed target family risk

## Core Changes

- Generate advisory path authority class map: framework, instance, state/control, state/evidence, generated/read-model, inputs/proposal.
- Map promotion targets and child write scopes to validators, owners, rollback surfaces, and dependent routes.
- Fail closed if stale graph is used as if it were authority.
- Use graph slices in proposal child context packs.

## Validators

- repo authority graph source digest test
- target-family boundary validation
- stale graph fail-closed negative control
- promotion-target/write-scope index coverage test

## Governance

Graph is a generated read model and never replaces durable source-of-truth files.

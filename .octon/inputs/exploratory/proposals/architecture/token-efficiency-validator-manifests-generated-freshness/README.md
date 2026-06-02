# Validator Manifests And Generated Freshness Handles

This is a child architecture proposal packet in the Token-Efficient Proposal Program Controller.

## Purpose

Add validator result manifests, failing slices, publication freshness manifests, generated/read-model digest handles, and compact run-health manifests.

## Parent Program

Parent: `token-efficient-proposal-program-controller`

## Phase

`phase-3` / group `validation-freshness`

## Non-Authority Statement

This child is a non-authoritative proposal input. It does not implement changes or authorize execution. Durable outputs must land in the declared promotion targets outside the proposal workspace.

## Model Route

Default route: deterministic; medium only on failing validator classification

Token ceiling: 3k for failing-slice explanation; 0 LLM for pass manifests

Escalation trigger: stale generated handle, failing negative control, validator stdout cannot be mapped to manifest

## Core Changes

- Emit pass/fail counts, failing slice refs, contract refs, negative controls, stdout/stderr refs, and evidence digests.
- Represent generated effective tree and run-health as compact freshness handles instead of broad path listings.
- Fail closed when generated freshness handles are stale or cannot be verified.
- Prefer manifests in planner/closeout/recovery context.

## Validators

- test-validate-publication-freshness-gates.sh
- test-run-health-read-model.sh
- new validator-result manifest schema tests
- stale generated handle negative control

## Governance

Validation still executes or is proven fresh; manifests do not replace canonical validators.

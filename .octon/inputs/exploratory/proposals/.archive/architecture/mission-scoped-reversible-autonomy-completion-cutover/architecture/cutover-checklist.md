# Cutover Checklist

Use this as the branch-level execution checklist for the atomic MSRAOM
completion cutover.

## Pre-Implementation

- [ ] Create durable migration plan under
      `.octon/instance/cognition/context/shared/migrations/mission-scoped-reversible-autonomy-completion-cutover/plan.md`
- [ ] Create migration evidence root under
      `.octon/state/evidence/migration/mission-scoped-reversible-autonomy-completion-cutover/`
- [ ] Record ratification decision under `instance/cognition/decisions/**`
- [ ] Reserve release target `0.6.0`

## Root Manifest And Architecture

- [ ] Update `version.txt`
- [ ] Update `.octon/octon.yml`
- [ ] Update umbrella architecture specification
- [ ] Update runtime-vs-ops contract
- [ ] Update contract registry
- [ ] Update MSRAOM principle and aligned governance principles

## Mission Authority And Scaffolding

- [ ] Update mission scaffold to create the full mission-control file family
- [ ] Validate mission registry and mission charter v2 alignment
- [ ] Migrate active missions to final v2 charter
- [ ] Fix orchestration readers to consume `owner_ref`

## Contracts

- [ ] Add `mission-control-lease-v1.schema.json`
- [ ] Add `mode-state-v1.schema.json`
- [ ] Add `action-slice-v1.schema.json`
- [ ] Add `intent-register-v1.schema.json`
- [ ] Add `control-directive-v1.schema.json`
- [ ] Add `schedule-control-v1.schema.json`
- [ ] Add `autonomy-budget-v1.schema.json`
- [ ] Add `circuit-breaker-v1.schema.json`
- [ ] Add `subscriptions-v1.schema.json`
- [ ] Add `control-receipt-v1.schema.json`
- [ ] Add `scenario-resolution-v1.schema.json`
- [ ] Update execution and policy v2 contracts as needed

## Runtime And Scheduler

- [ ] Enforce lease requirement for autonomous runs
- [ ] Enforce mission, slice, and intent references
- [ ] Publish forward intent register entries
- [ ] Consume directives
- [ ] Consume schedule control
- [ ] Enforce safe-boundary pause
- [ ] Implement overlap and backfill policies
- [ ] Implement pause-on-failure
- [ ] Derive recovery data from policy/effective route
- [ ] Remove hidden fallback recovery logic

## Trust Tightening And Emergency Paths

- [ ] Aggregate autonomy burn counters from evidence
- [ ] Write autonomy-budget state
- [ ] Trip and reset circuit breakers
- [ ] Enforce safing subset
- [ ] Implement break-glass authorize-update flow
- [ ] Emit control receipts for all control-plane mutations

## Generated Effective And Read Models

- [ ] Materialize `scenario-resolution.yml`
- [ ] Materialize mission `now.md`
- [ ] Materialize mission `next.md`
- [ ] Materialize mission `recent.md`
- [ ] Materialize mission `recover.md`
- [ ] Materialize operator digests
- [ ] Add freshness checks for generated outputs

## Assurance

- [ ] Add schema validation
- [ ] Add contract-registry alignment checks
- [ ] Add scenario conformance suite
- [ ] Add negative suite
- [ ] Add doc-claim alignment checks
- [ ] Add regression tests for `owner_ref`
- [ ] Add control-evidence emission tests

## Pre-Merge Final Review

- [ ] No placeholder-only canonical directories remain
- [ ] No runtime-required mission-control file lacks a schema
- [ ] No generated mission/operator surface is missing
- [ ] No hidden fallback recovery path remains for material work
- [ ] No stale docs claim functionality that is not wired
- [ ] Scenario suite is green
- [ ] Negative suite is green

## Merge And Immediate Verification

- [ ] Merge cutover branch
- [ ] Regenerate effective route and mission/operator summaries
- [ ] Verify at least one control receipt emitted in a sample run
- [ ] Verify at least one breaker trip/reset path in test evidence
- [ ] Verify `0.6.0` release metadata is visible
- [ ] Archive this proposal only after durable surfaces fully replace it

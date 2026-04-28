# Validation Plan

## Structural Validation

- Validate `proposal.yml` and `architecture-proposal.yml` against proposal standards.
- Validate new stewardship schemas.
- Validate root placement against the Octon class-root model.
- Validate no runtime/policy dependency reads from `inputs/**`.
- Validate generated stewardship projections are derived-only.

## Runtime Validation

- `octon steward open` creates or validates program/epoch control without material execution.
- `octon steward observe` normalizes supported triggers.
- `octon steward admit` emits Stewardship Admission Decisions before any mission handoff.
- `octon steward idle` emits a canonical Idle Decision when no admissible work exists.
- `octon steward renew` emits Renewal Decisions only after epoch closeout evidence.
- Handoff to v2 Mission Runner occurs only after admission.
- Stewardship never directly executes material work.

## Gate Validation

- Program Authority Gate blocks missing program authority.
- Epoch Gate blocks work outside active epoch.
- Trigger Gate blocks unrecognized event work.
- Admission Gate blocks mission creation without an admission decision.
- Idle Gate stops work when no admissible work exists.
- Renewal Gate blocks silent authority widening.
- Campaign Gate blocks campaign use unless criteria are met.
- V2 Mission Gate ensures admitted work goes through v2 Mission Runner.
- Run Gate ensures material execution goes through run lifecycle and authorization.

## Evidence Validation

- Trigger evidence retained.
- Admission evidence retained.
- Idle evidence retained.
- Renewal evidence retained.
- Stewardship Ledger traces programs, epochs, triggers, missions, campaigns, and decisions.
- Continuity is updated without becoming authority.

## Consecutive Pass Requirement

Closure requires two consecutive validation passes with no new blocking issues.

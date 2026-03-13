# Capabilities Ops

Cross-lane operational policy assets for capabilities-wide governance.

## Purpose

This directory centralizes deny-by-default controls shared by services and
skills:

- exception leases (`state/deny-by-default-exceptions.yml`)
- canonical v2 policy contract (`policy/deny-by-default.v2.yml`)
- v2 schema and reason taxonomy (`policy/deny-by-default.v2.schema.json`,
  `policy/reason-codes.md`)
- agent-only governance policy (`policy/agent-only-governance.yml`)
- profile bundles (`policy/profiles/*.yml`)
- validation and control-plane entrypoints (`scripts/`)

## Scripts

```bash
.octon/capabilities/_ops/scripts/validate-deny-by-default.sh --changed --profile dev-fast
.octon/capabilities/_ops/scripts/validate-deny-by-default.sh --all --profile strict
.octon/capabilities/_ops/scripts/validate-agent-only-governance.sh
.octon/capabilities/_ops/scripts/policy-profile-resolve.sh refactor
.octon/capabilities/_ops/scripts/policy-grant-broker.sh create --subject service:agent --tier low --request-id req-1 --agent-id agent-a --plan-step-id step-1
.octon/capabilities/_ops/scripts/policy-kill-switch.sh status
.octon/capabilities/_ops/scripts/policy-rollout-mode.sh get
```

## Profiles

- `strict`: full validation (recommended for CI and release gates)
- `dev-fast`: fast local iteration while preserving deny-by-default invariants

## State Model

- `state/grants/`: ephemeral least-privilege grant records
- `state/kill-switches/`: scoped, expiring kill-switch records
- `state/logs/deny-by-default-decisions.jsonl`: structured policy decisions

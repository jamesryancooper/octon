# Phase 6 Change Inventory

## Summary

- Simplified the agency kernel path onto the orchestrator contract.
- Deleted active and scaffolded `SOUL.md` overlays.
- Demoted the agency constitutional shim to a historical, non-required surface.
- Removed autonomy/AI-gate label mirrors from live GitHub workflows and local
  helper scripts.
- Added Phase 6 validation and CI enforcement.

## Orchestrator-Path Simplification

- Updated:
  - `/.octon/instance/ingress/AGENTS.md`
  - `/.octon/framework/agency/{README.md,_meta/architecture/**,governance/**}`
  - `/.octon/framework/agency/runtime/agents/{README.md,orchestrator/AGENT.md,verifier/AGENT.md,_scaffold/template/AGENT.md}`
  - `/.octon/framework/scaffolding/runtime/bootstrap/init-project.sh`
  - `/.octon/framework/scaffolding/runtime/templates/octon/**`
- Deleted:
  - `/.octon/framework/agency/runtime/agents/orchestrator/SOUL.md`
  - `/.octon/framework/agency/runtime/agents/verifier/SOUL.md`
  - `/.octon/framework/agency/runtime/agents/_scaffold/template/SOUL.md`

## Host-Shaped Authority Paths Removed

- Removed autonomy-lane and AI-gate label projections from:
  - `/.github/workflows/ai-review-gate.yml`
  - `/.github/workflows/pr-auto-merge.yml`
- Removed label-lane assumptions from:
  - `/.github/workflows/pr-triage.yml`
  - `/.github/workflows/pr-clean-state-enforcer.yml`
  - `/.github/workflows/pr-stale-close.yml`
  - `/.octon/framework/agency/_ops/scripts/git/git-pr-ship.sh`
  - `/.octon/framework/agency/_ops/scripts/ai-gate/aggregate-decision.sh`
  - `/.octon/framework/agency/_ops/scripts/github/sync-github-labels.sh`
  - `/.octon/framework/agency/_ops/scripts/validate/validate-autonomy-labels.sh`

## Phase 6 Exit Status

- Orchestrator is the kernel execution profile: satisfied by ingress, agency
  README/spec, validator checks, and active agent contracts.
- Persona-heavy surfaces are optional overlays only: satisfied by deleting
  active/scaffolded `SOUL.md` files and removing them from the required path.
- At least one host-shaped authority path is deleted: satisfied by removing
  autonomy/AI-gate label mirrors from the live GitHub control plane.

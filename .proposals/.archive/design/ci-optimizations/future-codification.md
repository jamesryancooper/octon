# Future CI Optimization Codification

This defines how to prevent CI-cost regressions when new workflows are introduced.

## Objective

Ensure all future PR-triggered workflows are efficient by default while preserving required governance outcomes.

## Required additions

1. Add `.github/workflows/ci-efficiency-guard.yml`
   - Source template: `.proposals/ci-optimizations/codification/ci-efficiency-guard.yml`
2. Add `.github/scripts/ci-efficiency-guard.sh`
   - Source template: `.proposals/ci-optimizations/codification/ci-efficiency-guard.sh`

## Enforced policy

- PR-triggered workflows require top-level `concurrency`.
- PR-triggered workflows require `timeout-minutes`.
- Workflows with both PR and push triggers must scope push branches/tags.
- Schedule frequencies under hourly are rejected unless explicitly allowlisted.

## Rollout steps

1. Copy the two codification files into `.github/`.
2. Add execute permission for `.github/scripts/ci-efficiency-guard.sh`.
3. Make `CI Efficiency Guard / enforce-ci-efficiency-policy` a required check for PRs that touch `.github/workflows/**`.
4. Track violations for 1 week in advisory mode if desired, then enforce hard-fail.

## Why this matters

Without codification, optimization drift will recur as new workflows are added by agents over time, reintroducing duplicate triggers and cost spikes.


---
title: Behavior Phases
description: Phase-by-phase instructions for deploy-status.
---

# Behavior Phases

## Phase 1: Pre-flight

**Goal:** Confirm status checks can run safely.

1. Verify `vercel` CLI is installed (`vercel --version`).
2. Confirm auth/link context is available for target project.
3. Resolve inspection target from parameters (`project`, `deployment`, `environment`).
4. Stop with escalation guidance if prerequisites fail.

## Phase 2: Status Collection

**Goal:** Collect authoritative deployment state.

1. Run scoped Vercel status command(s) for the target.
2. Extract deployment URL, state, and updated timestamp when available.
3. Normalize state labels to `ready`, `building`, `queued`, `error`, or `unknown`.
4. Record raw evidence used for the final determination.

## Phase 3: Verification

**Goal:** Validate external availability signal.

1. If `check_url=true` and URL exists, perform lightweight reachability check.
2. Capture response code and latency bucket (fast/slow/timeout).
3. If URL probe conflicts with CLI state, mark readiness as degraded and explain why.

## Phase 4: Report

**Goal:** Produce a decision-ready output.

1. Write readiness report to `.harmony/output/reports/analysis/`.
2. Write run log to `_ops/state/logs/deploy-status/{{run_id}}.md`.
3. Return external output metadata (deployment URL + normalized state) in the response.

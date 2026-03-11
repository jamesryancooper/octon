# Phase 6 Completion Receipt: Event-Driven Scale Surfaces

- Date: `2026-03-10`
- Package path: `.design-packages/orchestration-domain-design-package`
- Parent plan: `.harmony/output/plans/2026-03-10-orchestration-domain-end-to-end-build-plan.md`

## Scope Completed

Phase 6 completed the event-driven scale surfaces needed to make the watcher and
queue path deterministic, bounded, and testable.

## Implemented Changes

### Routing Semantics

- strengthened `.harmony/orchestration/runtime/_ops/scripts/route-watcher-event.sh`
  so it now supports:
  - lexical fan-out ordering by `automation_id`
  - target-hint intersection behavior
  - severity-threshold filtering
  - `source_ref_globs` filtering
  - `match_mode=all|any`
  - dedupe suppression when a matching queue item, decision, or run already
    exists for an automation and event

### Event Surface

- strengthened `.harmony/orchestration/runtime/_ops/scripts/emit-watcher-event.sh`
  so target automation hints can be overridden or omitted for testable routing
  scenarios

### Queue Correctness

- existing queue manager behavior now has direct regression coverage for:
  - stale-ack rejection
  - receipt creation for rejected acknowledgements
  - retry/dead-letter transition on claim expiry

### Validation And Test Coverage

- added `.harmony/orchestration/runtime/_ops/tests/test-watcher-routing-and-queue.sh`
- updated `.harmony/orchestration/runtime/_ops/scripts/validate-orchestration-runtime.sh`
  to execute that routing and queue suite alongside the existing primitive,
  first-slice, and automation-policy suites

## Exit Criteria Check

### 1. Watchers cannot launch workflows directly

- Status: `complete`
- Evidence:
  - routing remains watcher event -> queue item -> automation admission
  - no watcher-side script invokes workflow launch directly

### 2. Queue remains automation-ingress only

- Status: `complete`
- Evidence:
  - queue items still require `target_automation_id`
  - queue tests and routing scripts never target missions directly

### 3. Routing determinism is implemented

- Status: `complete`
- Evidence:
  - fan-out order is lexical
  - target-hint misses block queue creation
  - dedupe suppresses second route attempts
  - `match_mode=any` admits when any selector family matches
  - `source_ref_globs` affect routing decisions

### 4. Queue correctness is implemented

- Status: `complete`
- Evidence:
  - stale ack with the wrong `claim_token` is rejected
  - rejection writes a queue receipt
  - expired claims can move to retry or dead-letter according to `max_attempts`

## Validation Receipt

Commands run successfully during Phase 6:

- `bash -n .harmony/orchestration/runtime/_ops/scripts/emit-watcher-event.sh`
- `bash -n .harmony/orchestration/runtime/_ops/scripts/route-watcher-event.sh`
- `bash -n .harmony/orchestration/runtime/_ops/tests/test-watcher-routing-and-queue.sh`
- `bash .harmony/orchestration/runtime/_ops/tests/test-watcher-routing-and-queue.sh`
- `bash .harmony/orchestration/runtime/_ops/tests/test-automation-policy-and-scheduling.sh`
- `bash .harmony/orchestration/runtime/_ops/scripts/validate-orchestration-runtime.sh`
- `bash .harmony/assurance/runtime/_ops/scripts/validate-orchestration-design-package.sh`
- `git diff --check`

## Phase 6 Verdict

Phase 6 is complete.

The watcher and queue scale surfaces now have deterministic routing behavior,
correct queue lease handling, and explicit regression coverage for the core
event-driven path.

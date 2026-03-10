# Conformance

## Purpose

This module contains the behavioral proof layer for the orchestration design
package.

The package remains implementation-ready only when both of these are true:

- static contract validation passes
- semantic conformance scenarios pass

This module is package-local. It does not claim live `.harmony/orchestration`
adoption safety.

## Scenario Contract

Every scenario file under `conformance/scenarios/` is machine-readable JSON and
must declare:

- `scenario_id`
- `suite`
- `description`
- `expected`

Supported suites:

- `routing`
- `scheduling`
- `recovery`

### Routing Scenarios

Routing scenarios define:

- one canonical watcher `event`
- one or more candidate `automations`
- optional `dedupe_hits`
- expected matched and suppressed automation ids

The evaluator proves:

- severity threshold ordering
- `source_ref_globs` matching
- `match_mode=all|any`
- target-hint intersection behavior
- deterministic lexical fan-out ordering
- dedupe suppression

### Scheduling Scenarios

Scheduling scenarios define:

- one `schedule`
- one `transition` describing the local clock anomaly being exercised
- expected resolved local behavior

The evaluator proves:

- spring-forward resolves to the next valid minute on the same local date
- fall-back creates one schedule window and uses the first occurrence only

### Recovery Scenarios

Recovery scenarios define:

- one active `run`
- one set of liveness `signals`
- the expected recovery outcome

The evaluator proves:

- same-executor resume is the only resume path in v1
- abandonment is the fallback when safe resume is not available
- no new side effects are permitted while a run remains unrecovered or
  abandoned

## Validation

Semantic evaluation is implemented by:

- `conformance/validate_scenarios.py`

Static package validation is implemented by:

- `/.harmony/assurance/runtime/_ops/scripts/validate-orchestration-design-package.sh`

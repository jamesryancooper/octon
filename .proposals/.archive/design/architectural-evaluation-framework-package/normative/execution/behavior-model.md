# Behavior Model

## Purpose

Define the execution lifecycle, state transitions, and deterministic rules for
the future architecture-readiness audit capability.

## Lifecycle

1. `configure`
   - capture target path, thresholds, and optional supplemental audit toggles
2. `classify-target`
   - resolve `whole-harmony`, `bounded-surface-domain`, or unsupported profile
3. `applicability-gate`
   - continue only for supported target classes
4. `collect-evidence`
   - read local architecture, governance, runtime, and assurance artifacts
5. `score-dimensions`
   - apply the readiness framework to the supported scope
6. `analyze-failure-modes`
   - assess resistance, weakness, consequence, and remediation
7. `plan-remediation`
   - identify exact durable artifacts to create or update
8. `emit-report`
   - write the final report, summary data, and bundle outputs

## Critical Rules

- Target classification must happen before scoring.
- Unsupported targets must be rejected or reported as `not-applicable`; they
  must not be force-fit into the scorecard.
- Whole-harness mode may invoke supplemental audits, but the final readiness
  verdict belongs to the architecture-readiness capability.
- Bounded-domain mode must operate only on top-level bounded-surface domains.
- Surface-only targets route elsewhere and do not use this framework as the
  primary evaluator.
- Remediation outputs must point to durable Harmony paths outside
  `/.design-packages/`.

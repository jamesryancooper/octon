# ADR 080: Unified Execution Constitution Phase 4 Proof Evaluation And Lab Expansion

- Date: 2026-03-29
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-29-unified-execution-constitution-phase4-proof-evaluation-lab-expansion/plan.md`
  - `/.octon/state/evidence/migration/2026-03-29-unified-execution-constitution-phase4-proof-evaluation-lab-expansion/`
  - `/.octon/inputs/exploratory/proposals/architecture/octon-unified-execution-constitution-cutover/`

## Context

After Phase 3, the runtime/evidence model was normalized, but Phase 4 remained
thin in four places the packet and audit both called out:

- functional, behavioral, maintainability, and recovery planes were mostly
  README-level rather than suite-enforced
- the lab domain still lacked substantive top-level scenario/replay/shadow/fault
  authored roots
- retained lab evidence did not yet exercise replay/shadow/fault interfaces in
  one supported tier
- provider reviews still ran as provider-specific workflow branches instead of
  evaluator adapters

## Decision

Execute Phase 4 as an atomic proof-plane, lab, and evaluator-adapter cutover.

Rules:

1. Structural and governance gates remain blocking.
2. Functional, behavioral, maintainability, and recovery planes must have real
   authored suites and validator-backed enforcement.
3. `framework/lab/{scenarios,replay,shadow,faults}` must exist as substantive
   authored domains.
4. At least one supported tier must retain behavioral and recovery evidence
   backed by scenario/replay/shadow/fault lab artifacts.
5. Provider reviews must route through evaluator adapter manifests and a
   generic evaluator adapter runner.

## Consequences

### Benefits

- Proof planes now have enforceable authored suites instead of only schema and
  placeholder prose.
- The lab domain is visibly real in both authored and retained evidence
  surfaces.
- Evaluator logic is provider-agnostic at the workflow boundary.

### Costs

- CI and retained sample evidence both become richer and more explicit.
- The AI review gate gains an additional evaluator-adapter abstraction layer.

## Completion

This decision is complete once:

- all proof planes exist with authored suites and enforcement
- structural/governance remain blocking
- a supported tier carries substantive behavioral and recovery evidence
- lab scenario/replay/shadow/fault domains exist in substance
- provider reviews execute through evaluator adapters

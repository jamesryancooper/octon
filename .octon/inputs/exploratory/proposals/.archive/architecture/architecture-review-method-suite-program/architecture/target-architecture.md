# Target Architecture (Program Level)

The program's target state is coordination-complete, not implementation:
every registry child either closed through its own governed lifecycle,
superseded, rejected with rationale, or (command-facades only) recorded
no-action.

When all required children close, the Architectural Review Mechanism carries
an explicit method layer:

- `architecture-lens-bank-foundation` → one shared lens bank
  (`architecture-lens-bank.md` + `lens-bank.yml`) with 18 tiered lenses,
  per-method profiles, sprawl controls, and a lens-reference validator.
- `architecture-review-method-taxonomy-and-routing` → naming v2 (methods
  list, Balanced default) and routing v2 (method-selection semantics,
  fail-closed on unknown method) with validator coverage.
- `greenfield-reference-architecture-review-method` → Greenfield Reference
  Architecture Review as a first-class method whose output is
  reference architecture only.
- `companion-architecture-review-methods` → Tradeoff, Failure-Mode,
  Evolution/Fitness, and Boundary/Authority reviews as distinct, callable
  methods with explicit boundaries against readiness and surface-audit
  doctrine.
- `architectural-review-schema-extensions` → report and routing-decision
  schema v2 recording method and lenses applied; support receipt unchanged.
- `architectural-review-suite-integration` → method-id recording in review
  workflow evidence, navigation-only feature/mechanism notes, advisory
  lifecycle text, refreshed derived-only projections, green validator sweep.
- `architecture-review-command-facades` → facades exist only if demanded,
  else a recorded no-action.

Program-level invariants: Balanced Architecture Review remains the default
method; review outputs remain evidence or proposal input; the
pre-integration support receipt remains the only lifecycle-gating review
artifact; no new mechanism, routed workflow mode, or gate; readiness and
surface-audit doctrine untouched; generated outputs derived-only; children
stay in declared write scopes; parent evidence never substitutes for child
evidence.

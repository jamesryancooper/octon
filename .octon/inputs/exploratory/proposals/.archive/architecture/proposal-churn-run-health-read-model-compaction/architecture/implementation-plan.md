# Implementation Plan

Implementation is not authorized by this proposal packet.

When authorized, this child should:

1. Baseline current run-health generated file count and no-op rewrite rate.
2. Inventory every consumer of generated run-health projections, especially consumers that expect per-run `health.yml`.
3. Add fixtures for changed-run-only generation.
4. Refactor the generator to skip unchanged outputs and emit compact indexes.
5. Add migration or compatibility handling for any affected consumers.
6. Update validation to prove freshness and traceability for compact outputs.
7. Run test hermeticity gates from the existing dependency packet.
8. Record drift/churn evidence proving no-op generation is quiet.

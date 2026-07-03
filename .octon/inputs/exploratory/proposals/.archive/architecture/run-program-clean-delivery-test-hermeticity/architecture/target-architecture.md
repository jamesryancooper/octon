# Target Architecture

Hygiene and run-health read-model tests write only to temporary or fixture-owned locations and never mutate tracked generated health projections. Generator behavior remains covered by tests, but test execution is hermetic with respect to `.octon/generated/cognition/projections/materialized/runs`.

Final validation can therefore include a post-test `git status --short -- .octon/generated/cognition/projections/materialized/runs` check as meaningful hygiene evidence.

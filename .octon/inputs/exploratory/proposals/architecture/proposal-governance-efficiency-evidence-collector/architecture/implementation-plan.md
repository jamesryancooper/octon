# Implementation Plan

1. Identify retained evidence files and fields needed by the report contract.
2. Add a read-only collector that parses those files and emits normalized facts.
3. Add fixtures for complete, partial, stale, missing, and contradictory evidence.
4. Add write-safety tests proving the collector does not mutate repository, state, generated, or git surfaces.

Scoring and operator exposure are owned by later children.

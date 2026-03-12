# Filesystem Graph Phase 0 Baseline

Date: 2026-02-15

## Scope

Baseline for introducing a native-first filesystem + graph service contract.

## Deliverables Completed

1. Added context contract:
- `.harmony/cognition/context/filesystem-graph-interop.md`

2. Added ADR:
- `.harmony/cognition/decisions/013-filesystem-graph-native-first.md`

3. Added execution plan artifact:
- `.harmony/output/plans/2026-02-15-filesystem-graph-native-first-execution-plan.md`

## Baseline Assertions

1. Files remain canonical source-of-truth.
2. Graph remains derived from snapshots.
3. Core filesystem-graph semantics remain provider-agnostic.
4. Fail-closed behavior is required for invalid snapshot/path/policy conditions.

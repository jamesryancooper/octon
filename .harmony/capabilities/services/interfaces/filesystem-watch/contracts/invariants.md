# Invariants

1. Watch polling is deterministic for identical filesystem state.
2. Event ordering is stable and lexicographically sorted by path.
3. Volatile runtime and VCS paths are excluded by default.
4. Watch operations enforce bounded max file and max event limits.
5. Watch state writes are scoped to explicit state keys.

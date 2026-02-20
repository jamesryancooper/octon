# Guard Invariants

1. Given identical `content` and `options`, `check` output remains deterministic.
2. `summary.totalChecks` equals the length of `checks`.
3. `summary.failedChecks` equals the number of `checks` entries where `passed=false`.
4. `passed=false` when any enabled check fails.
5. `sanitized` is emitted only when redaction changes output content.

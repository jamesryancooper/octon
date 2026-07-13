# Rollback Plan

RP-14 has no runtime cutover to reverse. If proof execution or the claim map is
wrong, quarantine the affected RP-14 evidence generation, preserve raw inputs,
invalidate only dependent claim conclusions, and rerun from the last frozen
protocol. Never rewrite measurements or silently omit failures.

If an integrated feature fails, the owning child disables or rolls back that
feature and preserves candidate work; RP-14 records demotion and keeps the lower
safe state. Promotion handoff is withdrawn until fresh exact-commit proof passes.

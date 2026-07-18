# Rollback Plan

RP-14 has no runtime cutover to reverse. If proof execution or the claim map is
wrong, quarantine the affected RP-14 evidence generation, preserve raw inputs,
invalidate only dependent claim conclusions, and rerun from the last frozen
protocol with a new generation ordinal and run ID. Never rewrite measurements,
delete a failed/stale generation, reuse its identity, or silently omit failures.

An incomplete generation never writes `generation-complete.yml` or advances the
generation index. If the final expected-old index update loses its race, retain
the complete unindexed generation as non-current evidence and rerun allocation;
do not overwrite the winning generation. Provider or implementation drift marks
only attributable claims stale and withdraws their handoff without mutating the
proof subject or downstream authority.

If an integrated feature fails, the owning child disables or rolls back that
feature and preserves candidate work; RP-14 records demotion and keeps the lower
safe state. Promotion handoff is withdrawn until fresh exact-commit proof passes.

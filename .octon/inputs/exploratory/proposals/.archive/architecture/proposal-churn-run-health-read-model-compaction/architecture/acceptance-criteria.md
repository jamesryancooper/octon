# Acceptance Criteria

- No-op run-health generation creates zero tracked diffs.
- A single changed run does not rewrite unrelated retained run projections.
- Compact indexes preserve operator visibility and source traceability.
- Consumers that expect per-run `health.yml` are inventoried and either migrated or served by a validated compatibility projection.
- Run-health validation and negative controls still fail closed on stale or malformed projections.
- No retained run evidence is deleted.

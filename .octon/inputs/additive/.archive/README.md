# Additive Input Archive

`inputs/additive/.archive/<intake-id>/` stores retained additive intake only
when keeping the historical copy is safe, justified, and evidenced.

Allowed contents are rejected, superseded, blocked, quarantined, or historical
intake units that still need non-authoritative retention. Prohibited contents
include live runtime dependencies, policy sources, active extension state,
generated outputs, publication authority, host projections, and retained
evidence records.

Lifecycle:

1. Archive only after classification or disposition.
2. Record archive-retention evidence under `state/evidence/**`.
3. Keep the archive non-authoritative or remove it when retention is no longer
   justified.

Authority status: non-authoritative historical input only.

Validator coverage:

- `/.octon/framework/assurance/runtime/_ops/scripts/validate-input-archive-retention.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh`

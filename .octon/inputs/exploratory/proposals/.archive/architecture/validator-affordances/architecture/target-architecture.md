# Target Architecture

Affected validators emit structured recovery diagnostics with:

- `recovery_class`;
- `failing_path`;
- `observed_value`;
- `accepted_values` when applicable;
- `stale_source_ref` and `expected_digest` when applicable;
- `minimal_repair_hint`;
- `rerun_gate`;
- `hard_blocker_reason` when autonomous repair is forbidden.

Diagnostics stay compact and do not include full repeated logs unless required
for retained evidence.

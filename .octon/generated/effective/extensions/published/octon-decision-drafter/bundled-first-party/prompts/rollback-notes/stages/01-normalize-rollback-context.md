# Normalize Rollback Context

Normalize rollback context and retained grounding.

## Do

1. Confirm that exactly one diff source is present.
2. Normalize `changed_paths`.
3. Resolve `rollback_posture_ref` or `run_contract_ref` when present.
4. Gather retained control evidence relevant to reversibility, rollback
   strategy, contamination, or recovery windows.
5. Record the narrative target surface if the operator supplied one.

## Stop When

- the diff source is missing or ambiguous
- rollback claims would rely on unsupported guesses instead of retained
  evidence
- the request would require edits to rollback truth or other control files

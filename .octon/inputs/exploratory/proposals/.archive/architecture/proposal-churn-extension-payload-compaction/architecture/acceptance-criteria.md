# Acceptance Criteria

- No-op extension publication creates zero copied payload diffs.
- Changed extension inputs update only required generated/effective extension outputs.
- Publication and compatibility receipts remain linked and retrievable.
- Freshness validation still fails closed for stale or malformed extension state.
- Extension source and input surfaces are not treated as cleanup residue.

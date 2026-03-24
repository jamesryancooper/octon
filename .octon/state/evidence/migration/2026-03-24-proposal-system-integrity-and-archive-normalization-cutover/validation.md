# Validation

- [x] Kernel workflow runner compiles with the proposal-registry generator and
  new lifecycle operations.
- [x] Proposal standard validation covers lifecycle structure, generated
  artifact-catalog freshness, and registry drift.
- [x] Deterministic registry generation rejects orphaned/manual entries,
  invalid archive lineage, and path/status mismatches.
- [x] Workflow contracts exist for `validate-proposal`, `promote-proposal`,
  and `archive-proposal`.
- [x] Broken archived architecture packets were normalized into validator-clean
  archive state.

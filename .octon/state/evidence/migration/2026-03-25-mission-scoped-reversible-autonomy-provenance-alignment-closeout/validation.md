# Validation

- [x] Archived MSRAOM steady-state proposal package passes
      `validate-architecture-proposal.sh`.
- [x] Archived MSRAOM final-closeout proposal package passes
      `validate-architecture-proposal.sh`.
- [x] Archived MSRAOM provenance-alignment proposal package passes
      `validate-architecture-proposal.sh`.
- [x] `validate-proposal-standard.sh --all-standard-proposals --skip-registry-check`
      passes.
- [x] `generate-proposal-registry.sh --write` completes successfully.
- [x] `generate-proposal-registry.sh --check` passes.
- [x] `validate-proposal-standard.sh --all-standard-proposals` passes with
      non-blocking warnings from pre-existing legacy/archive inventory gaps.
- [x] `validate-version-parity.sh` passes at `0.6.3`.
- [x] `validate-architecture-conformance.sh` passes.
- [x] `alignment-check.sh --profile harness,mission-autonomy` passes.
- [x] Archived MSRAOM proposal packets are no longer matched by the
      `/.octon/inputs/exploratory/proposals/.archive/**` ignore rule.
- [x] ADR 066 and ADR 067 no longer point at deleted active proposal paths.

## Notes

- The full proposal-standard run completed with warnings from pre-existing
  legacy archived design packages and a few archived artifact catalogs that do
  not enumerate every visible file. These warnings were non-blocking and did
  not affect the MSRAOM provenance cutover.
- The combined `harness,mission-autonomy` alignment profile completed with
  non-blocking warnings for empty retained run directories and allowlisted
  historical framing tokens in older cognition decisions.

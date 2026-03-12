# Baseline capture notes

Required command executed:

- `bash .proposals/ci-optimizations/scripts/collect-actions-baseline.sh --days 30`

Observed defects in the collector script under current gh CLI behavior:

1. `gh api` with `-f` defaults to POST (causing 404 on `/actions/runs` list endpoint without `--method GET`).
2. workflow summary jq expression precedence emits header then errors (`Cannot index string with string "workflow"`).

Resulting baseline artifacts were completed using the successfully captured `runs.ndjson` from the same run and corrected aggregation commands.

Baseline directory:

- `.proposals/ci-optimizations/baseline/20260304T215613Z`

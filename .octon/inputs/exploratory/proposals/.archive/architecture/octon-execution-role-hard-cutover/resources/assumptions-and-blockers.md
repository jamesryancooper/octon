# Assumptions and Blockers

## Assumptions

1. Octon accepts a clean-break cutover and no legacy agency compatibility.
2. The public `main` branch reflects the live target implementation baseline.
3. Promotion will occur in one coherent change set.
4. Whole-repo validation and grep can be run by the implementation environment.
5. Runtime services for browser/API are either built before live support or excluded from live support.

## Blockers to resolve in implementation

### B1 — Support mode vocabulary alignment

`support-targets.yml` uses `bounded-admitted-finite`, while `charter.yml` uses
`bounded-admitted-finite-product`. The final target must use one schema-valid
mode or update the schema with a precise meaning. This packet recommends
`bounded-admitted-finite`.

### B2 — Browser/API runtime service reality

Browser/API support cannot be live until runtime services and proof exist. If
services are not implemented in the cutover, the live claims must be removed.

### B3 — Workflow reduction classification

Every workflow must be classified as governance-critical or removed/demoted.
This is a required implementation task, not an optional later cleanup.

### B4 — Exact generated/proposal registry refresh

Generated proposal registry refresh is not authored authority, but implementation
must regenerate it after manifests land.

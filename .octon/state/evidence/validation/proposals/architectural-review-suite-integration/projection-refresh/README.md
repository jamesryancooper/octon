# Projection refresh evidence — architectural-review-suite-integration

Derived-only refresh of affected generated projections via canonical publishers
(executable-implementation-prompt.md §4e / §5b). No `.octon/generated/**` path is
a direct write target; each file below is regenerated only by its canonical
publisher and proven fresh via that publisher's `--check`.

## Affected-projection determination

Grep of `.octon/generated/**` for the surfaces this child changed
(`method_selection_record`, `architectural-review-routing-decision-v2`,
`architectural-review-report-v2`, `method_selection`) matched only
proposal-registry / per-proposal artifact-index files — nothing under
`.octon/generated/effective/**`.

| Canonical publisher | Projection | Indexes this child's surfaces? | Action |
| --- | --- | --- | --- |
| `generate-proposal-registry.sh` | `.octon/generated/proposals/registry.yml` | Yes (packet summary + status) | Refresh `--write`, prove `--check` fresh |
| `generate-proposal-artifact-index.sh --proposal <this packet>` | `.octon/generated/proposals/artifacts/architecture/architectural-review-suite-integration/*` | Yes (per-packet index) | Already fresh — raw log retained at `.octon/state/evidence/runs/workflows/20260709-arms-program-clean-delivery-04/children/architectural-review-suite-integration/promotion-raw/artifact-index-check-before.txt` (errors=0, all digests fresh) |
| `generate-runtime-effective-route-bundle.sh` | `.octon/generated/effective/runtime/route-bundle.yml` | **No** — route bundle inputs are the workflow manifest + effective capability/extension/routing projections; it does not index the architectural-review `review-routing.yml` `method_selection` block or the per-workflow `*_method_selection_record` artifacts | No refresh forced (per §5b "record no generated surface indexes these files") |

## Files

- `registry-check-before.txt` — `generate-proposal-registry.sh --check` before refresh.
- `registry-write.txt` — `generate-proposal-registry.sh --write` refresh run.
- `registry-check-after.txt` — `generate-proposal-registry.sh --check` post-refresh (fresh).
- `.octon/state/evidence/runs/workflows/20260709-arms-program-clean-delivery-04/children/architectural-review-suite-integration/promotion-raw/artifact-index-check-before.txt` — per-packet artifact index already fresh; raw proposal-bound output is retained outside the promotion target.

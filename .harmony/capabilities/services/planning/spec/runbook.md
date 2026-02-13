# Spec — Operations Runbook (1 page)

## SLOs & Alerts

- Availability (HTTP wrapper): 99.9%
- p95 latency: validate <= 300ms; render <= 1000ms
- Burn-rate alerts: error budget > 2% over 1h; alert on 5xx > 1% of requests

## Validate (Preview or Prod)

- [ ] Healthcheck returns 200 (if HTTP exposed)
- [ ] `/v1/speckit/*` happy paths pass with example payloads
- [ ] Logs/metrics/traces present and sane; trace IDs correlate with `run_id`
- [ ] `speckit validate` passes for `docs/specs/*/spec.md`

## Rollback

- Command: `vercel promote <deployment-url>` (or your platform equivalent)
- Fallback: disable `flag.speckit`

## Artifacts / Snapshots

- Rebuild: run `speckit init` to regenerate missing scaffold files (non-destructive)
- Promote/Publish: use Doc to publish docs; record `manifest_uri`
- Verify: check `schema_version`, checksums, and OpenAPI version in `manifest.json` (if used)

## Common Issues

- 4xx spikes → invalid structure; run `specify check` and verify `.specify/` + `specs/<NNN>-<feature>/` layout
- 404s → wrong `path` or missing feature dir; ensure `/speckit.specify` ran
- 5xx spikes → check upstream filesystem/permissions; backoff retries on `Transient`
- Latency regressions → large repos; enable caching and limit diagram rendering

## Postmortem (blameless)

- Owner: Spec maintainers
- Timeline: `<UTC times>`
- Impact: `<teams blocked, PRs affected>`
- What worked / what didn’t: `<bullets>`
- Follow-ups: add negative tests from STRIDE; consider strict mode by default

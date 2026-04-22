# Closure Certification Plan

## Required retained closure evidence

| Evidence | Target root |
|---|---|
| Architecture transition manifest | `.octon/state/evidence/validation/architecture/10of10-target-transition/manifest.yml` |
| Validator transcript bundle | `.octon/state/evidence/validation/architecture/10of10-target-transition/validators/**` |
| Runtime authorization negative-control results | `.octon/state/evidence/validation/architecture/10of10-target-transition/authorization-boundary/**` |
| Publication freshness receipt | `.octon/state/evidence/validation/architecture/10of10-target-transition/publication/freshness.yml` |
| Support path normalization receipt | `.octon/state/evidence/validation/architecture/10of10-target-transition/support-targets/path-normalization.yml` |
| Support proof refresh receipt | `.octon/state/evidence/validation/architecture/10of10-target-transition/support-targets/proof-refresh.yml` |
| Pack route no-widening receipt | `.octon/state/evidence/validation/architecture/10of10-target-transition/capabilities/pack-route-no-widening.yml` |
| Extension compaction receipt | `.octon/state/evidence/validation/architecture/10of10-target-transition/extensions/active-state-compaction.yml` |
| Operator view generation receipt | `.octon/state/evidence/validation/architecture/10of10-target-transition/operator-views/generation.yml` |
| Final closure certification | `.octon/state/evidence/validation/architecture/10of10-target-transition/closure-certification.yml` |

## Closure rule

Closure may be claimed only when:

1. all validators pass,
2. all generated/effective outputs are current,
3. runtime hard-gates stale generated/effective access,
4. support and pack routes do not widen live claims,
5. extensions cannot activate without publication and compatibility receipts,
6. transitional shims are retired or registered with owners and dates,
7. no durable promoted target retains a proposal-path dependency.

## Final disclosure wording

The final closure disclosure must say that the target-state architecture is landed only for the
bounded live support universe declared in `support-targets.yml`. It must exclude stage-only,
unadmitted, unsupported, and retired surfaces from live claims.

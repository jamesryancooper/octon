# Risk Register

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Terminal proof becomes a second closeout authority. | Authority drift and false cleaned claims. | Schemas and validators classify proof bundles as evidence-only and require underlying receipts. |
| Scoped child validation hides unrelated registry drift. | Generated proposal registry may become stale. | Require one program-level registry freshness check before scoped child validation can pass. |
| Correction aggregate receipt replaces branch landing authorization. | Hosted branch-no-pr safety controls weaken. | Validator requires existing landing and cleanup authorization refs and rejects aggregate-only authorization. |
| New validators add runtime cost without reducing late drift. | Lifecycle remains expensive. | Scope terminal child validation to declared child sets and retain broad checks only where they prove distinct risk. |
| Compact logs obscure failures. | Operators miss actionable validator output. | Compact logs must include exit code, command, digest, bounded excerpts, and full-log ref when present. |
| Runtime resolution guidance becomes a waiver path. | Failed validators may be skipped. | Guidance requires resolving canonical invocation before waiver and does not permit gate weakening. |
| Terminal current-state proof leaks local-private evidence. | Hosted/shared closeout evidence may expose local paths. | Use publishable evidence summaries for hosted/shared claims and retain raw local details only where policy allows. |

# Risk Register

| Risk | Description | Likelihood | Impact | Mitigation |
|---|---|---:|---:|---|
| Validator false positives | New validators may reject legitimate runs before emitters are aligned | medium | medium | land additive schema changes and emitter alignment before hard-fail CI |
| Schema drift across request / grant / receipt | Field names may diverge across touched files | medium | high | freeze naming in Phase 0 and test with fixtures |
| Overlay-only pseudo-coverage | Team may be tempted to stop after policy/budget edits | high | high | keep Preferred Change Path explicit and reject fallback as default |
| Support-target confusion | Reviewers may mistake pack normalization for support widening | low | high | repeat non-widening posture in every packet and decision artifact |
| Evidence gaps | Enriched fields may exist in schema but not in retained samples | medium | high | make evidence retention part of acceptance criteria |
| Active packet overlap | Reviewers may try to fold this into the bounded UEC packet | medium | medium | retain sibling-packet rationale in README and baseline audit |

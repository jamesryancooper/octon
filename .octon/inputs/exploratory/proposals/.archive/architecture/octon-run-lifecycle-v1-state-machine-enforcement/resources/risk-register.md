# Risk Register

| Risk | Impact | Likelihood | Mitigation |
|---|---:|---:|---|
| Transition gate blocks valid runs due to incomplete state mapping | High | Medium | Start with report-only validator, fixture matrix, and staged blocking mode. |
| Runtime-state reconstruction differs from current runtime behavior | High | Medium | Treat journal as source of truth; add compatibility handling for legacy runs. |
| Lifecycle logic duplicates across modules | Medium | Medium | Centralize transition table and reconstruction in one runtime module. |
| Generated read models become accidental lifecycle authority | High | Medium | Add negative tests and source-ref checks. |
| Closeout gate too strict for existing historical runs | Medium | Medium | Apply blocking only to new consequential Runs; mark historical runs legacy unless reconstructed. |
| Token verification and lifecycle validation race | High | Low/Medium | Verify journal head before token consumption; journal token lifecycle events atomically. |
| Replay attempts to repeat live side effects | High | Low/Medium | Default replay to dry-run/sandbox; live replay requires fresh authorization and lifecycle gate. |
| Proposal packet treated as runtime authority | Medium | Low | Non-authority notices and promotion targets outside proposal tree. |
| Support-target claims unintentionally widened | High | Low | No support-target expansion; proof only narrows/validates existing claims. |

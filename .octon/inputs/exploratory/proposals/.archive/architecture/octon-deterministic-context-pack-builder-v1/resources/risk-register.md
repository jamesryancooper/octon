# Risk Register

| Risk | Likelihood | Impact | Mitigation |
|---|---:|---:|---|
| Schema strengthening becomes breaking in unexpected consumers | medium | medium-high | keep changes additive where possible; locate emitters before hard enforcement |
| Builder receipt duplicates existing evidence badly | medium | medium | keep receipt narrowly focused on builder proof and model-visible hash |
| Repo-local context policy becomes too broad or vague | medium | high | constrain to concrete QoS, trust, freshness, and omission rules |
| Validator becomes noisy or brittle | medium | high | ship deterministic fixtures and narrow false-positive surface before blocking CI |
| Support-target edits accidentally imply support-universe widening | low-medium | high | keep required-evidence strengthening narrow and do not change tuples or default routes |
| Generated summaries creep into runtime authority | low-medium | high | explicit validator checks and rejection rules |
| Runtime code landing zones differ from current README assumptions | medium | low-medium | treat README-derived code paths as likely landing zones, not immutable facts |
| Replay cannot reconstruct model-visible hash | low-medium | high | hash retained `model-visible-context.json` bytes directly; require receipt replay refs and negative replay-mismatch fixtures |
| Canonical journal accidentally records dot-named context events | low-medium | high | extend `run-event-v2`, alias maps, validator checks, and Rust tests so canonical writers emit only `context-pack-*` event names |

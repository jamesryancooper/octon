## Summary

Describe the intent and scope of this change in 2–3 sentences.

## Risk rubric

- Risk class: [ ] Trivial [ ] Low [ ] Medium [ ] High
- Rollback plan: (how to restore prior state; include `vercel promote <preview-url>` if applicable)
- Flags changed: name(s) • owner • expiry • rollout plan
  - Example: `enableNewNav` • @owner • 2025-12-31 • internal → 10% → 100%

## Contracts & Threat model

- OpenAPI/JSON‑Schema changes: link or note “none”
- Threat model link (STRIDE): link or note “none”

## Observability & Performance

- Traces/logs for changed flows: link or note “n/a”
- For High risk: representative trace link(s):
- Perf/Bundle impact (if any):

## License & Provenance

- New dependencies and licenses (MIT/BSD/Apache only; avoid GPL):
- Provenance notes (generated code/templates):

## Checklist (Definition of Safe)

- [ ] License and provenance reviewed; no policy‑blocked licenses
- [ ] Secrets absent; CSP/CSRF/SSRF defenses maintained
- [ ] Rollback path validated; feature flagged and default OFF
- [ ] Preview e2e smoke green; SLOs unaffected or improved
- [ ] Observability present: trace/log IDs for changed paths
- [ ] OpenAPI diff (oasdiff) checked; consumers unaffected or approved
- [ ] Risk class acknowledged; High risk reviewed by navigator + security

## Screenshots / Notes

Optional screenshots, links to Preview URL, and additional context.



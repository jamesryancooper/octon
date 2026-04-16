# Mixed Input Impact Map

Use this when more than one primary input family is present.

Route behavior:

- reconciles touched paths against proposal or refactor intent
- treats touched paths as the stronger factual source for impact claims
- surfaces drift explicitly instead of hiding it inside heuristics
- recommends packet refresh, scope tightening, or clarification before broader
  execution when the inputs disagree materially

Expected output sections:

- `impact_map`
- `minimum_credible_validation_set`
- `rationale_trace`
- `recommended_next_step`

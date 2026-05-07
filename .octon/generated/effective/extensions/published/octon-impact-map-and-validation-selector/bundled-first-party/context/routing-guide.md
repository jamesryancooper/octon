# Routing Guide

Use the dispatcher when you want one stable selector entry point:

- `/octon-impact-map-and-validation-selector`
- `octon-impact-map-and-validation-selector`

The source of truth for routing policy is:

- `context/routing.contract.yml`

The published runtime-facing projection is:

- `generated/effective/extensions/catalog.effective.yml` -> `route_dispatchers`

Routing defaults:

- no explicit bundle plus `touched_paths` only -> `touched-paths`
- `proposal_packet` only -> `proposal-packet`
- `refactor_target` only -> `refactor-target`
- more than one primary input family -> `mixed-inputs`

Route disambiguators:

- `bundle` forces one explicit leaf route
- `validation_depth` widens or narrows the evidence floor
- `strictness` chooses between `credible-minimum`, `balanced`, and
  `release-gate`
- `dry_run_route=true` returns the route receipt without prompt freshness or
  leaf execution
- `explanation_mode` switches between concise output and a full rationale trace

Mixed-input precedence:

- touched paths outrank packet or refactor intent for factual impact claims
- drift must stay explicit
- packet refresh, scope tightening, or clarification should be recommended
  before weak validation when the inputs disagree materially

Prefer the leaf commands and leaf skills when the target route is already
known.

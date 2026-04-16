# Octon Impact Map And Validation Selector

Run the `octon-impact-map-and-validation-selector` family dispatcher.

Dispatcher behavior:

- normalizes the provided primary inputs
- resolves one published route from the family routing contract
- returns the route receipt immediately when `dry_run_route=true`
- resolves prompt freshness only after a route is selected
- dispatches to the matching leaf command or skill only after both routing and
  prompt freshness succeed

Default dispatcher route id:

- `touched-paths`

Resolved routes:

- `/octon-impact-map-and-validation-selector-touched-paths`
- `/octon-impact-map-and-validation-selector-proposal-packet`
- `/octon-impact-map-and-validation-selector-refactor-target`
- `/octon-impact-map-and-validation-selector-mixed-inputs`

Route disambiguators:

- `--bundle <route-id>` for an explicit route override
- `--validation-depth minimal|standard|deep` to widen or narrow the evidence
  floor after the minimum credible selection is computed
- `--strictness credible-minimum|balanced|release-gate` to choose the
  governing validation posture
- `--dry-run-route true` to return only the route receipt
- `--explanation-mode concise|full-trace` to control how much rationale trace
  is returned

Primary input precedence:

- explicit `bundle` wins
- mixed primary inputs route to `mixed-inputs`
- otherwise the route follows the sole primary input family

The source of truth for route policy is `context/routing.contract.yml`.

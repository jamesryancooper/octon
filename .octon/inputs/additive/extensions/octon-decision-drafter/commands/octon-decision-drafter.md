# Octon Decision Drafter

Run the `octon-decision-drafter` family dispatcher.

Dispatcher behavior:

- normalizes diff, grounding, target-ref, and output-mode inputs
- resolves one published route from the family routing contract
- returns the route receipt immediately when `dry_run_route=true`
- resolves prompt freshness only after a route is selected
- dispatches to the matching leaf command or skill only after both routing and
  prompt freshness succeed

Default resolved route:

- diff plus retained grounding with no narrower target refs ->
  `change-receipt`

Leaf commands:

- `/octon-decision-drafter-adr-update`
- `/octon-decision-drafter-migration-rationale`
- `/octon-decision-drafter-rollback-notes`
- `/octon-decision-drafter-change-receipt`

Route disambiguators:

- `--bundle <route-id>` for an explicit route override
- `--output-mode inline|patch-suggestion|scratch-md`
- `--dry-run-route true` to return only the route receipt

The source of truth for route policy is `context/routing.contract.yml`.

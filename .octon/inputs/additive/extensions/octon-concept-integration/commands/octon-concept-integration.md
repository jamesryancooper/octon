# Octon Concept Integration

Run the `octon-concept-integration` family dispatcher.

Dispatcher behavior:

- normalizes composite inputs
- resolves one published route from the family routing contract
- returns the route receipt immediately when `dry_run_route=true`
- resolves prompt freshness only after a route is selected
- dispatches to the matching leaf command or skill only after both routing and
  prompt freshness succeed

Default resolved route:

- single-source external input without a narrower target kind ->
  `source-to-architecture-packet`

Leaf commands:

- `/octon-concept-integration-source-to-architecture-packet`
- `/octon-concept-integration-architecture-revision-packet`
- `/octon-concept-integration-constitutional-challenge-packet`
- `/octon-concept-integration-source-to-policy-packet`
- `/octon-concept-integration-source-to-migration-packet`
- `/octon-concept-integration-multi-source-synthesis-packet`
- `/octon-concept-integration-packet-refresh-and-supersession`
- `/octon-concept-integration-packet-to-implementation`
- `/octon-concept-integration-subsystem-targeted-integration`
- `/octon-concept-integration-repo-internal-concept-mining`

Route disambiguators:

- `--bundle <route-id>` for an explicit route override
- `--source-target-kind architecture|architecture-revision|policy|migration`
  for single-source work
- `--packet-action implement|refresh|supersede` for packet work
- `--refresh-mode auto|refresh|supersede` as the packet fallback selector when
  `packet_action` is omitted
- `--dry-run-route true` to return only the route receipt

The source of truth for route policy is `context/routing.contract.yml`.

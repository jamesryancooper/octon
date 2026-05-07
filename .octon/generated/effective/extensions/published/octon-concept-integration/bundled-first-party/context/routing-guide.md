# Routing Guide

Use the dispatcher when you want one stable family entrypoint:

- `/octon-concept-integration`
- `octon-concept-integration`

The source of truth for routing policy is:

- `context/routing.contract.yml`

The published runtime-facing projection is:

- `generated/effective/extensions/catalog.effective.yml` -> `route_dispatchers`

Routing defaults:

- no bundle specified -> `source-to-architecture-packet`
- concept fits current kernel but needs ordinary architecture revision ->
  `architecture-revision-packet`
- concept conflicts with charter, precedence, fail-closed, or authority rules
  -> `constitutional-challenge-packet`
- `proposal_packet` oriented work -> `packet-to-implementation` or
  `packet-refresh-and-supersession`, unless the packet reveals a kernel-level
  blocker and should route to `constitutional-challenge-packet`
- `source_artifacts` list -> `multi-source-synthesis-packet`
- `subsystem_scope` present -> `subsystem-targeted-integration`
- `repo_paths` present with repo-native source material ->
  `repo-internal-concept-mining`

Route disambiguators:

- `source_target_kind` disambiguates single-source external work across
  `architecture`, `architecture-revision`, `policy`, and `migration`
- `packet_action` disambiguates packet execution vs refresh
- `refresh_mode` is the packet fallback when `packet_action` is omitted
- `dry_run_route=true` returns the route receipt without prompt freshness or
  leaf execution

Reroute policy:

- at most one reroute is allowed
- only non-constitutional routes may reroute
- reroutes may target only `constitutional-challenge-packet`
- reroutes require a structured `kernel-conflict-detected` signal before packet
  emission or implementation starts

Prefer leaf commands and leaf skills when the target bundle is already known.

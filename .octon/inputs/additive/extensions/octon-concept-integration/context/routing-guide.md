# Routing Guide

Use the dispatcher when you want one stable family entrypoint:

- `/octon-concept-integration`
- `octon-concept-integration`

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

Prefer leaf commands and leaf skills when the target bundle is already known.

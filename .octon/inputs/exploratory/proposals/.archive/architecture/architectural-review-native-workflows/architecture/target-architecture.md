# Target Architecture

## Workflows

- `pre-integration-architecture-review`
- `post-integration-architecture-review`
- `current-state-mechanism-architecture-review`
- `architecture-readiness-audit`

## Workflow Contract Fields

Each workflow defines:

- subject binding;
- route decision binding;
- input authority classification;
- required schemas;
- validator set;
- evidence root;
- report output;
- support receipt output;
- blocked, deferred, and not applicable handling;
- non-authority boundaries.

## Architecture Readiness Slug

The workflow target is `architecture-readiness-audit`. Any legacy
`architecture-readiness-audit` workflow path is transitional and must be retired
by the naming migration plan.

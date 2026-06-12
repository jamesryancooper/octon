# Target Architecture

## Mandatory Gate

Architecture proposals require a passing
`pre-integration-architecture-review` receipt before:

- status can become `accepted`;
- an implementation prompt can be authorized;
- promotion workflow can proceed;
- archive as implemented can proceed.

## Fail-Closed Cases

The gate fails when the receipt is missing, stale, schema-invalid, non-passing,
not digest-bound, missing evidence refs, missing validator refs, has unresolved
blockers, or omits mode coverage.

## Preserved Gates

Implementation conformance and post-implementation drift/churn remain hard
closeout gates. This child does not weaken them.

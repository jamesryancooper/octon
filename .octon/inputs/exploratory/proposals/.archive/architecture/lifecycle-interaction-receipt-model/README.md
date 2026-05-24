# Lifecycle Interaction Receipt Model

This temporary architecture proposal defines a typed receipt model for
cross-lifecycle dependencies discovered during governed lifecycle execution.

The decision is to add `lifecycle-interaction-request-v1` and
`lifecycle-interaction-return-v1` as durable, schema-validated, runner-visible,
non-authorizing receipts. A request can say follow-on work is required in a
target lifecycle. It cannot authorize that target lifecycle, transfer Git or
hosted-provider authority, share phase-loop state, satisfy closeout gates, or
claim dependency resolution without return evidence.

The accepted implementation scope is intentionally narrow: schemas, lifecycle
contract metadata, runner checkpoint/event/request visibility, executor
adapter non-authority boundaries, workflow/skill guidance, validators, negative
tests, and derived projection refreshes.

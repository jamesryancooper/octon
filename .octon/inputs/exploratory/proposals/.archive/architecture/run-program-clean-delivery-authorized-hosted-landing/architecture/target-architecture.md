# Target Architecture

Hosted no-PR landing uses an explicit non-interactive execution flag such as
`--execute-authorized-landing`. The flag consumes a current authorization
receipt and requires immediate preflight validation of source and target refs,
exact source SHA, provider ruleset state, required checks or approved empty
check set, no-PR-required status, host-control preservation, rollback handle,
and final sync plan.

Autonomous execution also requires execution-environment lane coverage: either
pre-approved command prefixes for the exact mutation class or an equivalent
sandbox/tool authority receipt. Octon landing authorization and execution
environment approval remain separate facts that must both be current.

The route blocks when authorization is missing, stale, denied, externally
blocked, policy-incomplete, or would require force-push or destructive mutation
beyond the receipt.

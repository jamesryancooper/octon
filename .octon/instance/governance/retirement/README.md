# Retirement Governance

This root holds claim-facing retirement governance for Octon's build-to-delete
program.

The detailed contracts remain under `/.octon/instance/governance/contracts/**`.
This root defines how those contracts are interpreted at claim time so
retained compatibility shims, projection-only surfaces, and historical mirrors
do not block the bounded completion claim unless they are overdue, ownerless,
or unevidenced.

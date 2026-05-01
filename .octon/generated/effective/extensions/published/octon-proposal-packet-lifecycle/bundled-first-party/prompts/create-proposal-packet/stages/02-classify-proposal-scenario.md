# Classify Proposal Scenario

Classify the request into one supported scenario from
`context/scenario-taxonomy.md`. Select exactly one primary scenario and record
secondary influences as source context.

Use `audit-aligned-packet` when the source requires every audit finding or
constitutional consistency failure to map to remediation, acceptance criteria,
validation, and closure proof. Use `architecture-evaluation-packet` when the
source asks for a current-state score, target-state score, or gap-to-target
architecture package. Use `highest-leverage-next-step-packet` when the source
asks the packet to choose one repo-grounded next step instead of prescribing
the implementation target up front.

If proposal kind, durable target, or ownership cannot be reasonably inferred
from the live repo and user request, stop with `needs-packet-revision`.

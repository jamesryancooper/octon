# Octon Proposal Lifecycle: Closeout Packet

Run the `closeout-packet` bundle. Refuse closeout when validation,
evidence, staging, archive state, route-required review/check gates, or
route-required sync gates are not satisfied. Red required checks start
remediation rather than status-only waiting. PR, merge, branch cleanup, and
origin sync gates apply only when the selected implementation route uses a PR or
branch lane; otherwise closeout is governed by the packet receipts, durable
evidence, registry freshness, and final hygiene.

Boundary: packet closeout may record proposal evidence and advisory handoff
context only. It does not own lifecycle planning, phase-loop state, Change
closeout, hosted landing, branch cleanup, cleanup authority, or final Change
lifecycle outcome reporting.

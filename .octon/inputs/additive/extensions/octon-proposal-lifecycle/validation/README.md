# Proposal Lifecycle Validation

Pack-local validation proves that the lifecycle family has the required route
coverage, artifact placement rules, authority boundaries, proposal-program
fixtures, and deterministic route resolution.

Lifecycle contract validation also covers the proposal packet v2 phase loop:
phase ids must remain separate from proposal manifest statuses, phase
references must resolve to existing routes, receipts, gates, validators, loops,
or terminal outcomes, phase loop bounds must be finite, and terminal phases
must not dispatch routes.

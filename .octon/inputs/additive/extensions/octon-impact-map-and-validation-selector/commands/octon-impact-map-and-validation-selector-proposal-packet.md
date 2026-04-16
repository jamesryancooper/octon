# Proposal Packet Impact Map

Use this when the input is one proposal packet path or id.

Route behavior:

- resolves packet kind from `proposal.yml` plus exactly one subtype manifest
- selects the packet-kind validator floor from existing repo validators
- recommends the next canonical route for refresh, supersession, audit, or
  implementation follow-up

Expected output sections:

- `impact_map`
- `minimum_credible_validation_set`
- `rationale_trace`
- `recommended_next_step`

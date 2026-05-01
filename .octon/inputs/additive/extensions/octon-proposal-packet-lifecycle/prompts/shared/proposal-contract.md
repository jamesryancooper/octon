# Proposal Contract

Proposal packets are temporary, manifest-governed implementation aids under
`.octon/inputs/exploratory/proposals/<kind>/<proposal_id>/`.

Each route must preserve:

- `proposal.yml` as the highest packet-local lifecycle authority,
- exactly one subtype manifest,
- canonical path placement,
- declared promotion targets outside the proposal path,
- validator-driven proposal and subtype requirements,
- registry projection as discovery-only.

Routes must not create descendant-local proposal workspaces or nested child
proposal package directories.

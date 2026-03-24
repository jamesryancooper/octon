---
title: Policy Proposal Standard
description: Required files and policy-specific constraints for v1 policy proposals.
---

# Policy Proposal Standard

Policy proposals extend `proposal-standard.md`.

Canonical path:

- `/.octon/inputs/exploratory/proposals/policy/<proposal_id>/`
- the final directory name must equal `proposal_id` with no numeric prefix

Required files:

- `policy-proposal.yml`
- `policy/decision.md`
- `policy/policy-delta.md`
- `policy/enforcement-plan.md`

## Subtype Manifest Contract

`policy-proposal.yml` must define:

- `schema_version`
- `policy_area`
- `change_type`

Allowed values:

- `schema_version`: `policy-proposal-v1`
- `change_type`: `new-policy` | `policy-update` | `policy-removal`

Rules:

- `policy_area` must be a non-empty machine-readable policy slice name.
- `policy/decision.md` must use ADR-style decision sections.
- `policy/policy-delta.md` must identify target authority surfaces and the exact
  intended delta.
- `policy/enforcement-plan.md` must name verification or enforcement updates
  needed to make the policy effective.

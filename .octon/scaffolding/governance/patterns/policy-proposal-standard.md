---
title: Policy Proposal Standard
description: Required files and policy-specific constraints for v1 policy proposals.
---

# Policy Proposal Standard

Policy proposals extend `proposal-standard.md`.

Required files:

- `policy-proposal.yml`
- `policy/decision.md`
- `policy/policy-delta.md`
- `policy/enforcement-plan.md`

Rules:

- `policy/decision.md` must use ADR-style decision sections.
- `policy/policy-delta.md` must identify target authority surfaces and the exact
  intended delta.
- `policy/enforcement-plan.md` must name verification or enforcement updates
  needed to make the policy effective.

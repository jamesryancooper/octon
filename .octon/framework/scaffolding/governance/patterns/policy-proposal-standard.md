---
title: Policy Proposal Standard
description: Required files and policy-specific constraints for v1 policy proposals.
---

# Policy Proposal Standard

Policy proposals extend `proposal-standard.md`.

Lifecycle gates, receipt requirements, and closeout/archive semantics are owned
by `proposal-standard.md`. This subtype standard only adds policy-specific
content requirements.

Canonical path:

- `/.octon/inputs/exploratory/proposals/policy/<proposal_id>/`
- the final directory name must equal `proposal_id` with no numeric prefix

Required files:

- `policy-proposal.yml`
- `policy/decision.md`
- `policy/policy-delta.md`
- `policy/enforcement-plan.md`
- `implementation/implementation-map.md` before `in-review`
- `support/implementation-grade-completeness-review.md` before `in-review`

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
- `navigation/source-of-truth-map.md` must identify the durable authorities,
  proposal-local lifecycle sources, derived projections, retained evidence
  surfaces, and boundary rules for the policy change.
- `implemented` means the policy change is promoted into durable authority
  surfaces and the named enforcement or verification updates exist outside the
  proposal workspace.

## Implementation-Grade Requirements

Policy proposals are implementation-grade complete only when they define:

- the canonical policy authority location;
- the machine-readable policy contract when downstream automation depends on
  the policy;
- an enforcement and validator plan;
- an artifact-by-artifact implementation map;
- the role of each affected artifact: owns policy, references policy, or
  implementation-specific;
- downstream alignment for workflows, manifests, skills, validators,
  generated projections, and repo-local surfaces when applicable;
- explicit rollback, evidence, and closeout expectations.

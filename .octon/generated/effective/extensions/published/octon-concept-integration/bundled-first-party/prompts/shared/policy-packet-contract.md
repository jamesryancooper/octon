# Policy Packet Contract

This file is the single source of truth for extension-specific policy-packet
rules that sit on top of Octon's repo-wide proposal standards.

## Schema And Layout Sources Of Truth

Policy packet schema, lifecycle, and layout rules are owned by:

- `/.octon/framework/scaffolding/governance/patterns/proposal-standard.md`
- `/.octon/framework/scaffolding/governance/patterns/policy-proposal-standard.md`

## Extension-Specific Policy Packet Expectations

A concept-integration policy packet should:

- target policy, governance, admission, exclusion, validator, or review-ready
  enforcement surfaces,
- keep promotion targets out of the proposal tree,
- preserve source -> extraction -> verification -> policy recommendation ->
  packet traceability,
- include manifest-governed packet support artifacts when available,
- and be valid under both
  `validate-proposal-standard.sh --package <packet-path>` and
  `validate-policy-proposal.sh --package <packet-path>`.

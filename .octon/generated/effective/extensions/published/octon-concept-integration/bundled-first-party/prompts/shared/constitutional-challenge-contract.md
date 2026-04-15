# Constitutional Challenge Contract

This file is the single source of truth for extension-specific
constitutional-challenge rules that sit on top of Octon's repo-wide proposal
standards.

## Schema And Layout Sources Of Truth

Constitutional challenge packet schema, lifecycle, and layout rules are owned
by:

- `/.octon/framework/scaffolding/governance/patterns/proposal-standard.md`
- `/.octon/framework/scaffolding/governance/patterns/policy-proposal-standard.md`

## Extension-Specific Constitutional Challenge Expectations

A `constitutional-challenge-packet` should:

- be used only when the concept appears to require amending charter, kernel,
  precedence, fail-closed, support-universe, or authority-routing rules,
- map the exact conflicting kernel surfaces and explain why ordinary
  architecture revision is insufficient,
- stay at governed challenge documentation rather than runtime implementation,
- explicitly require human governance review and amendment approval before any
  downstream implementation packet is considered,
- and be valid under both
  `validate-proposal-standard.sh --package <packet-path>` and
  `validate-policy-proposal.sh --package <packet-path>`.

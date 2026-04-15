# Subsystem Targeted Integration Bundle Contract

- input type: single external source artifact plus required subsystem scope
- output type: architecture proposal packet
- scoping rule: every recommendation must stay inside the declared subsystem or
  explicitly call out a cross-subsystem dependency
- validators:
  - `validate-proposal-standard.sh --package <packet-path>`
  - `validate-architecture-proposal.sh --package <packet-path>`

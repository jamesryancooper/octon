# Constitutional Challenge Packet Bundle Contract

- input type: proposal packet, source artifact, or explicit kernel-conflict map
- output type: policy proposal packet for governed constitutional challenge
- hard gate: stop at challenge documentation; do not emit an execution prompt
  or direct handoff to `packet-to-implementation`
- validators:
  - `validate-proposal-standard.sh --package <packet-path>`
  - `validate-policy-proposal.sh --package <packet-path>`

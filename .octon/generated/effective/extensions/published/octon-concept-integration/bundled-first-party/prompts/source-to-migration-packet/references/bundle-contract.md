# Source To Migration Packet Bundle Contract

- input type: single external source artifact
- output type: migration proposal packet
- promotion surface bias: cutover, rollback, compatibility, rollout, and
  validation motion
- validators:
  - `validate-proposal-standard.sh --package <packet-path>`
  - `validate-migration-proposal.sh --package <packet-path>`

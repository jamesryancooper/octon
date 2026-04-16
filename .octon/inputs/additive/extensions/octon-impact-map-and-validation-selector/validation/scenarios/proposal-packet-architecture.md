# Scenario: Proposal Packet Architecture

## Input

- `proposal_packet` resolves to an architecture proposal directory

## Expected Route

- `proposal-packet`

## Expected Validation Floor

- `validate-proposal-standard.sh --package <proposal-path>`
- `validate-architecture-proposal.sh --package <proposal-path>`

## Expected Next Step

- default to packet refresh or supersession
- allow packet-to-implementation only when the packet is already current

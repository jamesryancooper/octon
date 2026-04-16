# Scenario: Proposal Packet Migration

## Input

- `proposal_packet` resolves to a migration proposal directory

## Expected Route

- `proposal-packet`

## Expected Validation Floor

- `validate-proposal-standard.sh --package <proposal-path>`
- `validate-migration-proposal.sh --package <proposal-path>`

## Expected Next Step

- packet refresh or supersession before implementation
- escalate to broader audit workflows only when depth or strictness requires it

# Scenario: Mixed Input Packet Drift

## Input

- `touched_paths` indicate current repo changes
- `proposal_packet` declares a scope that no longer matches those paths

## Expected Route

- `mixed-inputs`

## Expected Precedence

- touched paths are the stronger factual source for direct impact claims

## Expected Validation Floor

- touched-path validation floor first
- packet validators only if they still match the observed surfaces

## Expected Next Step

- `/octon-concept-integration-packet-refresh-and-supersession`
- or clarification when drift is too large for a credible answer

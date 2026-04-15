# Packet To Implementation Bundle Contract

This bundle executes an existing proposal packet against the live repository.

## Bundle Contract

- input type: proposal packet
- output type: implemented repo change set plus validation/evidence/closeout
- supported packet kinds: architecture, policy, migration
- validator rule:
  - architecture packet -> proposal + architecture validators
  - policy packet -> proposal + policy validators
  - migration packet -> proposal + migration validators

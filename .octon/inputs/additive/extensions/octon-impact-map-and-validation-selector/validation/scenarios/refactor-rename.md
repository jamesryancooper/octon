# Scenario: Refactor Rename

## Input

- `refactor_target`:
  - `type: rename`
  - `old: old-name`
  - `new: new-name`

## Expected Route

- `refactor-target`

## Expected Validation Floor

- `/refactor`
- extra validators only when the affected surfaces map to known path rules

## Expected Next Step

- `/refactor`

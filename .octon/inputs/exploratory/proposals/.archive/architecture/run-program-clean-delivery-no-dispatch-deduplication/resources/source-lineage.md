# Source Lineage

- PM-005: max-step resumptions produced repeated compact artifacts without
  forward action.
- Audit evidence: program events showed repeated `plan-created`,
  `aggregate-terminal-blockers`, `token-budget-ledger-written`, and
  `compact-evidence-written` events plus several `max-steps-exhausted` events.
- Audit acceptance: identical blocker fingerprint plus no dispatched action
  updates only a bounded attempt counter and timestamp.
- Operator decision: repeated fingerprints without changed inputs should emit
  compact delta receipts or bounded attempt entries instead of full duplicate
  artifacts.

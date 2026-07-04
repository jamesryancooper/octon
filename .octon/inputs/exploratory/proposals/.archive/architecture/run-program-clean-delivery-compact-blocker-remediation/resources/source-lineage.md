# Source Lineage

- PM-001: blocker handling generated too much residue.
- Audit evidence: 16 same-program workflow directories, a final run with 69
  files / 9264 KB, and thousands of untracked runtime evidence/control files.
- Audit acceptance: recoverable blocker retries emit one compact receipt plus
  bounded logs, and repeated full workflow directories fail closed after a
  configurable threshold.
- Operator decision: artifact budgets should use repeated fingerprints, file
  count, and total bytes, transitioning to compact blocker-remediation mode.
- Prior lineage:
  `.octon/inputs/exploratory/proposals/.archive/architecture/run-program-clean-delivery-postmortem-hardening`

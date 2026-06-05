# Target Architecture

Proposal-program lifecycle recovery uses three explicit blocker classes:

- `routine-autonomous`: deterministic, bounded, validator-backed repairs that
  should continue without operator escalation.
- `soft-blocker`: recoverable issues requiring bounded retry, delegated
  cleanup, receipt refresh, or gate rerun before continuing.
- `hard-blocker`: issues that require operator escalation because continuing
  would be destructive, authority-ambiguous, externally blocked, scope-widening,
  or unsupported by valid child-owned evidence.

The taxonomy must be machine-readable enough for validators and runners to
exchange recovery classes without parsing prose logs.

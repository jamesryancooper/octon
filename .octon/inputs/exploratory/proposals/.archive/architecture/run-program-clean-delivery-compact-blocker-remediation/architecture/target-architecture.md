# Target Architecture

The lifecycle runner maintains an artifact budget for recoverable blockers. The
budget uses three signals: repeated blocker fingerprints, file count, and total
bytes. When triggered, the run enters compact blocker-remediation mode.

Compact mode writes one current remediation receipt, one bounded validation log
summary, and digest references to retained full evidence when full evidence is
required. It deduplicates unchanged blocker output and continues the lifecycle
when a route-owned recovery path proves safe.

Repeated full workflow directory emission fails closed after a configurable
threshold. That fail-closed behavior applies to the full-output path, not to the
lifecycle itself: the lifecycle continues in compact mode when evidence remains
preserved and the blocker is still safely routable.

Human review remains required when compacting would lose required evidence or
when the blocker cannot be classified, preserved, or routed safely.

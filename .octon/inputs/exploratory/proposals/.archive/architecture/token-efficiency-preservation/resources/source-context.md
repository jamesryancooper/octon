# Source Context

Parent program:
`.octon/inputs/exploratory/proposals/architecture/autonomous-lifecycle-blocker-recovery`

Source findings:

- failure evidence was noisy and expensive to inspect;
- repeated stale receipt and freshness recovery attempts should be summarized
  as compact deltas;
- direct validator diagnostics can reduce broad context loading;
- compact summaries must not replace replay-critical evidence or child
  receipts.

This file is proposal-local context only.

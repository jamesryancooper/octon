# Implementation Plan

1. Add final report schema fields for branch roles and retained-state classes.
2. Update proposal-program delivery, closeout-change, and closeout-worktree
   reports to populate the fields.
3. Require current evidence for branch deletion, archive authorization,
   terminal hygiene, and generated-output freshness claims.
4. Add validators that fail broad cleanup claims without exact retained/deleted
   branch rows.
5. Add fixtures matching the dirty-anchor versus delivery-branch confusion from
   the postmortem.

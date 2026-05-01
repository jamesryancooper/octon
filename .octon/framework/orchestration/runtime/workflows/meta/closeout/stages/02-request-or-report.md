# Request Or Report

1. Use the resolved context to determine whether to:
   - request the next closeout mutation
   - report ready-status without another prompt
   - report blockers and continue implementation
2. When blockers include red required checks, failing jobs, failing scripts, or
   unresolved review conversations, report closeout as incomplete and continue
   the remediation loop from the Git/worktree autonomy contract unless the
   blocker is explicitly external.
3. Never restate the prompt matrix inline in ingress.
4. If a compatibility fallback prompt is still needed for legacy adapters, cite
   the workflow contract and retirement register rather than treating the
   prompt as canonical policy.

# Request Or Report

1. Use the resolved Change route to determine whether to:
   - complete direct-main with local validation, commit, Change receipt, and
     rollback handle
   - preserve, commit, push, land, or clean up branch-only work without opening
     a PR, but only when lifecycle evidence supports the claimed outcome
   - invoke PR-backed publication and review mechanics, and report draft/open,
     ready, landed, and cleaned as distinct outcomes
   - report stage-only or escalation blockers
   - report ready-status without another prompt
2. Mention PR mutation only when the selected route is `branch-pr`.
3. For hosted `branch-no-pr` landing, require hosted no-PR landing preflight,
   exact source SHA required checks, a pushed source branch current with
   `origin/main`, fast-forward-only update evidence, and post-push proof that
   `origin/main` equals the recorded `landed_ref`.
4. When blockers include PR-required provider rules for requested no-PR hosted
   landing, red required checks, failing jobs, failing scripts,
   unresolved review conversations, missing validation evidence, missing
   receipt, or missing rollback handle, report closeout as incomplete and
   continue the route-appropriate remediation loop unless the blocker is
   explicitly external.
5. Never report a patch, checkpoint, branch-local commit, or pushed-only branch
   as landed.
6. Never report a draft/open PR or ready but unmerged PR as full closeout.
7. Never restate the prompt matrix inline in ingress.
8. If a compatibility fallback prompt is still needed for legacy adapters, cite
   the workflow contract and retirement register rather than treating the
   prompt as canonical policy.

# Request Or Report

1. Use the resolved Change route to determine whether to:
   - complete direct-main with local validation, commit, Change receipt, and
     rollback handle, then push `main` to origin and verify `origin/main`
     contains the landed ref, fetch origin, sync local `main`, and verify local
     `main`, `origin/main`, and the landed ref align
   - preserve, commit, push, land, or clean up branch-only work without opening
     a PR, but only when lifecycle evidence supports the claimed outcome
   - invoke PR-backed publication and review mechanics, and report draft/open,
     ready, landed, and cleaned as distinct outcomes
   - report stage-only or escalation blockers
   - report ready-status without another prompt
2. Mention PR mutation only when the selected route is `branch-pr`.
3. For solo Changes on clean current `main`, consider direct-main before
   branch-no-pr when all direct-main predicates are satisfied and no branch or
   PR predicate applies.
4. For hosted `branch-no-pr` landing, require hosted no-PR landing preflight,
   exact source SHA required checks, a pushed source branch current with
   `origin/main`, fast-forward-only update evidence, and post-push proof that
   `origin/main` equals the recorded `landed_ref`.
5. For `branch-no-pr` closeout that does not land on hosted `main`, push the
   source branch to origin and record `remote_branch_ref`; otherwise report
   branch-local state as local-only or incomplete.
6. For landed `branch-no-pr` or `branch-pr` work, verify `origin/main`
   contains the landed commit or merge ref, verify post-landing checks and
   closeout evidence, clean up obsolete safe local and remote source branches,
   or record the precise deferred-cleanup blocker. Never delete protected
   branches, active work branches, unmerged branches, open-PR branches, or refs
   without retained evidence and rollback posture.
7. After branch cleanup is complete or explicitly deferred, fetch origin, sync
   local `main` to `origin/main`, and verify local `main`, `origin/main`, and
   the recorded `landed_ref` are aligned before declaring closeout complete.
8. When blockers include PR-required provider rules for requested no-PR hosted
   landing, red required checks, failing jobs, failing scripts,
   unresolved review conversations, missing validation evidence, missing
   receipt, or missing rollback handle, report closeout as incomplete and
   continue the route-appropriate remediation loop unless the blocker is
   explicitly external.
9. Never report a patch, checkpoint, branch-local commit, or pushed-only branch
   as landed.
10. Never report a draft/open PR or ready but unmerged PR as full closeout.
11. Never restate the prompt matrix inline in ingress.
12. If a compatibility fallback prompt is still needed for legacy adapters, cite
   the workflow contract and retirement register rather than treating the
   prompt as canonical policy.

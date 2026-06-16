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
2. Mention PR mutation only when the selected route is `branch-pr` and the
   Change receipt can record `branch_pr_predicate`. If `branch-pr` follows a
   different initial route, record route transition authority first.
3. Choose the report posture from evidence:
   - completed closeout only when the selected route, target outcome, actual
     outcome, state-machine receipt evidence, rollback, cleanup, and alignment
     evidence all agree
   - continued handoff for `published-branch`, `branch-local-complete`,
     `published`, or `ready`
   - blocker receipt when required validation, landing, cleanup, sync, review,
     or authority evidence is missing
   - denial when policy or authority forbids the requested closeout action
4. For solo Changes on clean current `main`, consider direct-main before
   branch-no-pr when all direct-main predicates are satisfied and no branch or
   PR predicate applies.
5. For hosted `branch-no-pr` landing, require hosted no-PR landing preflight,
   exact source SHA required checks or explicit empty-check-set policy plus
   retained rationale, a pushed source branch current with `origin/main`,
   governed `branch-landing-authorization-v1` evidence matching the pushed
   source ref and `origin/main` pre-ref, fast-forward-only update evidence, and
   post-push proof that `origin/main` equals the recorded `landed_ref`.
6. For generic closeout intent, default `target_lifecycle_outcome` to
   `cleaned`. Use `published-branch`, `branch-local-complete`, `landed`,
   `preserved`, or `blocked` only when the operator explicitly requests that
   narrower target. Treat `stage-only-escalate` as an explicit route request
   with a route-compatible target. Do not infer `published-branch` as full
   closeout from a route-only instruction.
7. For `branch-no-pr` closeout that does not land on hosted `main`, push the
   source branch to origin and record `remote_branch_ref`; otherwise report
   branch-local state as local-only or incomplete. If the target was `landed`
   or `cleaned`, also record landing evaluation evidence and
   `not_landed_reason`.
8. For landed `branch-no-pr` or `branch-pr` work, verify `origin/main`
   contains the landed commit or merge ref, verify post-landing checks and
   closeout evidence, clean up obsolete safe local and remote source branches,
   or record the precise deferred-cleanup blocker. Never delete protected
   branches, active work branches, unmerged branches, open-PR branches, or refs
   without retained evidence and rollback posture.
9. After branch cleanup is complete or explicitly deferred, fetch origin, sync
   local `main` to `origin/main`, and verify local `main`, `origin/main`, and
   the recorded `landed_ref` are aligned before declaring closeout complete.
10. Before claiming `cleaned`, classify any untracked local `.octon/state/**`
   artifacts left by publication, validation, service-build, closeout, or
   agent-quorum runs with
   `.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`.
   Retain or escalate referenced evidence, active control state,
   build-to-delete evidence, and manual-review artifacts. Delete only
   untracked, unreferenced cleanup candidates after explicit confirmation, and
   report any remaining local residue separately from durable closeout
   evidence.
11. When blockers include PR-required provider rules for requested no-PR hosted
    landing, red required checks, failing jobs, failing scripts,
    unresolved review conversations, missing validation evidence, missing
    receipt, or missing rollback handle, report closeout as incomplete and
   continue the route-appropriate remediation loop unless the blocker is
   explicitly external. Do not convert the blocker to `branch-pr` unless an
   initial branch-pr predicate exists or an authority-backed route transition
   is recorded.
12. Never report a patch, checkpoint, branch-local commit, or pushed-only branch
   as landed.
13. Never report `published-branch`, `branch-local-complete`, `published`, or
    `ready` as completed closeout.
14. Never claim completed or cleaned closeout without `stateful_closeout`
    evidence from the Change Closeout State Machine.
15. For proposal-program, generated-publication, archive, or correction-branch
    closeout that claims `cleaned`, retain and validate
    `lifecycle-terminal-current-state-proof-v1` evidence after the last
    mutation. If post-primary branch-no-pr correction branches occurred, also
    retain `lifecycle-correction-branch-aggregate-receipt-v1` evidence.
16. Never restate the prompt matrix inline in ingress.
17. If a compatibility fallback prompt is still needed for legacy adapters, cite
   the workflow contract and retirement register rather than treating the
   prompt as canonical policy.

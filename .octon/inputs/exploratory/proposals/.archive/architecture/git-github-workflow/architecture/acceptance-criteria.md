# Acceptance Criteria

The workflow can be considered complete only when all are true:

1. The documented default says implementation happens in feature branch
   worktrees in any worktree-capable Git environment.
2. The primary `main` worktree or clone is documented and treated as the clean
   integration anchor.
3. The assistant never attempts to open a PR from `main`.
4. The default unit of work is one task or PR per branch worktree.
5. The closeout prompt is not emitted after every file-changing turn.
6. The closeout prompt is emitted only at credible completion points or
   explicit finish, ship, or closeout requests.
7. The closeout wording changes by context:
   - primary `main`
   - branch with no PR
   - branch with an autonomous-lane-ready draft PR
   - branch with a manual-lane-ready draft PR
   - blocked or not-ready state
8. Blocked or not-ready states suppress the closeout question and instead
   surface blockers.
9. Review-remediation behavior is explicitly `fix + commit + reply`, never
   "resolve reviewer-owned threads to make the UI green".
10. PR standards, the remediation skill, and the companion PR template define
    review-thread handling in a way that preserves reviewer-owned resolution.
11. The ready-for-review transition is documented as a state criterion, not
    merely a helper-script button.
12. The manual lane is explicit for `exp/*`, high-impact governance or
    control-plane changes, and major or unknown Dependabot updates.
13. The autonomous lane is explicit as draft-first, squash-only, and still
    governed by canonical GitHub required checks and review-thread-resolution
    rules.
14. Post-merge cleanup converges local refs and `main`, and the linked-worktree
    directory cleanup step is documented or automated.
15. Ingress, workflow docs, PR standards, helper scripts, and the remediation
    skill no longer contradict one another.
16. The durable workflow definition no longer depends on Codex App as a
    prerequisite; Codex becomes only one valid operator environment.

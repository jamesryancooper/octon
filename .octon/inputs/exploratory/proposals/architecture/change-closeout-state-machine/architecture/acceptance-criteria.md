# Acceptance Criteria

Proposal: `change-closeout-state-machine`

The target architecture has landed when:

1. `change-closeout-state-machine-v1` exists as a durable product contract.
2. `default-work-unit.yml` and `default-work-unit.md` reference the state
   machine without weakening route distinctions.
3. `Closeout Change` remains the singular route-neutral executor.
4. `Closeout Worktree` is the only optional dirty-worktree wrapper term, and it
   decomposes work into singular Change closeouts instead of replacing the
   default work unit.
5. `Closeout PR` is documented as PR-backed Change closeout while preserving the
   command id for compatibility.
6. No peer `Publish Changes` workflow exists or is required for Change closeout.
7. Change receipts can record state-machine inventory, classification, cleanup,
   phase-exit, final verification, and escalation evidence.
8. Validators fail completed or cleaned claims that lack required
   state-machine evidence.
9. Validators fail destructive cleanup claims without evidence-backed safety.
10. Validators fail `published-branch`, `published`, or `ready` overclaims when
    they are presented as completed closeout.
11. Validators fail force-push claims and ambiguous deletion, reset,
    restoration, or overwrite of user-owned work.
12. Branch cleanup claims require origin/main containment, no-open-PR status,
    rollback/discard posture, and local/remote cleanup status.
13. Hosted no-PR landing still requires provider permission, pushed source
    branch, exact-SHA checks, fast-forward update proof, `origin/main` equality,
    rollback handle, and final main alignment.
14. Direct-main claims require clean-main, validation, push, rollback,
    fetch/sync, and final alignment evidence.
15. Stage-only or escalated outcomes cannot claim landed, cleaned, or completed
    lifecycle state.
16. PR-backed closeout remains delegated only after `branch-pr` route selection.
17. Generated/effective publication scripts remain lower-level operations and
    are not conflated with Change closeout publication status.
18. `.octon/inputs/**`, proposal-local files, generated outputs, host state,
    GitHub state, chat, model memory, and tool availability remain
    non-authoritative for closeout.
19. Implementation conformance and post-implementation drift/churn reviews pass
    before this packet is promoted or archived as implemented.

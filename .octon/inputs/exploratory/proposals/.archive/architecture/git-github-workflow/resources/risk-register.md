# Risk Register

| Risk | Trigger | Impact | Mitigation |
|---|---|---|---|
| Environment-specific overfit survives | Core docs still describe one app as the default workflow environment | The durable model remains less portable than intended | Rewrite workflow docs in terms of Git and worktree primitives, not host-app assumptions |
| Static closeout prompt survives in one authoritative surface | Ingress or practice docs retain the old fixed question | Conflicting operator behavior and stale adapter behavior | Sweep authoritative docs for the old string and make `branch_closeout_gate` canonical |
| Reviewer-resolution drift persists | PR standards, skill, and template do not all align | Agents may still self-resolve reviewer-owned threads or misreport readiness | Land PR standards, skill, and template wording together |
| Helper-script overclaim remains | `git-pr-ship.sh` still reads like a readiness oracle | Operators may conflate merge intent with true readiness | Tighten help text, success text, and workflow docs |
| Worktree cleanup remains implicit | Branch cleanup lands without worktree-directory handling | Stale local worktrees accumulate and confuse operators | Document or automate worktree-directory pruning |
| Companion repo-local alignment is skipped | Implementation lands only in `/.octon/**` | PR template continues to contradict the durable workflow | Treat `.github/PULL_REQUEST_TEMPLATE.md` as a must-update companion surface in the implementation branch |

# GitHub Closeout Boundary

Closeout routes may inspect and act on PR, CI, check, review, merge, branch,
and sync state only inside the granted execution scope.

Repository-wide GitHub closeout behavior is owned by
`.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
and the closeout workflow referenced by `.octon/instance/ingress/manifest.yml`.
Proposal lifecycle routes may add proposal archival, registry, and evidence
gates, but must not define a competing PR, CI, merge, or branch cleanup policy.

They must refuse to merge when required checks fail or review conversations are
unresolved. They must stage only intended files, avoid incidental build or
scratch artifacts, avoid deleting user work, and capture closeout status as
retained evidence when GitHub or CI state materially affects the verdict.

Red required checks are not a waiting state. Closeout routes must inspect every
failing check, job, and script; apply the smallest target-architecture-correct
fix; validate locally when reproducible; commit; push; and re-check until the
required checks are green or an explicit external blocker is recorded.

Final closeout requires a clean final hygiene pass: no unintended tracked
changes, no incidental untracked build/output artifacts, no unwanted prompt
scaffolding, no unwanted local skill logs, and no missing required generated or
evidence outputs.

GitHub comments, labels, checks, dashboards, and branch state are operational
signals. They do not become Octon authority unless captured into canonical
control or evidence surfaces under the applicable contract.

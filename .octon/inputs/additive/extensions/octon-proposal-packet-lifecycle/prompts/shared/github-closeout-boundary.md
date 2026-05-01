# GitHub Closeout Boundary

Closeout routes may inspect and act on PR, CI, check, review, merge, branch,
and sync state only inside the granted execution scope.

They must refuse to merge when required checks fail or review conversations are
unresolved. They must stage only intended files, avoid incidental build or
scratch artifacts, avoid deleting user work, and capture closeout status as
retained evidence when GitHub or CI state materially affects the verdict.

GitHub comments, labels, checks, dashboards, and branch state are operational
signals. They do not become Octon authority unless captured into canonical
control or evidence surfaces under the applicable contract.

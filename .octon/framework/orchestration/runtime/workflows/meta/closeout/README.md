---
name: "closeout"
description: "Resolve SI-00 Change closeout to preservation or stable pre-effect denial."
steps:
  - id: "evaluate-context"
    file: "stages/01-evaluate-context.md"
    description: "Bind and classify read-only state."
  - id: "request-or-report"
    file: "stages/02-request-or-report.md"
    description: "Report preservation, denial, and next owner."
---

# Closeout

SI-00 closeout inventories and preserves one Change. It never selects
direct-main, lands branch-no-PR work, cleans refs/worktrees, or reports
cleaned/synced success.

Landing/publication requests stop with
`RP00_CONTAINMENT_PUBLICATION_DISABLED`; cleanup requests stop with
`RP00_CONTAINMENT_CLEANUP_DISABLED`.

## Steps

1. [Evaluate context](./stages/01-evaluate-context.md)
2. [Request or report](./stages/02-request-or-report.md)

The canonical contract is [workflow.yml](./workflow.yml).

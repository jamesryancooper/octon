# Target Architecture

Branch-no-PR closeout can emit terminal proof after landing, sync, cleanup, and
validation evidence exists. That proof is retained evidence, not a source-branch
commit requirement and not a landed-ref mutation.

Terminal proof must identify the landed ref, the proof sink, cleanup
authorization, sync state, and validation evidence. It must not replace route
receipts owned by `closeout-change`, `closeout-worktree`, or proposal-packet
delivery.

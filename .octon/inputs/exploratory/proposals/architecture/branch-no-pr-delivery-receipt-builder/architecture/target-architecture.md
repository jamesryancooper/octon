# Target Architecture

Provide a canonical receipt builder for hosted landing, sync, cleanup authorization, branch cleanup, and cleaned proof.

## Target Behavior

- Builder emits a complete branch-no-PR receipt for landed, synced, cleanup-authorized, branch-cleaned, and cleaned states.
- PR metadata remains invalid for branch-no-PR receipts.
- Protected retained evidence and local terminal proof are preserved.

## Safety Properties

- Child authority is preserved.
- Parent summaries cannot satisfy child-owned evidence.
- Generated outputs remain derived-only and non-authoritative.
- Material side effects remain explicitly authorization-gated.
- PR fallback remains forbidden where branch-no-PR delivery is in scope.

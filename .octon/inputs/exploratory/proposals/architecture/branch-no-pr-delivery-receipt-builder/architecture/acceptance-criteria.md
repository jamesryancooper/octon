# Acceptance Criteria

- Builder emits a complete branch-no-PR receipt for landed, synced, cleanup-authorized, branch-cleaned, and cleaned states.
- PR metadata remains invalid for branch-no-PR receipts.
- Protected retained evidence and local terminal proof are preserved.

## Safety Acceptance

- No parent evidence replaces child-owned evidence.
- No PR fallback is introduced.
- No protected retained evidence is deleted.
- No generated output is hand-edited.

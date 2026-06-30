# Acceptance Criteria

- Change receipts encode branch publication, merge, sync, and cleanup state without relying on chat narrative.
- Validators reject terminal delivery claims that performed landing or cleanup actions without matching Change closeout receipt evidence.
- Host GitHub state is captured as observed evidence only.
- Route-neutral Change closeout remains reusable outside the Run Program To Clean Delivery wrapper.
- Positive and negative fixtures cover PR-backed, no-PR, already-landed, and branch-only outcomes.

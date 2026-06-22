# Acceptance Criteria

- final_verdict completed plans keep primary state free of actionable-looking stale receipt blocks.
- nonblocking_diagnostics include path, stored digest, current digest, and ignored reason.
- Diagnostics remain available for audit but cannot trigger recovery loops.

## Safety Acceptance

- No parent evidence replaces child-owned evidence.
- No PR fallback is introduced.
- No protected retained evidence is deleted.
- No generated output is hand-edited.

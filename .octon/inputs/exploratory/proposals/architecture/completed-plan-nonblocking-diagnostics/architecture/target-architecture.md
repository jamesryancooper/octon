# Target Architecture

Move irrelevant stale receipt data into compact nonblocking diagnostics when final_verdict is completed.

## Target Behavior

- final_verdict completed plans keep primary state free of actionable-looking stale receipt blocks.
- nonblocking_diagnostics include path, stored digest, current digest, and ignored reason.
- Diagnostics remain available for audit but cannot trigger recovery loops.

## Safety Properties

- Child authority is preserved.
- Parent summaries cannot satisfy child-owned evidence.
- Generated outputs remain derived-only and non-authoritative.
- Material side effects remain explicitly authorization-gated.
- PR fallback remains forbidden where branch-no-PR delivery is in scope.
